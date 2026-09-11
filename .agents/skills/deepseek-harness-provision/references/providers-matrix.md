# Provider × 端点矩阵（以官方文档为准，不要猜）

> baseURL 永远只写到 `/v1`。pi-ai 按 provider 的 `api` 自动拼接：
> `openai-responses` → `POST {base}/responses`，
> `openai-completions` → `POST {base}/chat/completions`，
> `anthropic-messages` → `POST {base}/messages`。
> 模型 id 永远用 `GET {base}/models` 返回的裸 id。

## b-ai（B.AI 网关，DeepSeek-V4-Flash / Vision-Exp）

- 官方指南：https://docs.b.ai/llmservice/deepseek-harness/integration-guide/
- API 参考：https://docs.b.ai/llmservice/api/
- 模型页：https://docs.b.ai/llmservice/models/deepseek-v4-flash
- `api: openai-completions`，`baseURL: https://api.b.ai/v1`，`apiKeyEnv: BAI_API_KEY`
- 模型：`deepseek-v4-flash`（`input: [text]`）、`deepseek-v4-flash-vision-exp`（`input: [text, image]`）
- 鉴权：`Authorization: Bearer <key>` 或 `x-api-key: <key>` 等价
- B.AI 明确：`deepseek-v4-flash` 调 `/v1/responses` 会 `400 model_not_supported_on_endpoint`，
  必须走 `/v1/chat/completions`；DeepSeek 请求不要带 `web_search` 工具
  （Codex 场景加顶层 `web_search = "disabled"`）。

## opencode-zen（Zen 网关，Muse Spark 1.3 Contributor Free）

- 文档：https://opencode.ai/docs/zen/ ／ https://opencode.ai/docs/zh-cn/zen/
- `api: openai-responses`，`baseURL: https://opencode.ai/zen/v1`，`apiKeyEnv: OPENCODE_API_KEY`
- 模型：`muse-spark-1.3-contributor-free`（`@ai-sdk/openai`，免费，`input: [text, image]`）
- 模型列表：`GET https://opencode.ai/zen/v1/models`
- OpenCode 配置里的 `opencode/<id>` 前缀是 OpenCode 自身的多协议分发写法，harness 不用。
- **会话头（缺它就 `400 MissingSessionID`）**：Zen/Go 自 2026-09 起要求请求带
  `x-opencode-session`（每会话稳定 ID，用于路由/缓存亲和），`x-opencode-client`
  建议顺手带上（如 `dsh`）。静态配置做不到 per-conversation，只能持久化单个稳定 id
  （亲和性打折但能用）。本 skill 预设 `generate_session_header: true` 会自动生成
  `dsh-<rand>` 并在重跑时复用（不轮换）；`--verify-only` 用同样线形复现
  （`verify-<rand>` 一次性 id）。
- **不要伪造 `User-Agent: opencode/*`**：免费匿名档的 UA 门和 keyed 请求的 session 门是两回事；
  实测 dsh 的 undici 默认 UA 即 200，Cloudflare 只拦 python-urllib 这类裸 UA
  （脚本 verify 已固定发浏览器 UA）。

## opencode-go（Go 订阅网关）

- 文档：https://opencode.ai/docs/go/ ／ https://opencode.ai/docs/zh-cn/go/
- 基址 `https://opencode.ai/zen/go/v1`，按模型前缀分发 `/responses` / `/chat/completions` / `/messages`
- harness 一条 provider 只能定一个 `api`，所以**按协议拆多条 provider**，
  不要把 responses 和 chat 模型塞进同一条。本 skill `go-chat` 预设只放 chat 模型。
- Go 同样要求 `x-opencode-session`（2026-09-06 起强制执行），`go-chat` 预设已带
  `generate_session_header: true`。

## 本地 CLIProxy 反代（gpt-5.6-luna）

- `api: openai-responses`，`baseURL: http://127.0.0.1:8317/v1`，`apiKeyEnv: CLIPROXY_API_KEY`
- 模型：`gpt-5.6-luna`（`contextWindow: 272000`，`reasoningEfforts: low/medium/high/xhigh/max`）
- 先决条件：`127.0.0.1:8317` 必须 LISTEN，
  起法：`CLIProxyAPI\cli-proxy-api.exe -config config.yaml`。
