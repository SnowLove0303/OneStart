#!/usr/bin/env python3
"""
jev.py — TypeSafe System One (Jev 1.13) 零依赖 Python 调用器
基于 yuyang2230/jev-agent-skill (2026-09-20) 改造，适配 OpenCode Zen 免费档端点。

用法:
  1. 命令行管道调用:
     echo '{"state": "测试", "questions": {"q": {"type": "noul", "instructions": "是否安全?"}}}' | python scripts/jev.py
  2. 传入文件:
     python scripts/jev.py request.json
  3. 作为 Python 模块导入:
     from scripts.jev import call_jev, decide_noul, decide_choice, decide_score
"""

import json
import os
import ssl
import sys
import time
import urllib.error
import urllib.request
import uuid

# 兼容 Windows 控制台 UTF-8 输出
if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    sys.stderr.reconfigure(encoding="utf-8", errors="replace")

# 默认凭据与端点配置
DEFAULT_KEY = "sk-11TfygLJVvZeqDfH6abnPN7Z4Y1j0TimvlpA9pwGTN9eehU2CS7eQVzDIaqxS3QS"
OPENCODE_KEY = os.environ.get("ZEN_API_KEY", DEFAULT_KEY).strip()
ENDPOINT = os.environ.get("JEV_ENDPOINT", "https://opencode.ai/zen/v1/systemone")
MODEL = os.environ.get("JEV_MODEL", "jev-1.13-free")
RETRYABLE_CODES = {429, 500, 502, 503, 529}


def call_jev(payload: dict, retries: int = 2) -> dict:
    """调用 OpenCode Zen Jev System One 端点，内置网络抖动指数退避重试"""
    payload.setdefault("model", MODEL)
    data_bytes = json.dumps(payload, ensure_ascii=False).encode("utf-8")

    headers = {
        "Authorization": f"Bearer {OPENCODE_KEY}",
        "Content-Type": "application/json",
        "User-Agent": "opencode/1.18.31",
        "x-opencode-client": "cli",
        "x-opencode-session": f"ses_{uuid.uuid4().hex[:16]}",
        "x-opencode-request": f"msg_{uuid.uuid4().hex[:16]}",
    }

    last_exc = None
    for attempt in range(retries + 1):
        try:
            req = urllib.request.Request(ENDPOINT, data=data_bytes, headers=headers, method="POST")
            with urllib.request.urlopen(req, context=ssl.create_default_context(), timeout=8) as resp:
                return json.loads(resp.read().decode("utf-8"))
        except urllib.error.HTTPError as e:
            last_exc = e
            if e.code in RETRYABLE_CODES and attempt < retries:
                time.sleep(0.5 * (attempt + 1))
                continue
            err_body = e.read().decode("utf-8", errors="replace")
            raise RuntimeError(f"HTTP {e.code}: {err_body}") from e
        except Exception as e:
            last_exc = e
            if attempt < retries:
                time.sleep(0.5)
                continue
            raise last_exc


def decide_noul(state: str, instructions: str) -> float:
    """便捷方法：布尔概率评估 (0.0 ~ 1.0)"""
    res = call_jev({"state": state, "questions": {"q": {"type": "noul", "instructions": instructions}}})
    return res.get("answers", {}).get("q", {}).get("noul", 0.0)


def decide_choice(state: str, instructions: str, criteria: dict[str, str]) -> tuple[str, float]:
    """便捷方法：单选评估，返回 (选择结果, 置信度)"""
    res = call_jev(
        {
            "state": state,
            "questions": {"q": {"type": "choice", "instructions": instructions, "criteria": criteria}},
        }
    )
    ans = res.get("answers", {}).get("q", {})
    return ans.get("choice", ""), ans.get("confidence", 0.0)


def decide_score(state: str, instructions: str, criteria: list[str]) -> tuple[int, float]:
    """便捷方法：等级评分评估，返回 (分数索引, 置信度)"""
    res = call_jev(
        {
            "state": state,
            "questions": {"q": {"type": "score", "instructions": instructions, "criteria": criteria}},
        }
    )
    ans = res.get("answers", {}).get("q", {})
    return ans.get("score", 0), ans.get("confidence", 0.0)


def main():
    raw_mode = "--raw" in sys.argv
    args = [a for a in sys.argv[1:] if a != "--raw"]

    if args and os.path.exists(args[0]):
        raw_input = open(args[0], encoding="utf-8").read()
    elif not sys.stdin.isatty():
        raw_input = sys.stdin.buffer.read().decode("utf-8", errors="replace")
    else:
        print("Usage: python jev.py [--raw] <request.json> or echo '{...}' | python jev.py", file=sys.stderr)
        sys.exit(2)

    try:
        req_json = json.loads(raw_input)
    except Exception as e:
        print(f"JSON 解析失败: {e}", file=sys.stderr)
        sys.exit(1)

    res = call_jev(req_json)

    if raw_mode:
        print(json.dumps(res, indent=2, ensure_ascii=False))
        return

    # 紧凑格式输出
    for q_id, ans in res.get("answers", {}).items():
        ans_type = ans.get("type")
        if ans_type == "noul":
            print(f"{q_id}: {ans.get('noul')}")
        elif ans_type == "choice":
            print(f"{q_id}: {ans.get('choice')} (conf: {ans.get('confidence', 0):.2f})")
        elif ans_type == "score":
            print(f"{q_id}: score={ans.get('score')} (conf: {ans.get('confidence', 0):.2f})")


if __name__ == "__main__":
    main()
