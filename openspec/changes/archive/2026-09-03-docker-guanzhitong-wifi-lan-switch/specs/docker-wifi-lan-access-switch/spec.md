## Purpose

为统一启动器提供一个可审计、可回读且默认收敛的开关，用于控制现有冠志通 Docker Web 是否能被当前 Private Wi‑Fi 子网中的其他设备访问，同时保留本机访问能力。

## ADDED Requirements

### Requirement: Launcher SHALL expose a LAN access switch for the existing Docker Web service

统一启动器 SHALL 提供 `wll lan on`、`wll lan off` 和 `wll lan status` 三个命令，并在交互菜单中提供等价操作。开关 SHALL 针对现有容器 `guanzhitong-compliance` 和宿主机端口 `18765`，不得创建新容器、镜像或备用端口。

#### Scenario: User enables Wi‑Fi LAN access

- **WHEN** 用户执行 `wll lan on`
- **THEN** 启动器校验 Docker Desktop、目标容器和端口映射，并启用仅允许当前 Private Wi‑Fi IPv4 子网访问 TCP `18765` 的入站规则

#### Scenario: User disables Wi‑Fi LAN access

- **WHEN** 用户执行 `wll lan off`
- **THEN** 启动器禁用冠志通专用入站规则，保留容器和本机 `localhost` 访问，不停止 Docker 服务

#### Scenario: User checks switch status

- **WHEN** 用户执行 `wll lan status`
- **THEN** 启动器显示容器状态、健康状态、宿主机端口、当前 WLAN 名称/IP/子网、防火墙规则状态、允许来源和局域网访问地址

### Requirement: LAN access SHALL be restricted to the active Private Wi‑Fi subnet

开启状态 SHALL 仅允许当前活跃 WLAN 的 Private IPv4 子网作为远程来源；Public 网络、FlClash 等其他网卡、未知网络类别和公网来源 SHALL 不被放行。若无法唯一识别满足条件的 WLAN 子网，启动器 SHALL 失败关闭并报告原因。

#### Scenario: Active WLAN is the known Private subnet

- **WHEN** 当前唯一活跃网络为 Private WLAN，地址为 `192.168.0.119/24`
- **THEN** 开关将远程来源限定为 `192.168.0.0/24`，访问地址显示为 `http://192.168.0.119:18765`

#### Scenario: Active network is Public or ambiguous

- **WHEN** 当前 WLAN 为 Public、存在多个候选 Private 接口、没有 IPv4 地址/前缀，或无法确认网络归属
- **THEN** `wll lan on` 不启用规则或立即回滚本次变更，并返回可操作的安全错误

#### Scenario: Public interface attempts to reach the service

- **WHEN** 请求来自 Public 网络接口、FlClash 接口或不属于当前 Wi‑Fi 子网的地址
- **THEN** Windows 防火墙不允许该请求通过冠志通局域网规则

### Requirement: The switch SHALL fail closed and avoid parallel Docker objects

开关 SHALL 只操作已确认的 Docker CLI、容器名、镜像和宿主机端口；目标不存在、健康检查失败、端口映射不匹配、Docker 不可用或防火墙操作失败时 SHALL 返回非零结果并保持/恢复关闭状态。启动器 SHALL 不执行 `docker run`、不复制项目、不创建第二个容器或临时端口。

#### Scenario: Target container is missing or unhealthy

- **WHEN** `guanzhitong-compliance` 不存在、未运行或健康状态不是 `healthy`
- **THEN** `wll lan on` 不开放局域网规则，并显示目标容器和修复原因

#### Scenario: Target port mapping is not the expected mapping

- **WHEN** 目标容器没有将容器端口 `8765` 映射到宿主机 `18765`
- **THEN** `wll lan on` 拒绝继续，不修改其他端口或容器

#### Scenario: Docker Desktop has a broad TCP inbound rule

- **WHEN** Docker Desktop 的宽泛 TCP 入站规则会使 Docker 发布端口绕过冠志通来源限制
- **THEN** 启动器 SHALL 在开启或状态检查时检测该条件，保持该宽泛规则关闭，并在状态中报告该安全前提

### Requirement: Existing Web launcher commands SHALL target the single Docker service

现有 `wll web`、`wll start web` 和 `wll compliance`/`wll start compliance` SHALL 使用现有 Docker 容器作为冠志通 Web 来源，不再启动旧版 Windows Python Web 进程；这些命令 SHALL 保持本机访问可用，并显示实际端口 `18765`。

#### Scenario: User starts the Web service

- **WHEN** 用户执行 `wll web` 或从菜单选择启动冠志通 Web
- **THEN** 启动器启动或复用 `guanzhitong-compliance`，等待其达到健康状态，并显示 `http://127.0.0.1:18765`

#### Scenario: User opens the compliance application

- **WHEN** 用户执行 `wll compliance`
- **THEN** 启动器确保同一个 Docker Web 已就绪，并打开该服务的合规工作台 URL，不启动另一个本地 Web 实例

### Requirement: The launcher SHALL provide safe operational feedback and logs

每次开关操作 SHALL 记录目标容器、端口、网络接口、允许来源、规则变更、结果和错误；输出 SHALL 区分“容器运行状态”和“局域网访问开关状态”，不得仅以端口监听作为 LAN 已开启的依据。

#### Scenario: Successful toggle is logged

- **WHEN** `wll lan on` 或 `wll lan off` 成功完成
- **THEN** 控制台和 `System/logs/launcher.log` 均记录明确的成功状态、规则范围和访问地址/关闭结果

#### Scenario: Firewall operation requires elevation

- **WHEN** 当前 PowerShell 权限不足以读取或修改 Windows 防火墙
- **THEN** 启动器提示需要管理员权限，返回失败结果，不留下半完成的启用状态
