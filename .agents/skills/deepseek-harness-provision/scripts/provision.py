#!/usr/bin/env python3
"""Provision DeepSeek Harness LLM providers on a new machine (stdlib only).

Writes ONLY:
  <dsh-home>/settings.yaml      (provider refs, never secrets)
  <dsh-home>/.credentials.yaml  (secrets)

Handles both credentials formats:
  old flat:  BAI_API_KEY: sk-...
  new:       version: "1" / refs: / BAI_API_KEY: sk-...
Merges into an existing llm-pi-ai section (never creates a duplicate top-level
key) and expands flow-style `providers: {}` / `refs: {}` stubs.

Presets with "generate_session_header": true get a stable per-provider
x-opencode-session id (generated once, reused on re-runs) plus
x-opencode-client: dsh; --verify-only reproduces the same wire shape with a
throwaway verify-<rand> session id.

Usage:
  py -3 provision.py --list-presets
  py -3 provision.py --preset b-ai-flash --api-key "sk-..." [--dsh-home ...]
  py -3 provision.py --preset b-ai-flash --verify-only
  py -3 provision.py --set-key BAI_API_KEY --api-key "sk-..."
  py -3 provision.py --provider-id my-gw --api openai-completions --base-url https://gw/x/v1 \
      --api-key-env MY_GW_KEY --api-key "sk-..." --model deepseek-v4-flash [--with-image] [--set-default]
"""
import argparse
import json
import os
import re
import secrets
import socket
import sys
import urllib.request
import urllib.error

HERE = os.path.dirname(os.path.abspath(__file__))
PRESETS_PATH = os.path.join(HERE, "presets.json")
SUPPORTED_APIS = ("openai-responses", "openai-completions", "anthropic-messages")
SUFFIX_RE = re.compile(r"/(responses|chat/completions|messages)/?$")


def dsh_home(cli_value):
    if cli_value:
        return os.path.abspath(os.path.expandvars(cli_value))
    env = os.environ.get("DSH_HOME", "").strip()
    if env:
        return os.path.abspath(os.path.expandvars(env))
    return os.path.join(os.path.expanduser("~"), ".dsh")


def mask(key):
    if not key:
        return "<empty>"
    return ("*" * max(0, len(key) - 4)) + key[-4:]


def load_presets():
    with open(PRESETS_PATH, encoding="utf-8") as f:
        data = json.load(f)
    return {k: v for k, v in data.items() if not k.startswith("_")}


def validate_provider(pid, api, base_url, models):
    errors = []
    if not re.fullmatch(r"[a-z][a-z0-9-]*", pid or ""):
        errors.append("provider id must match [a-z][a-z0-9-]* (lowercase, permanent)")
    if api not in SUPPORTED_APIS:
        errors.append(f"api must be one of {SUPPORTED_APIS}, got {api!r}")
    if not base_url or not base_url.startswith(("http://", "https://")):
        errors.append("baseURL must be an http(s) URL stopping at /v1")
    elif SUFFIX_RE.search(base_url.rstrip("/")):
        errors.append("baseURL must stop at /v1; do NOT append /responses or /chat/completions")
    if not models:
        errors.append("models must be non-empty for a hand-declared route")
    for m in models:
        if not m.get("id"):
            errors.append("every model needs a non-empty id (use GET /models ids verbatim)")
    return errors


# ---------- credentials.yaml (text-level, format preserving) ----------

def upsert_credential(path, ref, value):
    if not re.fullmatch(r"[A-Za-z_][A-Za-z0-9_]*", ref or ""):
        raise ValueError(f"bad credential ref {ref!r}")
    lines = []
    if os.path.exists(path):
        with open(path, encoding="utf-8") as f:
            lines = f.read_text if False else f.read().splitlines()
    while lines and lines[-1].strip() == "":
        lines.pop()  # no stray blank lines in output
    # new format? a "refs:" top-level key in any form ("refs:" or "refs: {}").
    # NOTE: "refs: {}" (flow style) must count as new too; otherwise the key
    # lands at top level and dsh rejects it as "unknown top-level key".
    is_new = any(re.match(r"^refs:\s*(\{\})?\s*(#.*)?$", ln) for ln in lines)
    # a versioned document without a refs: section yet is still new format:
    # the key must go under a refs: section, never top level.
    is_new = is_new or any(re.match(r"^version:\s*", ln) for ln in lines)
    if not lines:
        lines = [f"{ref}: {value}"]
    elif is_new:
        # expand a flow-style "refs: {}" stub before inserting
        lines = ["refs:" if re.match(r"^refs:\s*\{\}\s*(#.*)?$", ln) else ln for ln in lines]
        # insert/update under refs: (2-space indent), keep records: etc. untouched
        out, done, in_refs = [], False, False
        for i, ln in enumerate(lines):
            if re.match(r"^refs:\s*$", ln):
                in_refs = True
                out.append(ln)
                continue
            if in_refs and ln.strip() == "":
                continue  # drop stray blanks inside refs: (cosmetic, YAML-legal either way)
            if in_refs and re.match(r"^\S", ln):  # next top-level key ends refs section
                if not done:
                    out.append(f"  {ref}: {value}")
                    done = True
                in_refs = False
            if in_refs and re.match(rf"^  {re.escape(ref)}:", ln):
                out.append(f"  {ref}: {value}")
                done = True
                continue
            out.append(ln)
        if not done:
            # refs: was last section or missing trailing newline handling
            if in_refs:
                out.append(f"  {ref}: {value}")
            else:
                out += ["refs:", f"  {ref}: {value}"]
        lines = out
    else:
        pat = re.compile(rf"^{re.escape(ref)}:\s*.*$")
        done = False
        out = []
        for ln in lines:
            if pat.match(ln):
                out.append(f"{ref}: {value}")
                done = True
            else:
                out.append(ln)
        if not done:
            out.append(f"{ref}: {value}")
        lines = out
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)
    with open(path, "w", encoding="utf-8", newline="\n") as f:
        f.write("\n".join(lines) + "\n")


# ---------- settings.yaml (text-level provider block replace) ----------

def render_model(m, indent):
    p = indent + "  - id: " + m["id"] + "\n"
    p += indent + f"    name: {m.get('name', m['id'])}\n"
    if m.get("context_window"):
        p += indent + f"    contextWindow: {m['context_window']}\n"
    if m.get("max_tokens"):
        p += indent + f"    maxTokens: {m['max_tokens']}\n"
    inp = m.get("input") or ["text"]
    p += indent + "    input: [ " + ", ".join(inp) + " ]\n"
    if m.get("reasoning_efforts"):
        p += indent + "    reasoningEfforts:\n"
        for k, v in m["reasoning_efforts"].items():
            p += indent + f"      {k}: {v}\n"
    return p


def render_provider(pid, cfg):
    ind = "      "  # llm-pi-ai(0) providers(2) <id>(4) fields(6)
    s = f"    {pid}:\n"
    s += ind + f"displayName: {cfg.get('display_name', pid)}\n"
    s += ind + f"api: {cfg['api']}\n"
    s += ind + f"baseURL: {cfg['base_url']}\n"
    s += ind + f"apiKeyEnv: {cfg['api_key_env']}\n"
    if cfg.get("headers"):
        s += ind + "headers:\n"
        for k, v in cfg["headers"].items():
            s += ind + f"  {k}: {v}\n"
    if cfg.get("timeout_ms"):
        s += ind + f"timeoutMs: {cfg['timeout_ms']}\n"
    if cfg.get("stream_idle_timeout_ms"):
        s += ind + f"streamIdleTimeoutMs: {cfg['stream_idle_timeout_ms']}\n"
    s += ind + "models:\n"
    for m in cfg["models"]:
        s += render_model(m, ind)
    return s.rstrip("\n") + "\n"


def upsert_provider_block(text, pid, block):
    """Replace the `    <pid>:` block under llm-pi-ai/providers, or insert it.

    Merges into an EXISTING llm-pi-ai section (never appends a second one,
    which dsh rejects as DUPLICATE_KEY). Also understands the flow-style
    `providers: {}` stub: it is expanded to a mapping before inserting.
    """
    lines = text.splitlines()
    # find the llm-pi-ai top-level section and its providers: line (any form)
    llm_idx = next((i for i, ln in enumerate(lines) if re.match(r"^llm-pi-ai:\s*$", ln)), None)
    prov_idx, prov_empty_flow = None, False
    if llm_idx is not None:
        for i in range(llm_idx + 1, len(lines)):
            ln = lines[i]
            if re.match(r"^\S", ln):
                break  # next top-level section
            m = re.match(r"^  providers:\s*(\{\})?\s*(#.*)?$", ln)
            if m:
                prov_idx = i
                prov_empty_flow = bool(m.group(1))
                break
    if prov_idx is None:
        if llm_idx is not None:
            # llm-pi-ai: exists but has no providers: mapping yet; add it
            # in place instead of appending a second top-level section.
            ins = llm_idx + 1
            while ins < len(lines) and lines[ins].strip() == "":
                ins += 1
            lines[ins:ins] = (["  providers:"] + block.rstrip("\n").splitlines())
            return "\n".join(lines) + "\n"
        # no llm-pi-ai section at all: append a fresh one
        if not text.endswith("\n"):
            text += "\n"
        return text + f"llm-pi-ai:\n  providers:\n{block}"
    if prov_empty_flow:
        lines[prov_idx] = "  providers:"
    # find existing provider block start
    start = next((i for i in range(prov_idx + 1, len(lines))
                  if re.match(rf"^    {re.escape(pid)}:\s*$", lines[i])), None)
    if start is not None:
        end = len(lines)
        for i in range(start + 1, len(lines)):
            if re.match(r"^    [A-Za-z0-9_-]+:\s*$", lines[i]) or re.match(r"^[A-Za-z_-]+:", lines[i]) or re.match(r"^  [A-Za-z_-]+:", lines[i]):
                # next provider (4sp) or next top section (0sp) or next llm-pi-ai key (2sp)
                if re.match(r"^    [A-Za-z0-9_-]+:\s*$", lines[i]) or re.match(r"^[A-Za-z]", lines[i]) or re.match(r"^  \S", lines[i]):
                    # careful: 6-space field lines must NOT stop the scan
                    if re.match(r"^      \S", lines[i]):
                        continue
                    end = i
                    break
        lines[start:end] = block.rstrip("\n").splitlines()
        return "\n".join(lines) + "\n"
    # insert after providers: line, before next 4-space provider or 2-space key
    ins = prov_idx + 1
    while ins < len(lines) and lines[ins].strip() == "":
        ins += 1
    lines[ins:ins] = block.rstrip("\n").splitlines()
    return "\n".join(lines) + "\n"


def ensure_session_header(cfg, pid, text):
    """Give presets with generate_session_header a stable x-opencode-session.

    Vendors (Zen/Go) require one stable id per conversation for routing; static
    config cannot mint per-conversation ids, so we persist ONE stable id per
    provider. Re-runs reuse the id already in settings (never rotate it:
    rotation would break request attribution/history linkage).
    """
    hdrs = cfg.setdefault("headers", {})
    hdrs.setdefault("x-opencode-client", "dsh")
    if "x-opencode-session" in hdrs:
        return cfg
    sid = None
    start = re.search(rf"^    {re.escape(pid)}:\s*$", text, re.M)
    if start:
        rest = text[start.end():]
        stop = re.search(r"(?m)^(    [A-Za-z0-9_-]+:\s*|  \S|\S)", rest)
        block = rest[:stop.start()] if stop else rest
        # header entries sit one level deeper than provider fields
        # (6sp fields, 8sp headers: children) — accept any indent here
        f = re.search(r"^[ ]+x-opencode-session:\s*(\S+)\s*$", block, re.M)
        if f:
            sid = f.group(1)
    if not sid:
        sid = "dsh-" + secrets.token_hex(12)
    hdrs["x-opencode-session"] = sid
    return cfg


def set_default_model(text, pid, mid):
    if re.search(r"^agent-default-model:\s*$", text, re.M):
        text = re.sub(r"(?m)^agent-default-model:\s*\n(?:  \S.*\n?)*",
                      f"agent-default-model:\n  provider: {pid}\n  model: {mid}\n", text, count=1)
    else:
        if not text.endswith("\n"):
            text += "\n"
        text += f"agent-default-model:\n  provider: {pid}\n  model: {mid}\n"
    return text


# ---------- verify (stdlib urllib, never prints the key) ----------

def http_json(url, key, payload=None, timeout=20, max_len=2000, extra_headers=None):
    headers = {"Authorization": f"Bearer {key}", "Content-Type": "application/json",
               "HTTP-Referer": "https://opencode.ai/", "X-Title": "opencode",
               "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}
    # preset/provider headers ride along (e.g. x-opencode-session); they win
    # over the defaults above so verify reproduces the exact dsh wire shape.
    if extra_headers:
        headers.update(extra_headers)
    data = json.dumps(payload).encode() if payload is not None else None
    req = urllib.request.Request(url, data=data, headers=headers,
                                 method="POST" if payload is not None else "GET")
    try:
        with urllib.request.urlopen(req, timeout=timeout) as r:
            return r.status, r.read().decode(errors="replace")[:max_len]
    except urllib.error.HTTPError as e:
        return e.code, e.read().decode(errors="replace")[:1000]
    except Exception as e:  # timeout / refused
        return -1, f"{type(e).__name__}: {e}"


def tcp_open(host, port, timeout=3):
    try:
        with socket.create_connection((host, int(port)), timeout=timeout):
            return True
    except OSError:
        return False


def verify_preset(preset, key):
    base = preset["base_url"].rstrip("/")
    verify = preset.get("verify") or {"method": "chat" if preset.get("api") == "openai-completions" else "responses",
                                      "model": (preset.get("models") or [{"id": ""}])[0]["id"]}
    model = verify["model"]
    method = verify["method"]
    # reproduce the dsh wire shape: preset headers plus a session id when the
    # vendor gates on one (Zen: x-opencode-session, MissingSessionID otherwise)
    wire_headers = dict(preset.get("headers") or {})
    if preset.get("generate_session_header") and "x-opencode-session" not in wire_headers:
        wire_headers["x-opencode-session"] = "verify-" + secrets.token_hex(8)
    if preset.get("precheck", {}).get("tcp"):
        host, port = preset["precheck"]["tcp"].split(":")
        if not tcp_open(host, port):
            return False, f"precheck failed: {preset['precheck']['tcp']} not listening. {preset['precheck'].get('hint','')}"
    print(f"[1/3] GET {base}/models ...")
    code, body = http_json(base + "/models", key, max_len=20000, extra_headers=wire_headers)
    if code != 200 or model not in body:
        # /models may be public or key-scoped; warn but continue
        print(f"      warn: GET /models -> {code} (model id not listed, continuing)")
    else:
        print(f"      ok: model id listed ({model})")
    if method == "chat":
        url, payload = base + "/chat/completions", {"model": model, "messages": [{"role": "user", "content": "Reply only with: Connection successful."}], "stream": False}
    elif method == "responses":
        url, payload = base + "/responses", {"model": model, "input": "Reply only with: Connection successful."}
    else:
        return False, f"unknown verify method {method}"
    print(f"[2/3] POST {url} (non-stream) ...")
    code, body = http_json(url, key, payload, timeout=60, extra_headers=wire_headers)
    if code != 200:
        return False, f"POST failed: HTTP {code}: {body[:500]}"
    print(f"      ok: HTTP 200, body {len(body)} chars")
    print(f"[3/3] POST stream:true (first bytes) ...")
    payload["stream"] = True
    code, body = http_json(url, key, payload, timeout=60, extra_headers=wire_headers)
    if code != 200:
        return False, f"stream probe failed: HTTP {code}: {body[:500]}"
    print("      ok: stream established")
    return True, "all probes passed"


def main(argv=None):
    ap = argparse.ArgumentParser(description="Provision DeepSeek Harness providers (stdlib only).")
    ap.add_argument("--dsh-home", default=None)
    ap.add_argument("--list-presets", action="store_true")
    ap.add_argument("--preset", default=None)
    ap.add_argument("--verify-only", action="store_true")
    ap.add_argument("--set-key", default=None, help="credential ref to write, e.g. BAI_API_KEY")
    ap.add_argument("--api-key", default=None, help="secret value (never printed)")
    ap.add_argument("--provider-id", default=None)
    ap.add_argument("--display-name", default=None)
    ap.add_argument("--api", default=None, choices=list(SUPPORTED_APIS))
    ap.add_argument("--base-url", default=None)
    ap.add_argument("--api-key-env", default=None)
    ap.add_argument("--model", action="append", default=[], help="repeatable model id")
    ap.add_argument("--model-name", default=None)
    ap.add_argument("--with-image", action="store_true")
    ap.add_argument("--set-default", action="store_true")
    args = ap.parse_args(argv)

    presets = load_presets()
    if args.list_presets:
        for name, p in presets.items():
            print(f"{name}: {p['display_name']} | {p['api']} {p['base_url']} | " +
                  ", ".join(m["id"] for m in p["models"]))
        return 0

    home = dsh_home(args.dsh_home)
    settings_p = os.path.join(home, "settings.yaml")
    creds_p = os.path.join(home, ".credentials.yaml")

    # build provider cfg from preset or flags
    if args.preset:
        if args.preset not in presets:
            print(f"unknown preset {args.preset!r}, see --list-presets", file=sys.stderr)
            return 2
        cfg = json.loads(json.dumps(presets[args.preset]))  # deep copy
        pid = cfg["provider_id"]
    else:
        if not (args.provider_id and args.api and args.base_url and args.api_key_env and args.model):
            print("--preset or all of --provider-id/--api/--base-url/--api-key-env/--model required", file=sys.stderr)
            return 2
        pid = args.provider_id
        cfg = {"provider_id": pid, "display_name": args.display_name or pid, "api": args.api,
               "base_url": args.base_url, "api_key_env": args.api_key_env,
               "models": [{"id": m, "name": args.model_name or m,
                           "input": ["text", "image"] if args.with_image else ["text"]} for m in args.model]}
    key = args.api_key
    if not key and not args.verify_only:
        # allow key-only-from-file verify? no: writing needs the secret
        if args.set_key and not key:
            print("--api-key required with --set-key", file=sys.stderr)
            return 2
    if args.verify_only and not key:
        # read existing credential from file for verify
        try:
            txt = open(creds_p, encoding="utf-8").read()
            m = re.search(rf"(?:^|\n)(?:  )?{re.escape(cfg['api_key_env'])}:\s*(\S+)", txt)
            key = m.group(1) if m else ""
        except OSError:
            key = ""
        if not key:
            print(f"no stored {cfg['api_key_env']} found; pass --api-key", file=sys.stderr)
            return 2

    errs = validate_provider(pid, cfg["api"], cfg["base_url"], cfg["models"])
    if errs:
        print("config invalid:", file=sys.stderr)
        for e in errs:
            print(f"  - {e}", file=sys.stderr)
        return 2

    if args.verify_only:
        # pass the whole cfg: verify reproduces headers/session from it
        ok, msg = verify_preset(cfg, key)
        print(("PASS: " if ok else "FAIL: ") + msg)
        print(f"(key used: {mask(key)}, {len(key)} chars - value never printed)")
        return 0 if ok else 1

    # write credentials first, then provider ref
    ref = args.set_key or cfg["api_key_env"]
    if key:
        upsert_credential(creds_p, ref, key)
        print(f"credentials: {ref} written to {creds_p} (key {mask(key)})")
    if not os.path.exists(settings_p):
        raise SystemExit(f"settings.yaml not found at {settings_p}; is --dsh-home correct?")
    with open(settings_p, encoding="utf-8") as f:
        text = f.read()
    if cfg.get("generate_session_header"):
        cfg = ensure_session_header(cfg, pid, text)
    text = upsert_provider_block(text, pid, render_provider(pid, cfg))
    if args.set_default or args.preset in ("b-ai-flash", "zen-spark-free", "cliproxy-luna"):
        if args.preset and not args.set_default:
            pass  # do not move default unless asked... except explicit below
        if args.set_default:
            text = set_default_model(text, pid, cfg["models"][0]["id"])
    with open(settings_p, "w", encoding="utf-8", newline="\n") as f:
        f.write(text)
    print(f"settings: provider '{pid}' written to {settings_p}")
    print("note: settings hot-reload in ~100ms; if the Models page still shows old state, restart dsh-web.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
