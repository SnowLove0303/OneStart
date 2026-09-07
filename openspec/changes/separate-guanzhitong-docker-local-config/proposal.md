## Why

当前冠志通 Docker 目标参数和宿主机启动器参数虽然有注释分组，但仍直接散落在主 PowerShell 脚本的变量区，后续修改时容易把容器内部端口、宿主机端口、URL、防火墙和 Docker Desktop 配置混淆。提交前需要把它们收敛到一个明确、可审计且不改变运行行为的配置边界。

## What Changes

- 新增唯一正式配置文件 `System\config\guanzhitong.config.psd1`。
- 在配置文件中明确分成 `Docker` 和 `Local` 两个区块：Docker 区块只放 Docker CLI、Compose 参考路径、容器名、镜像和容器端口；Local 区块只放宿主机端口、URL、健康等待时间和 Windows 防火墙规则标识。
- `Workflow-Launcher.ps1` 从该配置文件加载并校验必需字段，再将配置值提供给现有启动、停止、LAN 开关和状态逻辑。
- README 增加配置边界说明，避免用户把 Docker 内部配置与本机配置混用。
- 不改变现有命令、容器、镜像、端口映射、数据目录或 LAN 安全策略。

## Capabilities

### New Capabilities

<!-- Pure configuration refactor; no externally observable capability is introduced. -->

### Modified Capabilities

<!-- No requirement-level behavior changes. -->

## Impact

- 代码：`System\Workflow-Launcher.ps1` 的配置加载与配置引用。
- 新文件：`System\config\guanzhitong.config.psd1`。
- 文档：`System\README.md`。
- 运行时：仅读取本机配置文件；启动器继续只操作已确认的 Docker 容器和宿主机防火墙规则。
- Git：通过静态检查、真实状态检查和 diff 审查后，提交本次整理及当前已确认的统一启动器变更；不自动推送。
