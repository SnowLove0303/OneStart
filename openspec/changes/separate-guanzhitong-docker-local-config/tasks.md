## 1. 配置边界整理

- [ ] 1.1 创建 `System\config\guanzhitong.config.psd1`，将 Docker CLI/Compose 参考路径/容器名/镜像/容器端口与宿主机端口/URL/超时/防火墙标识分置于 `Docker`、`Local` 两个区块，并验证文件只包含配置数据、不含密钥或可执行逻辑
- [ ] 1.2 修改 `System\Workflow-Launcher.ps1` 从唯一 `.psd1` 加载配置、校验必需字段并生成运行时派生值；用 AST 解析和配置缺失/字段读取检查确认不再存在第二套硬编码配置来源
- [ ] 1.3 保持现有 Docker Web、LAN 开关和一键生命周期函数使用同一份派生配置；用静态引用扫描确认 Docker 内部端口与宿主机端口、URL、防火墙参数归属不混用

## 2. 文档与提交整理

- [ ] 2.1 更新 `System\README.md` 的配置归属说明，明确 Docker 区块、本机 Local 区块、动态 WLAN 状态和 Compose 只读参考的边界；用 `rg` 检查路径、端口和命令与配置文件一致
- [ ] 2.2 检查当前工作区 diff，保留既有用户修改和 OpenSpec 历史，不纳入缓存、日志、临时文件或无关目录；用 `git diff --check`、文件清单和敏感信息扫描确认提交范围

## 3. 验证与提交

- [ ] 3.1 执行 PowerShell AST/语法检查、配置导入检查、OpenSpec 严格校验和 Code Review Graph 影响检查；确认配置文件可读、规格与实现范围一致
- [ ] 3.2 使用真实唯一 Docker 容器执行 `wll start guanzhitong-lan`、状态回读和 `wll stop guanzhitong-lan`，确认整理前后容器、健康状态、端口映射、HTTP、WLAN 防火墙边界和关闭状态不变
- [ ] 3.3 在提交前复核仓库、分支、canonical commit、改动文件和未提交范围，创建一个说明“分离 Docker 与本地配置并整理统一启动器”的 Git commit，并验证 commit 内容；不推送远端
