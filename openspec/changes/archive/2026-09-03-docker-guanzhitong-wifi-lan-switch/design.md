## Context

统一启动器位于 `D:\应用研究\统一启动器`，现有 `System\wll.bat` 仅转发到 `Workflow-Launcher.ps1`。当前 PowerShell 文件已有冠志通 Web 的旧版 Windows Python 启动逻辑，但实际正式服务是 Docker 容器 `guanzhitong-compliance`，其容器端口 `8765` 发布到宿主机 `18765`。Docker Desktop 使用 `com.docker.backend.exe` 接收发布端口；本机当前 WLAN 为 Private，IPv4 子网为 `192.168.0.0/24`，另有 Public 的 FlClash 接口。

## Goals / Non-Goals

**Goals:**

- 在既有 PowerShell 启动器中提供可脚本化、可交互的 LAN on/off/status 开关。
- 将冠志通 Web 的启动、健康检查、打开和停止逻辑统一到现有 Docker 容器。
- 通过 Windows 防火墙把 LAN 入站来源收敛到当前 Private Wi‑Fi 子网，并对 Docker Desktop 宽泛 TCP 入站规则采取失败关闭策略。
- 保留用户已有的启动器未提交修改，使用唯一的 `wll.bat` 和 `Workflow-Launcher.ps1` 入口。

**Non-Goals:**

- 不修改冠志通 Docker 镜像、Compose 文件、容器应用代码、数据库或 volume 数据。
- 不创建新的容器、镜像、端口、项目副本、备用启动器或第二套配置。
- 不提供公网访问、路由器端口转发、VPN、认证系统或应用层权限改造。
- 不把 LAN 开关的关闭动作解释为停止或删除 Docker 服务。

## Decisions

### 1. 复用现有启动器并增加 `lan` 动作

在 `Workflow-Launcher.ps1` 中增加 `lan` 动作及 `on`/`off`/`status` 子命令，同时增加交互菜单项。保留 `System\wll.bat` 作为唯一入口。相比新增独立脚本，这能让日志、状态和权限处理与现有启动器一致，也避免出现两个可能互相覆盖的控制入口。

### 2. 通过 Docker CLI 做身份和健康核验

使用固定的绝对 Docker CLI 路径 `D:\APP\Docker\resources\bin\docker.exe`（若不可用再尝试 PATH 中的 `docker.exe`），按精确容器名查询状态、健康检查和端口映射。`on` 只启动/复用现有容器，不执行 `docker run`；当容器不健康或映射不符时拒绝开放防火墙。

### 3. 以当前唯一 Private WLAN 的 CIDR 作为入站来源

从 Windows 网络配置读取活跃接口、Private 网络类别、IPv4 地址、前缀长度和默认网关；要求可唯一确定候选 WLAN。把来源规范化为 CIDR（当前为 `192.168.0.0/24`），并在启用规则时拒绝 Public/未知接口。相比固定允许 `Any`，CIDR 约束可以阻断 FlClash、其他网卡和公网路径；相比盲目使用当前所有接口，失败关闭更符合安全边界。

### 4. 使用稳定的冠志专用防火墙规则并兼容既有规则

以稳定的显示名称/规则标识管理冠志专用 TCP `18765` 入站规则：Private profile、远程来源当前 Wi‑Fi CIDR、启用状态由开关控制。若检测到本机既有的“Guanzhitong 合规性判断 8765”规则，则复用并修正其端口/范围，避免创建重复规则；若不存在才创建专用规则。规则读回失败时，操作失败关闭。

### 5. 关闭 Docker Desktop 的宽泛 TCP 入站旁路

Docker Desktop 的自动 TCP Backend 规则可能按程序和 Private profile 允许任意来源，不能与服务级 CIDR 限制同时存在。启动器在 `on`/`status` 时检测该规则并保持它关闭；`off` 不重新启用该宽泛规则。当前 Docker 仅有一个目标容器，因此该策略不会牺牲现有其他 Docker Web 服务；未来其他容器需要 LAN 访问时，必须单独建立受限规则并经用户确认。

### 6. 将旧版 Web 逻辑收口到 Docker

把现有 `Start-GuanZhiWeb`、运行检查、打开、停止和 `compliance` 路由改为 Docker 容器/宿主机端口 `18765`。不再从 `F:\APP Location\Guanzhi Tong\旧版\01_主程序\Web正式版` 直接启动 Python；这样 `wll web` 不会产生与 Docker 同名服务的端口竞争或版本分叉。

## Risks / Trade-offs

- [Risk] Windows 防火墙变更需要管理员权限。→ 在执行前检查管理员令牌；不足时明确失败并不做半成品变更。
- [Risk] Wi‑Fi 网络切换后原 CIDR 可能失效。→ `status`/`on` 每次重新读取当前 WLAN 并重写专用规则；无法识别时失败关闭。
- [Risk] Docker Desktop 可能重新生成宽泛 Backend 规则。→ 每次 `on`/`status` 检测并报告；发现重新启用时保持 LAN 开关关闭，直到规则再次收敛。
- [Risk] 禁用 Docker Backend 宽泛 TCP 规则会影响其他 Docker 容器的入站访问。→ 当前核验只有目标容器；README 明确说明未来其他容器必须单独授权，且 `off` 不会自动恢复宽泛规则。
- [Risk] 本机通过自身 WLAN 地址回环测试不可靠。→ 用 localhost/容器健康检查验证本机服务，并在状态输出中给出局域网 URL；最终 LAN 验证使用另一台同 Wi‑Fi 设备。
- [Risk] 用户已有未提交代码改动可能包含并行冠志通 Web 逻辑。→ 实施前保存基线与 diff，按函数和配置块最小合并，不覆盖无关修改。

## Migration Plan

1. 备份并审查现有工作区差异，创建稳定规则标识和 Docker 目标配置。
2. 实现 Docker 状态/健康/端口检查、网络 CIDR 解析、防火墙开关、状态输出和日志。
3. 将现有 Web/compliance 路由切换到 Docker，更新菜单和 README。
4. 用 `wll lan status`、`wll lan on`、`wll lan off` 进行受控回放，检查规则读回、容器健康和 localhost HTTP `200`。
5. 关闭时仅禁用冠志专用规则；回滚代码可恢复旧脚本，但不自动恢复 Docker 宽泛入站规则，以保持默认安全状态。

## Open Questions

无。当前 Docker 容器、宿主机端口、WLAN 子网和访问边界均已由现场状态确认。
