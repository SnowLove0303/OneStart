## Why

当前冠志通 Docker Web 的“启动服务”和“打开 Wi‑Fi 局域网访问”是两个独立操作，用户需要记住并按正确顺序执行多条命令，也容易在验证结束后遗留容器运行或防火墙放行状态。本次将两者收敛为可审计的一键生命周期操作，并在交付后用同一入口完成真实启动、回读验证和安全关闭。

## What Changes

- 新增一键启动命令 `wll start guanzhitong-lan`，并提供等价快捷写法 `wll guanzhitong-lan`。
- 一键启动只复用已确认的 `guanzhitong-compliance` 容器、镜像和宿主机端口 `18765`：先确保 Docker Web 健康，再开启当前唯一 Private WLAN IPv4 子网的专用防火墙规则。
- 一键启动完成后回读容器、健康检查、端口映射、监听 HTTP、当前 Wi‑Fi 子网和防火墙规则，并显示本机访问地址与局域网访问地址；任一步骤失败时保持局域网规则关闭。
- 新增匹配的一键关闭命令 `wll stop guanzhitong-lan`，先关闭局域网防火墙开关，再停止同一 Docker 容器；关闭失败时报告原因，不伪造完成状态。
- 在交互式菜单中增加一键启动和一键关闭入口，保留现有 `wll web`、`wll lan on/off/status` 兼容行为。
- 更新 README，记录一键操作、真实验证闭环、管理员权限要求和关闭后的预期状态。

## Capabilities

### New Capabilities

<!-- No separate capability is introduced; the one-click lifecycle is an extension of the existing Docker LAN switch contract. -->

### Modified Capabilities

- `docker-wifi-lan-access-switch`: 增加 Docker Web 与 LAN 开关的一键启动/关闭生命周期、原子式失败收敛和可回读验收要求。

## Impact

- 代码：`System/Workflow-Launcher.ps1` 的命令解析、交互菜单和 Docker/LAN 编排函数。
- 文档：`System/README.md` 的命令表、菜单说明和安全操作说明。
- 运行时：只操作既有 Docker Desktop、容器 `guanzhitong-compliance`、宿主机 TCP `18765` 与当前 Private WLAN 专用防火墙规则；不新增镜像、容器、端口、依赖或项目副本。
- 验证：开发完成后执行真实的“启动并开启 → 回读/HTTP 验证 → 关闭并停止 → 再次回读”流程，最终应为容器停止、LAN 规则关闭、本机端口不再提供服务。
