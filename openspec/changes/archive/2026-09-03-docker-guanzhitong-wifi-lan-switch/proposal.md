## Why

当前统一启动器中的冠志通 Web 入口仍面向旧版 Windows Python 服务，而实际使用的冠志通合规 Web 已运行在 Docker 容器 `guanzhitong-compliance` 中。用户需要通过同一个 `wll` 入口明确控制该 Docker Web 是否允许同一 Wi‑Fi 下的其他设备访问，并在关闭时回收局域网入站权限，避免依赖手工修改防火墙。

## What Changes

- 在现有 `Workflow-Launcher.ps1` 中增加 Docker 冠志通 Web 局域网访问开关。
- 提供 `wll lan on`、`wll lan off`、`wll lan status` 命令，并在交互菜单中提供对应操作。
- `on` 只针对现有容器 `guanzhitong-compliance` 的宿主机 TCP `18765` 端口启用局域网访问，来源限制为当前 WLAN 的 Private IPv4 子网。
- `off` 禁用冠志通专用入站规则，不停止 Docker 容器，也不影响本机 `localhost` 访问。
- 开启前校验 Docker Desktop、目标容器/镜像、健康状态、WLAN 网络类别、当前 IP/子网和端口映射；条件不满足时失败关闭，不自动创建容器或备用端口。
- 状态命令显示容器健康、局域网开关状态、当前 Wi‑Fi 地址/子网、防火墙规则和局域网访问地址。
- 保持 Docker Desktop 宽泛 TCP 入站规则关闭，防止其他 Docker 发布端口绕过冠志通专用来源限制。
- 更新统一启动器 README，记录命令、菜单、访问地址、关闭行为和安全边界。

## Capabilities

### New Capabilities

- `docker-wifi-lan-access-switch`: 通过统一启动器安全控制现有冠志通 Docker Web 的同 Wi‑Fi 局域网入站访问。

### Modified Capabilities

无。当前仓库尚无已建立的 OpenSpec 能力规格；现有 `web`/`compliance` 代码行为属于待实现的启动器事实，不作为已确认规格继承。

## Impact

- 代码：`System/Workflow-Launcher.ps1`。
- 文档：`System/README.md`。
- 入口：继续使用现有 `System/wll.bat`，不创建第二套启动器。
- 外部系统：Windows Defender Firewall 的现有冠志通规则；Docker Desktop 容器 `guanzhitong-compliance` 仅做只读状态和端口核验。
- 不新增依赖、容器、镜像、端口、数据库或宿主机项目副本。
- 现有 `System/README.md` 与 `System/Workflow-Launcher.ps1` 的未提交修改属于既有用户状态，实施时必须保留并做最小增量合并。
