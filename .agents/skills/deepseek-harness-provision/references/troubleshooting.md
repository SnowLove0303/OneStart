# 排障速查（按报错原文定位）

## `MISSING_CREDENTIAL`
引用存在但解析为空。到 Web UI `Settings → Models` 重存 key，或补对应环境变量。
本地 `settings.yaml` 只应出现 `apiKeyEnv` 名，值在 `.credentials.yaml`。

## `INVALID_CREDENTIAL`
本地格式错（`packages/llm/llm/src/api-key.ts` 只接受可进 HTTP 头的可见 ASCII）。
检查 key 首尾空格/换行，不要带 `Bearer ` 前缀。

## 远端 `401 API key is invalid / Unauthorized`
网关鉴权失败。先 `curl` 直测网关（`GET /models` 公开只验连通，`POST` 才鉴权）：
`GET /models` 通但 `POST` 401 = key/订阅/环境问题，与 harness 配置无关。
`{"Model  is not supported"}`（注意 Model 后双空格）是 opencode 网关的 401 变体。

## `400 model_not_supported_on_endpoint`
模型与端点不匹配：换 `api`（如 B.AI DeepSeek 用 `openai-completions` 不用 `openai-responses`）。

## `400 reasoning_content must be passed back`
DeepSeek thinking-mode 强校验：首轮的 `reasoning_content` 次轮必须原样回传，
带 `tools` 参数的请求最严。偶发时**新开会话**重试；不要跨 `flash`/`vision-exp` 复用历史。
根因文档：https://api-docs.deepseek.com/guides/thinking_mode/

## `Request timed out` / 重试延迟后无反应
- `8317` 反代没起（`Connection refused`）→ 先起 CLIProxyAPI。
- `api.b.ai` 直连不通 → 按 `start-dsh-web.cmd` 设 `NODE_USE_ENV_PROXY=1` 走本地代理。
- 默认模型指向了错的 provider（如 `opencode-go/deepseek-v4-flash` 走 responses）→
  把 `agent-default-model` 指回对的 provider。
- 给 B.AI 加 `timeoutMs: 120000` + `streamIdleTimeoutMs: 300000` 再测。

## `400 insufficient_user_quota / credit insufficient balance`
B.AI 账户余额为 0。配置本身是对的（`GET /models` 能列出模型），去 B.AI 控制台充值或换有额度的 key。
验证脚本 `--verify-only` 会原样透出该报错，不要误判为协议配错。

## `MissingSessionID: free tier can only be used in OpenCode`
缺的是 `x-opencode-session` 请求头，不是端点也不是 key（已实锤，可复现）：
裸调/缺头 → `400 MissingSessionID`；加上 `x-opencode-session: <稳定id>`（+ 建议
`x-opencode-client: dsh`）→ `200`。Zen/Go 用它做会话路由与缓存亲和。
本 skill 的 `zen-spark-free` / `go-chat` 预设已带 `generate_session_header: true`，
写入时自动生成 `dsh-<rand>` 并持久化（重跑复用不轮换）；`--verify-only` 会用
同样的线形（`verify-<rand>` 一次性 id）复现验证。
注意静态配置只能做到单个稳定 id，做不到 per-conversation。
旧结论“只能在 OpenCode 里用”作废。

## `settings-file: ... DUPLICATE_KEY`（如两个 `llm-pi-ai:`）
旧版脚本在已有 `providers: {}` 存根时会又追加一段顶级 `llm-pi-ai:`，
dsh 启动直接拒绝。新版脚本会合并进已有段（并展开 `{}` 存根）。
手工修：删掉空的 `llm-pi-ai:\n  providers: {}` 那一段，只留有内容的。

## `credentials-local: unknown top-level key "XXX"`
key 被写在了顶层；新格式（`version: 1`）下 key 必须进 `refs:`（缩进两格），
`refs: {}` 存根要先展开。新版脚本已处理；手工修：把那一行移到 `refs:` 下面。

## Cloudflare `403 error code: 1010`（verify/探针时）
裸 UA（如 python-urllib 默认）被 Cloudflare 浏览器检查拦了，不是 key/端点问题。
脚本 verify 已固定发浏览器 UA；dsh 运行时的 undici UA 实测 200，不用动。
**不要**靠伪造 `User-Agent: opencode/*` 绕门：匿名免费档的 UA 门和 keyed 请求的
session 门是两道不同的检查，keyed 场景只认 `x-opencode-session`。

## 改了配置没生效
`settings.yaml` / `.credentials.yaml` 热加载约 100ms；若 Models 页仍是旧态，
重启 `dsh-web`（kill 掉 9010 的 PID，按原命令行拉起，工作目录须是 harness 仓根目录）。

## `settings-rejected` / 整段 llm-pi-ai 不服务
某条 provider 缺 `api`/`baseURL`/`models`（手写路由三件套缺一）或模型项带了非法字段
（`models[]` 只允许 `id/name/contextWindow/maxTokens/input/reasoningEfforts/compat`，
`api/baseURL` 只能在 provider 级）。删掉非法字段或补齐三件套。
