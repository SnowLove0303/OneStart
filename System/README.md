# Workflow Launcher (wll)

管理本机 **AI Study Tauri**、**DeepSeek Harness (dsh)**、**冠志通 Docker Web 工作台** 与 **AI 桌面协同组合 (Antigravity / IDE / ChatGPT / Cockpit)** 的启动、停止、状态查询、日志查看和 Wi‑Fi 局域网访问开关。

## 安装位置

```
D:\应用研究\统一启动器\
├── System\
│   ├── Workflow-Launcher.ps1   # 主脚本（PowerShell）
│   ├── Workflow-Launcher.bat   # 双击启动入口
│   ├── wll.bat                 # 快捷指令别名 (终端直接输入 wll)
│   ├── logs\                   # 运行日志
│   └── README.md               # 本说明
```

`System` 目录已加入用户 PATH，在任意终端输入 `wll` 即可呼出启动器。

## 运行方式

### 方式一：终端快捷指令（推荐）

```
wll                 # 打开交互菜单
wll dsh             # 便捷写法，等价于 start dsh
wll aistudy         # 便捷写法，等价于 start aistudy
wll web             # 便捷写法，启动冠志通 Web 工作台
wll guanzhitong-lan # 一键启动 Docker Web 并开启同一 Wi‑Fi 局域网访问
wll compliance      # 便捷写法，打开合规性判断工作台应用
wll lan on           # 开启同一 Wi‑Fi 局域网访问
wll lan off          # 关闭同一 Wi‑Fi 局域网访问（不停止 Docker）
wll lan status       # 查看 Docker、Wi‑Fi 和防火墙状态
wll start ai-suite   # 一键启动 AI 桌面协同组合 (4个工具全启)
wll stop ai-suite    # 一键关闭 AI 桌面协同组合 (4个工具全关)
wll status ai-suite  # 查看 AI 桌面协同组合实时状态与 PID
```

### 方式二：双击运行

双击 `System\Workflow-Launcher.bat` 即可打开交互式控制台菜单。

### 方式三：命令行参数

```powershell
# 启动
.\Workflow-Launcher.ps1 start dsh
.\Workflow-Launcher.ps1 start aistudy
.\Workflow-Launcher.ps1 start aistudy
.\Workflow-Launcher.ps1 start web
.\Workflow-Launcher.ps1 start guanzhitong-lan
.\Workflow-Launcher.ps1 start compliance
.\Workflow-Launcher.ps1 start ai-suite
.\Workflow-Launcher.ps1 start antigravity
.\Workflow-Launcher.ps1 start antigravity-ide
.\Workflow-Launcher.ps1 start chatgpt
.\Workflow-Launcher.ps1 start cockpit
.\Workflow-Launcher.ps1 start all

# Docker Web Wi‑Fi 局域网访问开关
.\Workflow-Launcher.ps1 lan on
.\Workflow-Launcher.ps1 lan off
.\Workflow-Launcher.ps1 lan status

# 停止
.\Workflow-Launcher.ps1 stop dsh
.\Workflow-Launcher.ps1 stop aistudy
.\Workflow-Launcher.ps1 stop guanzhitong-lan
.\Workflow-Launcher.ps1 stop ai-suite
.\Workflow-Launcher.ps1 stop antigravity
.\Workflow-Launcher.ps1 stop antigravity-ide
.\Workflow-Launcher.ps1 stop chatgpt
.\Workflow-Launcher.ps1 stop cockpit
.\Workflow-Launcher.ps1 stop all

# 查看状态 / 日志
.\Workflow-Launcher.ps1 status
.\Workflow-Launcher.ps1 logs dsh
```

> 如果 PowerShell 提示执行策略限制，需先运行：
> ```powershell
> Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
> ```

## 菜单功能

| 编号 | 功能 | 说明 |
|------|------|------|
| 1 | 启动 AI Study Tauri | 动态扫描 `.build\cargo-target-latest-*\release\AIstudy.exe` 最新正式构建并启动 |
| 2 | 启动 DeepSeek Harness | 后台启动 dsh Web（预编译 CLI，端口 9010），就绪后自动打开浏览器 |
| 3 | DeepSeek Harness 一次性任务 | CLI 交互模式（headless） |
| 4 | 启动冠志通 Docker Web 工作台 | 启动或复用 Docker 容器 `guanzhitong-compliance`，宿主机端口 18765 |
| 5 | 同时启动 | 依次启动 AI Study Tauri、DeepSeek Harness 和冠志通 Web |
| 6 | 查看状态 | 显示各平台运行状态 |
| 7 | 停止 AI Study Tauri | 按进程名收口所有 AIstudy.exe 实例 |
| 8 | 停止 DeepSeek Harness | 按端口 9010 + 命令行关键词清理 |
| 9 | 停止冠志通 Web | 停止现有 Docker 容器 `guanzhitong-compliance` |
| 10 | 停止全部 | 停止所有平台 |
| 11 | 开启冠志通 Docker Web Wi‑Fi 局域网访问 | 仅允许当前 Private Wi‑Fi 子网访问 TCP 18765 |
| 12 | 关闭冠志通 Docker Web Wi‑Fi 局域网访问 | 关闭入站规则，不停止 Docker 容器 |
| 13 | 查看冠志通 Docker Web 局域网状态 | 显示 Docker、WLAN、CIDR、规则和访问地址 |
| 14 | 一键启动冠志通 Docker Web + Wi‑Fi 局域网访问 | 先确认 Docker Web 健康，再开启当前 Private Wi‑Fi 子网访问 |
| 15 | 一键关闭 LAN 并停止冠志通 Docker Web | 先关闭局域网规则，再停止同一 Docker 容器并回读状态 |
| 16 | 进入 AI 工具套件组合菜单 | 独立二级交互面板：支持 Antigravity / IDE / ChatGPT / Cockpit 全部统一启动、全部关闭、独立分开展控及实时 PID 看板 |
| E1 | 打开 DeepSeek Harness 网页 | 浏览器打开 http://127.0.0.1:9010 |
| 0 | 退出 | 关闭启动器 |

## 平台访问地址

| 平台 | 地址 |
|------|------|
| AI Study Tauri | 本机桌面应用（最新正式构建版） |
| DeepSeek Harness | http://127.0.0.1:9010 |
| 冠志通 Docker Web 工作台 | http://127.0.0.1:18765 |

## 本机平台目录

```
D:\应用研究\AI Study Tauri（AST)\        # AI Study Tauri 项目根目录
├── .build\cargo-target-latest-*\release\AIstudy.exe   # 正式构建产物（动态扫描最新）
└── build-release.ps1 / open-latest.ps1

D:\APP\AI app\deepseek\                # DeepSeek Harness (dsh) 根目录
├── apps\cli\lib\bin.js                # 预编译 CLI（启动 dsh Web / headless 任务）
├── dsh-web.out.log                    # dsh Web 输出日志
├── dsh-web.err.log                    # dsh Web 错误日志
└── ...                                # 源码、packages 等

C:\Users\Administrator\.dsh\           # dsh 数据主目录（profiles、sessions、settings.yaml）

F:\APP Location\Guanzhi Tong\旧版\       # 冠志通 Docker Compose 项目目录
├── docker-compose.yml                    # Docker Web 唯一启动配置
└── ...                                    # Docker 构建上下文与项目文件
```

## 启动器行为

- **去重检查**：平台已在运行时不会重复启动。
- **健康检查**：dsh 启动后通过 HTTP 检查 http://127.0.0.1:9010 就绪状态。
- **动态构建**：AI Study Tauri 自动扫描 `.build\cargo-target-latest-*` 目录中最新的正式 EXE。
- **单实例**：AI Study Tauri 启动前自动关闭历史 AIstudy.exe 进程，避免新旧版本并存。
- **自动打开浏览器**：dsh 就绪后自动用 Chrome 打开 Dashboard。
- **安全停止**：dsh 按端口定位进程清理，不误杀其他 node 进程。
- **日志记录**：所有操作写入 `System\logs\launcher.log`，包含时间、操作、命令、结果和错误信息。
- **Wi‑Fi 安全边界**：`wll lan on` 仅允许当前 Private WLAN IPv4 子网访问宿主机 TCP 18765；Public、FlClash、未知网卡和公网来源不放行。
- **失败关闭**：无法确认 Docker 容器健康、端口映射、Private WLAN 或防火墙范围时，不会开启局域网规则。
- **一键生命周期**：`wll start guanzhitong-lan`（或 `wll guanzhitong-lan`）串联 Docker Web 启动、LAN 开启和最终状态回读；`wll stop guanzhitong-lan` 先关闭 LAN，再停止容器并验证端口已无监听。
- **启动回滚**：一键启动若本次启动了原本停止的容器、但 LAN 配置或最终验证失败，会保持 LAN 关闭并停止本次启动的容器；原本已运行的容器不会被误停。
- **权限要求**：`wll lan on/off` 修改 Windows 防火墙，需要以管理员身份运行；`wll lan status` 可用于只读检查。
- **关闭语义**：`wll lan off` 只关闭局域网入站访问，Docker 容器和本机 `http://127.0.0.1:18765` 保持不变。
- **Docker 宽泛规则**：统一启动器保持 Docker Desktop 宽泛 TCP 入站规则关闭，避免其他 Docker 发布端口绕过来源限制。


### AI 桌面工具协同组合 (Antigravity / IDE / ChatGPT / Cockpit)

统一启动器支持将以下 4 款核心 AI 工具作为独立组合协同管理，既能一键统一启动/关闭，也支持在二级交互面板或 CLI 中单独管理：

| 组件名称 | 启动执行路径 / 方式 | 进程名识别 | 说明 |
|:---|:---|:---|:---|
| **Antigravity** | `C:\Users\Administrator\AppData\Local\Programs\antigravity\Antigravity.exe` | `Antigravity.exe` | 精确匹配进程名，与 IDE 独立管理 |
| **Antigravity IDE** | `D:\APP\AI app\Antigravity\Antigravity IDE\Antigravity IDE.exe` | `Antigravity IDE.exe` | 锁定工作目录启动，支持防重复多开 |
| **ChatGPT** | `shell:AppsFolder\OpenAI.Codex_2p2nqsd0c76g0!App` | `ChatGPT.exe` | Windows Store 官方应用协议激活 |
| **Cockpit** | `D:\APP\AI app\Cockpit\cockpit-tools.exe` | `cockpit-tools.exe` | Explorer 桌面环境激活，保障托盘与 WebView2 稳定 |

#### 常用指令

```powershell
# 组合统一控制
wll start ai-suite    # 一键启动全部 4 个工具
wll stop ai-suite     # 一键关闭全部 4 个工具
wll status ai-suite   # 查看组合组件状态

# 单独启停
wll start antigravity     | wll stop antigravity
wll start antigravity-ide | wll stop antigravity-ide
wll start chatgpt         | wll stop chatgpt
wll start cockpit         | wll stop cockpit
```

#### 控制台体验优化

- **日志输出保留**：移除了主菜单循环自动清屏（`Clear-Host`），控制台历史回滚缓冲区得以完整保留。
- **快捷复制**：操作结束后按 `[C]` 键，一键将最近 30 行执行日志复制到系统剪贴板。
- **划选保护**：划选控制台文本时自动忽略 `Shift`/`Ctrl`/`Alt` 等修饰键，按 `[Enter]` 确认返回主菜单。
- **手动清屏**：支持在菜单输入 `cls` 或 `clear` 随时恢复干净的控制台界面。

## 常见错误及处理

### PowerShell 执行策略限制

**现象**：提示 "无法加载文件，因为在此系统上禁止运行脚本"。

**处理**：
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 找不到 wll 指令

**处理**：确认 `D:\应用研究\统一启动器\System` 已加入用户 PATH（修改后需重新打开终端生效）。

### DeepSeek Harness 启动超时

**现象**：启动后提示 "DeepSeek Harness 启动超时"。

**处理**：
1. 查看 `D:\APP\AI app\deepseek\dsh-web.err.log` 最近日志。
2. 常见原因：端口 9010 被其他程序占用、依赖未安装。
3. 首次启动需联网拉取依赖。

### AI Study Tauri 未找到正式构建版

**现象**：提示 "未找到正式构建版"。

**处理**：进入 `D:\应用研究\AI Study Tauri（AST)` 运行 `build-release.ps1` 或 `build-release.bat` 生成最新正式构建。

### 冠志通 Docker Web 局域网访问

```powershell
# 查看当前状态
wll lan status

# 开启同 Wi‑Fi 访问（需管理员 PowerShell）
wll lan on

# 关闭局域网访问，但不停止容器
wll lan off

# 推荐：一键启动 Docker Web + 开启 LAN（需管理员 PowerShell）
wll start guanzhitong-lan

# 验证结束后的安全关闭：关闭 LAN + 停止容器（需管理员 PowerShell）
wll stop guanzhitong-lan
```

一键启动成功后会同时显示本机地址 `http://127.0.0.1:18765` 和当前 WLAN 地址；关闭命令完成后，预期状态是冠志通专用防火墙规则关闭、目标容器停止、宿主机 `18765` 端口无监听。浏览器已打开的页面不会由关闭命令强制关闭。

开启后，同一 Wi‑Fi 下设备访问当前 WLAN 地址，例如：

```text
http://192.168.0.119:18765
```

如果其他设备仍无法访问，请检查是否连接到了访客网络，以及路由器是否启用了无线客户端隔离。不要直接把 Docker 端口暴露到公网，也不要手工重新启用 Docker Desktop 的宽泛 TCP 入站规则。
