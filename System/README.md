# Workflow Launcher (wll)

管理本机 **AI Study Tauri** 和 **DeepSeek Harness (dsh)** 两个 AI 平台的启动、停止、状态查询和日志查看。

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
```

### 方式二：双击运行

双击 `System\Workflow-Launcher.bat` 即可打开交互式控制台菜单。

### 方式三：命令行参数

```powershell
# 启动
.\Workflow-Launcher.ps1 start dsh
.\Workflow-Launcher.ps1 start aistudy
.\Workflow-Launcher.ps1 start all

# 停止
.\Workflow-Launcher.ps1 stop dsh
.\Workflow-Launcher.ps1 stop aistudy
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
| 4 | 同时启动 | 依次启动 AI Study Tauri 和 DeepSeek Harness |
| 5 | 查看状态 | 显示各平台运行状态 |
| 6 | 停止 AI Study Tauri | 按进程名收口所有 AIstudy.exe 实例 |
| 7 | 停止 DeepSeek Harness | 按端口 9010 + 命令行关键词清理 |
| 8 | 停止全部 | 停止所有平台 |
| E1 | 打开 DeepSeek Harness 网页 | 浏览器打开 http://127.0.0.1:9010 |
| 0 | 退出 | 关闭启动器 |

## 平台访问地址

| 平台 | 地址 |
|------|------|
| AI Study Tauri | 本机桌面应用（最新正式构建版） |
| DeepSeek Harness | http://127.0.0.1:9010 |

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
```

## 启动器行为

- **去重检查**：平台已在运行时不会重复启动。
- **健康检查**：dsh 启动后通过 HTTP 检查 http://127.0.0.1:9010 就绪状态。
- **动态构建**：AI Study Tauri 自动扫描 `.build\cargo-target-latest-*` 目录中最新的正式 EXE。
- **单实例**：AI Study Tauri 启动前自动关闭历史 AIstudy.exe 进程，避免新旧版本并存。
- **自动打开浏览器**：dsh 就绪后自动用 Chrome 打开 Dashboard。
- **安全停止**：dsh 按端口定位进程清理，不误杀其他 node 进程。
- **日志记录**：所有操作写入 `System\logs\launcher.log`，包含时间、操作、命令、结果和错误信息。

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
