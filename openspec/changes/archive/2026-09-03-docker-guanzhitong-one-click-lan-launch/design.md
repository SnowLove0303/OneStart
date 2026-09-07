## Context

本变更建立在已归档的 `docker-guanzhitong-wifi-lan-switch` 能力上。当前唯一正式入口是 `System\Workflow-Launcher.ps1`，唯一目标运行实例是 Docker 容器 `guanzhitong-compliance`，容器端口 `8765` 映射到宿主机端口 `18765`；已有实现分别负责 Docker Web 启动/停止和 Private WLAN 防火墙开关。新入口必须复用这些校验与对象，不得引入第二套服务生命周期。

## Goals / Non-Goals

**Goals:**

- 将“确保 Docker Web 健康”和“开启当前 Private WLAN 访问”编排为一个可重复执行的一键启动动作。
- 提供对称的一键关闭动作，先收敛局域网暴露面，再停止同一容器。
- 在一键动作中保留失败关闭、原状态识别、必要回滚、日志和最终状态回读。
- 让命令行和交互菜单使用同一套编排函数，并保持现有基础命令兼容。
- 以真实容器、HTTP、端口映射、防火墙规则和关闭后状态作为验收依据。

**Non-Goals:**

- 不修改 Docker Compose、镜像、容器内部应用、宿主机端口或项目数据存储。
- 不创建新的脚本入口、备用配置、备用端口、第二个容器或常驻后台守护进程。
- 不把 LAN 开关默认改为开机自动启用，也不放开 Public、FlClash 或公网来源。
- 不把“本机回环访问成功”当作唯一的物理 Wi‑Fi 设备可达性证明；如无第二台同 Wi‑Fi 设备，只报告主机侧可验证证据和限制。

## Decisions

### 1. Add a dedicated paired lifecycle target

新增 `Start-GuanZhiLanSession` 与 `Stop-GuanZhiLanSession` 两个编排层函数，命令解析映射到 `start guanzhitong-lan` / `guanzhitong-lan` 和 `stop guanzhitong-lan`，菜单增加对应选项。编排层调用已有的 `Start-GuanZhiWeb`、`Invoke-GuanZhiLanCommand` 和 `Stop-GuanZhiWeb`，避免复制 Docker 或防火墙逻辑。

选择独立目标而不是改变现有 `wll guanzhi` 语义，是为了保持当前仅启动 Web 的用户脚本兼容；选择对称 stop 目标，则让真实验证后的安全关闭有明确、可重复的入口。

### 2. Start in dependency order and open only after verification

一键启动先记录目标容器是否已运行，再以 `-SkipOpen` 方式确保 Web 健康，随后执行 LAN `on`。只有两者都成功且状态回读通过后才打开本机 Web 页面并输出 LAN 地址。这样浏览器不会在防火墙配置失败时误导用户认为一键动作已完成。

如果本次操作把原本停止的目标容器启动起来，但 LAN 开启或最终验证失败，则关闭 LAN 规则并停止本次启动的容器；如果容器原本已运行，则保留其运行状态，但不启用 LAN 规则。

### 3. Stop in exposure-first order

一键关闭先调用现有 LAN `off`，成功后再调用同一目标容器的 Web stop，并回读确认专用规则关闭、容器停止以及本机 HTTP 不再成功。若关闭防火墙失败，编排层返回失败并不宣称闭环完成；该顺序优先缩短暴露窗口。

### 4. Keep a single command and menu contract

命令解析增加明确目标别名：`guanzhitong-lan` 为便捷写法，`start guanzhitong-lan` 和 `stop guanzhitong-lan` 为显式写法。交互菜单采用新编号，不重用已有的 `11/12/13` 基础 LAN 操作编号。README 同步列出推荐的一键流程和基础诊断命令。

### 5. Verify the real instance, not only the port

真实验证脚本/命令按固定顺序回读：目标容器名与镜像、运行/健康状态、端口映射、宿主机 HTTP、当前唯一 Private WLAN、专用规则属性与远程来源、Docker 宽泛 TCP 规则状态；关闭阶段再次回读容器与规则，并验证本机 HTTP 不可用。验证只针对已确认正式对象，不启动测试副本。

## Risks / Trade-offs

- [Risk] LAN 配置成功但浏览器打开失败，会让用户误以为服务失败 → 将浏览器打开作为最后的非核心动作，核心成功状态已先写日志和控制台；打开失败只记录提示。
- [Risk] 一键启动中途失败时，可能难以区分容器是本次启动还是用户原先启动 → 在编排开始时读取精确容器状态，只对本次从 stopped 变为 running 的容器执行回滚。
- [Risk] 防火墙规则被外部工具或用户改写 → 一键启动/状态回读校验规则名、Private profile、TCP、18765 和当前 WLAN 子网；不匹配时保持 LAN 关闭并报告。
- [Risk] 同一主机自测 `192.168.x.x:18765` 可能受 Windows/Docker 回环路径限制 → 将 `localhost` HTTP、监听/端口映射和防火墙配置分开报告；物理第二设备验证若不可用则明确标注未执行。
- [Risk] 既有 `System\Workflow-Launcher.ps1` 和 README 存在用户未提交修改 → 只在相关命令/菜单/说明区域做最小补丁，执行前后检查 diff，不重置或覆盖无关修改。

## Migration Plan

1. 在现有统一启动器根目录实现编排函数、命令别名、菜单入口和 README 更新。
2. 执行 PowerShell 解析、语法检查、OpenSpec 严格校验及差异范围审查。
3. 在当前唯一 Docker 容器和实际 Private WLAN 上运行真实回放：一键启动、状态/HTTP/容器/规则验证、一键关闭、关闭后再次验证。
4. 若启动阶段失败，确认 LAN 规则关闭；若关闭阶段失败，保留证据并停止交付声明，避免留下未核验的暴露状态。
5. 无需迁移数据或更新 Docker 镜像；回滚代码时仅回滚本次新增编排/入口/文档改动，运行时通过 `wll stop guanzhitong-lan` 收敛。

