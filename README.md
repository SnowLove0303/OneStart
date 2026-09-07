# OneStart (统一启动器)

`OneStart` 是本机 AI 工作流统一启动与生命周期管理中枢，集成调度 **AI Study Tauri** 桌面客户端、**DeepSeek Harness (dsh)**、**冠志通 Docker Web 工作台** 以及 **AI 桌面协同组合 (Antigravity / IDE / ChatGPT / Cockpit)** 等核心平台与工具。

---

## 🌟 核心特性

- **多平台与组合协同调度**：一键管理 `AI Study Tauri`、`DeepSeek Harness`、`冠志通 Docker Web` 以及 `Antigravity / IDE / ChatGPT / Cockpit` AI 桌面工具套件的启动、停止与状态监控。
- **独立二级组合面板**：针对 AI 桌面协同工具提供专属二级交互界面，支持**全部统一启动**、**全部关闭**与**独立分开启动/关闭**，配备实时 PID 状态看板。
- **Wi‑Fi 局域网安全访问控制**：支持一键开启/关闭冠志通 Docker Web 在局域网（Private Wi‑Fi）内的访问，严格限定来源网段，具备故障自动回滚机制。
- **极速终端别名 (`wll`)**：在任意终端直接输入 `wll` 唤起交互式控制台，或通过参数直接执行自动化启停脚本。
- **控制台输出与交互优化**：
  - 保留控制台历史回滚缓冲区（避免菜单循环自动清屏刷掉输出）；
  - 支持按 `[C]` 键一键将最近 30 行执行日志复制至剪贴板；
  - 划选文本时智能过滤 `Shift`/`Ctrl`/`Alt` 修饰键，按 `[Enter]` 确认返回主菜单；
  - 支持输入 `cls` / `clear` 手动清屏。
- **环境守护与防重复多开**：自动感知进程状态，已在运行的应用避免重复启动；关闭时精准处理主子进程树。
- **全流程日志追踪**：所有操作全面记录于 `System/logs/launcher.log`，方便运行审计与故障排查。

---

## 📁 目录结构

```
OneStart/
├── System/
│   ├── Workflow-Launcher.ps1      # 核心启动器主程序 (PowerShell)
│   ├── Workflow-Launcher.bat      # 双击运行脚本 (BAT)
│   ├── wll.bat                    # 快捷指令别名 (终端直接输入 wll)
│   ├── wl.bat                     # 兼容别名
│   ├── logs/                      # 运行日志目录
│   └── README.md                  # System 模块详细说明
├── openspec/                      # 变更提案与功能规格说明文档
├── Codex/                         # 规范与说明文档
├── migration-backups/             # 历史迁移归档
├── .gitignore
└── README.md                      # 项目总说明
```

---

## 🚀 快速开始

### 方式一：终端快捷指令（推荐）

`System` 目录已添加至系统 `PATH` 环境变量，在任意终端直接输入：

```powershell
wll                 # 打开统一启动器主菜单
wll status          # 查看全部平台与组件运行状态

# AI 桌面工具协同组合 (Antigravity / IDE / ChatGPT / Cockpit)
wll start ai-suite  # 一键全部统一启动 (4个工具全启)
wll stop ai-suite   # 一键全部关闭 (4个工具全关)
wll status ai-suite # 查看 AI 协同组合状态看板

# 独立启停
wll start dsh       | wll stop dsh
wll start aistudy   | wll stop aistudy
wll start web       | wll stop web
wll start antigravity     | wll stop antigravity
wll start antigravity-ide | wll stop antigravity-ide
wll start chatgpt         | wll stop chatgpt
wll start cockpit         | wll stop cockpit

# Docker Web 局域网控制
wll lan on          # 开启同 Wi‑Fi 局域网访问
wll lan off         # 关闭局域网访问
wll lan status      # 查看局域网访问状态
wll start guanzhitong-lan # 一键启动 Docker Web + 开启 LAN 访问
```

### 方式二：双击运行

双击 `System\Workflow-Launcher.bat` 即可打开交互式控制台菜单。

### 方式三：PowerShell CLI 命令行调用

```powershell
# 打开交互主菜单
.\System\Workflow-Launcher.ps1

# 启动指定平台或组合
.\System\Workflow-Launcher.ps1 start ai-suite
.\System\Workflow-Launcher.ps1 start dsh
.\System\Workflow-Launcher.ps1 start all

# 停止
.\System\Workflow-Launcher.ps1 stop ai-suite
.\System\Workflow-Launcher.ps1 stop all

# 查看运行状态 / 日志
.\System\Workflow-Launcher.ps1 status
.\System\Workflow-Launcher.ps1 logs dsh
```

---

## 📋 控制台菜单对照表

| 序号 | 平台 / 操作 | 说明 |
| :--- | :--- | :--- |
| **[1]** | 启动 AI Study Tauri 系统 | 动态扫描最新正式构建 Release |
| **[2]** | 启动 DeepSeek Harness (Web) | http://127.0.0.1:9010 |
| **[3]** | 运行 DeepSeek Harness 一次性任务 | CLI 交互模式 (Headless) |
| **[4]** | 启动冠志通 Web 工作台 | 启动 Docker 容器 `guanzhitong-compliance` (http://127.0.0.1:18765) |
| **[5]** | 同时启动全部平台 | 依次启动全部常规核心服务 |
| **[6]** | 查看全部运行状态 | 端口、容器、进程与 AI 组合综合巡检 |
| **[7-10]** | 停止对应服务 / 停止全部 | 优雅安全下线 |
| **[11]** | 开启冠志通 Docker Web Wi‑Fi 局域网访问 | 仅允许当前 Private Wi‑Fi 子网访问 TCP 18765 |
| **[12]** | 关闭冠志通 Docker Web Wi‑Fi 局域网访问 | 关闭入站规则，不停止 Docker 容器 |
| **[13]** | 查看冠志通 Docker Web 局域网状态 | 显示 Docker、WLAN、CIDR、规则和访问地址 |
| **[14]** | 一键启动 Docker Web + Wi‑Fi 访问 | 先确认容器健康，再开启当前子网访问 |
| **[15]** | 一键关闭 LAN 并停止 Docker Web | 先关闭局域网规则，再安全停止容器 |
| **[16]** | **进入 AI 工具套件组合菜单 >>>** | **专属二级子菜单：Antigravity / IDE / ChatGPT / Cockpit 协同管理** |
| **[E1]** | 快速在浏览器打开 DeepSeek Harness | 直接跳转对应管理界面 |
| **[CLS]** | 清屏 | 恢复清爽控制台界面 |
| **[0]** | 退出 | 关闭启动器 |

---

## 📄 开源与协议

本项目遵循 MIT 许可证。
