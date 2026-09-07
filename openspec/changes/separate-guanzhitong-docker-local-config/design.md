## Context

参见 proposal.md。当前正式入口是 `System\wll.bat` 转发的 `System\Workflow-Launcher.ps1`；冠志通 Docker Web 的唯一实例是 `guanzhitong-compliance`，容器端口 `8765` 发布到宿主机 `18765`。本次是纯配置边界重构，必须保持已验证的一键启动、LAN 开关和关闭行为不变。

## Goals / Non-Goals

**Goals:**

- 使用一个唯一的 PowerShell data file 作为冠志通配置来源。
- 通过顶层 `Docker` 与 `Local` 节点让“容器/镜像/容器端口”和“宿主机端口/URL/防火墙/本机等待参数”有明确归属。
- 在启动脚本加载时检查配置文件存在且必需字段非空，配置错误时尽早失败，不产生部分运行状态。
- 保留现有脚本变量作为运行时派生别名，减少行为代码改动，并让所有既有函数继续使用同一配置源。

**Non-Goals:**

- 不拆分或复制 Docker Compose 文件，不把 Compose 当作启动器的第二套配置。
- 不把动态 WLAN 地址、当前网络类别或运行时防火墙状态硬编码进配置文件。
- 不新增环境变量、依赖、服务、容器、端口、数据迁移或备用启动入口。
- 不在本次整理中修改 Docker 镜像、容器内部应用或历史数据。

## Decisions

### 1. Use a single `.psd1` with explicit nested sections

采用 `System\config\guanzhitong.config.psd1`，使用 `@{ Docker = @{ ... }; Local = @{ ... } }` 的只读数据结构。`.psd1` 可由 PowerShell 原生安全导入，不需要执行任意脚本，也比继续散落变量更容易审查。

Docker 区块包含 `CliPath`、`ComposeFile`（只读参考）、`ContainerName`、`Image`、`ContainerPort`；Local 区块包含 `HostPort`、`WebUrl`、`ReadyTimeoutSec`、`FirewallRuleName`、兼容旧规则名称、Docker Backend 规则显示名和合规工作台 URL 后缀/地址。

### 2. Keep compatibility aliases inside the launcher

脚本加载并校验 `$Script:GuanZhiConfig.Docker` 和 `$Script:GuanZhiConfig.Local` 后，生成现有 `$Script:GuanZhiDockerCli`、`$Script:GuanZhiWebPort` 等运行时别名。这样现有函数调用链、命令解析和日志格式不需要大范围重写；别名不得再成为独立配置来源。

### 3. Fail early on missing or malformed configuration

加载后校验两个区块存在，并检查所有必需字符串/端口/超时字段。配置文件缺失、区块缺失或值为空时，脚本记录明确错误并终止，避免回退到隐含默认值或启动错误 Docker 对象。

### 4. Document ownership and commit as one coherent change

README 添加“配置归属”表：Docker 区块描述容器侧对象，Local 区块描述宿主机侧对象，动态 WLAN 和实时防火墙状态由命令运行时发现。Git 提交前只纳入当前任务相关文件和已确认的 OpenSpec/启动器变更，保留用户无关文件，不推送远端。

## Risks / Trade-offs

- [Risk] `.psd1` 路径或字段拼写错误导致启动器不可用 → 加载时执行存在性和必需字段校验，并运行 AST/命令冒烟测试。
- [Risk] Compose 参考路径被误认为启动来源 → 字段命名为 `ComposeFile` 并在 README 标为只读参考；启动代码仍只通过精确 Docker CLI/容器名操作。
- [Risk] 配置重构改变既有服务行为 → 保留运行时别名并用真实一键启动/关闭回放核对容器、端口、HTTP、LAN 和防火墙状态。
- [Risk] 当前工作区包含此前用户修改 → 先记录 diff 和文件范围，使用最小补丁，不执行 reset、clean 或覆盖无关文件。

## Migration Plan

1. 添加唯一配置文件并迁移主脚本配置区到加载/校验逻辑。
2. 更新 README 的配置边界说明。
3. 执行 AST、语法、安全扫描、OpenSpec 校验、命令冒烟和真实 Docker/LAN 关闭回放。
4. 检查 diff、敏感信息和唯一配置/端口/容器对象后创建 Git 提交。
5. 若需要回滚，只恢复本次配置文件/加载逻辑/文档改动；不删除 Docker 数据或容器。
