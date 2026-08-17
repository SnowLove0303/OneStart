# OneStart (统一工作流启动器)

`OneStart` 是面向本机 AI 工作流与开发生态的统一启动与生命周期管理中枢，集成并调度 n8n、Dify、Cogpit Dashboard、MSDS 智能编辑器、AI Study Tauri 桌面客户端以及 DeepSeek Harness (dsh) 等核心平台与工具。

---

## 🌟 核心特性

- **多平台统一调度**：一键管理 `n8n`、`Dify`、`Cogpit`、`MSDS Editor`、`AI Study Tauri` 与 `DeepSeek Harness` 的启动、停止、重启与状态检测。
- **环境与容器就绪守护**：
  - 启动前自动检测 Docker Engine，若未就绪自动唤起 Docker Desktop 并等待就绪。
  - 自动检测端口冲突与服务健康状态检查（HTTP Health Check）。
  - 避免重复启动已运行的实例。
- **极速一键别名**：支持在终端直接输入 `wl` 快速调出统一控制台，或通过参数直接执行自动化脚本。
- **安全停止与数据守护**：优雅关闭服务，保留数据卷与配置。
- **全流程日志追踪**：操作链路全面记录于日志，方便故障排查与运行审计。

---

## 📁 目录结构

```
OneStart/
├── System/
│   ├── Workflow-Launcher.ps1      # 核心启动器主程序 (PowerShell)
│   ├── Workflow-Launcher.bat      # 双击运行脚本 (BAT)
│   ├── wl.bat                     # 快捷指令别名 (终端直接输入 wl)
│   ├── fix-encoding.ps1           # 编码修复工具
│   ├── assets/
│   │   └── syntax-check.ps1       # 语法与配置检测工具
│   └── README.md                  # System 模块说明
├── Codex/                         # 规范与说明文档
├── migration-backups/             # 历史迁移归档
├── .gitignore
└── README.md                      # 项目总说明
```

---

## 🚀 快速开始

### 方式一：终端快捷指令（推荐）
将 `System` 目录添加至系统 `PATH` 环境变量，或直接进入 `System` 目录运行：
```powershell
wl
```

### 方式二：双击运行
双击 `System\Workflow-Launcher.bat` 即可打开交互式控制台菜单。

### 方式三：PowerShell CLI 命令行调用
```powershell
# 打开交互主菜单
.\System\Workflow-Launcher.ps1

# 单独启动指定平台
.\System\Workflow-Launcher.ps1 start n8n
.\System\Workflow-Launcher.ps1 start dify
.\System\Workflow-Launcher.ps1 start cogpit
.\System\Workflow-Launcher.ps1 start msds
.\System\Workflow-Launcher.ps1 start aistudy
.\System\Workflow-Launcher.ps1 start dsh
.\System\Workflow-Launcher.ps1 start all

# 停止平台
.\System\Workflow-Launcher.ps1 stop n8n
.\System\Workflow-Launcher.ps1 stop dify
.\System\Workflow-Launcher.ps1 stop cogpit
.\System\Workflow-Launcher.ps1 stop msds
.\System\Workflow-Launcher.ps1 stop dsh
.\System\Workflow-Launcher.ps1 stop all

# 查看运行状态
.\System\Workflow-Launcher.ps1 status
```

---

## 📋 控制台菜单对照表

| 序号 | 平台 / 操作 | 访问地址 / 说明 |
| :--- | :--- | :--- |
| **[1]** | 启动 n8n | http://127.0.0.1:5678 |
| **[2]** | 启动 Dify | http://localhost |
| **[3]** | 启动 Cogpit Dashboard | http://127.0.0.1:19384 |
| **[4]** | 启动 MSDS Editor | 结构读取 / 检索 / 覆写系统 |
| **[5]** | 启动 AI Study Tauri 系统 | 动态扫描最新正式构建 Release |
| **[6]** | 启动 DeepSeek Harness (Web) | http://127.0.0.1:3080 |
| **[7]** | 运行 DeepSeek Harness 一次性任务 | CLI 交互模式 |
| **[8]** | 同时启动全部平台 | 依次启动全部已配置服务 |
| **[9]** | 查看全部运行状态 | 端口、容器与进程综合巡检 |
| **[10-14]**| 停止对应服务 / 停止全部 | 优雅安全下线 |
| **[E1-E4]**| 快速在浏览器打开网页 | 直接跳转对应管理界面 |

---

## 📄 开源与协议

本项目遵循 MIT 许可证。
