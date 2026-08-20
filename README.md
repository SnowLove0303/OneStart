# OneStart (统一启动器)

`OneStart` 是本机 AI 工作流统一启动与生命周期管理中枢，集成调度 **AI Study Tauri** 桌面客户端与 **DeepSeek Harness (dsh)** 等本机核心平台与工具。

---

## 🌟 核心特性

- **多平台统一调度**：一键管理 `AI Study Tauri` 与 `DeepSeek Harness` 的启动、停止、重启与状态检测。
- **极速一键别名**：支持在终端直接输入 `wll` 快速调出统一控制台，或通过参数直接执行自动化脚本。
- **环境就绪守护**：
  - 自动检测平台是否已运行，避免重复启动。
  - dsh 启动后自动健康检查（HTTP Health Check）。
- **动态构建解析**：AI Study Tauri 自动扫描最新正式构建 Release，无需手动改路径。
- **安全停止与数据守护**：优雅关闭服务，不误杀其他进程、不删除数据。
- **全流程日志追踪**：操作链路全面记录于日志，方便故障排查与运行审计。

---

## 📁 目录结构

```
OneStart/
├── System/
│   ├── Workflow-Launcher.ps1      # 核心启动器主程序 (PowerShell)
│   ├── Workflow-Launcher.bat      # 双击运行脚本 (BAT)
│   ├── wll.bat                    # 快捷指令别名 (终端直接输入 wll)
│   ├── logs\                      # 运行日志
│   └── README.md                  # System 模块说明
├── Codex/                         # 规范与说明文档
├── migration-backups/             # 历史迁移归档
├── .gitignore
└── README.md                      # 项目总说明
```

---

## 🚀 快速开始

### 方式一：终端快捷指令（推荐）

`System` 目录已添加至系统 `PATH` 环境变量，任意终端输入：
```
wll            # 打开交互菜单
wll dsh        # 直接启动 DeepSeek Harness (Web)
wll aistudy    # 直接启动 AI Study Tauri
wll status     # 查看运行状态
```

### 方式二：双击运行

双击 `System\Workflow-Launcher.bat` 即可打开交互式控制台菜单。

### 方式三：PowerShell CLI 命令行调用

```powershell
# 打开交互主菜单
.\System\Workflow-Launcher.ps1

# 单独启动指定平台
.\System\Workflow-Launcher.ps1 start dsh
.\System\Workflow-Launcher.ps1 start aistudy
.\System\Workflow-Launcher.ps1 start all

# 停止平台
.\System\Workflow-Launcher.ps1 stop dsh
.\System\Workflow-Launcher.ps1 stop aistudy
.\System\Workflow-Launcher.ps1 stop all

# 查看运行状态 / 日志
.\System\Workflow-Launcher.ps1 status
.\System\Workflow-Launcher.ps1 logs dsh
```

---

## 📋 控制台菜单对照表

| 序号 | 平台 / 操作 | 访问地址 / 说明 |
| :--- | :--- | :--- |
| **[1]** | 启动 AI Study Tauri 系统 | 动态扫描最新正式构建 Release |
| **[2]** | 启动 DeepSeek Harness (Web) | http://127.0.0.1:9010 |
| **[3]** | 运行 DeepSeek Harness 一次性任务 | CLI 交互模式 |
| **[4]** | 同时启动全部平台 | 依次启动全部已配置服务 |
| **[5]** | 查看全部运行状态 | 端口、容器与进程综合巡检 |
| **[6-8]**| 停止对应服务 / 停止全部 | 优雅安全下线 |
| **[E1]** | 快速在浏览器打开 DeepSeek Harness | 直接跳转对应管理界面 |

---

## 📄 开源与协议

本项目遵循 MIT 许可证。
