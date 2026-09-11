---
name: deepseek-harness-provision
description: 新设备上自动配置 DeepSeek Harness 的 LLM Provider、API Key 与模型。覆盖 b-ai、opencode-zen、opencode-go、本地 CLIProxy 反代四类接入，含端点/协议对照表、settings.yaml 与 .credentials.yaml 写入规范、连通性验证与 reasoning_content 等常见故障排查。触发词：harness配置/provision/provider接入/模型接不通/配API Key/新设备配模型
triggers:
  - harness配置
  - deepseek harness配置
  - provision harness
  - provider接入
  - 配API Key
  - 新设备配模型
  - 模型接不通
  - reasoning_content报错
  - 401 invalid key
  - Request timed out
links:
  - [[references/providers-matrix]]
  - [[references/troubleshooting]]
---

# DeepSeek Harness Provision

> 在**新设备**上让 Agent 自动完成 DeepSeek Harness 的 Provider + API Key + 模型配置。
> 所有脚本自包含在本 skill 目录 `scripts/` 下，只用 Python 标准库，无第三方依赖。
> 默认不覆盖已有 provider，只做增量写入；全程不打印密钥明文。

## 0. 先搞清三件事（必读，30 秒）

1. **程序位置**：`http://127.0.0.1:9010/` 背后是 `node <harness-repo>/apps/cli/lib/bin.js web --port 9010`，
   源码仓一般在 `D:\APP\AI app\deepseek`。`9010` 只是 Web UI，**模型配置不在程序目录**。
2. **配置位置**：Harness home = `$DSH_HOME`，未设置时为 `~/.dsh`（Windows 如 `C:\Users\<你>\.dsh`），
   判定逻辑见 `packages/util/home-paths/src/index.ts:87 resolveDshHome()`。两个文件：
   - `settings.yaml` ——只放**引用**（`apiKeyEnv: BAI_API_KEY`），**绝不放密钥明文**
   - `.credentials.yaml` ——放密钥明文（0600，老格式 `KEY: value`；新格式 `version: "1"` + `refs:`，脚本自动兼容）
3. **一条 provider = 一个 wire 协议**：`llm-pi-ai` 的 `api` 是 provider 级字段
   （`packages/llm/llm-pi-ai/src/provider.ts:47 supportedProtocols()` 仅含
   `openai-responses` / `openai-completions` / `anthropic-messages`），
   一个 provider 下**不能混** `/responses` 和 `/chat/completions` 的模型。

## 1. 标准流程（按顺序执行）

```
[1 定位] → [2 读文档定端点] → [3 写入凭据] → [4 写入provider] → [5 验证] → [6 设默认模型/重启]
```

### 步骤 1 — 定位 harness 与 DSH_HOME

```powershell
netstat -ano | Select-String "9010"          # 找到 LISTENING 的 PID
Get-CimInstance Win32_Process -Filter "ProcessId=<PID>" | Select-Object -ExpandProperty CommandLine
# 期望看到: node ".../deepseek/apps/cli/lib/bin.js" web ... --port 9010
echo $env:DSH_HOME                            # 为空则家目录为 C:\Users\<你>\.dsh
```

### 步骤 2 — 按矩阵定端点（不要猜）

详见 `references/providers-matrix.md`。速查：

| Provider | `api` | `baseURL` | 模型 id（裸 id，不要加前缀） |
|---|---|---|---|
| b-ai（DeepSeek-V4-Flash / Vision-Exp） | `openai-completions` | `https://api.b.ai/v1` | `deepseek-v4-flash`、`deepseek-v4-flash-vision-exp` |
| opencode-zen（Muse Spark 1.3 Free） | `openai-responses` | `https://opencode.ai/zen/v1` | `muse-spark-1.3-contributor-free` |
| opencode-go | `openai-completions` | `https://opencode.ai/zen/go/v1` | go 列表里的 chat 模型（responses/messages 模型另起 provider） |
| 本地 CLIProxy（gpt-5.6-luna） | `openai-responses` | `http://127.0.0.1:8317/v1` | `gpt-5.6-luna`（先确认 8317 在 LISTEN） |

> `baseURL` 只写到 `/v1`，**不要**把 `/responses` 或 `/chat/completions` 后缀写进去，
> pi-ai 会按 `api` 自动拼接。写全了会请求成 `/responses/responses` → 404。

### 步骤 3 — 写凭据（只写 `.credentials.yaml`）

```powershell
py -3 "<skill>/scripts/provision.py" --set-key BAI_API_KEY --api-key "sk-..." --dsh-home "C:\Users\<你>\.dsh"
```

### 步骤 4 — 写 provider（只写 `settings.yaml` 的引用）

```powershell
# 用内置预设一键写入（推荐；需要同时切默认模型就加 --set-default）
py -3 "<skill>/scripts/provision.py" --preset b-ai-flash --api-key "sk-..." --dsh-home "C:\Users\<你>\.dsh" --set-default
py -3 "<skill>/scripts/provision.py" --preset zen-spark-free --api-key "sk-..." --dsh-home "C:\Users\<你>\.dsh" --set-default
py -3 "<skill>/scripts/provision.py" --preset cliproxy-luna --api-key "sk-dsh-local-..." --dsh-home "C:\Users\<你>\.dsh"
```

> Zen/Go 预设（`zen-spark-free`、`go-chat`）写入时会自动生成并持久化
> `x-opencode-session: dsh-<rand>`（每 provider 一个，重跑复用不轮换）+
> `x-opencode-client: dsh`。缺这个头就是 `400 MissingSessionID`，
> 与端点/key 无关，详见 `references/troubleshooting.md`。

### 步骤 5 — 验证（先公后私：models → 非流 → 流）

```powershell
py -3 "<skill>/scripts/provision.py" --preset b-ai-flash --verify-only --dsh-home "C:\Users\<你>\.dsh"
```

脚本依次打：`GET /models`（公开的不校验 Key，只验连通）→ `POST` 非流小请求 →
`POST stream:true` 首包。`--verify-only` 不写文件。
验证走与 dsh 完全相同的线形：预设 `headers` 全带上，需要 session 头的预设用
一次性 `verify-<rand>` id。`--verify-only` 不带 `--api-key` 时自动读
`.credentials.yaml` 里存好的 key。

### 步骤 6 — 设默认模型并生效

- `settings.yaml` 顶部 `agent-default-model: {provider: <id>, model: <id>}`，或 Web UI 里选模型
  （`http://127.0.0.1:9010` → Settings → Models → 模型下拉框）。
- `settings.yaml` / `.credentials.yaml` 由 chokidar 热加载（约 100ms），一般**不用重启**；
  若怀疑没加载，重启 `dsh-web`（先 `Stop-Process` 掉 9010 的 PID，再按步骤 1 的命令行原样拉起）。

## 2. Provider ID 规范（踩坑重灾区）

- 全小写、`[a-z0-9-]`，**永久**（请求、历史会话、凭据引用都用它），改名 = 新建 + 删旧：
  推荐 `b-ai`、`opencode-zen`、`opencode-go`、`chatgpt-cli-proxy`。
- `displayName` 可随意改，`api`/`baseURL`/`models` 可改，但 `api` 一改整条路由换协议。
- `models[].id` 必须用**网关返回的裸 id**（`GET /models` 的 `data[].id`），不要自创，
  不要加 `opencode/` / `opencode-go/` 前缀（那是 OpenCode 自身的多协议分发前缀，harness 不认）。
- 手写路由（pi-ai 没 shipped 的 key，如 `b-ai`）必须同时给 `api` + `baseURL` + 非空 `models`，
  否则整段 `llm-pi-ai` 被判不可服务（`assertServiceable`，见 `src/config.ts:271`）。
- Vision 模型必须声明 `input: [text, image]`，纯文本模型写 `input: [text]`，
  否则 Web UI 里贴图会被 harness 在发送前直接拒绝。

## 3. 注意事项（必看）

1. **密钥只进 `.credentials.yaml`**，`settings.yaml` 永远只出现 `apiKeyEnv` 引用名。
   `MISSING_CREDENTIAL` = 引用解析为空（去 Models 页存 key 或补环境变量）；
   本地格式错（不可进 HTTP 头的字符）= `INVALID_CREDENTIAL`（`packages/llm/llm/src/api-key.ts:15`）。
   远端 `401` = 网关鉴权失败（key 过期/环境错/订阅不对），先用 `curl` 直测网关再怀疑 harness。
2. **先直测网关，再调 harness**：`curl` 返回 `400 model_not_supported_on_endpoint` 说明
   模型与端点不匹配（换 `api`）；返回 `401` 说明 key/订阅问题；`Request timed out`
   先看本地代理（`8317` 在吗？`NODE_USE_ENV_PROXY=1` 设了吗？见 `start-dsh-web.cmd:8`）。
3. **DeepSeek thinking-mode `reasoning_content` 400**（`The reasoning_content in the thinking mode
   must be passed back`）：首轮返回的 `reasoning_content` 次轮必须原样回传，带 `tools` 参数的
   请求尤其严格。harness 侧 `llm-deepseek` 只在 tool-call 轮回传（`src/serialize.ts:96`），
   `pi-ai/openai-completions` 靠 `thinkingSignature` 透传；偶发时**新开会话**重试，
   跨 `flash`/`vision-exp` 不要复用同一会话历史。
4. **B.AI 的 DeepSeek 不支持 web search**：调 B.AI 时请求里不要带 `web_search` 工具；
   Codex 场景要在配置里加顶层 `web_search = "disabled"`。
5. **opencode(-go) 必需头**：`HTTP-Referer: https://opencode.ai/` + `X-Title: opencode`，
   缺了可能被限流或 401。harness 里写进 provider 的 `headers:` 即可。
6. **不要把密钥贴进截图/群聊/公开仓库**；不同项目用不同 key；泄露立即吊销。
   排障日志只贴 `sk-****后4位` 和 `request id`。
7. **CLIProxy（8317）是独立进程**：`dsh-web` 重启不顺带拉起它，
   `8317` 不 LISTEN 时先起 `CLIProxyAPI\cli-proxy-api.exe -config config.yaml` 再测 harness。
8. **地域限制**：`Muse Spark Contributor` 系列受 Meta 地域政策限制，
   换地区/换模型前先看 Zen 隐私表。

## 4. 参考链接（详细文档）

- B.AI 接 Harness 官方指南：https://docs.b.ai/llmservice/deepseek-harness/integration-guide/
- B.AI API 参考（含 Responses/Chat/Messages 三协议与错误码）：https://docs.b.ai/llmservice/api/
- B.AI 模型页（DeepSeek V4 Flash 能力与限额）：https://docs.b.ai/llmservice/models/deepseek-v4-flash
- OpenCode Zen（端点表/价格/免费模型说明）：https://opencode.ai/docs/zen/（中文：https://opencode.ai/docs/zh-cn/zen/）
- OpenCode Go（订阅/限额/端点表）：https://opencode.ai/docs/go/（中文：https://opencode.ai/docs/zh-cn/go/）
- DeepSeek Harness 仓库：https://github.com/deepseek-ai/deepseek-harness
- DeepSeek Thinking Mode（`reasoning_content` 回传规则）：https://api-docs.deepseek.com/guides/thinking_mode/
- 本地源码（以仓内为准）：`packages/llm/llm-pi-ai/README.md`（provider 模型）、
  `packages/llm/llm-pi-ai/src/config.ts`（schema/校验）、
  `packages/llm/llm-pi-ai/src/provider.ts`（`supportedProtocols`）、
  `packages/llm/llm-deepseek/README.md`（`reasoning_content` 回传规则）、
  `packages/util/home-paths/src/index.ts`（`resolveDshHome`）、
  `docs/user/guide/providers.md`（Models 页操作）。

## 5. 脚本用法

```powershell
# 看内置预设
py -3 scripts/provision.py --list-presets
# 只验证不断言写入
py -3 scripts/provision.py --preset b-ai-flash --verify-only
# 写入 key + provider（幂等，可反复跑）
py -3 scripts/provision.py --preset b-ai-flash --api-key "sk-..." --dsh-home "C:\Users\<你>\.dsh"
# 完全自定义（无预设时）
py -3 scripts/provision.py --provider-id my-gw --display-name "My GW" --api openai-completions `
  --base-url https://gw.example/v1 --api-key-env MY_GW_KEY --api-key "sk-..." `
  --model deepseek-v4-flash --model-name "DeepSeek V4 Flash" --with-image
```

预设清单：`b-ai-flash`（flash+vision 双模型）、`b-ai-flash-only`、`zen-spark-free`、
`go-chat`、`cliproxy-luna`。全部定义在 `scripts/presets.json`，改它即可加新设备常用项。

## 6. 更新日志

- **v1.1（2026-09-07，实测打通 `muse-spark-1.3-contributor-free`）**
  - 根因：`400 MissingSessionID` 缺的是 `x-opencode-session` 请求头，不是端点/key。
    另有匿名免费档的 UA 门（`User-Agent: opencode/*`），与 keyed 场景无关，不要混用。
  - `zen-spark-free` / `go-chat` 预设新增 `generate_session_header`，
    写入自动生成并持久化 `x-opencode-session`（重跑复用），附 `x-opencode-client: dsh`；
    `--verify-only` 同线形复现（含一次性 session id）。
  - 修 writer 两个写坏 bug：`settings.yaml` 重复顶级 `llm-pi-ai:`（`providers: {}` 存根未合并）、
    新格式 `.credentials.yaml` 下 key 落到顶层（`refs: {}` 存根未展开）。
  - 文档：`troubleshooting.md` 的 MissingSessionID/DUPLICATE_KEY/unknown-top-level-key/
    Cloudflare-1010 四条，`providers-matrix.md` 的 Zen/Go 会话头说明。
