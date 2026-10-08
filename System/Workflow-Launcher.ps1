<#
  Workflow Launcher (指令: wll)
  本机统一启动器：管理 AI Study Tauri、DeepSeek Harness (dsh) 与冠志通 Docker Web 的启动、停止、状态与日志。

  用法：
    .\Workflow-Launcher.ps1                  显示交互菜单
    .\Workflow-Launcher.ps1 start dsh        启动 DeepSeek Harness (Web)
    .\Workflow-Launcher.ps1 start aistudy    启动 AI Study Tauri
    .\Workflow-Launcher.ps1 start studypower  启动 StudyPower Web 工作台
    .\Workflow-Launcher.ps1 start web        启动冠志通 Web 工作台
    .\Workflow-Launcher.ps1 start guanzhitong-lan 一键启动冠志通 Docker Web 并开启 Wi‑Fi 局域网访问
    .\Workflow-Launcher.ps1 start compliance 启动合规性判断工作台应用
    .\Workflow-Launcher.ps1 start all        同时启动全部平台
    .\Workflow-Launcher.ps1 stop all         停止全部平台
    .\Workflow-Launcher.ps1 stop guanzhitong-lan 一键关闭局域网访问并停止冠志通 Docker Web
    .\Workflow-Launcher.ps1 status           查看运行状态
    .\Workflow-Launcher.ps1 logs dsh         查看 dsh 运行日志
    .\Workflow-Launcher.ps1 dsh              便捷写法，等价于 start dsh
    .\Workflow-Launcher.ps1 studypower       便捷写法，等价于 start studypower
    .\Workflow-Launcher.ps1 web              便捷写法，等价于 start web
    .\Workflow-Launcher.ps1 guanzhitong-lan   便捷写法，等价于 start guanzhitong-lan
    .\Workflow-Launcher.ps1 compliance       便捷写法，打开合规性判断工作台应用
    .\Workflow-Launcher.ps1 lan on           开启当前 Wi‑Fi 局域网访问
    .\Workflow-Launcher.ps1 lan off          关闭当前 Wi‑Fi 局域网访问
    .\Workflow-Launcher.ps1 lan status       查看 Docker Web 局域网状态
    .\Workflow-Launcher.ps1 start ai-suite   一键启动 AI 桌面协同组合 (Antigravity/IDE/ChatGPT/Cockpit)
    .\Workflow-Launcher.ps1 stop ai-suite    一键关闭 AI 桌面协同组合
    .\Workflow-Launcher.ps1 status ai-suite  查看 AI 桌面协同组合状态
    .\Workflow-Launcher.ps1 start dsh-wsl    启动 DeepSeek Harness WSL 版 (Ubuntu :9011)
    .\Workflow-Launcher.ps1 stop dsh-wsl     停止 DeepSeek Harness WSL 版
    .\Workflow-Launcher.ps1 restart dsh-wsl  重启 DeepSeek Harness WSL 版
    .\Workflow-Launcher.ps1 url dsh-wsl      浏览器打开 DeepSeek Harness WSL 版 (token 地址)
    .\Workflow-Launcher.ps1 start antigravity-wsl         启动 Antigravity WSL 版 (WSLg GUI)
    .\Workflow-Launcher.ps1 restart antigravity-ide-wsl   重启 Antigravity IDE WSL 版
    .\Workflow-Launcher.ps1 stop cockpit-wsl              关闭 Cockpit WSL 版
    .\Workflow-Launcher.ps1 start wsl      一键启动 WSL 专区全部 (dsh + Antigravity 套件)
    .\Workflow-Launcher.ps1 status wsl     查看 WSL 专区状态看板
    .\Workflow-Launcher.ps1 start feishu          一键拉起全套 (根服务 + 飞书双桥接)
    .\Workflow-Launcher.ps1 stop feishu           一键关闭全套 (双桥接 + 核心根服务)
    .\Workflow-Launcher.ps1 restart feishu        一键重启全套服务 (根服务 + 飞书双桥接)
    .\Workflow-Launcher.ps1 status feishu         查看根服务与飞书双机器人综合状态看板
    .\Workflow-Launcher.ps1 url feishu            浏览器打开飞书桥接管理面板 (http://127.0.0.1:7891)
    .\Workflow-Launcher.ps1 logs feishu           查看飞书桥接运行日志
    .\Workflow-Launcher.ps1 feishu                便捷写法，等价于 start feishu
    .\Workflow-Launcher.ps1 start feishu-opencode 快速拉起 OpenCode 2 全套服务 (根服务 + 飞书桥接)
    .\Workflow-Launcher.ps1 stop feishu-opencode  快速关闭 OpenCode 2 飞书服务
    .\Workflow-Launcher.ps1 start feishu-ag       快速拉起 Antigravity 全套服务 (根服务 + 飞书桥接)
    .\Workflow-Launcher.ps1 stop feishu-ag        快速关闭 Antigravity 飞书服务
    .\Workflow-Launcher.ps1 start opencode2-core  单独启动 OpenCode 2 核心根服务 (后台 Web/API 服务)
    .\Workflow-Launcher.ps1 stop opencode2-core   单独关闭 OpenCode 2 核心根服务
    .\Workflow-Launcher.ps1 start ag-core         单独启动 Antigravity 核心根服务 (Remote-Control 守护)
    .\Workflow-Launcher.ps1 stop ag-core          单独关闭 Antigravity 核心根服务
    .\Workflow-Launcher.ps1 pair opencode2        查看 OpenCode 2 Web 配对凭据 (URL/密码)
    .\Workflow-Launcher.ps1 url opencode2         浏览器打开 OpenCode 2 Web 服务 (http://127.0.0.1:49374)
    .\Workflow-Launcher.ps1 start msds       启动 MSDS-Engine Web 工作台
    .\Workflow-Launcher.ps1 start msds-web   启动 MSDS-Engine Web 工作台
    .\Workflow-Launcher.ps1 start msds-api   启动 MSDS-Engine Agent REST API 服务
    .\Workflow-Launcher.ps1 stop msds        停止 MSDS-Engine 全部服务 (Web / API)
    .\Workflow-Launcher.ps1 stop msds-web    停止 MSDS-Engine Web 工作台
    .\Workflow-Launcher.ps1 stop msds-api    停止 MSDS-Engine Agent REST API 服务
    .\Workflow-Launcher.ps1 status msds      查看 MSDS-Engine 运行状态
    .\Workflow-Launcher.ps1 url msds         浏览器打开 MSDS-Engine Web 工作台 (http://127.0.0.1:5173)
    .\Workflow-Launcher.ps1 url msds-api     浏览器打开 MSDS-Engine Agent API 健康检查 (http://127.0.0.1:5174/api/msds/health)
    .\Workflow-Launcher.ps1 logs msds        查看 MSDS-Engine 运行日志
    .\Workflow-Launcher.ps1 msds             便捷写法，等价于 start msds
    .\Workflow-Launcher.ps1 msds-api         便捷写法，等价于 start msds-api
#>

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ============================================================
# 全局配置 — 本机路径、地址、服务名集中定义于此
# ============================================================

# --- 项目根目录 ---
$Script:LauncherRoot = $PSScriptRoot

# --- 日志 ---
$Script:LogFile = Join-Path $LauncherRoot 'logs\launcher.log'

# --- StudyPower Web 工作台配置 ---
$Script:StudyPowerRoot          = 'F:\APP Location\StudyPower'
$Script:StudyPowerPort          = 3100
$Script:StudyPowerUrl           = 'http://127.0.0.1:3100'
$Script:StudyPowerReadyTimeoutSec = 30
$Script:StudyPowerOutLog        = Join-Path $LauncherRoot 'logs\studypower.out.log'
$Script:StudyPowerErrLog        = Join-Path $LauncherRoot 'logs\studypower.err.log'

# --- MSDS-Engine (化学品安全技术说明书智能处理引擎) 配置 ---
$Script:MsdsEngineRoot          = 'F:\App Location\Guanzhi Tong\Skill\MSDS-Engine'
$Script:MsdsEngineWebDir        = Join-Path $Script:MsdsEngineRoot 'web'
$Script:MsdsEngineWebPort       = 5173
$Script:MsdsEngineWebUrl        = 'http://127.0.0.1:5173'
$Script:MsdsEngineApiPort       = 5174
$Script:MsdsEngineApiUrl        = 'http://127.0.0.1:5174/api/msds'
$Script:MsdsEngineHealthUrl     = 'http://127.0.0.1:5174/api/msds/health'
$Script:MsdsEngineReadyTimeoutSec = 30
$Script:MsdsEngineWebOutLog     = Join-Path $LauncherRoot 'logs\msds-engine-web.out.log'
$Script:MsdsEngineWebErrLog     = Join-Path $LauncherRoot 'logs\msds-engine-web.err.log'
$Script:MsdsEngineApiOutLog     = Join-Path $LauncherRoot 'logs\msds-engine-api.out.log'
$Script:MsdsEngineApiErrLog     = Join-Path $LauncherRoot 'logs\msds-engine-api.err.log'

# --- AI Study Tauri 配置 ---
$Script:AIStudyTauriDir = 'D:\应用研究\AI Study Tauri（AST)'

# --- DeepSeek Harness (dsh) 配置 ---
$Script:DshRoot             = 'D:\APP\AI app\deepseek'
# 预编译 CLI：dsh 的发布产物。用它启动避开 tsx 源码即时转译（实测启动 ~95s -> ~4s）。
$Script:DshCliBin           = Join-Path $Script:DshRoot 'apps\cli\lib\bin.js'
# dsh 数据主目录（含 profiles、sessions、settings.yaml 等）
$Script:DshHome             = 'C:\Users\Administrator\.dsh'
$Script:DshPort             = 9010
$Script:DshUrl              = 'http://127.0.0.1:9010'
$Script:DshHealthUrl        = 'http://127.0.0.1:9010'
$Script:DshReadyTimeoutSec  = 60
$Script:DshAutoOpenBrowser  = $true   # 启动成功后自动用浏览器打开 Dashboard
$Script:DshBrowserPath      = 'C:\Program Files\Google\Chrome\Application\chrome.exe'

# --- 冠志通 Docker Web 工作台配置 ---
$Script:GuanZhiDockerCli    = 'D:\APP\Docker\resources\bin\docker.exe'
$Script:DockerDesktopExe    = 'D:\APP\Docker\Docker Desktop.exe'
$Script:DockerEngineReadyTimeoutSec = 90
$Script:GuanZhiDockerContainer = 'guanzhitong-compliance'
$Script:GuanZhiDockerImage  = 'guanzhitong-compliance:20260901'
$Script:GuanZhiContainerPort = 8765
$Script:GuanZhiWebPort      = 18765
$Script:GuanZhiWebUrl       = 'http://127.0.0.1:18765'
$Script:GuanZhiWebReadyTimeoutSec = 30
$Script:GuanZhiComplianceUrl = "$($Script:GuanZhiWebUrl)/?app=compliance-workbench"
$Script:GuanZhiFirewallRuleName = 'Guanzhitong Docker Web WiFi LAN 18765'
$Script:GuanZhiLegacyFirewallRuleName = 'Guanzhitong 合规性判断 8765'

# --- GLaDOS 自动签到配置 ---
$Script:GladosDir               = 'F:\App Location\Glados'
$Script:GladosScript            = Join-Path $Script:GladosDir 'glados.py'
$Script:GladosConfigFile        = Join-Path $Script:GladosDir 'config.json'
$Script:GladosLogFile           = Join-Path $Script:GladosDir 'checkin.log'
$Script:GladosPythonExe         = 'C:\Users\Administrator\AppData\Local\Programs\Python\Python312\python.exe'
$Script:GuanZhiDockerBackendRuleDisplayName = 'Docker Desktop Backend'

# --- AI 桌面工具协同组合 (Antigravity / IDE / ChatGPT / Cockpit) 配置 ---
$Script:AntigravityExe          = Join-Path $env:LOCALAPPDATA 'Programs\antigravity\Antigravity.exe'
$Script:AntigravityAltLauncher  = 'D:\APP\AI app\Antigravity\Antigravity-launcher.cmd'
$Script:AntigravityIdeExe       = 'D:\APP\AI app\Antigravity\Antigravity IDE\Antigravity IDE.exe'
$Script:CockpitExe              = 'D:\APP\AI app\Cockpit\cockpit-tools.exe'
$Script:CockpitDir              = 'D:\APP\AI app\Cockpit'
$Script:ChatGptPackageFamily    = 'OpenAI.Codex_2p2nqsd0c76g0'
$Script:ChatGptAppId            = 'OpenAI.Codex_2p2nqsd0c76g0!App'

# --- WSL 专区 (Ubuntu) 配置：DeepSeek Harness / Antigravity 套件 ---
# 助手脚本位于 WSL 内，通过 `wsl -d Ubuntu -- ~/.local/bin/<helper> <cmd>` 调用（单 token 无引号坑）。
$Script:WslDistro        = 'Ubuntu'
$Script:WslDshHelperPath = '~/.local/bin/dsh-web'   # DeepSeek Harness WSL 助手 (start/stop/restart/status/url)
$Script:WslAgHelperPath  = '~/.local/bin/agw'       # Antigravity WSL 套件助手 (gui/ide/cockpit)
$Script:WslFeishuHelperPath = '~/.local/bin/feishu-bridge' # 飞书双机器人与根服务助手 (OpenCode 2 + Antigravity)
$Script:WslFeishuPort    = 7891
$Script:WslFeishuUrl     = 'http://127.0.0.1:7891'
$Script:WslOpencode2Port = 49374
$Script:WslOpencode2Url  = 'http://127.0.0.1:49374'
$Script:WslDshPort       = 9011
$Script:WslDshUrl        = 'http://127.0.0.1:9011'

# --- 启动后等待 ---
$Script:PostStartWaitSeconds = 5

# ============================================================
# 辅助函数
# ============================================================

function Write-LauncherLog {
    <#
    .SYNOPSIS 向日志文件和控制台输出信息
    #>
    param(
        [Parameter(Mandatory)][string]$Message,
        [ValidateSet('INFO','WARN','ERROR')][string]$Level = 'INFO'
    )
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $entry = "[$timestamp] [$Level] $Message"

    try {
        $logDir = Split-Path $Script:LogFile -Parent
        if (-not (Test-Path $logDir)) {
            New-Item -ItemType Directory -Path $logDir -Force | Out-Null
        }
        Add-Content -Path $Script:LogFile -Value $entry -Encoding UTF8
    } catch {
        # 日志落盘失败（并发调用抢写锁等）绝不中断主流程；控制台已输出该条目
        Write-Host "(日志写入跳过: $($_.Exception.Message))" -ForegroundColor DarkGray
    }

    switch ($Level) {
        'INFO'  { Write-Host $entry -ForegroundColor Cyan }
        'WARN'  { Write-Host $entry -ForegroundColor Yellow }
        'ERROR' { Write-Host $entry -ForegroundColor Red }
    }
}

function Write-Menu {
    <#
    .SYNOPSIS 显示主菜单
    .NOTES 保留控制台历史回滚缓冲区，不在此处调用 Clear-Host 避免抹除历史输出。
    #>
    Write-Host ''
    Write-Host '  ============================================================' -ForegroundColor Cyan
    Write-Host '   Workflow Launcher (AI Study Tauri / DeepSeek Harness)' -ForegroundColor White
    Write-Host '  ============================================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '    [1]  启动 AI Study Tauri 系统 (最新正式构建版)' -ForegroundColor Green
    Write-Host '    [2]  启动 DeepSeek Harness (dsh Web)' -ForegroundColor Green
    Write-Host '    [3]  运行 DeepSeek Harness 一次性任务 (CLI 输入)' -ForegroundColor Green
    Write-Host '    [4]  启动冠志通 Web 工作台' -ForegroundColor Green
    Write-Host '    [5]  同时启动全部平台' -ForegroundColor Green
    Write-Host ''
    Write-Host '    [6]  查看全部运行状态' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '    [7]  停止 AI Study Tauri' -ForegroundColor Red
    Write-Host '    [8]  停止 DeepSeek Harness' -ForegroundColor Red
    Write-Host '    [9]  停止冠志通 Web 工作台' -ForegroundColor Red
    Write-Host '    [10] 停止全部平台' -ForegroundColor Red
    Write-Host ''
    Write-Host '    [11] 开启冠志通 Docker Web Wi‑Fi 局域网访问' -ForegroundColor Green
    Write-Host '    [12] 关闭冠志通 Docker Web Wi‑Fi 局域网访问' -ForegroundColor Red
    Write-Host '    [13] 查看冠志通 Docker Web 局域网状态' -ForegroundColor Yellow
    Write-Host '    [14] 一键启动冠志通 Docker Web + Wi‑Fi 局域网访问' -ForegroundColor Green
    Write-Host '    [15] 一键关闭 LAN 并停止冠志通 Docker Web' -ForegroundColor Red
    Write-Host ''
    Write-Host '    [16] 进入 AI 工具套件组合菜单 (Antigravity / IDE / ChatGPT / Cockpit) >>>' -ForegroundColor Magenta
    $gladosCount = Get-GladosAccountCount
    Write-Host "    [17] GLaDOS 一键自动签到 (执行签到并汇总 $gladosCount 个账号状态)" -ForegroundColor Green
    Write-Host '    [18] 查看 GLaDOS 最新签到历史与账号状态' -ForegroundColor Yellow
    Write-Host '    [19] 进入 WSL 专区菜单 (DeepSeek Harness / Antigravity WSL) >>>' -ForegroundColor DarkCyan
    Write-Host '    [20] 进入飞书机器人与根服务专区 (OpenCode 2 + Antigravity 根服务/桥接/面板) >>>' -ForegroundColor DarkCyan
    Write-Host '    [22] 启动 StudyPower Web 工作台' -ForegroundColor Green
    Write-Host '    [23] 停止 StudyPower Web 工作台' -ForegroundColor Red
    Write-Host '    [24] 进入 MSDS-Engine 智能处理专区 (Web / API / 测试 / 批注) >>>' -ForegroundColor DarkCyan
    Write-Host '    [25] 启动 MSDS-Engine Web 工作台' -ForegroundColor Green
    Write-Host '    [26] 停止 MSDS-Engine 全部服务 (Web / API)' -ForegroundColor Red
    Write-Host ''
    Write-Host '    [E1] 打开 DeepSeek Harness 网页' -ForegroundColor Magenta
    Write-Host ''
    Write-Host '    [CLS] 清屏 (恢复干净控制台界面)' -ForegroundColor DarkGray
    Write-Host '    [0]  退出' -ForegroundColor Gray
    Write-Host ''
    Write-Host '  ============================================================' -ForegroundColor Cyan
    Write-Host ''
}

# ============================================================
# 平台状态
# ============================================================

function Get-DshProcess {
    <#
    .SYNOPSIS 返回持有 127.0.0.1:9010 监听端口的 dsh node 进程（数组，可能为空）
    .NOTES 用一元逗号返回，避免空数组被展开成 $null（StrictMode 下 $null.Count 会抛异常）。
    #>
    $result = @()
    try {
        $listeners = @(Get-NetTCPConnection -LocalAddress '127.0.0.1' -LocalPort $Script:DshPort -State Listen -ErrorAction Stop)
        if ($listeners.Count -gt 0) {
            $ownerPids = @($listeners | Select-Object -ExpandProperty OwningProcess -Unique)
            $result = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.ProcessId -in $ownerPids -and
                    $_.Name -eq 'node.exe' -and
                    ($_.CommandLine -like "*dsh*" -or $_.CommandLine -like "*bin.js*" -or $_.CommandLine -like "*$($Script:DshCliBin)*")
                })
        }
    } catch {}
    return ,$result
}

function Test-DshRunning {
    <#
    .SYNOPSIS 检测 DeepSeek Harness Web 是否正在运行
    .NOTES dsh 首页会保持流式响应，不能用 Invoke-WebRequest 等待响应结束；
           通过固定端口和正式 CLI 入口确认唯一运行实例。
    #>
    return ((Get-DshProcess).Count -gt 0)
}

function Show-DshResultSummary {
    <#
    .SYNOPSIS 打印 DeepSeek Harness 启动/状态结果小结（常驻控制台，不会被浏览器盖掉）
    #>
    # Get-DshProcess 用一元逗号返回数组整体，此处直接赋值（不再套 @()，否则形成嵌套数组）
    $dshProcs = Get-DshProcess
    $dshPids = @($dshProcs | Select-Object -ExpandProperty ProcessId)
    $dashboardUrl = Get-DshDashboardUrl
    $dshOut = Join-Path $Script:DshRoot 'dsh-web.out.log'
    $dshErr = Join-Path $Script:DshRoot 'dsh-web.err.log'
    Write-Host ''
    Write-Host '  ============ DeepSeek Harness 运行结果 ============' -ForegroundColor Cyan
    if ($dshPids.Count -gt 0) {
        Write-Host "  状态: 运行中 (PID: $($dshPids -join ', '), 端口 $($Script:DshPort))" -ForegroundColor Green
    } else {
        Write-Host "  状态: 未运行 (端口 $($Script:DshPort) 无监听)" -ForegroundColor Yellow
    }
    Write-Host "  网页: $dashboardUrl" -ForegroundColor Magenta
    Write-Host "  输出日志: $dshOut" -ForegroundColor Gray
    Write-Host "  错误日志: $dshErr" -ForegroundColor Gray
    Write-Host '  查看日志: wll logs dsh' -ForegroundColor Gray
    Write-Host '  =====================================================' -ForegroundColor Cyan
    Write-Host ''
}

function Get-StudyPowerProcessTree {
    <# 返回 StudyPower 项目上下文中的进程树；不匹配项目路径时不返回进程。 #>
    param([switch]$RequireListener)

    $allProcesses = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)
    if ($allProcesses.Count -eq 0) { return @() }

    $rootPattern = [regex]::Escape($Script:StudyPowerRoot.TrimEnd('\'))
    $contextProcesses = @($allProcesses | Where-Object {
            -not [string]::IsNullOrWhiteSpace([string]$_.CommandLine) -and
            [regex]::IsMatch([string]$_.CommandLine, $rootPattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        })
    if ($contextProcesses.Count -eq 0) { return @() }

    $knownPids = @{}
    foreach ($process in $contextProcesses) { $knownPids[[int]$process.ProcessId] = $true }
    do {
        $changed = $false
        foreach ($process in $allProcesses) {
            $processId = [int]$process.ProcessId
            if (-not $knownPids.ContainsKey($processId) -and $knownPids.ContainsKey([int]$process.ParentProcessId)) {
                $knownPids[$processId] = $true
                $changed = $true
            }
        }
    } while ($changed)

    $tree = @($allProcesses | Where-Object { $knownPids.ContainsKey([int]$_.ProcessId) })
    if ($RequireListener) {
        $listeners = @(Get-NetTCPConnection -LocalPort $Script:StudyPowerPort -State Listen -ErrorAction SilentlyContinue)
        $listenerPids = @($listeners | Select-Object -ExpandProperty OwningProcess)
        if (@($tree | Where-Object { $_.ProcessId -in $listenerPids }).Count -eq 0) { return @() }
    }
    return $tree
}

function Test-StudyPowerRunning {
    <# 只有项目进程占用固定端口且 HTTP 可达时才视为运行中。 #>
    $processes = @(Get-StudyPowerProcessTree -RequireListener)
    if ($processes.Count -eq 0) { return $false }
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri $Script:StudyPowerUrl -TimeoutSec 3 -ErrorAction Stop
        return ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500)
    } catch {
        return $false
    }
}

function Start-StudyPower {
    <# 启动 StudyPower Next.js 生产服务并在就绪后打开浏览器。 #>
    Write-Host ''
    Write-Host '  正在启动 StudyPower Web 工作台 ...' -ForegroundColor Green
    Write-LauncherLog '========== 启动 StudyPower Web 工作台 ==========' -Level INFO

    if (Test-StudyPowerRunning) {
        Write-LauncherLog 'StudyPower 已在运行，跳过重复启动' -Level INFO
        Write-Host "  StudyPower 已在运行中: $($Script:StudyPowerUrl)" -ForegroundColor Green
        Open-PlatformUrl -Name 'StudyPower' -Url $Script:StudyPowerUrl
        return $true
    }
    if (-not (Test-Path -LiteralPath $Script:StudyPowerRoot -PathType Container)) {
        Write-LauncherLog "StudyPower 目录不存在: $($Script:StudyPowerRoot)" -Level ERROR
        Write-Host "  未找到 StudyPower 目录: $($Script:StudyPowerRoot)" -ForegroundColor Red
        return $false
    }
    if (-not (Test-Path -LiteralPath (Join-Path $Script:StudyPowerRoot 'package.json') -PathType Leaf)) {
        Write-LauncherLog "StudyPower package.json 不存在: $($Script:StudyPowerRoot)" -Level ERROR
        Write-Host '  StudyPower 项目缺少 package.json，已停止启动。' -ForegroundColor Red
        return $false
    }

    $listeners = @(Get-NetTCPConnection -LocalPort $Script:StudyPowerPort -State Listen -ErrorAction SilentlyContinue)
    if ($listeners.Count -gt 0) {
        Write-LauncherLog "StudyPower 预期端口已被其他进程占用: $($Script:StudyPowerPort)" -Level ERROR
        Write-Host "  端口 $($Script:StudyPowerPort) 已被非 StudyPower 进程占用，已拒绝启动。" -ForegroundColor Red
        return $false
    }

    $npm = Get-Command npm.cmd -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $npm -or [string]::IsNullOrWhiteSpace($npm.Source)) {
        Write-LauncherLog '未找到 npm.cmd，无法启动 StudyPower' -Level ERROR
        Write-Host '  未找到 npm.cmd，请确认 Node.js/npm 已加入 PATH。' -ForegroundColor Red
        return $false
    }

    Remove-Item -LiteralPath $Script:StudyPowerOutLog, $Script:StudyPowerErrLog -ErrorAction SilentlyContinue
    try {
        Start-Process -FilePath $npm.Source -ArgumentList "run start -- -p $($Script:StudyPowerPort)" `
            -WorkingDirectory $Script:StudyPowerRoot -WindowStyle Hidden `
            -RedirectStandardOutput $Script:StudyPowerOutLog -RedirectStandardError $Script:StudyPowerErrLog
        Write-LauncherLog "StudyPower 后台启动命令已发出: npm run start -- -p $($Script:StudyPowerPort) (工作目录: $($Script:StudyPowerRoot))" -Level INFO
    } catch {
        Write-LauncherLog "启动 StudyPower 异常: $($_.Exception.Message)" -Level ERROR
        Write-Host "  启动失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }

    Write-LauncherLog "等待 StudyPower 就绪 (端口 $($Script:StudyPowerPort))..." -Level INFO
    for ($i = 0; $i -lt $Script:StudyPowerReadyTimeoutSec; $i++) {
        Start-Sleep -Seconds 1
        if (Test-StudyPowerRunning) {
            Write-LauncherLog "StudyPower 启动完成: $($Script:StudyPowerUrl)" -Level INFO
            Write-Host "  StudyPower 已就绪: $($Script:StudyPowerUrl)" -ForegroundColor Green
            Open-PlatformUrl -Name 'StudyPower' -Url $Script:StudyPowerUrl
            return $true
        }
    }

    Write-LauncherLog 'StudyPower 启动超时，请查看 studypower.err.log' -Level ERROR
    Write-Host '  StudyPower 启动超时，请查看启动器 logs\studypower.err.log。' -ForegroundColor Red
    if (Test-Path -LiteralPath $Script:StudyPowerErrLog) {
        Get-Content -LiteralPath $Script:StudyPowerErrLog -Tail 15 -Encoding UTF8 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    }
    return $false
}

function Stop-StudyPower {
    <# 只停止 StudyPower 项目上下文的进程树。 #>
    Write-Host ''
    Write-Host '  正在停止 StudyPower Web 工作台 ...' -ForegroundColor Red
    Write-LauncherLog '========== 停止 StudyPower Web 工作台 ==========' -Level INFO

    $processes = @(Get-StudyPowerProcessTree)
    if ($processes.Count -eq 0) {
        Write-Host '  StudyPower 未在运行。' -ForegroundColor Yellow
        return $true
    }

    $knownPids = @{}
    foreach ($process in $processes) { $knownPids[[int]$process.ProcessId] = $true }
    $roots = @($processes | Where-Object { -not $knownPids.ContainsKey([int]$_.ParentProcessId) })
    try {
        foreach ($process in $roots) {
            $null = & taskkill.exe /PID $process.ProcessId /T /F 2>$null
            Write-LauncherLog "已停止 StudyPower 进程树: PID=$($process.ProcessId)" -Level INFO
        }
        Start-Sleep -Milliseconds 500
        if (@(Get-StudyPowerProcessTree).Count -gt 0) { throw 'StudyPower 进程未完全退出' }
        Write-Host '  StudyPower 已停止。' -ForegroundColor Green
        return $true
    } catch {
        Write-LauncherLog "停止 StudyPower 异常: $($_.Exception.Message)" -Level ERROR
        Write-Host "  停止失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# ============================================================
# MSDS-Engine (化学品安全技术说明书智能处理引擎)
# ============================================================

function Get-MsdsEngineWebProcessTree {
    <# 返回持有 5173 监听端口或在 MSDS-Engine\web 目录下运行的 Vite 进程树 #>
    $listeners = @(Get-NetTCPConnection -LocalPort $Script:MsdsEngineWebPort -State Listen -ErrorAction SilentlyContinue)
    $listenerPids = @($listeners | Select-Object -ExpandProperty OwningProcess -Unique)
    $allProcesses = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)
    if ($allProcesses.Count -eq 0) { return @() }

    $targetPids = @{}
    foreach ($p in $allProcesses) {
        $cmd = [string]$p.CommandLine
        if ($cmd -and $cmd -match 'MSDS-Engine' -and ($cmd -match 'vite' -or $cmd -match 'dev')) {
            $targetPids[[int]$p.ProcessId] = $true
        }
    }
    foreach ($pidNum in $listenerPids) {
        $targetPids[[int]$pidNum] = $true
    }
    if ($targetPids.Count -eq 0) { return @() }

    do {
        $changed = $false
        foreach ($proc in $allProcesses) {
            $procId = [int]$proc.ProcessId
            if (-not $targetPids.ContainsKey($procId) -and $targetPids.ContainsKey([int]$proc.ParentProcessId)) {
                $targetPids[$procId] = $true
                $changed = $true
            }
        }
    } while ($changed)

    return @($allProcesses | Where-Object { $targetPids.ContainsKey([int]$_.ProcessId) })
}

function Get-MsdsEngineApiProcessTree {
    <# 返回持有 5174 监听端口或运行 api-server.mjs 的 API 进程树 #>
    $listeners = @(Get-NetTCPConnection -LocalPort $Script:MsdsEngineApiPort -State Listen -ErrorAction SilentlyContinue)
    $listenerPids = @($listeners | Select-Object -ExpandProperty OwningProcess -Unique)
    $allProcesses = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue)
    if ($allProcesses.Count -eq 0) { return @() }

    $targetPids = @{}
    foreach ($p in $allProcesses) {
        $cmd = [string]$p.CommandLine
        if ($cmd -and $cmd -match 'api-server\.mjs') {
            $targetPids[[int]$p.ProcessId] = $true
        }
    }
    foreach ($pidNum in $listenerPids) {
        $targetPids[[int]$pidNum] = $true
    }
    if ($targetPids.Count -eq 0) { return @() }

    do {
        $changed = $false
        foreach ($proc in $allProcesses) {
            $procId = [int]$proc.ProcessId
            if (-not $targetPids.ContainsKey($procId) -and $targetPids.ContainsKey([int]$proc.ParentProcessId)) {
                $targetPids[$procId] = $true
                $changed = $true
            }
        }
    } while ($changed)

    return @($allProcesses | Where-Object { $targetPids.ContainsKey([int]$_.ProcessId) })
}

function Test-MsdsEngineWebRunning {
    <# 检查 MSDS-Engine Web 工作台是否正常运行 #>
    $listeners = @(Get-NetTCPConnection -LocalPort $Script:MsdsEngineWebPort -State Listen -ErrorAction SilentlyContinue)
    if ($listeners.Count -eq 0) { return $false }
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri $Script:MsdsEngineWebUrl -TimeoutSec 3 -ErrorAction Stop
        return ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500)
    } catch {
        return $false
    }
}

function Test-MsdsEngineApiRunning {
    <# 检查 MSDS-Engine Agent REST API 服务是否正常运行 #>
    $listeners = @(Get-NetTCPConnection -LocalPort $Script:MsdsEngineApiPort -State Listen -ErrorAction SilentlyContinue)
    if ($listeners.Count -eq 0) { return $false }
    try {
        $response = Invoke-RestMethod -Uri $Script:MsdsEngineHealthUrl -TimeoutSec 3 -ErrorAction Stop
        return ($null -ne $response -and $response.success -eq $true)
    } catch {
        return $false
    }
}

function Open-MsdsEngineWeb {
    Open-PlatformUrl -Name 'MSDS-Engine Web 工作台' -Url $Script:MsdsEngineWebUrl
    return $true
}

function Open-MsdsEngineApi {
    Open-PlatformUrl -Name 'MSDS-Engine Agent API 健康检查' -Url $Script:MsdsEngineHealthUrl
    return $true
}

function Start-MsdsEngineWeb {
    <# 启动 MSDS-Engine Web 交互工作台并在就绪后自动打开浏览器 #>
    Write-Host ''
    Write-Host '  正在启动 MSDS-Engine Web 工作台 (Vite) ...' -ForegroundColor Green
    Write-LauncherLog '========== 启动 MSDS-Engine Web 工作台 ==========' -Level INFO

    if (Test-MsdsEngineWebRunning) {
        Write-LauncherLog 'MSDS-Engine Web 已在运行，跳过重复启动' -Level INFO
        Write-Host "  MSDS-Engine Web 工作台已在运行中: $($Script:MsdsEngineWebUrl)" -ForegroundColor Green
        Open-MsdsEngineWeb
        return $true
    }
    if (-not (Test-Path -LiteralPath $Script:MsdsEngineWebDir -PathType Container)) {
        Write-LauncherLog "MSDS-Engine Web 目录不存在: $($Script:MsdsEngineWebDir)" -Level ERROR
        Write-Host "  未找到 MSDS-Engine Web 目录: $($Script:MsdsEngineWebDir)" -ForegroundColor Red
        return $false
    }

    $listeners = @(Get-NetTCPConnection -LocalPort $Script:MsdsEngineWebPort -State Listen -ErrorAction SilentlyContinue)
    if ($listeners.Count -gt 0) {
        Write-LauncherLog "端口 $($Script:MsdsEngineWebPort) 已被其他进程占用" -Level ERROR
        Write-Host "  端口 $($Script:MsdsEngineWebPort) 已被其他进程占用，已停止启动。" -ForegroundColor Red
        return $false
    }

    $npm = Get-Command npm.cmd -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $npm -or [string]::IsNullOrWhiteSpace($npm.Source)) {
        Write-LauncherLog '未找到 npm.cmd，无法启动 MSDS-Engine' -Level ERROR
        Write-Host '  未找到 npm.cmd，请确认 Node.js/npm 已加入 PATH。' -ForegroundColor Red
        return $false
    }

    Remove-Item -LiteralPath $Script:MsdsEngineWebOutLog, $Script:MsdsEngineWebErrLog -ErrorAction SilentlyContinue
    try {
        $cmdLine = "cmd.exe /c `"npm.cmd run dev -- --host 127.0.0.1 > `"$Script:MsdsEngineWebOutLog`" 2> `"$Script:MsdsEngineWebErrLog`"`""
        $wmiRes = ([wmiclass]'Win32_Process').Create($cmdLine, $Script:MsdsEngineWebDir, $null)
        if ($null -eq $wmiRes -or $wmiRes.ReturnValue -ne 0) {
            Start-Process -FilePath 'cmd.exe' -ArgumentList "/c `"$cmdLine`"" `
                -WorkingDirectory $Script:MsdsEngineWebDir -WindowStyle Hidden
        }
        Write-LauncherLog "MSDS-Engine Web 后台启动命令已发出: npm run dev -- --host 127.0.0.1" -Level INFO
    } catch {
        Write-LauncherLog "启动 MSDS-Engine Web 异常: $($_.Exception.Message)" -Level ERROR
        Write-Host "  启动失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }

    Write-LauncherLog "等待 MSDS-Engine Web 就绪 (端口 $($Script:MsdsEngineWebPort))..." -Level INFO
    for ($i = 0; $i -lt $Script:MsdsEngineReadyTimeoutSec; $i++) {
        Start-Sleep -Seconds 1
        if (Test-MsdsEngineWebRunning) {
            Write-LauncherLog "MSDS-Engine Web 启动完成: $($Script:MsdsEngineWebUrl)" -Level INFO
            Write-Host "  MSDS-Engine Web 工作台已就绪: $($Script:MsdsEngineWebUrl)" -ForegroundColor Green
            Open-MsdsEngineWeb
            return $true
        }
    }

    Write-LauncherLog 'MSDS-Engine Web 启动超时，请查看 msds-engine-web.err.log' -Level ERROR
    Write-Host '  MSDS-Engine Web 启动超时，请查看 logs\msds-engine-web.err.log。' -ForegroundColor Red
    if (Test-Path -LiteralPath $Script:MsdsEngineWebErrLog) {
        Get-Content -LiteralPath $Script:MsdsEngineWebErrLog -Tail 15 -Encoding UTF8 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    }
    return $false
}

function Stop-MsdsEngineWeb {
    <# 停止 MSDS-Engine Web 工作台 #>
    Write-Host ''
    Write-Host '  正在停止 MSDS-Engine Web 工作台 ...' -ForegroundColor Red
    Write-LauncherLog '========== 停止 MSDS-Engine Web 工作台 ==========' -Level INFO

    $processes = @(Get-MsdsEngineWebProcessTree)
    if ($processes.Count -eq 0) {
        Write-Host '  MSDS-Engine Web 工作台未在运行。' -ForegroundColor Yellow
        return $true
    }

    $knownPids = @{}
    foreach ($process in $processes) { $knownPids[[int]$process.ProcessId] = $true }
    $roots = @($processes | Where-Object { -not $knownPids.ContainsKey([int]$_.ParentProcessId) })
    try {
        foreach ($process in $roots) {
            $null = & taskkill.exe /PID $process.ProcessId /T /F 2>$null
            Write-LauncherLog "已停止 MSDS-Engine Web 进程树: PID=$($process.ProcessId)" -Level INFO
        }
        Start-Sleep -Milliseconds 500
        Write-Host '  MSDS-Engine Web 工作台已停止。' -ForegroundColor Green
        return $true
    } catch {
        Write-LauncherLog "停止 MSDS-Engine Web 异常: $($_.Exception.Message)" -Level ERROR
        Write-Host "  停止失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Start-MsdsEngineApi {
    <# 启动 MSDS-Engine Agent REST API 独立服务 #>
    Write-Host ''
    Write-Host '  正在启动 MSDS-Engine Agent REST API 独立服务 ...' -ForegroundColor Green
    Write-LauncherLog '========== 启动 MSDS-Engine Agent API 服务 ==========' -Level INFO

    if (Test-MsdsEngineApiRunning) {
        Write-LauncherLog 'MSDS-Engine API 服务已在运行，跳过重复启动' -Level INFO
        Write-Host "  MSDS-Engine Agent API 服务已在运行中: $($Script:MsdsEngineApiUrl)" -ForegroundColor Green
        Open-MsdsEngineApi
        return $true
    }
    if (-not (Test-Path -LiteralPath (Join-Path $Script:MsdsEngineWebDir 'src\api-server.mjs') -PathType Leaf)) {
        Write-LauncherLog "未找到 api-server.mjs 入口文件" -Level ERROR
        Write-Host "  未找到 MSDS-Engine API 入口文件: src\api-server.mjs" -ForegroundColor Red
        return $false
    }

    $listeners = @(Get-NetTCPConnection -LocalPort $Script:MsdsEngineApiPort -State Listen -ErrorAction SilentlyContinue)
    if ($listeners.Count -gt 0) {
        Write-LauncherLog "端口 $($Script:MsdsEngineApiPort) 已被其他进程占用" -Level ERROR
        Write-Host "  端口 $($Script:MsdsEngineApiPort) 已被其他进程占用，已停止启动。" -ForegroundColor Red
        return $false
    }

    $node = Get-Command node.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -eq $node -or [string]::IsNullOrWhiteSpace($node.Source)) {
        Write-LauncherLog '未找到 node.exe，无法启动 API 服务' -Level ERROR
        Write-Host '  未找到 node.exe，请确认 Node.js 已安装并加入 PATH。' -ForegroundColor Red
        return $false
    }

    Remove-Item -LiteralPath $Script:MsdsEngineApiOutLog, $Script:MsdsEngineApiErrLog -ErrorAction SilentlyContinue
    try {
        $cmdLine = "cmd.exe /c `"node.exe src/api-server.mjs > `"$Script:MsdsEngineApiOutLog`" 2> `"$Script:MsdsEngineApiErrLog`"`""
        $wmiRes = ([wmiclass]'Win32_Process').Create($cmdLine, $Script:MsdsEngineWebDir, $null)
        if ($null -eq $wmiRes -or $wmiRes.ReturnValue -ne 0) {
            Start-Process -FilePath 'cmd.exe' -ArgumentList "/c `"$cmdLine`"" `
                -WorkingDirectory $Script:MsdsEngineWebDir -WindowStyle Hidden
        }
        Write-LauncherLog "MSDS-Engine API 后台启动命令已发出: node src/api-server.mjs" -Level INFO
    } catch {
        Write-LauncherLog "启动 MSDS-Engine API 异常: $($_.Exception.Message)" -Level ERROR
        Write-Host "  启动失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }

    Write-LauncherLog "等待 MSDS-Engine API 就绪 (端口 $($Script:MsdsEngineApiPort))..." -Level INFO
    for ($i = 0; $i -lt $Script:MsdsEngineReadyTimeoutSec; $i++) {
        Start-Sleep -Seconds 1
        if (Test-MsdsEngineApiRunning) {
            Write-LauncherLog "MSDS-Engine API 启动完成: $($Script:MsdsEngineApiUrl)" -Level INFO
            Write-Host "  MSDS-Engine Agent API 服务已就绪: $($Script:MsdsEngineApiUrl)" -ForegroundColor Green
            Open-MsdsEngineApi
            return $true
        }
    }

    Write-LauncherLog 'MSDS-Engine API 启动超时，请查看 msds-engine-api.err.log' -Level ERROR
    Write-Host '  MSDS-Engine API 启动超时，请查看 logs\msds-engine-api.err.log。' -ForegroundColor Red
    if (Test-Path -LiteralPath $Script:MsdsEngineApiErrLog) {
        Get-Content -LiteralPath $Script:MsdsEngineApiErrLog -Tail 15 -Encoding UTF8 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
    }
    return $false
}

function Stop-MsdsEngineApi {
    <# 停止 MSDS-Engine Agent REST API 独立服务 #>
    Write-Host ''
    Write-Host '  正在停止 MSDS-Engine Agent REST API 独立服务 ...' -ForegroundColor Red
    Write-LauncherLog '========== 停止 MSDS-Engine Agent API 服务 ==========' -Level INFO

    $processes = @(Get-MsdsEngineApiProcessTree)
    if ($processes.Count -eq 0) {
        Write-Host '  MSDS-Engine Agent API 服务未在运行。' -ForegroundColor Yellow
        return $true
    }

    $knownPids = @{}
    foreach ($process in $processes) { $knownPids[[int]$process.ProcessId] = $true }
    $roots = @($processes | Where-Object { -not $knownPids.ContainsKey([int]$_.ParentProcessId) })
    try {
        foreach ($process in $roots) {
            $null = & taskkill.exe /PID $process.ProcessId /T /F 2>$null
            Write-LauncherLog "已停止 MSDS-Engine API 进程树: PID=$($process.ProcessId)" -Level INFO
        }
        Start-Sleep -Milliseconds 500
        Write-Host '  MSDS-Engine Agent API 服务已停止。' -ForegroundColor Green
        return $true
    } catch {
        Write-LauncherLog "停止 MSDS-Engine API 异常: $($_.Exception.Message)" -Level ERROR
        Write-Host "  停止失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Stop-MsdsEngineAll {
    <# 停止 MSDS-Engine 全部服务 (Web + API) #>
    $stopWeb = Stop-MsdsEngineWeb
    $stopApi = Stop-MsdsEngineApi
    return ($stopWeb -and $stopApi)
}

function Show-MsdsEngineSummary {
    <# 显示 MSDS-Engine 状态汇总 #>
    Write-Host '  ------ MSDS-Engine (化学品说明书智能引擎) 状态 ------' -ForegroundColor Cyan
    $webRunning = Test-MsdsEngineWebRunning
    $apiRunning = Test-MsdsEngineApiRunning

    if ($webRunning) {
        Write-Host "  Web 交互工作台: 运行中 ($($Script:MsdsEngineWebUrl))" -ForegroundColor Green
    } else {
        Write-Host '  Web 交互工作台: 未运行' -ForegroundColor Yellow
    }

    if ($apiRunning) {
        Write-Host "  Agent REST API : 运行中 ($($Script:MsdsEngineApiUrl))" -ForegroundColor Green
    } else {
        Write-Host '  Agent REST API : 未运行' -ForegroundColor Yellow
    }
    Write-Host "  项目物理根路径: $($Script:MsdsEngineRoot)" -ForegroundColor DarkGray
}

function Show-MsdsEngineLogs {
    <# 显示 MSDS-Engine 最新日志 #>
    Write-Host ''
    Write-Host '  --- msds-engine-web.out.log (最近 20 行) ---' -ForegroundColor Cyan
    if (Test-Path $Script:MsdsEngineWebOutLog) { Get-Content -LiteralPath $Script:MsdsEngineWebOutLog -Tail 20 -Encoding UTF8 } else { Write-Host '  (暂无 Web 输出日志)' }
    Write-Host ''
    Write-Host '  --- msds-engine-web.err.log (最近 20 行) ---' -ForegroundColor Cyan
    if (Test-Path $Script:MsdsEngineWebErrLog) { Get-Content -LiteralPath $Script:MsdsEngineWebErrLog -Tail 20 -Encoding UTF8 } else { Write-Host '  (暂无 Web 错误日志)' }
    Write-Host ''
    Write-Host '  --- msds-engine-api.out.log (最近 20 行) ---' -ForegroundColor Cyan
    if (Test-Path $Script:MsdsEngineApiOutLog) { Get-Content -LiteralPath $Script:MsdsEngineApiOutLog -Tail 20 -Encoding UTF8 } else { Write-Host '  (暂无 API 输出日志)' }
    Write-Host ''
    Write-Host '  --- msds-engine-api.err.log (最近 20 行) ---' -ForegroundColor Cyan
    if (Test-Path $Script:MsdsEngineApiErrLog) { Get-Content -LiteralPath $Script:MsdsEngineApiErrLog -Tail 20 -Encoding UTF8 } else { Write-Host '  (暂无 API 错误日志)' }
    Write-Host ''
}

function Show-MsdsEngineMenu {
    <# MSDS-Engine 专用交互式二级菜单 #>
    Write-LauncherLog '进入 MSDS-Engine 二级菜单' -Level INFO
    $inMsdsMenu = $true
    while ($inMsdsMenu) {
        $webRunning = Test-MsdsEngineWebRunning
        $apiRunning = Test-MsdsEngineApiRunning

        Write-Host ''
        Write-Host '  ============================================================' -ForegroundColor DarkCyan
        Write-Host '   MSDS-Engine (化学品安全技术说明书智能处理引擎) 专区' -ForegroundColor White
        Write-Host '  ============================================================' -ForegroundColor DarkCyan
        Write-Host ''
        Write-Host '   【当前组件运行状态】' -ForegroundColor Cyan
        Write-Host "     1. Web 交互工作台 (Vite):   $(if ($webRunning) { '[√] 运行中 (' + $Script:MsdsEngineWebUrl + ')' } else { '[x] 未运行' })" -ForegroundColor $(if ($webRunning) { 'Green' } else { 'DarkGray' })
        Write-Host "     2. Agent REST API 服务:     $(if ($apiRunning) { '[√] 运行中 (' + $Script:MsdsEngineApiUrl + ')' } else { '[x] 未运行' })" -ForegroundColor $(if ($apiRunning) { 'Green' } else { 'DarkGray' })
        Write-Host ''
        Write-Host '   【快捷启动】' -ForegroundColor Green
        Write-Host '    [1]  启动 Web 交互工作台 (自动打开浏览器 127.0.0.1:5173)' -ForegroundColor Green
        Write-Host '    [2]  启动 Agent REST API 独立无头服务 (127.0.0.1:5174)' -ForegroundColor Green
        Write-Host '    [3]  一键全部启动 (Web + API 独立服务)' -ForegroundColor Green
        Write-Host ''
        Write-Host '   【服务关闭】' -ForegroundColor Red
        Write-Host '    [4]  停止 Web 交互工作台' -ForegroundColor Red
        Write-Host '    [5]  停止 Agent REST API 独立服务' -ForegroundColor Red
        Write-Host '    [6]  一键全部停止 (关闭 Web 与 API 服务)' -ForegroundColor Red
        Write-Host ''
        Write-Host '   【浏览与测试工具】' -ForegroundColor Yellow
        Write-Host '    [7]  在浏览器中打开 Web 交互工作台' -ForegroundColor Magenta
        Write-Host '    [8]  在浏览器中打开 Agent API 健康检查' -ForegroundColor Magenta
        Write-Host '    [9]  执行核心冒烟与测试套件 (npm run test:smoke)' -ForegroundColor Cyan
        Write-Host '    [10] 在 VS Code 中打开 MSDS-Engine 工程' -ForegroundColor Cyan
        Write-Host '    [11] 查看 MSDS-Engine 运行日志' -ForegroundColor DarkGray
        Write-Host ''
        Write-Host '    [R]   刷新当前状态' -ForegroundColor Cyan
        Write-Host '    [CLS] 清屏' -ForegroundColor DarkGray
        Write-Host '    [0]   返回统一启动器主菜单' -ForegroundColor Gray
        Write-Host '  ============================================================' -ForegroundColor DarkCyan
        Write-Host ''

        $subChoice = Read-Host '  请选择 MSDS-Engine 操作 [0-11, R, CLS]'
        if ([string]::IsNullOrWhiteSpace($subChoice)) { continue }
        $subKey = $subChoice.Trim().ToLowerInvariant()

        switch ($subKey) {
            '1' { $null = Start-MsdsEngineWeb }
            '2' { $null = Start-MsdsEngineApi }
            '3' {
                $null = Start-MsdsEngineWeb
                $null = Start-MsdsEngineApi
            }
            '4' { $null = Stop-MsdsEngineWeb }
            '5' { $null = Stop-MsdsEngineApi }
            '6' { $null = Stop-MsdsEngineAll }
            '7' { $null = Open-MsdsEngineWeb }
            '8' { $null = Open-MsdsEngineApi }
            '9' {
                Write-Host ''
                Write-Host '  正在执行 MSDS-Engine 自动化测试套件 ...' -ForegroundColor Cyan
                $npm = Get-Command npm.cmd -ErrorAction SilentlyContinue | Select-Object -First 1
                if ($npm) {
                    & $npm.Source --prefix $Script:MsdsEngineWebDir run test:smoke
                }
            }
            '10' {
                Write-Host ''
                Write-Host "  正在使用 VS Code 打开: $($Script:MsdsEngineRoot)" -ForegroundColor Cyan
                code $Script:MsdsEngineRoot
            }
            '11' {
                Show-MsdsEngineLogs
            }
            'r' { continue }
            'cls' { Clear-Host; continue }
            'clear' { Clear-Host; continue }
            '0' {
                Write-Host '  已返回统一启动器主菜单。' -ForegroundColor Gray
                $inMsdsMenu = $false
                break
            }
            default {
                Write-Host '  无效选项，请重新输入。' -ForegroundColor Yellow
            }
        }
        if ($inMsdsMenu -and $subKey -notin @('r', 'cls', 'clear')) {
            Wait-ActionPause -PromptText '操作执行完毕。按 [Enter] 键返回 MSDS 专区菜单...'
        }
    }
}

function Get-AIStudyProcesses {
    <#
    .SYNOPSIS 返回本机所有 AIstudy.exe 进程（始终为数组）
    #>
    return ,@(Get-CimInstance Win32_Process -Filter "Name = 'AIstudy.exe'" -ErrorAction SilentlyContinue)
}

function Get-GuanZhiDockerCli {
    <# 返回唯一 Docker CLI 路径，不创建或复制任何 Docker 对象。 #>
    if (Test-Path -LiteralPath $Script:GuanZhiDockerCli -PathType Leaf) {
        return $Script:GuanZhiDockerCli
    }
    $command = Get-Command docker.exe -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($null -ne $command -and -not [string]::IsNullOrWhiteSpace($command.Source)) {
        return $command.Source
    }
    return $null
}

function Get-DockerDesktopExe {
    <# 返回 Docker Desktop 启动程序路径 #>
    if (Test-Path -LiteralPath $Script:DockerDesktopExe -PathType Leaf) {
        return $Script:DockerDesktopExe
    }
    $candidates = @(
        'D:\APP\Docker\Docker Desktop.exe',
        'C:\Program Files\Docker\Docker\Docker Desktop.exe',
        (Join-Path $env:ProgramFiles 'Docker\Docker\Docker Desktop.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Docker\Docker\Docker Desktop.exe')
    )
    foreach ($p in $candidates) {
        if (Test-Path -LiteralPath $p -PathType Leaf) {
            return $p
        }
    }
    $shortcut = 'C:\Users\Administrator\Desktop\Docker Desktop.lnk'
    if (Test-Path -LiteralPath $shortcut -PathType Leaf) {
        try {
            $ws = New-Object -ComObject WScript.Shell
            $target = $ws.CreateShortcut($shortcut).TargetPath
            if (Test-Path -LiteralPath $target -PathType Leaf) {
                return $target
            }
        } catch {}
    }
    return $null
}

function Ensure-GuanZhiDockerEngineRunning {
    <# 确保 Docker 引擎正在运行；若未运行则自动拉起 Docker Desktop 并等待就绪 #>
    param([Parameter(Mandatory)][string]$DockerCli)
    if (Test-GuanZhiDockerAvailable -DockerCli $dockerCli) {
        return $true
    }
    $desktopExe = Get-DockerDesktopExe
    if ($null -eq $desktopExe -or -not (Test-Path -LiteralPath $desktopExe -PathType Leaf)) {
        Write-LauncherLog 'Docker 引擎未就绪且未找到 Docker Desktop 启动程序' -Level WARN
        return $false
    }
    Write-Host ''
    Write-Host '  检测到 Docker 引擎未运行，正在自动拉起 Docker Desktop，请稍候 ...' -ForegroundColor Yellow
    Write-LauncherLog "Docker 引擎不可用，正在自动拉起 Docker Desktop: $desktopExe" -Level INFO
    try {
        Start-Process -FilePath $desktopExe
    } catch {
        Write-LauncherLog "启动 Docker Desktop 进程失败: $($_.Exception.Message)" -Level ERROR
        return $false
    }

    $timeout = $Script:DockerEngineReadyTimeoutSec
    Write-Host "  正在等待 Docker 引擎初始化就绪（上限 ${timeout} 秒）..." -ForegroundColor Cyan
    for ($i = 1; $i -le $timeout; $i++) {
        Start-Sleep -Seconds 1
        if (Test-GuanZhiDockerAvailable -DockerCli $dockerCli) {
            Write-Host "  Docker 引擎已成功就绪！（耗时 $i 秒）" -ForegroundColor Green
            Write-LauncherLog "Docker 引擎已就绪，耗时 $i 秒" -Level INFO
            return $true
        }
        if ($i % 5 -eq 0) {
            Write-Host "  等待 Docker 引擎就绪中... ($i/${timeout}s)" -ForegroundColor Gray
        }
    }
    Write-LauncherLog "等待 Docker 引擎就绪超时（${timeout} 秒）" -Level ERROR
    Write-Host "  等待 Docker 引擎就绪超时（${timeout} 秒），请检查 Docker Desktop 是否启动异常。" -ForegroundColor Red
    return $false
}

function Get-GuanZhiDockerState {
    param([Parameter(Mandatory)][string]$DockerCli)
    $format = '{{json .State}}|{{json .Config.Image}}|{{json .NetworkSettings.Ports}}'
    try {
        $raw = (& $DockerCli inspect --format $format $Script:GuanZhiDockerContainer 2>$null | Out-String).Trim()
        if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($raw)) {
            return [pscustomobject]@{ Exists = $false; Error = '目标 Docker 容器不存在或无法 inspect。' }
        }
        $parts = $raw -split '\|', 3
        $state = $parts[0] | ConvertFrom-Json
        $image = $parts[1] | ConvertFrom-Json
        $ports = $parts[2] | ConvertFrom-Json
        $health = 'none'
        if ($null -ne $state.Health -and $state.Health.Status) { $health = [string]$state.Health.Status }
        $portProperty = @($ports.PSObject.Properties | Where-Object { $_.Name -eq "$($Script:GuanZhiContainerPort)/tcp" }) | Select-Object -First 1
        $bindings = @()
        if ($null -ne $portProperty) { $bindings = @($portProperty.Value | Where-Object { $null -ne $_ }) }
        $validBindings = @($bindings | Where-Object {
                ([string]$_.HostPort -eq [string]$Script:GuanZhiWebPort) -and
                ([string]$_.HostIp -eq '0.0.0.0' -or [string]$_.HostIp -eq '::' -or [string]::IsNullOrWhiteSpace([string]$_.HostIp))
            })
        return [pscustomobject]@{
            Exists            = $true
            Running           = [bool]$state.Running
            Status            = [string]$state.Status
            Health            = $health
            Image             = [string]$image
            PortBindings      = $bindings
            PortMappingValid  = ($validBindings.Count -gt 0)
            Ready             = ([bool]$state.Running -and $health -eq 'healthy' -and $validBindings.Count -gt 0)
            Error             = $null
        }
    } catch {
        return [pscustomobject]@{ Exists = $false; Error = "读取 Docker 容器状态失败: $($_.Exception.Message)" }
    }
}

function Test-GuanZhiDockerAvailable {
    param([Parameter(Mandatory)][string]$DockerCli)
    try {
        $null = & $DockerCli version --format '{{.Server.Version}}' 2>$null
        return ($LASTEXITCODE -eq 0)
    } catch {
        return $false
    }
}

function Test-GuanZhiWebRunning {
    param([switch]$Quiet)
    $dockerCli = Get-GuanZhiDockerCli
    if ($null -eq $dockerCli -or -not (Test-GuanZhiDockerAvailable -DockerCli $dockerCli)) { return $false }
    $state = Get-GuanZhiDockerState -DockerCli $dockerCli
    if (-not $state.Ready) { return $false }
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri $Script:GuanZhiWebUrl -TimeoutSec 3 -ErrorAction Stop
        return ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500)
    } catch {
        return $false
    }
}

function Test-GuanZhiWebPortListening {
    try {
        $listeners = @(Get-NetTCPConnection -LocalPort $Script:GuanZhiWebPort -State Listen -ErrorAction Stop)
        return ($listeners.Count -gt 0)
    } catch {
        return $false
    }
}

function Get-GuanZhiWlanInfo {
    <# 只返回唯一活跃 Private WLAN 的 IPv4 CIDR；无法唯一识别时失败关闭。 #>
    try {
        $profiles = @(Get-NetConnectionProfile -ErrorAction Stop | Where-Object {
                $_.NetworkCategory -eq 'Private' -and $_.IPv4Connectivity -ne 'NoTraffic'
            })
        $preferred = @($profiles | Where-Object {
                $_.InterfaceAlias -eq 'WLAN' -or $_.InterfaceAlias -match 'Wi-?Fi|无线|WLAN'
            })
        if ($preferred.Count -gt 0) { $profiles = $preferred }
        $candidates = @()
        foreach ($profile in $profiles) {
            $adapter = Get-NetAdapter -InterfaceIndex $profile.InterfaceIndex -ErrorAction SilentlyContinue
            if ($null -eq $adapter -or $adapter.Status -ne 'Up') { continue }
            if ($profile.InterfaceAlias -match 'vEthernet|Loopback|FlClash|Docker|WSL|VPN|虚拟') { continue }
            $ip = @(Get-NetIPAddress -InterfaceIndex $profile.InterfaceIndex -AddressFamily IPv4 -ErrorAction SilentlyContinue |
                    Where-Object { $_.AddressState -eq 'Preferred' -and $_.IPAddress -notlike '127.*' } | Select-Object -First 1)
            $gateway = @(Get-NetRoute -InterfaceIndex $profile.InterfaceIndex -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue | Select-Object -First 1)
            if ($ip.Count -ne 1 -or $gateway.Count -ne 1) { continue }
            $prefix = [int]$ip[0].PrefixLength
            if ($prefix -lt 1 -or $prefix -gt 32) { continue }
            $ipBytes = ([System.Net.IPAddress]::Parse([string]$ip[0].IPAddress)).GetAddressBytes()
            [byte[]]$networkBytes = New-Object byte[] 4
            [byte[]]$maskBytes = New-Object byte[] 4
            for ($i = 0; $i -lt 4; $i++) {
                $remaining = $prefix - ($i * 8)
                if ($remaining -ge 8) { $mask = 255 }
                elseif ($remaining -le 0) { $mask = 0 }
                else { $mask = [int](256 - [math]::Pow(2, 8 - $remaining)) }
                $maskBytes[$i] = [byte]$mask
                $networkBytes[$i] = [byte]($ipBytes[$i] -band $mask)
            }
            $candidates += [pscustomobject]@{
                InterfaceAlias = [string]$profile.InterfaceAlias
                InterfaceIndex = [int]$profile.InterfaceIndex
                NetworkName     = [string]$profile.Name
                NetworkCategory = [string]$profile.NetworkCategory
                IPAddress       = [string]$ip[0].IPAddress
                PrefixLength    = $prefix
                NetworkCidr     = (($networkBytes -join '.') + "/$prefix")
                NetworkMaskCidr = (($networkBytes -join '.') + '/' + ($maskBytes -join '.'))
            }
        }
        if ($candidates.Count -ne 1) { return $null }
        return $candidates[0]
    } catch {
        return $null
    }
}

function Test-GuanZhiAdministrator {
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
        $principal = New-Object Security.Principal.WindowsPrincipal($identity)
        return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    } catch {
        return $false
    }
}

function Get-GuanZhiFirewallRules {
    $rules = @()
    $rules += @(Get-NetFirewallRule -DisplayName $Script:GuanZhiFirewallRuleName -ErrorAction SilentlyContinue)
    $rules += @(Get-NetFirewallRule -DisplayName $Script:GuanZhiLegacyFirewallRuleName -ErrorAction SilentlyContinue)
    return @($rules | Group-Object Name | ForEach-Object { $_.Group[0] })
}

function Get-GuanZhiDockerBackendTcpRules {
    $rules = @(Get-NetFirewallRule -DisplayName $Script:GuanZhiDockerBackendRuleDisplayName -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -like 'TCP*' })
    $result = @()
    foreach ($rule in $rules) {
        $portFilter = $rule | Get-NetFirewallPortFilter -ErrorAction SilentlyContinue
        if ($null -ne $portFilter -and [string]$portFilter.Protocol -eq 'TCP') { $result += $rule }
    }
    return $result
}

function Disable-GuanZhiDockerBackendWideRule {
    try {
        $rules = @(Get-GuanZhiDockerBackendTcpRules)
        foreach ($rule in $rules) {
            if ($rule.Enabled -eq 'True' -or $rule.Enabled -eq $true) {
                Set-NetFirewallRule -Name $rule.Name -Enabled False -ErrorAction Stop
                Write-LauncherLog "已禁用 Docker Desktop 宽泛 TCP 入站规则: $($rule.Name)" -Level INFO
            }
        }
        return $true
    } catch {
        Write-LauncherLog "无法禁用 Docker Desktop 宽泛 TCP 入站规则: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Set-GuanZhiFirewallRule {
    param(
        [Parameter(Mandatory)][string]$RemoteCidr,
        [Parameter(Mandatory)][bool]$Enabled
    )
    $rules = @(Get-GuanZhiFirewallRules)
    if ($rules.Count -gt 1) { throw '发现多个同名冠志通防火墙规则，已拒绝继续以避免规则歧义。' }
    $rule = $null
    if ($rules.Count -eq 1) {
        $rule = $rules[0]
    } else {
        $null = New-NetFirewallRule -DisplayName $Script:GuanZhiFirewallRuleName -Direction Inbound -Action Allow `
            -Enabled False -Profile Private -Protocol TCP -LocalPort $Script:GuanZhiWebPort `
            -RemoteAddress $RemoteCidr -Description '仅允许当前 Private WiFi 子网访问 Guanzhitong Docker Web' -ErrorAction Stop
        $rule = Get-NetFirewallRule -DisplayName $Script:GuanZhiFirewallRuleName -ErrorAction Stop
    }
    $enabledValue = if ($Enabled) { 'True' } else { 'False' }
    Set-NetFirewallRule -Name $rule.Name -Enabled $enabledValue -Direction Inbound -Action Allow -Profile Private -ErrorAction Stop
    $portFilter = $rule | Get-NetFirewallPortFilter -ErrorAction Stop
    Set-NetFirewallPortFilter -InputObject $portFilter -Protocol TCP -LocalPort $Script:GuanZhiWebPort -RemotePort Any -ErrorAction Stop | Out-Null
    $addressFilter = $rule | Get-NetFirewallAddressFilter -ErrorAction Stop
    Set-NetFirewallAddressFilter -InputObject $addressFilter -LocalAddress Any -RemoteAddress $RemoteCidr -ErrorAction Stop | Out-Null
    return (Get-NetFirewallRule -Name $rule.Name -ErrorAction Stop)
}

function Get-GuanZhiFirewallState {
    $rules = @(Get-GuanZhiFirewallRules)
    $backendRules = @(Get-GuanZhiDockerBackendTcpRules)
    $rule = if ($rules.Count -eq 1) { $rules[0] } else { $null }
    $port = $null
    $address = $null
    if ($null -ne $rule) {
        $port = $rule | Get-NetFirewallPortFilter -ErrorAction SilentlyContinue
        $address = $rule | Get-NetFirewallAddressFilter -ErrorAction SilentlyContinue
    }
    return [pscustomobject]@{
        RuleCount       = $rules.Count
        Rule            = $rule
        Enabled         = ($null -ne $rule -and ($rule.Enabled -eq 'True' -or $rule.Enabled -eq $true))
        Profile         = if ($null -ne $rule) { [string]$rule.Profile } else { '' }
        Protocol        = if ($null -ne $port) { [string]$port.Protocol } else { '' }
        LocalPort       = if ($null -ne $port) { [string]$port.LocalPort } else { '' }
        RemoteAddress   = if ($null -ne $address) { [string]($address.RemoteAddress -join ',') } else { '' }
        BackendRuleCount = $backendRules.Count
        BackendEnabled  = (@($backendRules | Where-Object { $_.Enabled -eq 'True' -or $_.Enabled -eq $true }).Count -gt 0)
    }
}

function Test-GuanZhiLanRuleEnabled {
    param(
        [Parameter(Mandatory)][AllowNull()][object]$Wlan,
        [Parameter(Mandatory)][object]$Firewall
    )
    if ($null -eq $Wlan -or $Firewall.RuleCount -ne 1 -or -not $Firewall.Enabled -or
        $Firewall.Profile -ne 'Private' -or $Firewall.Protocol -ne 'TCP' -or
        $Firewall.LocalPort -ne [string]$Script:GuanZhiWebPort -or $Firewall.BackendEnabled) {
        return $false
    }
    return ($Firewall.RemoteAddress -match [regex]::Escape($Wlan.NetworkCidr) -or
        $Firewall.RemoteAddress -match [regex]::Escape($Wlan.NetworkMaskCidr))
}

function Open-GuanZhiWeb {
    try {
        Start-Process $Script:GuanZhiWebUrl
        Write-LauncherLog "打开冠志通 Docker Web 工作台: $Script:GuanZhiWebUrl" -Level INFO
        Write-Host "  已打开冠志通 Docker Web 工作台: $($Script:GuanZhiWebUrl)" -ForegroundColor Magenta
    } catch {
        Write-LauncherLog "打开冠志通 Web 失败: $($_.Exception.Message)" -Level ERROR
    }
}

function Open-GuanZhiCompliance {
    try {
        Start-Process $Script:GuanZhiComplianceUrl
        Write-LauncherLog "打开合规性判断工作台应用: $Script:GuanZhiComplianceUrl" -Level INFO
        Write-Host "  已打开合规性判断工作台应用: $($Script:GuanZhiComplianceUrl)" -ForegroundColor Magenta
    } catch {
        Write-LauncherLog "打开合规性判断工作台应用失败: $($_.Exception.Message)" -Level ERROR
    }
}

function Start-GuanZhiWeb {
    param([switch]$SkipOpen)
    Write-Host ''
    Write-Host '  正在启动冠志通 Docker Web 工作台 ...' -ForegroundColor Green
    Write-LauncherLog '========== 启动冠志通 Docker Web 工作台 ==========' -Level INFO
    $dockerCli = Get-GuanZhiDockerCli
    if ($null -eq $dockerCli) {
        Write-LauncherLog "未找到 Docker CLI: $($Script:GuanZhiDockerCli)" -Level ERROR
        Write-Host '  未找到 Docker CLI，请确认 Docker Desktop 已安装。' -ForegroundColor Red
        return $false
    }
    if (-not (Ensure-GuanZhiDockerEngineRunning -DockerCli $dockerCli)) {
        Write-LauncherLog 'Docker 引擎不可用，未启动或创建任何容器' -Level ERROR
        Write-Host '  Docker 引擎不可用，请先启动 Docker Desktop。' -ForegroundColor Red
        return $false
    }
    $state = Get-GuanZhiDockerState -DockerCli $dockerCli
    if (-not $state.Exists) {
        Write-LauncherLog "目标容器不存在: $($Script:GuanZhiDockerContainer)；$($state.Error)" -Level ERROR
        Write-Host "  未找到目标容器: $($Script:GuanZhiDockerContainer)" -ForegroundColor Red
        return $false
    }
    if ([string]$state.Image -ne $Script:GuanZhiDockerImage) {
        Write-LauncherLog "目标容器镜像不匹配: 实际=$($state.Image)，预期=$($Script:GuanZhiDockerImage)" -Level ERROR
        Write-Host '  目标容器镜像与统一启动器配置不匹配，已拒绝操作。' -ForegroundColor Red
        return $false
    }
    if (-not $state.Running) {
        Write-LauncherLog "启动现有 Docker 容器: $($Script:GuanZhiDockerContainer)" -Level INFO
        $null = & $dockerCli start $Script:GuanZhiDockerContainer 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-LauncherLog '启动现有 Docker 容器失败' -Level ERROR
            Write-Host '  Docker 容器启动失败。' -ForegroundColor Red
            return $false
        }
    }
    for ($i = 0; $i -lt $Script:GuanZhiWebReadyTimeoutSec; $i++) {
        Start-Sleep -Seconds 1
        $state = Get-GuanZhiDockerState -DockerCli $dockerCli
        if ($state.Ready -and (Test-GuanZhiWebRunning -Quiet)) {
            Write-LauncherLog "冠志通 Docker Web 已就绪；容器=$($Script:GuanZhiDockerContainer)；端口=$($Script:GuanZhiWebPort)" -Level INFO
            Write-Host "  冠志通 Docker Web 已就绪: $($Script:GuanZhiWebUrl)" -ForegroundColor Green
            if (-not $SkipOpen) { Open-GuanZhiWeb }
            return $true
        }
    }
    Write-LauncherLog "冠志通 Docker Web 启动失败或超时；状态=$($state.Status)；健康=$($state.Health)；端口映射有效=$($state.PortMappingValid)" -Level ERROR
    Write-Host "  Docker Web 未在 $($Script:GuanZhiWebReadyTimeoutSec) 秒内就绪，请检查容器日志。" -ForegroundColor Red
    return $false
}

function Start-GuanZhiCompliance {
    Write-Host ''
    Write-Host '  正在打开冠志通合规性判断工作台应用 ...' -ForegroundColor Green
    $started = Start-GuanZhiWeb -SkipOpen
    if (-not $started) { return $false }
    Open-GuanZhiCompliance
    return $true
}

function Stop-GuanZhiWeb {
    Write-Host ''
    Write-Host '  正在停止冠志通 Docker Web 工作台 ...' -ForegroundColor Red
    Write-LauncherLog '========== 停止冠志通 Docker Web 工作台 ==========' -Level INFO
    $dockerCli = Get-GuanZhiDockerCli
    if ($null -eq $dockerCli -or -not (Test-GuanZhiDockerAvailable -DockerCli $dockerCli)) {
        Write-LauncherLog 'Docker 引擎不可用，无法停止目标容器' -Level ERROR
        return $false
    }
    $state = Get-GuanZhiDockerState -DockerCli $dockerCli
    if (-not $state.Exists -or -not $state.Running) {
        Write-Host '  冠志通 Docker Web 未在运行。' -ForegroundColor Yellow
        return $true
    }
    $null = & $dockerCli stop $Script:GuanZhiDockerContainer 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-LauncherLog "停止 Docker 容器失败: $($Script:GuanZhiDockerContainer)" -Level ERROR
        return $false
    }
    Write-LauncherLog "已停止 Docker 容器: $($Script:GuanZhiDockerContainer)" -Level INFO
    return $true
}

function Start-GuanZhiLanSession {
    Write-Host ''
    Write-Host '  正在一键启动冠志通 Docker Web 并开启 Wi‑Fi 局域网访问 ...' -ForegroundColor Green
    Write-LauncherLog '========== 一键启动冠志通 Docker Web + Wi‑Fi LAN ==========' -Level INFO

    $dockerCli = Get-GuanZhiDockerCli
    if ($null -eq $dockerCli) {
        Write-LauncherLog "一键启动失败：未找到 Docker CLI: $($Script:GuanZhiDockerCli)" -Level ERROR
        Write-Host '  未找到 Docker CLI，请确认 Docker Desktop 已安装。' -ForegroundColor Red
        return $false
    }
    if (-not (Ensure-GuanZhiDockerEngineRunning -DockerCli $dockerCli)) {
        Write-LauncherLog '一键启动失败：Docker CLI/引擎不可用' -Level ERROR
        Write-Host '  Docker 引擎不可用，未开启局域网访问。' -ForegroundColor Red
        return $false
    }
    $before = Get-GuanZhiDockerState -DockerCli $dockerCli
    if (-not $before.Exists -or [string]$before.Image -ne $Script:GuanZhiDockerImage) {
        Write-LauncherLog "一键启动失败：目标容器不存在或镜像不匹配；容器=$($Script:GuanZhiDockerContainer)；实际镜像=$($before.Image)" -Level ERROR
        Write-Host '  目标 Docker 容器或镜像不符合预期，未开启局域网访问。' -ForegroundColor Red
        return $false
    }
    $wasRunning = [bool]$before.Running

    $webReady = Start-GuanZhiWeb -SkipOpen
    if (-not $webReady) {
        Write-LauncherLog '一键启动失败：Docker Web 未就绪，局域网访问保持关闭' -Level ERROR
        return $false
    }
    $lanEnabled = Start-GuanZhiLanAccess
    if (-not $lanEnabled) {
        if (-not $wasRunning) {
            $rollback = Stop-GuanZhiWeb
            Write-LauncherLog "LAN 开启失败；本次启动的容器回滚结果=$rollback" -Level WARN
        } else {
            Write-LauncherLog 'LAN 开启失败；目标容器原本已运行，按原状态保留容器' -Level WARN
        }
        return $false
    }

    $wlan = Get-GuanZhiWlanInfo
    $firewall = Get-GuanZhiFirewallState
    $state = Get-GuanZhiDockerState -DockerCli $dockerCli
    $verified = ($state.Ready -and (Test-GuanZhiWebRunning -Quiet) -and (Test-GuanZhiLanRuleEnabled -Wlan $wlan -Firewall $firewall))
    if (-not $verified) {
        $null = Stop-GuanZhiLanAccess
        if (-not $wasRunning) {
            $rollback = Stop-GuanZhiWeb
            Write-LauncherLog "一键启动最终验证失败；LAN 已回滚；本次启动的容器回滚结果=$rollback" -Level ERROR
        } else {
            Write-LauncherLog '一键启动最终验证失败；LAN 已回滚；目标容器原本已运行，按原状态保留容器' -Level ERROR
        }
        Write-Host '  一键启动未通过最终安全验证，局域网访问已回滚为关闭。' -ForegroundColor Red
        return $false
    }

    Write-LauncherLog "一键启动成功；容器=$($Script:GuanZhiDockerContainer)；端口=$($Script:GuanZhiWebPort)；接口=$($wlan.InterfaceAlias)；来源=$($wlan.NetworkCidr)；LAN 地址=http://$($wlan.IPAddress):$($Script:GuanZhiWebPort)" -Level INFO
    Write-Host "  一键启动完成：本机 $($Script:GuanZhiWebUrl)" -ForegroundColor Green
    Write-Host "  同 Wi‑Fi 设备访问: http://$($wlan.IPAddress):$($Script:GuanZhiWebPort)" -ForegroundColor Green
    Open-GuanZhiWeb
    return $true
}

function Stop-GuanZhiLanSession {
    Write-Host ''
    Write-Host '  正在一键关闭冠志通 Wi‑Fi 局域网访问并停止 Docker Web ...' -ForegroundColor Red
    Write-LauncherLog '========== 一键关闭冠志通 Docker Web + Wi‑Fi LAN ==========' -Level INFO

    if (-not (Stop-GuanZhiLanAccess)) {
        Write-LauncherLog '一键关闭失败：局域网防火墙规则未能确认关闭，未停止容器' -Level ERROR
        Write-Host '  局域网开关未能确认关闭，已停止后续动作以避免留下未核验状态。' -ForegroundColor Red
        return $false
    }
    if (-not (Stop-GuanZhiWeb)) {
        Write-LauncherLog '一键关闭失败：Docker Web 容器未能停止' -Level ERROR
        return $false
    }

    $dockerCli = Get-GuanZhiDockerCli
    $state = if ($null -ne $dockerCli -and (Test-GuanZhiDockerAvailable -DockerCli $dockerCli)) {
        Get-GuanZhiDockerState -DockerCli $dockerCli
    } else {
        $null
    }
    $firewall = Get-GuanZhiFirewallState
    $containerStopped = ($null -ne $state -and (-not $state.Exists -or -not $state.Running))
    $lanClosed = ($firewall.RuleCount -le 1 -and -not $firewall.Enabled -and -not $firewall.BackendEnabled)
    $portClosed = -not (Test-GuanZhiWebPortListening)
    if (-not ($containerStopped -and $lanClosed -and $portClosed)) {
        Write-LauncherLog "一键关闭最终验证失败；容器已停止=$containerStopped；LAN 已关闭=$lanClosed；端口已关闭=$portClosed" -Level ERROR
        Write-Host '  一键关闭未通过最终验证，请检查状态和日志。' -ForegroundColor Red
        return $false
    }
    Write-LauncherLog "一键关闭成功；容器=$($Script:GuanZhiDockerContainer) 已停止；LAN 规则已关闭；宿主机端口=$($Script:GuanZhiWebPort) 已无监听" -Level INFO
    Write-Host '  一键关闭完成：局域网访问已关闭，Docker Web 容器已停止。' -ForegroundColor Yellow
    return $true
}

function Show-GuanZhiLanStatus {
    Write-LauncherLog '查询冠志通 Docker Web 局域网状态...' -Level INFO
    $dockerCli = Get-GuanZhiDockerCli
    $dockerAvailable = ($null -ne $dockerCli -and (Test-GuanZhiDockerAvailable -DockerCli $dockerCli))
    $state = if ($dockerAvailable) { Get-GuanZhiDockerState -DockerCli $dockerCli } else { [pscustomobject]@{ Exists=$false; Error='Docker CLI 或 Docker 引擎不可用。'; Running=$false; Status='unavailable'; Health='unknown'; Image=''; PortMappingValid=$false } }
    $wlan = Get-GuanZhiWlanInfo
    $firewall = Get-GuanZhiFirewallState
    $ruleMatches = Test-GuanZhiLanRuleEnabled -Wlan $wlan -Firewall $firewall
    $lanEnabled = [bool]$ruleMatches
    Write-Host ''
    Write-Host '  ------ 冠志通 Docker Web 局域网状态 ------' -ForegroundColor Cyan
    Write-Host "  容器: $($Script:GuanZhiDockerContainer)"
    Write-Host "  Docker: $(if ($dockerAvailable) { '可用' } else { '不可用' })"
    Write-Host "  容器状态: $($state.Status)；健康: $($state.Health)；镜像: $($state.Image)"
    Write-Host "  端口映射: 容器 $($Script:GuanZhiContainerPort) -> 宿主机 $($Script:GuanZhiWebPort)；有效: $($state.PortMappingValid)"
    if ($null -ne $wlan) {
        Write-Host "  Wi‑Fi: $($wlan.NetworkName) / $($wlan.InterfaceAlias) / $($wlan.IPAddress)/$($wlan.PrefixLength)"
        Write-Host "  允许来源: $($wlan.NetworkCidr)"
        Write-Host "  局域网地址: http://$($wlan.IPAddress):$($Script:GuanZhiWebPort)"
    } else {
        Write-Host '  Wi‑Fi: 未能唯一识别 Private WLAN，局域网开关应保持关闭。' -ForegroundColor Yellow
    }
    Write-Host "  冠志通专用防火墙规则: $(if ($ruleMatches) { '已正确启用' } else { '未启用/范围不符合' })"
    Write-Host "  Docker 宽泛 TCP 规则: $(if ($firewall.BackendEnabled) { '仍启用（不安全）' } else { '已关闭' })"
    Write-Host "  局域网访问开关: $(if ($lanEnabled) { '开启' } else { '关闭' })" -ForegroundColor $(if ($lanEnabled) { 'Green' } else { 'Yellow' })
    if ($state.Exists -and $state.Running -and (Test-GuanZhiWebRunning -Quiet)) {
        Write-Host "  本机 HTTP: 正常 ($($Script:GuanZhiWebUrl))" -ForegroundColor Green
    } else {
        Write-Host '  本机 HTTP: 未验证通过' -ForegroundColor Yellow
    }
    if (-not $state.Exists) { Write-Host "  诊断: $($state.Error)" -ForegroundColor Red }
    Write-Host ''
}

function Start-GuanZhiLanAccess {
    return (Invoke-GuanZhiLanCommand -Command 'on')
}

function Stop-GuanZhiLanAccess {
    return (Invoke-GuanZhiLanCommand -Command 'off')
}

function Invoke-GuanZhiLanCommand {
    param([ValidateSet('on','off','status')][string]$Command = 'status')
    if ($Command -eq 'status') {
        Show-GuanZhiLanStatus
        return $true
    }
    Write-Host ''
    Write-Host "  正在$(if ($Command -eq 'on') { '开启' } else { '关闭' })冠志通 Docker Web Wi‑Fi 局域网访问 ..." -ForegroundColor $(if ($Command -eq 'on') { 'Green' } else { 'Yellow' })
    Write-LauncherLog "========== 冠志通 Docker Web LAN $Command ==========" -Level INFO
    if (-not (Test-GuanZhiAdministrator)) {
        Write-LauncherLog '防火墙操作需要管理员权限，已拒绝执行' -Level ERROR
        Write-Host '  此操作需要以管理员身份运行 PowerShell/wll。' -ForegroundColor Red
        return $false
    }
    if ($Command -eq 'off') {
        try {
            $rules = @(Get-GuanZhiFirewallRules)
            if ($rules.Count -gt 1) { throw '发现多个同名冠志通防火墙规则，已拒绝关闭歧义规则。' }
            if ($rules.Count -eq 1) {
                Set-NetFirewallRule -Name $rules[0].Name -Enabled 'False' -ErrorAction Stop
            }
            Write-LauncherLog 'LAN 已关闭；容器保持不变；Docker 宽泛 TCP 规则保持关闭' -Level INFO
            Write-Host '  已关闭局域网访问；Docker Web 容器仍保持运行。' -ForegroundColor Yellow
            return $true
        } catch {
            Write-LauncherLog "关闭 LAN 失败: $($_.Exception.Message)" -Level ERROR
            Write-Host "  关闭局域网访问失败: $($_.Exception.Message)" -ForegroundColor Red
            return $false
        }
    }

    $wlan = Get-GuanZhiWlanInfo
    if ($null -eq $wlan) {
        Write-LauncherLog '未能唯一识别活跃 Private WLAN，LAN 操作失败关闭' -Level ERROR
        Write-Host '  未能唯一识别 Private Wi‑Fi 子网，已拒绝修改防火墙。' -ForegroundColor Red
        return $false
    }
    $dockerCli = Get-GuanZhiDockerCli
    if ($null -eq $dockerCli) {
        Write-LauncherLog '未找到 Docker CLI，LAN 操作失败关闭' -Level ERROR
        Write-Host '  未找到 Docker CLI，已拒绝修改防火墙。' -ForegroundColor Red
        return $false
    }
    if ($Command -eq 'on') {
        if (-not (Ensure-GuanZhiDockerEngineRunning -DockerCli $dockerCli)) {
            Write-LauncherLog 'Docker CLI/引擎不可用，LAN 操作失败关闭' -Level ERROR
            Write-Host '  Docker 引擎不可用，已拒绝修改防火墙。' -ForegroundColor Red
            return $false
        }
    } else {
        if (-not (Test-GuanZhiDockerAvailable -DockerCli $dockerCli)) {
            Write-LauncherLog 'Docker CLI/引擎不可用，LAN 操作失败关闭' -Level ERROR
            Write-Host '  Docker 引擎不可用，已拒绝修改防火墙。' -ForegroundColor Red
            return $false
        }
    }
    $state = Get-GuanZhiDockerState -DockerCli $dockerCli
    if (-not $state.Exists -or [string]$state.Image -ne $Script:GuanZhiDockerImage) {
        Write-LauncherLog "目标容器不存在或镜像不匹配；容器=$($Script:GuanZhiDockerContainer)；实际镜像=$($state.Image)" -Level ERROR
        Write-Host '  目标 Docker 容器或镜像不符合预期，已拒绝修改防火墙。' -ForegroundColor Red
        return $false
    }
    if ($Command -eq 'on') {
        if (-not $state.Running) {
            $null = & $dockerCli start $Script:GuanZhiDockerContainer 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-LauncherLog '目标 Docker 容器未运行且启动失败，LAN 保持关闭' -Level ERROR
                return $false
            }
        }
        $ready = $false
        for ($i = 0; $i -lt $Script:GuanZhiWebReadyTimeoutSec; $i++) {
            Start-Sleep -Seconds 1
            $state = Get-GuanZhiDockerState -DockerCli $dockerCli
            if ($state.Ready -and (Test-GuanZhiWebRunning -Quiet)) { $ready = $true; break }
        }
        if (-not $ready) {
            Write-LauncherLog "目标 Docker Web 未健康就绪，LAN 保持关闭；状态=$($state.Status)；健康=$($state.Health)" -Level ERROR
            Write-Host '  Docker Web 未健康就绪，已拒绝开启局域网访问。' -ForegroundColor Red
            return $false
        }
        if (-not (Disable-GuanZhiDockerBackendWideRule)) {
            Write-Host '  无法关闭 Docker 宽泛入站规则，已拒绝开启局域网访问。' -ForegroundColor Red
            return $false
        }
        try {
            $null = Set-GuanZhiFirewallRule -RemoteCidr $wlan.NetworkCidr -Enabled $true
            $verify = Get-GuanZhiFirewallState
            if ($verify.RuleCount -ne 1 -or -not $verify.Enabled -or $verify.Profile -ne 'Private' -or $verify.Protocol -ne 'TCP' -or $verify.LocalPort -ne [string]$Script:GuanZhiWebPort -or ($verify.RemoteAddress -notmatch [regex]::Escape($wlan.NetworkCidr) -and $verify.RemoteAddress -notmatch [regex]::Escape($wlan.NetworkMaskCidr)) -or $verify.BackendEnabled) {
                throw '防火墙规则读回结果不符合安全范围。'
            }
            Write-LauncherLog "LAN 已开启；接口=$($wlan.InterfaceAlias)；IP=$($wlan.IPAddress)；来源=$($wlan.NetworkCidr)；地址=http://$($wlan.IPAddress):$($Script:GuanZhiWebPort)" -Level INFO
            Write-Host "  已开启同 Wi‑Fi 局域网访问: http://$($wlan.IPAddress):$($Script:GuanZhiWebPort)" -ForegroundColor Green
            return $true
        } catch {
            try { $null = Set-GuanZhiFirewallRule -RemoteCidr $wlan.NetworkCidr -Enabled $false } catch {}
            Write-LauncherLog "开启 LAN 失败，已回滚冠志通规则: $($_.Exception.Message)" -Level ERROR
            Write-Host '  防火墙规则未通过安全校验，已回滚为关闭。' -ForegroundColor Red
            return $false
        }
    }
}

function Show-PlatformStatus {
    <#
    .SYNOPSIS 显示所有平台的运行状态
    #>
    Write-LauncherLog '查询全部运行状态...' -Level INFO
    Write-Host ''
    Write-Host '  -- DeepSeek Harness 状态 --' -ForegroundColor Cyan
    if (Test-DshRunning) {
        Write-Host '  DeepSeek Harness: 运行中' -ForegroundColor Green
        Write-Host "  URL: $($Script:DshUrl)"
    } else {
        Write-Host '  DeepSeek Harness: 未运行' -ForegroundColor Yellow
    }

    Write-Host ''
    Write-Host '  ------ StudyPower Web 工作台状态 ------' -ForegroundColor Cyan
    if (Test-StudyPowerRunning) {
        Write-Host "  StudyPower: 运行中 ($($Script:StudyPowerUrl))" -ForegroundColor Green
    } else {
        Write-Host '  StudyPower: 未运行' -ForegroundColor Yellow
    }
    Write-Host '  ------ AI Study Tauri 状态 ------' -ForegroundColor Cyan
    $aiStudyProcs = Get-AIStudyProcesses
    if ($aiStudyProcs.Count -gt 0) {
        Write-Host '  AI Study Tauri: 运行中' -ForegroundColor Green
        $aiStudyProcs | ForEach-Object { Write-Host "    PID: $($_.ProcessId)" -ForegroundColor Gray }
    } else {
        Write-Host '  AI Study Tauri: 未运行' -ForegroundColor Yellow
    }
    Write-Host ''
    Write-Host '  ------ 冠志通 Web 工作台状态 ------' -ForegroundColor Cyan
    $guanZhiWebRunning = Test-GuanZhiWebRunning -Quiet
    if ($guanZhiWebRunning) {
        Write-Host "  冠志通 Web: 运行中 ($($Script:GuanZhiWebUrl))" -ForegroundColor Green
    } else {
        Write-Host '  冠志通 Web: 未运行' -ForegroundColor Yellow
    }
    $lanStatus = Get-GuanZhiFirewallState
    $wlan = Get-GuanZhiWlanInfo
    $lanRuleEnabled = Test-GuanZhiLanRuleEnabled -Wlan $wlan -Firewall $lanStatus
    Write-Host "  Wi‑Fi 局域网访问: $(if ($lanRuleEnabled) { '开启' } else { '关闭' })" -ForegroundColor $(if ($lanRuleEnabled) { 'Green' } else { 'Yellow' })
    if ($null -ne $wlan) {
        Write-Host "  局域网地址: http://$($wlan.IPAddress):$($Script:GuanZhiWebPort)；允许来源: $($wlan.NetworkCidr)"
    }
    Write-Host ''
    Write-Host '  -- AI 桌面协同组合状态 (Antigravity / IDE / ChatGPT / Cockpit) --' -ForegroundColor Cyan
    Show-AiSuiteSummary
    Write-Host ''
    Show-WslSummary
    Write-Host ''
    Show-WslFeishuSummary
    Write-Host ''
    Show-GladosStatus
    Write-Host ''
    Show-MsdsEngineSummary
    Write-Host ''
}

# ============================================================
# AI Study Tauri System
# ============================================================

function Get-OfficialAIStudyExe {
    <#
    .SYNOPSIS 返回 AI Study Tauri 唯一正式构建产物。
    .DESCRIPTION
    只扫描正式打包脚本生成的 cargo-target-latest-* 目录，并选择最新的完整 EXE。
    preview、final-fixed-corners 和其他历史目录不参与 wll 默认启动。
    #>
    param(
        [string]$ProjectDir = $Script:AIStudyTauriDir
    )
    $buildRoot = Join-Path $ProjectDir '.build'
    if (-not (Test-Path -LiteralPath $buildRoot -PathType Container)) {
        return $null
    }
    $candidate = Get-ChildItem -LiteralPath $buildRoot -Directory -Filter 'cargo-target-latest-*' -ErrorAction SilentlyContinue |
        ForEach-Object {
            $exe = Join-Path $_.FullName 'release\AIstudy.exe'
            if (Test-Path -LiteralPath $exe -PathType Leaf) {
                Get-Item -LiteralPath $exe
            }
        } |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if ($candidate) {
        return $candidate.FullName
    }
    return $null
}

function Start-AIStudyTauri {
    <#
    .SYNOPSIS 启动 AI Study Tauri 系统唯一正式构建版
    #>
    Write-Host ''
    Write-Host '  正在启动 AI Study Tauri 系统 (正式构建版) ...' -ForegroundColor Green
    Write-LauncherLog '========== 启动 AI Study Tauri ==========' -Level INFO

    $officialExePath = Get-OfficialAIStudyExe
    if (-not $officialExePath) {
        $expected = Join-Path $Script:AIStudyTauriDir '.build\cargo-target-latest-*\release\AIstudy.exe'
        Write-LauncherLog "未找到正式 AI Study Tauri 最新构建产物: $expected" -Level ERROR
        Write-Host "  未找到正式构建版，请先运行 build-release.ps1 或 build-release.bat。" -ForegroundColor Red
        return $false
    }

    # wll 只允许存在一个 AI Study Tauri 实例，避免旧版窗口继续占据用户视图。
    # 这里按进程名收口，因为提升权限的旧实例可能无法返回 ExecutablePath，
    # 但 AIstudy.exe 是本统一启动器管理的唯一 Tauri 主程序名。
    $existingProcesses = Get-AIStudyProcesses
    foreach ($process in $existingProcesses) {
        try {
            Stop-Process -Id $process.ProcessId -Force -ErrorAction Stop
            Write-LauncherLog "启动前关闭历史 AIstudy 进程: PID=$($process.ProcessId)" -Level INFO
        } catch {
            Write-LauncherLog "启动前无法关闭历史 AIstudy 进程: PID=$($process.ProcessId), 原因=$($_.Exception.Message)" -Level ERROR
            Write-Host "  无法关闭旧版 AI Study Tauri 进程 PID=$($process.ProcessId)，请以管理员身份运行 wll 后重试。" -ForegroundColor Red
            return $false
        }
    }
    Start-Sleep -Milliseconds 300
    $remainingProcesses = Get-AIStudyProcesses
    if ($remainingProcesses.Count -gt 0) {
        $remainingIds = ($remainingProcesses | ForEach-Object ProcessId) -join ', '
        Write-LauncherLog "启动前仍存在 AIstudy 进程，阻止启动: PID=$remainingIds" -Level ERROR
        Write-Host "  旧版 AI Study Tauri 尚未退出，已阻止启动以避免新旧版本并存。" -ForegroundColor Red
        return $false
    }

    $lastTime = (Get-Item $officialExePath).LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
    Write-LauncherLog "动态解析最新正式主程序: $officialExePath (修改时间: $lastTime)" -Level INFO
    Write-Host "  [最新正式产物] $officialExePath" -ForegroundColor Cyan
    Write-Host "  [构建时间] $lastTime" -ForegroundColor Gray

    try {
        $workingDir = Split-Path $officialExePath -Parent
        Start-Process -FilePath $officialExePath -WorkingDirectory $workingDir
        Write-Host '  AI Study Tauri 系统界面已成功启动！' -ForegroundColor Green
        return $true
    } catch {
        Write-LauncherLog "启动 AI Study Tauri 异常: $($_.Exception.Message)" -Level ERROR
        Write-Host "  启动失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Stop-AIStudyTauri {
    <#
    .SYNOPSIS 停止所有由统一启动器管理的 AI Study Tauri 实例
    #>
    Write-Host ''
    Write-Host '  正在停止 AI Study Tauri 正式构建版 ...' -ForegroundColor Red
    Write-LauncherLog '========== 停止 AI Study Tauri ==========' -Level INFO

    try {
        $processes = Get-AIStudyProcesses
        if ($processes.Count -eq 0) {
            Write-LauncherLog '未找到 AI Study Tauri 实例，按未运行处理' -Level WARN
            Write-Host '  AI Study Tauri 未在运行。' -ForegroundColor Yellow
            return $true
        }
        foreach ($process in $processes) {
            Stop-Process -Id $process.ProcessId -Force -ErrorAction Stop
            Write-LauncherLog "已停止 AIstudy 进程: PID=$($process.ProcessId)" -Level INFO
        }
        Start-Sleep -Milliseconds 300
        $remainingProcesses = Get-AIStudyProcesses
        if ($remainingProcesses.Count -gt 0) {
            $remainingIds = ($remainingProcesses | ForEach-Object ProcessId) -join ', '
            throw "AIstudy 进程未完全退出: PID=$remainingIds"
        }
        Write-LauncherLog 'AI Study Tauri 所有实例已停止' -Level INFO
        return $true
    } catch {
        Write-LauncherLog "停止 AI Study Tauri 异常: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

# ============================================================
# DeepSeek Harness (dsh)
# ============================================================

function Get-DshDashboardUrl {
    <#
    .SYNOPSIS 返回当前 dsh 实例带访问 token 的 Dashboard 地址
    #>
    $dshOut = Join-Path $Script:DshRoot 'dsh-web.out.log'
    if (Test-Path -LiteralPath $dshOut) {
        try {
            $content = Get-Content -LiteralPath $dshOut -Raw -Encoding UTF8 -ErrorAction Stop
            $match = [regex]::Match($content, 'http://127\.0\.0\.1:' + [regex]::Escape([string]$Script:DshPort) + '/\?token=[^\s]+')
            if ($match.Success) { return $match.Value }
        } catch {}
    }
    return $Script:DshUrl
}

function Open-DshDashboard {
    <#
    .SYNOPSIS 用指定浏览器打开 DeepSeek Harness Dashboard
    #>
    if (-not $Script:DshAutoOpenBrowser) { return }
    try {
        $dashboardUrl = Get-DshDashboardUrl
        if (Test-Path -LiteralPath $Script:DshBrowserPath) {
            Start-Process -FilePath $Script:DshBrowserPath -ArgumentList $dashboardUrl
            Write-LauncherLog "用浏览器打开 DeepSeek Harness: $dashboardUrl" -Level INFO
            Write-Host "  已用 Chrome 打开 DeepSeek Harness Dashboard: $dashboardUrl" -ForegroundColor Magenta
        } else {
            Open-PlatformUrl -Name 'DeepSeek Harness' -Url $dashboardUrl
        }
    } catch {
        Write-LauncherLog "打开 DeepSeek Harness 浏览器失败: $($_.Exception.Message)" -Level ERROR
    }
}

function Open-PlatformUrl {
    <#
    .SYNOPSIS 打开指定平台的网页
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Url
    )

    Write-LauncherLog "打开 $Name 网页: $Url" -Level INFO
    try {
        Start-Process $Url
        Write-Host "  已打开 $Name : $Url" -ForegroundColor Magenta
    } catch {
        Write-LauncherLog "打开网页失败: $($_.Exception.Message)" -Level ERROR
    }
}

function Start-Dsh {
    <#
    .SYNOPSIS 启动 DeepSeek Harness Web (后台)
    #>
    Write-Host ''
    Write-Host '  正在启动 DeepSeek Harness (dsh Web) ...' -ForegroundColor Green
    Write-LauncherLog '========== 启动 DeepSeek Harness ==========' -Level INFO

    if (Test-DshRunning) {
        Write-LauncherLog 'DeepSeek Harness 已在运行，跳过启动' -Level INFO
        Write-Host '  DeepSeek Harness 已在运行中（跳过重复启动）。' -ForegroundColor Green
        Show-DshResultSummary
        Write-Host '  正在打开浏览器 ...' -ForegroundColor Gray
        Open-DshDashboard
        return $true
    }

    if (-not (Test-Path -LiteralPath $Script:DshRoot)) {
        Write-LauncherLog "DeepSeek Harness 目录不存在: $($Script:DshRoot)" -Level ERROR
        Write-Host "  未找到 DeepSeek Harness 目录: $Script:DshRoot" -ForegroundColor Red
        return $false
    }
    if (-not (Test-Path -LiteralPath $Script:DshCliBin)) {
        Write-LauncherLog "DeepSeek Harness 预编译 CLI 不存在: $($Script:DshCliBin)" -Level ERROR
        Write-Host "  未找到预编译 CLI: $($Script:DshCliBin)" -ForegroundColor Red
        return $false
    }

    # 检查端口是否被遗留进程占用，防止 EADDRINUSE 导致启动超时
    $staleConn = Get-NetTCPConnection -LocalPort $Script:DshPort -State Listen -ErrorAction SilentlyContinue
    if ($staleConn) {
        Write-LauncherLog "检测到端口 $($Script:DshPort) 存在旧进程占用，正在清理..." -Level WARN
        $stalePids = @($staleConn | Select-Object -ExpandProperty OwningProcess -Unique)
        foreach ($spid in $stalePids) {
            try { Stop-Process -Id $spid -Force -ErrorAction SilentlyContinue } catch {}
        }
        Start-Sleep -Milliseconds 800
    }

    # 后台拉起 dsh web（经 cmd 纯后台独立进程启动并文件重定向，彻底解绑控制台管道，杜绝 EPIPE / 管道断开导致进程退出）。
    # 优先用预编译 CLI（node apps/cli/lib/bin.js），避免 pnpm+tsx 源码转译导致的 ~95s 冷启动。
    $dshOut = Join-Path $Script:DshRoot 'dsh-web.out.log'
    $dshErr = Join-Path $Script:DshRoot 'dsh-web.err.log'
    Remove-Item -LiteralPath $dshOut, $dshErr -ErrorAction SilentlyContinue
    try {
        $env:DSH_HOME = $Script:DshHome
        $env:NODE_USE_ENV_PROXY = '1'
        $dshWorkDir = $Script:DshRoot
        # 路径含空格，必须显式加引号；Start-Process -ArgumentList 数组拼接不会自动加引号
        $dshArgs = "`"$($Script:DshCliBin)`" web --patch apps/cli/config/examples/schedule/cordis.yml --port $($Script:DshPort)"
        $cmdLine = "cmd.exe /c `"`"node.exe`" $dshArgs > `"$dshOut`" 2> `"$dshErr`"`""
        $wmiRes = ([wmiclass]'Win32_Process').Create($cmdLine, $dshWorkDir, $null)
        if ($null -eq $wmiRes -or $wmiRes.ReturnValue -ne 0) {
            Start-Process -FilePath 'cmd.exe' -ArgumentList "/c $cmdLine" `
                -WorkingDirectory $dshWorkDir -WindowStyle Hidden
        }
        Write-LauncherLog "后台启动命令已发出: node $dshArgs (工作目录: $dshWorkDir)" -Level INFO
    } catch {
        Write-LauncherLog "启动 DeepSeek Harness 异常: $($_.Exception.Message)" -Level ERROR
        Write-Host "  启动失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }

    # 等待就绪（实时透出 dsh 启动输出 + 倒计时，避免长时间无反馈）
    Write-LauncherLog "等待 DeepSeek Harness 就绪 (端口 $($Script:DshPort))..." -Level INFO
    Write-Host "  等待就绪中 (最多 $($Script:DshReadyTimeoutSec)s)，dsh 启动输出如下:" -ForegroundColor Gray
    $ready = $false
    $lastOutLen = 0
    for ($i = 0; $i -lt $Script:DshReadyTimeoutSec; $i++) {
        Start-Sleep -Seconds 1
        if (Test-Path -LiteralPath $dshOut) {
            try {
                $outContent = Get-Content -LiteralPath $dshOut -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
                if ($outContent -and $outContent.Length -gt $lastOutLen) {
                    $newText = $outContent.Substring($lastOutLen)
                    $lastOutLen = $outContent.Length
                    foreach ($newLine in ($newText -split "`r?`n")) {
                        if (-not [string]::IsNullOrWhiteSpace($newLine)) {
                            Write-Host "    [dsh] $newLine" -ForegroundColor DarkGray
                        }
                    }
                }
            } catch {}
        }
        if ((($i + 1) % 10) -eq 0) {
            Write-Host "  ... 已等待 $($i + 1)s/$($Script:DshReadyTimeoutSec)s" -ForegroundColor DarkGray
        }
        if (Test-DshRunning) {
            $ready = $true
            break
        }
    }

    if ($ready) {
        Write-LauncherLog 'DeepSeek Harness 启动完成' -Level INFO
        Write-Host "  DeepSeek Harness 已就绪。" -ForegroundColor Green
        Show-DshResultSummary
        Write-Host '  正在打开浏览器 ...' -ForegroundColor Gray
        Open-DshDashboard
        return $true
    } else {
        Write-LauncherLog 'DeepSeek Harness 启动超时，请查看 dsh-web.err.log' -Level WARN
        Write-Host '  DeepSeek Harness 启动超时，请查看 dsh-web.err.log。' -ForegroundColor Yellow
        if (Test-Path $dshOut) {
            Write-Host '  --- dsh-web.out.log (全部) ---' -ForegroundColor Cyan
            Get-Content -LiteralPath $dshOut -Encoding UTF8 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
        }
        if (Test-Path $dshErr) {
            Write-Host '  --- dsh-web.err.log (最近 15 行) ---' -ForegroundColor Cyan
            Get-Content -LiteralPath $dshErr -Tail 15 -Encoding UTF8 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
        }
        Write-Host '  排查: 1) wll logs dsh 看完整日志  2) wll stop dsh 后重试  3) 检查端口 9010 是否被占用' -ForegroundColor Yellow
        return $false
    }
}

function Start-DshHeadless {
    <#
    .SYNOPSIS 以 CLI 模式运行 DeepSeek Harness 一次性任务（前台，输出结果后退出）
    #>
    Write-Host ''
    Write-Host '  运行 DeepSeek Harness 一次性任务 (headless) ...' -ForegroundColor Green
    Write-LauncherLog '========== DeepSeek Harness headless 任务 ==========' -Level INFO

    if (-not (Test-Path -LiteralPath $Script:DshRoot)) {
        Write-LauncherLog "DeepSeek Harness 目录不存在: $($Script:DshRoot)" -Level ERROR
        Write-Host "  未找到 DeepSeek Harness 目录: $Script:DshRoot" -ForegroundColor Red
        return $false
    }
    if (-not (Test-Path -LiteralPath $Script:DshCliBin)) {
        Write-LauncherLog "DeepSeek Harness 预编译 CLI 不存在: $($Script:DshCliBin)" -Level ERROR
        Write-Host "  未找到预编译 CLI: $($Script:DshCliBin)" -ForegroundColor Red
        return $false
    }

    $task = Read-Host '  请输入任务描述'
    if ([string]::IsNullOrWhiteSpace($task)) {
        Write-Host '  任务描述为空，已取消。' -ForegroundColor Yellow
        return $false
    }

    try {
        $env:DSH_HOME = $Script:DshHome
        Write-Host ''
        Write-Host '  --- dsh headless 输出开始 ---' -ForegroundColor Cyan
        & 'node.exe' $Script:DshCliBin --profile headless $task
        Write-Host '  --- dsh headless 输出结束 ---' -ForegroundColor Cyan
        return $true
    } catch {
        Write-LauncherLog "运行 DeepSeek Harness headless 异常: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Stop-Dsh {
    <#
    .SYNOPSIS 停止由统一启动器管理的 DeepSeek Harness Web 进程
    #>
    Write-Host ''
    Write-Host '  正在停止 DeepSeek Harness ...' -ForegroundColor Red
    Write-LauncherLog '========== 停止 DeepSeek Harness ==========' -Level INFO

    if (-not (Test-DshRunning)) {
        Write-LauncherLog 'DeepSeek Harness 未在运行' -Level INFO
        Write-Host '  DeepSeek Harness 未在运行。' -ForegroundColor Yellow
        return $true
    }

    try {
        # 1) 按端口定位持有进程（最可靠）
        $portOwners = @()
        try {
            $conn = Get-NetTCPConnection -LocalPort $Script:DshPort -State Listen -ErrorAction SilentlyContinue
            $portOwners = @($conn | Select-Object -ExpandProperty OwningProcess -Unique)
        } catch {}
        foreach ($ownerPid in $portOwners) {
            try {
                Stop-Process -Id $ownerPid -Force -ErrorAction Stop
                Write-LauncherLog "已按端口停止 dsh 进程: PID=$ownerPid" -Level INFO
            } catch {
                Write-LauncherLog "按端口停止失败 PID=${ownerPid}: $($_.Exception.Message)" -Level WARN
            }
        }
        # 2) 兜底：按命令行关键词清残留
        $processes = Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
            Where-Object {
                ($_.Name -eq 'node.exe') -and $_.CommandLine -and
                ($_.CommandLine -like '*apps/cli/lib/bin.js*' -or
                 $_.CommandLine -like '*apps/cli/src/bin.ts*')
            }
        foreach ($process in $processes) {
            Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue
            Write-LauncherLog "已停止 dsh 进程: PID=$($process.ProcessId)" -Level INFO
        }
        Start-Sleep -Seconds 2
        if (Test-DshRunning) {
            Write-LauncherLog 'DeepSeek Harness 端口仍在监听' -Level WARN
            Write-Host '  DeepSeek Harness 端口仍在监听，可能仍有残留进程。' -ForegroundColor Yellow
            return $false
        }
        Write-LauncherLog 'DeepSeek Harness 已停止' -Level INFO
        return $true
    } catch {
        Write-LauncherLog "停止 DeepSeek Harness 异常: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

# ============================================================
# AI 桌面工具协同组合 (Antigravity / IDE / ChatGPT / Cockpit)
# ============================================================

function Get-AntigravityProcesses {
    <#
    .SYNOPSIS 获取独立运行的 Antigravity 客户端进程
    .NOTES Antigravity IDE 进程名为 'Antigravity IDE.exe'，此处精确过滤 'Antigravity.exe' 避免混淆。
    #>
    return ,@(Get-CimInstance Win32_Process -Filter "Name = 'Antigravity.exe'" -ErrorAction SilentlyContinue)
}

function Get-AntigravityIdeProcesses {
    <#
    .SYNOPSIS 获取 Antigravity IDE 进程
    #>
    return ,@(Get-CimInstance Win32_Process -Filter "Name = 'Antigravity IDE.exe'" -ErrorAction SilentlyContinue)
}

function Get-ChatGptProcesses {
    <#
    .SYNOPSIS 获取 ChatGPT 桌面客户端进程
    #>
    return ,@(Get-CimInstance Win32_Process -Filter "Name = 'ChatGPT.exe'" -ErrorAction SilentlyContinue)
}

function Get-CockpitProcesses {
    <#
    .SYNOPSIS 获取 Cockpit (Cockpit Tools) 进程
    #>
    return ,@(Get-CimInstance Win32_Process -Filter "Name = 'cockpit-tools.exe'" -ErrorAction SilentlyContinue)
}

function Get-ChatGptAppId {
    <#
    .SYNOPSIS 动态获取 ChatGPT Windows Store 应用的激活 AppId
    #>
    try {
        $pkg = Get-AppxPackage -AllUsers | Where-Object { $_.Name -match 'OpenAI\.Codex|ChatGPT' } | Select-Object -First 1
        if ($null -ne $pkg -and -not [string]::IsNullOrWhiteSpace($pkg.PackageFamilyName)) {
            return "$($pkg.PackageFamilyName)!App"
        }
    } catch {}
    return $Script:ChatGptAppId
}

function Show-AiSuiteSummary {
    <#
    .SYNOPSIS 在全局状态中简要输出 AI 组合运行概况
    #>
    $antiProcs    = Get-AntigravityProcesses
    $antiIdeProcs = Get-AntigravityIdeProcesses
    $chatGptProcs = Get-ChatGptProcesses
    $cockpitProcs = Get-CockpitProcesses

    $antiStatus    = if ($antiProcs.Count -gt 0) { "[√] 运行中 (PID: $(($antiProcs | ForEach-Object ProcessId) -join ', '))" } else { '[x] 未运行' }
    $antiIdeStatus = if ($antiIdeProcs.Count -gt 0) { "[√] 运行中 (PID: $(($antiIdeProcs | ForEach-Object ProcessId) -join ', '))" } else { '[x] 未运行' }
    $chatStatus    = if ($chatGptProcs.Count -gt 0) { "[√] 运行中 (PID: $(($chatGptProcs | ForEach-Object ProcessId) -join ', '))" } else { '[x] 未运行' }
    $cockpitStatus = if ($cockpitProcs.Count -gt 0) { "[√] 运行中 (PID: $(($cockpitProcs | ForEach-Object ProcessId) -join ', '))" } else { '[x] 未运行' }

    Write-Host "  Antigravity:     $antiStatus" -ForegroundColor $(if ($antiProcs.Count -gt 0) { 'Green' } else { 'Yellow' })
    Write-Host "  Antigravity IDE: $antiIdeStatus" -ForegroundColor $(if ($antiIdeProcs.Count -gt 0) { 'Green' } else { 'Yellow' })
    Write-Host "  ChatGPT:         $chatStatus" -ForegroundColor $(if ($chatGptProcs.Count -gt 0) { 'Green' } else { 'Yellow' })
    Write-Host "  Cockpit:         $cockpitStatus" -ForegroundColor $(if ($cockpitProcs.Count -gt 0) { 'Green' } else { 'Yellow' })
}

function Start-AntigravityApp {
    <#
    .SYNOPSIS 启动 Antigravity 客户端
    #>
    Write-Host ''
    Write-Host '  正在启动 Antigravity 客户端 ...' -ForegroundColor Green
    Write-LauncherLog '========== 启动 Antigravity ==========' -Level INFO

    $procs = Get-AntigravityProcesses
    if ($procs.Count -gt 0) {
        $pids = ($procs | ForEach-Object ProcessId) -join ', '
        Write-Host "  Antigravity 已经在运行中 (PID: $pids)，无需重复启动。" -ForegroundColor Yellow
        Write-LauncherLog "Antigravity 已在运行: PID=$pids" -Level INFO
        return $true
    }

    $targetExe = $Script:AntigravityExe
    if (-not (Test-Path -LiteralPath $targetExe -PathType Leaf)) {
        if (Test-Path -LiteralPath $Script:AntigravityAltLauncher -PathType Leaf) {
            $targetExe = $Script:AntigravityAltLauncher
        } else {
            Write-LauncherLog "未找到 Antigravity 可执行文件: $targetExe" -Level ERROR
            Write-Host "  错误: 未找到 Antigravity 可执行文件 ($targetExe)" -ForegroundColor Red
            return $false
        }
    }

    try {
        Start-Process -FilePath 'explorer.exe' -ArgumentList "`"$targetExe`""
        Start-Sleep -Seconds 2
        $procs = Get-AntigravityProcesses
        if ($procs.Count -gt 0) {
            $pids = ($procs | ForEach-Object ProcessId) -join ', '
            Write-Host "  [√] Antigravity 启动成功 (PID: $pids)" -ForegroundColor Green
            Write-LauncherLog "Antigravity 启动成功: PID=$pids" -Level INFO
            return $true
        } else {
            Write-Host '  Antigravity 启动命令已发送。' -ForegroundColor Green
            Write-LauncherLog 'Antigravity 启动命令已触发' -Level INFO
            return $true
        }
    } catch {
        Write-LauncherLog "启动 Antigravity 失败: $($_.Exception.Message)" -Level ERROR
        Write-Host "  启动 Antigravity 失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Start-AntigravityIdeApp {
    <#
    .SYNOPSIS 启动 Antigravity IDE
    #>
    Write-Host ''
    Write-Host '  正在启动 Antigravity IDE ...' -ForegroundColor Green
    Write-LauncherLog '========== 启动 Antigravity IDE ==========' -Level INFO

    $procs = Get-AntigravityIdeProcesses
    if ($procs.Count -gt 0) {
        $pids = ($procs | ForEach-Object ProcessId) -join ', '
        Write-Host "  Antigravity IDE 已经在运行中 (PID: $pids)，无需重复启动。" -ForegroundColor Yellow
        Write-LauncherLog "Antigravity IDE 已在运行: PID=$pids" -Level INFO
        return $true
    }

    if (-not (Test-Path -LiteralPath $Script:AntigravityIdeExe -PathType Leaf)) {
        Write-LauncherLog "未找到 Antigravity IDE 文件: $($Script:AntigravityIdeExe)" -Level ERROR
        Write-Host "  错误: 未找到 Antigravity IDE ($($Script:AntigravityIdeExe))" -ForegroundColor Red
        return $false
    }

    try {
        $workDir = Split-Path $Script:AntigravityIdeExe -Parent
        Start-Process -FilePath $Script:AntigravityIdeExe -WorkingDirectory $workDir
        Start-Sleep -Seconds 1
        $procs = Get-AntigravityIdeProcesses
        if ($procs.Count -gt 0) {
            $pids = ($procs | ForEach-Object ProcessId) -join ', '
            Write-Host "  [√] Antigravity IDE 启动成功 (PID: $pids)" -ForegroundColor Green
            Write-LauncherLog "Antigravity IDE 启动成功: PID=$pids" -Level INFO
            return $true
        } else {
            Write-Host '  Antigravity IDE 启动命令已发送。' -ForegroundColor Green
            Write-LauncherLog 'Antigravity IDE 启动命令已触发' -Level INFO
            return $true
        }
    } catch {
        Write-LauncherLog "启动 Antigravity IDE 失败: $($_.Exception.Message)" -Level ERROR
        Write-Host "  启动 Antigravity IDE 失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Start-ChatGptApp {
    <#
    .SYNOPSIS 启动 ChatGPT 桌面应用
    #>
    Write-Host ''
    Write-Host '  正在启动 ChatGPT ...' -ForegroundColor Green
    Write-LauncherLog '========== 启动 ChatGPT ==========' -Level INFO

    $procs = Get-ChatGptProcesses
    if ($procs.Count -gt 0) {
        $pids = ($procs | ForEach-Object ProcessId) -join ', '
        Write-Host "  ChatGPT 已经在运行中 (PID: $pids)，无需重复启动。" -ForegroundColor Yellow
        Write-LauncherLog "ChatGPT 已在运行: PID=$pids" -Level INFO
        return $true
    }

    try {
        $appId = Get-ChatGptAppId
        Start-Process -FilePath 'explorer.exe' -ArgumentList "shell:AppsFolder\$appId"
        Start-Sleep -Seconds 1
        $procs = Get-ChatGptProcesses
        if ($procs.Count -gt 0) {
            $pids = ($procs | ForEach-Object ProcessId) -join ', '
            Write-Host "  [√] ChatGPT 启动成功 (PID: $pids)" -ForegroundColor Green
            Write-LauncherLog "ChatGPT 启动成功: PID=$pids" -Level INFO
            return $true
        } else {
            Write-Host '  ChatGPT 启动命令已发送。' -ForegroundColor Green
            Write-LauncherLog "ChatGPT 启动命令已触发 (AppId=$appId)" -Level INFO
            return $true
        }
    } catch {
        Write-LauncherLog "启动 ChatGPT 失败: $($_.Exception.Message)" -Level ERROR
        Write-Host "  启动 ChatGPT 失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Start-CockpitApp {
    <#
    .SYNOPSIS 启动 Cockpit (Cockpit Tools)
    #>
    Write-Host ''
    Write-Host '  正在启动 Cockpit (Cockpit Tools) ...' -ForegroundColor Green
    Write-LauncherLog '========== 启动 Cockpit ==========' -Level INFO

    $procs = Get-CockpitProcesses
    if ($procs.Count -gt 0) {
        $pids = ($procs | ForEach-Object ProcessId) -join ', '
        Write-Host "  Cockpit 已经在运行中 (PID: $pids)，无需重复启动。" -ForegroundColor Yellow
        Write-LauncherLog "Cockpit 已在运行: PID=$pids" -Level INFO
        return $true
    }

    if (-not (Test-Path -LiteralPath $Script:CockpitExe -PathType Leaf)) {
        Write-LauncherLog "未找到 Cockpit 执行文件: $($Script:CockpitExe)" -Level ERROR
        Write-Host "  错误: 未找到 Cockpit ($($Script:CockpitExe))" -ForegroundColor Red
        return $false
    }

    try {
        Start-Process -FilePath 'explorer.exe' -ArgumentList "`"$($Script:CockpitExe)`""
        Start-Sleep -Seconds 2
        $procs = Get-CockpitProcesses
        if ($procs.Count -gt 0) {
            $pids = ($procs | ForEach-Object ProcessId) -join ', '
            Write-Host "  [√] Cockpit 启动成功 (PID: $pids)" -ForegroundColor Green
            Write-LauncherLog "Cockpit 启动成功: PID=$pids" -Level INFO
            return $true
        } else {
            Write-Host '  Cockpit 启动命令已发送。' -ForegroundColor Green
            Write-LauncherLog 'Cockpit 启动命令已触发' -Level INFO
            return $true
        }
    } catch {
        Write-LauncherLog "启动 Cockpit 失败: $($_.Exception.Message)" -Level ERROR
        Write-Host "  启动 Cockpit 失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

function Stop-AntigravityApp {
    <#
    .SYNOPSIS 停止 Antigravity 客户端
    #>
    Write-Host ''
    Write-Host '  正在停止 Antigravity 客户端 ...' -ForegroundColor Yellow
    Write-LauncherLog '========== 停止 Antigravity ==========' -Level INFO

    $procs = Get-AntigravityProcesses
    if ($procs.Count -eq 0) {
        Write-Host '  Antigravity 未在运行。' -ForegroundColor Yellow
        return $true
    }

    $allStopped = $true
    foreach ($p in $procs) {
        try {
            if (Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue) {
                Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
                Write-LauncherLog "已停止 Antigravity 进程: PID=$($p.ProcessId)" -Level INFO
            }
        } catch {
            Write-LauncherLog "停止 Antigravity 进程 PID=$($p.ProcessId) 异常: $($_.Exception.Message)" -Level WARN
        }
    }

    Start-Sleep -Milliseconds 300
    $remaining = Get-AntigravityProcesses
    if ($remaining.Count -eq 0) {
        Write-Host '  [√] Antigravity 已成功关闭。' -ForegroundColor Green
        return $true
    } else {
        Write-Host "  部分 Antigravity 进程未能关闭 (残留 PID: $(($remaining | ForEach-Object ProcessId) -join ', '))" -ForegroundColor Red
        return $false
    }
}

function Stop-AntigravityIdeApp {
    <#
    .SYNOPSIS 停止 Antigravity IDE
    #>
    Write-Host ''
    Write-Host '  正在停止 Antigravity IDE ...' -ForegroundColor Yellow
    Write-LauncherLog '========== 停止 Antigravity IDE ==========' -Level INFO

    $procs = Get-AntigravityIdeProcesses
    if ($procs.Count -eq 0) {
        Write-Host '  Antigravity IDE 未在运行。' -ForegroundColor Yellow
        return $true
    }

    $allStopped = $true
    foreach ($p in $procs) {
        try {
            if (Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue) {
                Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
                Write-LauncherLog "已停止 Antigravity IDE 进程: PID=$($p.ProcessId)" -Level INFO
            }
        } catch {
            Write-LauncherLog "停止 Antigravity IDE 进程 PID=$($p.ProcessId) 异常: $($_.Exception.Message)" -Level WARN
        }
    }

    Start-Sleep -Milliseconds 300
    $remaining = Get-AntigravityIdeProcesses
    if ($remaining.Count -eq 0) {
        Write-Host '  [√] Antigravity IDE 已成功关闭。' -ForegroundColor Green
        return $true
    } else {
        Write-Host "  部分 Antigravity IDE 进程未能关闭 (残留 PID: $(($remaining | ForEach-Object ProcessId) -join ', '))" -ForegroundColor Red
        return $false
    }
}

function Stop-ChatGptApp {
    <#
    .SYNOPSIS 停止 ChatGPT 桌面应用
    #>
    Write-Host ''
    Write-Host '  正在停止 ChatGPT ...' -ForegroundColor Yellow
    Write-LauncherLog '========== 停止 ChatGPT ==========' -Level INFO

    $procs = Get-ChatGptProcesses
    if ($procs.Count -eq 0) {
        Write-Host '  ChatGPT 未在运行。' -ForegroundColor Yellow
        return $true
    }

    $allStopped = $true
    foreach ($p in $procs) {
        try {
            if (Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue) {
                Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
                Write-LauncherLog "已停止 ChatGPT 进程: PID=$($p.ProcessId)" -Level INFO
            }
        } catch {
            Write-LauncherLog "停止 ChatGPT 进程 PID=$($p.ProcessId) 异常: $($_.Exception.Message)" -Level WARN
        }
    }

    Start-Sleep -Milliseconds 300
    $remaining = Get-ChatGptProcesses
    if ($remaining.Count -eq 0) {
        Write-Host '  [√] ChatGPT 已成功关闭。' -ForegroundColor Green
        return $true
    } else {
        Write-Host "  部分 ChatGPT 进程未能关闭 (残留 PID: $(($remaining | ForEach-Object ProcessId) -join ', '))" -ForegroundColor Red
        return $false
    }
}

function Stop-CockpitApp {
    <#
    .SYNOPSIS 停止 Cockpit (Cockpit Tools)
    #>
    Write-Host ''
    Write-Host '  正在停止 Cockpit (Cockpit Tools) ...' -ForegroundColor Yellow
    Write-LauncherLog '========== 停止 Cockpit ==========' -Level INFO

    $procs = Get-CockpitProcesses
    if ($procs.Count -eq 0) {
        Write-Host '  Cockpit 未在运行。' -ForegroundColor Yellow
        return $true
    }

    $allStopped = $true
    foreach ($p in $procs) {
        try {
            if (Get-Process -Id $p.ProcessId -ErrorAction SilentlyContinue) {
                Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
                Write-LauncherLog "已停止 Cockpit 进程: PID=$($p.ProcessId)" -Level INFO
            }
        } catch {
            Write-LauncherLog "停止 Cockpit 进程 PID=$($p.ProcessId) 异常: $($_.Exception.Message)" -Level WARN
        }
    }

    Start-Sleep -Milliseconds 300
    $remaining = Get-CockpitProcesses
    if ($remaining.Count -eq 0) {
        Write-Host '  [√] Cockpit 已成功关闭。' -ForegroundColor Green
        return $true
    } else {
        Write-Host "  部分 Cockpit 进程未能关闭 (残留 PID: $(($remaining | ForEach-Object ProcessId) -join ', '))" -ForegroundColor Red
        return $false
    }
}

function Start-AiSuite {
    <#
    .SYNOPSIS 一键统一启动全部 4 个 AI 桌面协同工具
    #>
    Write-Host ''
    Write-Host '  ============================================================' -ForegroundColor Magenta
    Write-Host '   一键启动 AI 桌面协同组合 (Antigravity / IDE / ChatGPT / Cockpit)' -ForegroundColor White
    Write-Host '  ============================================================' -ForegroundColor Magenta
    Write-LauncherLog '========== 一键统一启动 AI 桌面工具协同组合 ==========' -Level INFO

    $r1 = Start-AntigravityApp
    $r2 = Start-AntigravityIdeApp
    $r3 = Start-ChatGptApp
    $r4 = Start-CockpitApp

    Write-Host ''
    if ($r1 -and $r2 -and $r3 -and $r4) {
        Write-Host '  [√] AI 桌面工具协同组合已全部启动完毕！' -ForegroundColor Green
        Write-LauncherLog 'AI 桌面工具协同组合全部启动完成' -Level INFO
        return $true
    } else {
        Write-Host '  [!] 部分组件启动可能存在异常，请查看上方提示或组合状态。' -ForegroundColor Yellow
        Write-LauncherLog 'AI 桌面工具协同组合部分启动未完全就绪' -Level WARN
        return $false
    }
}

function Stop-AiSuite {
    <#
    .SYNOPSIS 一键全部关闭 4 个 AI 桌面协同工具
    #>
    Write-Host ''
    Write-Host '  ============================================================' -ForegroundColor Red
    Write-Host '   一键关闭 AI 桌面协同组合 (Antigravity / IDE / ChatGPT / Cockpit)' -ForegroundColor White
    Write-Host '  ============================================================' -ForegroundColor Red
    Write-LauncherLog '========== 一键统一关闭 AI 桌面工具协同组合 ==========' -Level INFO

    $r1 = Stop-AntigravityApp
    $r2 = Stop-AntigravityIdeApp
    $r3 = Stop-ChatGptApp
    $r4 = Stop-CockpitApp

    Write-Host ''
    if ($r1 -and $r2 -and $r3 -and $r4) {
        Write-Host '  [√] AI 桌面工具协同组合已全部关闭完毕！' -ForegroundColor Green
        Write-LauncherLog 'AI 桌面工具协同组合全部关闭完成' -Level INFO
        return $true
    } else {
        Write-Host '  [!] 部分组件关闭可能存在残留，请查看上方日志。' -ForegroundColor Yellow
        Write-LauncherLog 'AI 桌面工具协同组合部分组件未能完全关闭' -Level WARN
        return $false
    }
}

function Wait-ActionPause {
    <#
    .SYNOPSIS 操作执行完毕后稳定驻留反馈结果，清空输入缓冲并暂停等待，防止菜单立即刷新冲掉输出
    #>
    param(
        [string]$PromptText = '操作执行完毕。请查看上方反馈结果，按 [Enter] 键继续...'
    )
    Write-Host ''
    Write-Host '  ------------------------------------------------------------' -ForegroundColor DarkGray
    Write-Host "  [提示] $PromptText" -ForegroundColor DarkCyan
    Write-Host '         (日志已同步记录至 System\logs\launcher.log)' -ForegroundColor DarkGray

    # 清空输入缓冲区中可能残留的击键或换行
    try {
        while ($Host.UI.RawUI.KeyAvailable) {
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
        }
    } catch {}

    # 等待用户按 Enter 键确认继续
    try {
        $null = Read-Host
    } catch {
        Start-Sleep -Seconds 3
    }
}

function Show-AiSuiteMenu {
    <#
    .SYNOPSIS AI 桌面工具协同组合独立二级菜单
    #>
    Write-LauncherLog '进入 AI 桌面协同组合二级菜单' -Level INFO
    $inSuiteMenu = $true
    while ($inSuiteMenu) {
        $antiProcs    = Get-AntigravityProcesses
        $antiIdeProcs = Get-AntigravityIdeProcesses
        $chatGptProcs = Get-ChatGptProcesses
        $cockpitProcs = Get-CockpitProcesses

        Write-Host ''
        Write-Host '  ============================================================' -ForegroundColor Magenta
        Write-Host '   AI 桌面工具协同组合 (Antigravity / IDE / ChatGPT / Cockpit)' -ForegroundColor White
        Write-Host '  ============================================================' -ForegroundColor Magenta
        Write-Host ''
        Write-Host '   【当前组件运行状态】' -ForegroundColor Cyan
        Write-Host "     1. Antigravity:     $(if ($antiProcs.Count -gt 0) { '[√] 运行中 (PID: ' + (($antiProcs | ForEach-Object ProcessId) -join ', ') + ')' } else { '[x] 未运行' })" -ForegroundColor $(if ($antiProcs.Count -gt 0) { 'Green' } else { 'DarkGray' })
        Write-Host "     2. Antigravity IDE: $(if ($antiIdeProcs.Count -gt 0) { '[√] 运行中 (PID: ' + (($antiIdeProcs | ForEach-Object ProcessId) -join ', ') + ')' } else { '[x] 未运行' })" -ForegroundColor $(if ($antiIdeProcs.Count -gt 0) { 'Green' } else { 'DarkGray' })
        Write-Host "     3. ChatGPT:         $(if ($chatGptProcs.Count -gt 0) { '[√] 运行中 (PID: ' + (($chatGptProcs | ForEach-Object ProcessId) -join ', ') + ')' } else { '[x] 未运行' })" -ForegroundColor $(if ($chatGptProcs.Count -gt 0) { 'Green' } else { 'DarkGray' })
        Write-Host "     4. Cockpit:         $(if ($cockpitProcs.Count -gt 0) { '[√] 运行中 (PID: ' + (($cockpitProcs | ForEach-Object ProcessId) -join ', ') + ')' } else { '[x] 未运行' })" -ForegroundColor $(if ($cockpitProcs.Count -gt 0) { 'Green' } else { 'DarkGray' })
        Write-Host ''
        Write-Host '   【组合统一操作】' -ForegroundColor Yellow
        Write-Host '    [1]  一键全部启动 (4个工具同时启动)' -ForegroundColor Green
        Write-Host '    [2]  一键全部关闭 (4个工具同时关闭)' -ForegroundColor Red
        Write-Host ''
        Write-Host '   【独立控制 - 启动】' -ForegroundColor Yellow
        Write-Host '    [3]  启动 Antigravity' -ForegroundColor Green
        Write-Host '    [5]  启动 Antigravity IDE' -ForegroundColor Green
        Write-Host '    [7]  启动 ChatGPT' -ForegroundColor Green
        Write-Host '    [9]  启动 Cockpit (Cockpit Tools)' -ForegroundColor Green
        Write-Host ''
        Write-Host '   【独立控制 - 关闭】' -ForegroundColor Yellow
        Write-Host '    [4]  关闭 Antigravity' -ForegroundColor Red
        Write-Host '    [6]  关闭 Antigravity IDE' -ForegroundColor Red
        Write-Host '    [8]  关闭 ChatGPT' -ForegroundColor Red
        Write-Host '    [10] 关闭 Cockpit (Cockpit Tools)' -ForegroundColor Red
        Write-Host ''
        Write-Host '    [R]   刷新当前状态' -ForegroundColor Cyan
        Write-Host '    [CLS] 清屏' -ForegroundColor DarkGray
        Write-Host '    [0]   返回主菜单' -ForegroundColor Gray
        Write-Host ''
        Write-Host '  ============================================================' -ForegroundColor Magenta
        Write-Host ''

        $subChoice = Read-Host '  请选择 AI 组合操作 [0-10, R, CLS]'
        if ([string]::IsNullOrWhiteSpace($subChoice)) { continue }
        $subKey = $subChoice.Trim().ToLowerInvariant()

        switch ($subKey) {
            '1' { $null = Start-AiSuite }
            '2' { $null = Stop-AiSuite }
            '3' { $null = Start-AntigravityApp }
            '4' { $null = Stop-AntigravityApp }
            '5' { $null = Start-AntigravityIdeApp }
            '6' { $null = Stop-AntigravityIdeApp }
            '7' { $null = Start-ChatGptApp }
            '8' { $null = Stop-ChatGptApp }
            '9' { $null = Start-CockpitApp }
            '10' { $null = Stop-CockpitApp }
            'r' { continue }
            'cls' { Clear-Host; continue }
            'clear' { Clear-Host; continue }
            '0' {
                Write-Host '  已返回统一启动器主菜单。' -ForegroundColor Gray
                $inSuiteMenu = $false
                break
            }
            default {
                Write-Host '  无效选项，请重新输入。' -ForegroundColor Yellow
            }
        }
        if ($inSuiteMenu -and $subKey -notin @('r', 'cls', 'clear', '0')) {
            Wait-ActionPause -PromptText 'AI 套件操作已完成。按 [Enter] 键刷新并返回菜单...'
        }
    }
}

# ============================================================
# WSL 专区 (Ubuntu): DeepSeek Harness / Antigravity 套件
# ============================================================

function Invoke-WslHelper {
    <#
    .SYNOPSIS 调用 WSL 内的管理助手脚本，返回清理后的输出行与退出码
    .NOTES wsl.exe 的 UTF-16 通知行含 NUL 字符，直接过滤避免污染菜单；
           EAP=Stop 下 wsl.exe 的 stderr 会抛 NativeCommandError，临时降级规避。
    #>
    param(
        [Parameter(Mandatory)][ValidateSet('dsh', 'ag', 'feishu')][string]$Helper,
        [string[]]$WslArgs = @()
    )
    $helperPath = switch ($Helper) {
        'dsh'    { $Script:WslDshHelperPath }
        'ag'     { $Script:WslAgHelperPath }
        'feishu' { $Script:WslFeishuHelperPath }
    }
    $prevEap = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $raw = @( & wsl.exe -d $Script:WslDistro -- $helperPath @WslArgs 2>&1 )
        $lines = @()
        foreach ($item in $raw) {
            $text = [string]$item
            if ($text.Length -eq 0) { continue }
            if ($text.IndexOf([char]0) -ge 0) { continue }
            $lines += $text
        }
        return [pscustomobject]@{ Lines = $lines; ExitCode = $LASTEXITCODE }
    } catch {
        Write-LauncherLog "WSL 助手调用失败 ($Helper $($WslArgs -join ' ')): $($_.Exception.Message)" -Level ERROR
        return [pscustomobject]@{ Lines = @("WSL call failed: $($_.Exception.Message)"); ExitCode = 1 }
    } finally {
        $ErrorActionPreference = $prevEap
    }
}

function Get-WslDshState {
    <#
    .SYNOPSIS 查询 DeepSeek Harness WSL 运行状态 (一次 wsl 调用)
    #>
    $res = Invoke-WslHelper -Helper dsh -WslArgs @('status')
    $listenLine = $res.Lines | Where-Object { $_ -match ':' + [string]$Script:WslDshPort } | Select-Object -First 1
    $procLine = $res.Lines | Where-Object { $_ -match '^\s*\d+\s+.*bin\.js' } | Select-Object -First 1
    $procId = $null
    if ($procLine -and $procLine -match '^\s*(\d+)') { $procId = $Matches[1] }
    return [pscustomobject]@{
        Running = [bool]$listenLine
        Pid     = $procId
        Lines   = $res.Lines
    }
}

function Get-WslAntigravityState {
    <#
    .SYNOPSIS 查询 Antigravity WSL 套件三组件状态 (一次 wsl 调用)
    #>
    $res = Invoke-WslHelper -Helper ag -WslArgs @('status')
    $state = @{ Gui = $false; Ide = $false; Cockpit = $false; Pids = @{} }
    foreach ($line in $res.Lines) {
        if ($line -match '^(gui|ide|cockpit):\s+(RUNNING|stopped)(?:\s+pid=(.*))?$') {
            $key = switch ($Matches[1]) { 'gui' { 'Gui' } 'ide' { 'Ide' } 'cockpit' { 'Cockpit' } }
            $state[$key] = ($Matches[2] -eq 'RUNNING')
            if ($Matches[3]) { $state.Pids[$key] = $Matches[3] }
        }
    }
    return [pscustomobject]$state
}

function Show-WslHelperLines {
    param([Parameter(Mandatory)]$Result)
    foreach ($line in $Result.Lines) { Write-Host "    $line" -ForegroundColor Cyan }
}

function Start-WslDsh {
    <#
    .SYNOPSIS 启动 DeepSeek Harness WSL 版 (Ubuntu :9011，首次启动约 30s)
    #>
    Write-Host ''
    Write-Host '  正在启动 DeepSeek Harness WSL 版 (Ubuntu :9011) ...' -ForegroundColor Green
    Write-LauncherLog '启动 DeepSeek Harness WSL 版' -Level INFO
    $res = Invoke-WslHelper -Helper dsh -WslArgs @('start')
    Show-WslHelperLines $res
    if ($res.ExitCode -eq 0) {
        Write-Host '  [√] DeepSeek Harness WSL 已就绪。' -ForegroundColor Green
        return $true
    }
    Write-Host '  [x] DeepSeek Harness WSL 启动失败，请查看 WSL 日志。' -ForegroundColor Red
    return $false
}

function Stop-WslDsh {
    <#
    .SYNOPSIS 停止 DeepSeek Harness WSL 版
    #>
    Write-LauncherLog '停止 DeepSeek Harness WSL 版' -Level INFO
    $res = Invoke-WslHelper -Helper dsh -WslArgs @('stop')
    Show-WslHelperLines $res
    if ($res.ExitCode -eq 0) {
        Write-Host '  [√] DeepSeek Harness WSL 已停止。' -ForegroundColor Green
        return $true
    }
    Write-Host '  [x] DeepSeek Harness WSL 停止失败。' -ForegroundColor Red
    return $false
}

function Restart-WslDsh {
    <#
    .SYNOPSIS 重启 DeepSeek Harness WSL 版
    #>
    Write-Host ''
    Write-Host '  正在重启 DeepSeek Harness WSL 版 (Ubuntu :9011) ...' -ForegroundColor Green
    Write-LauncherLog '重启 DeepSeek Harness WSL 版' -Level INFO
    $res = Invoke-WslHelper -Helper dsh -WslArgs @('restart')
    Show-WslHelperLines $res
    if ($res.ExitCode -eq 0) {
        Write-Host '  [√] DeepSeek Harness WSL 重启完成。' -ForegroundColor Green
        return $true
    }
    Write-Host '  [x] DeepSeek Harness WSL 重启失败，请查看 WSL 日志。' -ForegroundColor Red
    return $false
}

function Get-WslDshUrl {
    <#
    .SYNOPSIS 获取 DeepSeek Harness WSL 当前带 token 的访问地址
    #>
    $res = Invoke-WslHelper -Helper dsh -WslArgs @('url')
    $url = $res.Lines | Where-Object { $_ -match '^http://127\.0\.0\.1:' + [string]$Script:WslDshPort + '/\?token=' } | Select-Object -Last 1
    if ($url) { return $url }
    return $Script:WslDshUrl
}

function Open-WslDshDashboard {
    <#
    .SYNOPSIS 用浏览器打开 DeepSeek Harness WSL 版 (localhost 中继直达 WSL)
    #>
    $url = Get-WslDshUrl
    Write-LauncherLog "打开 DeepSeek Harness WSL 网页: $url" -Level INFO
    try {
        if (Test-Path -LiteralPath $Script:DshBrowserPath) {
            Start-Process -FilePath $Script:DshBrowserPath -ArgumentList $url
        } else {
            Start-Process $url
        }
        Write-Host "  已打开 DeepSeek Harness WSL: $url" -ForegroundColor Magenta
        return $true
    } catch {
        Write-LauncherLog "打开 DeepSeek Harness WSL 失败: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Start-WslAntigravity {
    <#
    .SYNOPSIS 启动 Antigravity WSL 组件 (gui/ide/cockpit/all)
    #>
    param([ValidateSet('gui', 'ide', 'cockpit', 'all')][string]$Component = 'gui')
    Write-Host ''
    Write-Host "  正在启动 Antigravity WSL 组件 ($Component，WSLg 窗口) ..." -ForegroundColor Green
    Write-LauncherLog "启动 Antigravity WSL ($Component)" -Level INFO
    $res = Invoke-WslHelper -Helper ag -WslArgs @('start', $Component)
    Show-WslHelperLines $res
    if ($res.ExitCode -eq 0) { return $true }
    Write-Host "  [x] Antigravity WSL ($Component) 启动失败。" -ForegroundColor Red
    return $false
}

function Stop-WslAntigravity {
    <#
    .SYNOPSIS 关闭 Antigravity WSL 组件 (gui/ide/cockpit/all)
    #>
    param([ValidateSet('gui', 'ide', 'cockpit', 'all')][string]$Component = 'gui')
    Write-LauncherLog "停止 Antigravity WSL ($Component)" -Level INFO
    $res = Invoke-WslHelper -Helper ag -WslArgs @('stop', $Component)
    Show-WslHelperLines $res
    if ($res.ExitCode -eq 0) { return $true }
    Write-Host "  [x] Antigravity WSL ($Component) 关闭失败。" -ForegroundColor Red
    return $false
}

function Restart-WslAntigravity {
    <#
    .SYNOPSIS 重启 Antigravity WSL 组件 (gui/ide/cockpit/all)
    #>
    param([ValidateSet('gui', 'ide', 'cockpit', 'all')][string]$Component = 'gui')
    Write-Host ''
    Write-Host "  正在重启 Antigravity WSL 组件 ($Component) ..." -ForegroundColor Green
    Write-LauncherLog "重启 Antigravity WSL ($Component)" -Level INFO
    $res = Invoke-WslHelper -Helper ag -WslArgs @('restart', $Component)
    Show-WslHelperLines $res
    if ($res.ExitCode -eq 0) { return $true }
    Write-Host "  [x] Antigravity WSL ($Component) 重启失败。" -ForegroundColor Red
    return $false
}

function Start-WslSuite {
    <#
    .SYNOPSIS 一键启动 WSL 专区全部 (DeepSeek Harness + Antigravity 套件)
    #>
    $d = Start-WslDsh
    $a = Start-WslAntigravity -Component all
    return ($d -and $a)
}

function Stop-WslSuite {
    <#
    .SYNOPSIS 一键停止 WSL 专区全部 (DeepSeek Harness + Antigravity 套件)
    #>
    $d = Stop-WslDsh
    $a = Stop-WslAntigravity -Component all
    return ($d -and $a)
}

function Show-WslSummary {
    <#
    .SYNOPSIS 显示 WSL 专区状态看板 (供全局 status 与专区菜单使用)
    #>
    Write-Host '  -- WSL 专区状态 (Ubuntu) --' -ForegroundColor DarkCyan
    $dsh = Get-WslDshState
    if ($dsh.Running) {
        Write-Host "  DeepSeek Harness WSL: 运行中 (PID: $($dsh.Pid), 端口 $($Script:WslDshPort))" -ForegroundColor Green
    } else {
        Write-Host '  DeepSeek Harness WSL: 未运行' -ForegroundColor Yellow
    }
    $ag = Get-WslAntigravityState
    $components = @(
        @{ Name = 'Antigravity GUI WSL'; Key = 'Gui' },
        @{ Name = 'Antigravity IDE WSL'; Key = 'Ide' },
        @{ Name = 'Cockpit WSL';         Key = 'Cockpit' }
    )
    foreach ($c in $components) {
        $running = [bool]$ag.($c.Key)
        $pidText = if ($running -and $ag.Pids[$c.Key]) { " (PID: $($ag.Pids[$c.Key]))" } else { '' }
        $mark = if ($running) { '[√] 运行中' } else { '[x] 未运行' }
        Write-Host "  $($c.Name): $mark$pidText" -ForegroundColor $(if ($running) { 'Green' } else { 'DarkGray' })
    }
}

function Show-WslMenu {
    <#
    .SYNOPSIS WSL 专区独立二级菜单 (DeepSeek Harness / Antigravity 套件)
    #>
    Write-LauncherLog '进入 WSL 专区二级菜单' -Level INFO
    $inWslMenu = $true
    while ($inWslMenu) {
        $dsh = Get-WslDshState
        $ag  = Get-WslAntigravityState

        Write-Host ''
        Write-Host '  ============================================================' -ForegroundColor DarkCyan
        Write-Host '   WSL 专区 (Ubuntu): DeepSeek Harness / Antigravity 套件' -ForegroundColor White
        Write-Host '  ============================================================' -ForegroundColor DarkCyan
        Write-Host ''
        Write-Host '   【当前组件运行状态】' -ForegroundColor Cyan
        $dshMark = if ($dsh.Running) { "[√] 运行中 (PID: $($dsh.Pid))" } else { '[x] 未运行' }
        Write-Host "     DeepSeek Harness ($($Script:WslDshPort)): $dshMark" -ForegroundColor $(if ($dsh.Running) { 'Green' } else { 'DarkGray' })
        $antiRows = @(
            @{ Label = 'Antigravity GUI:'; Key = 'Gui' },
            @{ Label = 'Antigravity IDE:'; Key = 'Ide' },
            @{ Label = 'Cockpit:        '; Key = 'Cockpit' }
        )
        foreach ($row in $antiRows) {
            $running = [bool]$ag.($row.Key)
            $pidText = if ($running -and $ag.Pids[$row.Key]) { " (PID: $($ag.Pids[$row.Key]))" } else { '' }
            $mark = if ($running) { '[√] 运行中' } else { '[x] 未运行' }
            Write-Host "     $($row.Label) $mark$pidText" -ForegroundColor $(if ($running) { 'Green' } else { 'DarkGray' })
        }
        Write-Host ''
        Write-Host '   【统一操作】' -ForegroundColor Yellow
        Write-Host '    [1]  一键全部启动 (dsh + Antigravity 套件)' -ForegroundColor Green
        Write-Host '    [2]  一键全部关闭 (dsh + Antigravity 套件)' -ForegroundColor Red
        Write-Host ''
        Write-Host '   【DeepSeek Harness WSL (:9011)】' -ForegroundColor Yellow
        Write-Host '    [3]  启动      [4]  停止      [5]  重启      [6]  打开网页 (token)' -ForegroundColor Green
        Write-Host ''
        Write-Host '   【Antigravity WSL (WSLg 窗口)】' -ForegroundColor Yellow
        Write-Host '    [7]  启动 GUI      [8]  关闭 GUI      [9]  重启 GUI' -ForegroundColor Green
        Write-Host '    [10] 启动 IDE      [11] 关闭 IDE      [12] 重启 IDE' -ForegroundColor Green
        Write-Host '    [13] 启动 Cockpit  [14] 关闭 Cockpit  [15] 重启 Cockpit' -ForegroundColor Green
        Write-Host ''
        Write-Host '    [R]   刷新当前状态' -ForegroundColor Cyan
        Write-Host '    [CLS] 清屏' -ForegroundColor DarkGray
        Write-Host '    [0]   返回主菜单' -ForegroundColor Gray
        Write-Host ''
        Write-Host '  ============================================================' -ForegroundColor DarkCyan
        Write-Host ''

        $subChoice = Read-Host '  请选择 WSL 专区操作 [0-15, R, CLS]'
        if ([string]::IsNullOrWhiteSpace($subChoice)) { continue }
        $subKey = $subChoice.Trim().ToLowerInvariant()

        switch ($subKey) {
            '1'  { $null = Start-WslSuite }
            '2'  { $null = Stop-WslSuite }
            '3'  { $null = Start-WslDsh }
            '4'  { $null = Stop-WslDsh }
            '5'  { $null = Restart-WslDsh }
            '6'  { $null = Open-WslDshDashboard }
            '7'  { $null = Start-WslAntigravity -Component gui }
            '8'  { $null = Stop-WslAntigravity -Component gui }
            '9'  { $null = Restart-WslAntigravity -Component gui }
            '10' { $null = Start-WslAntigravity -Component ide }
            '11' { $null = Stop-WslAntigravity -Component ide }
            '12' { $null = Restart-WslAntigravity -Component ide }
            '13' { $null = Start-WslAntigravity -Component cockpit }
            '14' { $null = Stop-WslAntigravity -Component cockpit }
            '15' { $null = Restart-WslAntigravity -Component cockpit }
            'r' { continue }
            'cls' { Clear-Host; continue }
            'clear' { Clear-Host; continue }
            '0' {
                Write-Host '  已返回统一启动器主菜单。' -ForegroundColor Gray
                $inWslMenu = $false
                break
            }
            default {
                Write-Host '  无效选项，请重新输入。' -ForegroundColor Yellow
            }
        }
        if ($inWslMenu -and $subKey -notin @('r', 'cls', 'clear', '0')) {
            Wait-ActionPause -PromptText 'WSL 专区操作已完成。按 [Enter] 键刷新并返回菜单...'
        }
    }
}


# ============================================================
# 飞书机器人与根服务专区 (BotMux + OpenCode 2 / Antigravity 根服务)
# ============================================================

function Get-WslFeishuState {
    <#
    .SYNOPSIS 查询底层核心根服务与飞书机器人桥接 (OpenCode 2 + Antigravity) 运行状态
    #>
    $res = Invoke-WslHelper -Helper feishu -WslArgs @('status')
    $state = @{
        Opencode2Core       = $false
        Opencode2CorePid    = $null
        Opencode2CoreUrl    = $Script:WslOpencode2Url
        AntigravityCore     = $false
        AntigravityCorePid  = $null
        Supervisor          = $false
        Antigravity         = $false
        OpenCode2           = $false
        Dashboard           = $false
        AntigravityDisabled = $false
        OpenCode2Disabled   = $false
        Pids                = @{}
        Port                = $Script:WslFeishuPort
        Lines               = $res.Lines
    }
    foreach ($line in $res.Lines) {
        if ($line -match '^opencode2-core:\s+(RUNNING|stopped)(?:\s+pid=(\d+))?(?:\s+url=(.+))?') {
            $state.Opencode2Core = ($Matches[1] -eq 'RUNNING')
            if ($Matches[2]) { $state.Opencode2CorePid = $Matches[2]; $state.Pids['opencode2-core'] = $Matches[2] }
            if ($Matches[3]) { $state.Opencode2CoreUrl = $Matches[3].Trim() }
        }
        elseif ($line -match '^antigravity-core:\s+(RUNNING|stopped)(?:\s+pid=(\d+))?') {
            $state.AntigravityCore = ($Matches[1] -eq 'RUNNING')
            if ($Matches[2]) { $state.AntigravityCorePid = $Matches[2]; $state.Pids['antigravity-core'] = $Matches[2] }
        }
        elseif ($line -match '^(supervisor|antigravity|opencode2|dashboard):\s+(RUNNING|STOPPED|DISABLED)(?:\s+pid=(\d+))?(?:\s+port=(\d+))?') {
            $comp = $Matches[1]
            $status = $Matches[2]
            $running = ($status -eq 'RUNNING')
            $disabled = ($status -eq 'DISABLED')
            switch ($comp) {
                'supervisor'  { $state.Supervisor  = $running }
                'antigravity' { $state.Antigravity = $running; $state.AntigravityDisabled = $disabled }
                'opencode2'   { $state.OpenCode2   = $running; $state.OpenCode2Disabled   = $disabled }
                'dashboard'   { $state.Dashboard   = $running }
            }
            if ($Matches[3]) { $state.Pids[$comp] = $Matches[3] }
            if ($Matches[4]) { $state.Port = [int]$Matches[4] }
        }
    }
    return [pscustomobject]$state
}

function Show-WslFeishuSummary {
    <#
    .SYNOPSIS 显示根服务与飞书双机器人综合状态看板
    #>
    Write-Host '  -- 根服务与飞书双机器人状态看板 (OpenCode 2 + Antigravity) --' -ForegroundColor DarkCyan
    $fs = Get-WslFeishuState

    Write-Host '   [底层核心根服务 (Core Engine Services)]' -ForegroundColor Cyan
    $opCoreMark = if ($fs.Opencode2Core) { "[√] 运行中 (PID: $($fs.Opencode2CorePid)) $($fs.Opencode2CoreUrl)" } else { '[x] 未运行' }
    $agCoreMark = if ($fs.AntigravityCore) { "[√] 运行中 (PID: $($fs.AntigravityCorePid))" } else { '[x] 未运行' }
    Write-Host "     OpenCode 2 根服务:    $opCoreMark" -ForegroundColor $(if ($fs.Opencode2Core) { 'Green' } else { 'DarkGray' })
    Write-Host "     Antigravity 根服务:   $agCoreMark" -ForegroundColor $(if ($fs.AntigravityCore) { 'Green' } else { 'DarkGray' })

    Write-Host '   [飞书机器人桥接 (BotMux Adapters)]' -ForegroundColor Cyan
    $supMark = if ($fs.Supervisor) { "[√] 运行中 (PID: $($fs.Pids['supervisor']))" } else { '[x] 未运行' }
    Write-Host "     守护总管 (Supervisor): $supMark" -ForegroundColor $(if ($fs.Supervisor) { 'Green' } else { 'DarkGray' })

    $agMark = if ($fs.Antigravity) {
        "[√] 运行中 (PID: $($fs.Pids['antigravity']))"
    } elseif ($fs.AntigravityDisabled) {
        '[-] 已关闭 (未启用)'
    } else {
        '[x] 未运行'
    }
    $agColor = if ($fs.Antigravity) { 'Green' } elseif ($fs.AntigravityDisabled) { 'DarkYellow' } else { 'DarkGray' }
    Write-Host "     Antigravity 机器人:    $agMark" -ForegroundColor $agColor

    $opMark = if ($fs.OpenCode2) {
        "[√] 运行中 (PID: $($fs.Pids['opencode2']))"
    } elseif ($fs.OpenCode2Disabled) {
        '[-] 已关闭 (未启用)'
    } else {
        '[x] 未运行'
    }
    $opColor = if ($fs.OpenCode2) { 'Green' } elseif ($fs.OpenCode2Disabled) { 'DarkYellow' } else { 'DarkGray' }
    Write-Host "     OpenCode 2 机器人:     $opMark" -ForegroundColor $opColor

    $dashMark = if ($fs.Dashboard) { "[√] 运行中 (http://127.0.0.1:$($fs.Port))" } else { '[x] 未运行' }
    Write-Host "     Web 终端管理面板:      $dashMark" -ForegroundColor $(if ($fs.Dashboard) { 'Green' } else { 'DarkGray' })
}

function Start-WslFeishuBridge {
    <#
    .SYNOPSIS 启动飞书双机器人桥接及根服务
    #>
    param([string]$Target = 'all')
    Write-Host ''
    if ($Target -in @('all', 'all-full', '*')) {
        Write-Host '  正在一键全套启动 (OpenCode 2 根服务 + Antigravity 根服务 + 飞书双桥接) ...' -ForegroundColor Green
    } else {
        Write-Host "  正在启动目标服务 ($Target) ..." -ForegroundColor Green
    }
    Write-LauncherLog "启动目标服务 ($Target)" -Level INFO
    $res = Invoke-WslHelper -Helper feishu -WslArgs @('start', $Target)
    Show-WslHelperLines $res
    if ($res.ExitCode -eq 0) {
        Write-Host "  [√] 启动命令执行完成 ($Target)。" -ForegroundColor Green
        return $true
    }
    Write-Host "  [x] 启动失败 ($Target)，请检查 WSL 日志。" -ForegroundColor Red
    return $false
}

function Stop-WslFeishuBridge {
    <#
    .SYNOPSIS 停止飞书双机器人桥接及根服务
    #>
    param([string]$Target = 'all')
    Write-Host ''
    if ($Target -in @('all', 'all-full', '*')) {
        Write-Host '  正在一键全套停止 (飞书双桥接 + 核心根服务) ...' -ForegroundColor Yellow
    } else {
        Write-Host "  正在停止目标服务 ($Target) ..." -ForegroundColor Yellow
    }
    Write-LauncherLog "停止目标服务 ($Target)" -Level INFO
    $res = Invoke-WslHelper -Helper feishu -WslArgs @('stop', $Target)
    Show-WslHelperLines $res
    if ($res.ExitCode -eq 0) {
        Write-Host "  [√] 停止操作已完成 ($Target)。" -ForegroundColor Green
        return $true
    }
    Write-Host "  [x] 停止失败 ($Target)。" -ForegroundColor Red
    return $false
}

function Restart-WslFeishuBridge {
    <#
    .SYNOPSIS 重启飞书双机器人桥接及根服务
    #>
    param([string]$Target = 'all')
    Write-Host ''
    Write-Host "  正在重启目标服务 ($Target) ..." -ForegroundColor Green
    Write-LauncherLog "重启目标服务 ($Target)" -Level INFO
    $res = Invoke-WslHelper -Helper feishu -WslArgs @('restart', $Target)
    Show-WslHelperLines $res
    if ($res.ExitCode -eq 0) {
        Write-Host "  [√] 重启完成 ($Target)。" -ForegroundColor Green
        return $true
    }
    Write-Host "  [x] 重启失败 ($Target)。" -ForegroundColor Red
    return $false
}

function Start-WslFeishuBot {
    <#
    .SYNOPSIS 启动指定的飞书机器人服务 (自动前置拉起根服务)
    #>
    param([ValidateSet('opencode2', 'antigravity')][string]$Bot = 'opencode2')
    return Start-WslFeishuBridge -Target $Bot
}

function Stop-WslFeishuBot {
    <#
    .SYNOPSIS 关闭指定的飞书机器人桥接服务
    #>
    param([ValidateSet('opencode2', 'antigravity')][string]$Bot = 'opencode2')
    return Stop-WslFeishuBridge -Target $Bot
}

function Restart-WslFeishuBot {
    <#
    .SYNOPSIS 重启指定的飞书机器人桥接服务
    #>
    param([ValidateSet('opencode2', 'antigravity', 'all')][string]$Bot = 'all')
    return Restart-WslFeishuBridge -Target $Bot
}

function Show-Opencode2PairInfo {
    <#
    .SYNOPSIS 查看 OpenCode 2 Web / 远程配对信息与访问凭据
    #>
    Write-Host ''
    Write-Host '  --- OpenCode 2 Web 配对与连接凭据 ---' -ForegroundColor Cyan
    $res = Invoke-WslHelper -Helper feishu -WslArgs @('pair')
    Show-WslHelperLines $res
    Write-Host ''
}

function Open-Opencode2Web {
    <#
    .SYNOPSIS 浏览器打开 OpenCode 2 Web 服务
    #>
    $url = $Script:WslOpencode2Url
    Write-LauncherLog "打开 OpenCode 2 Web 服务: $url" -Level INFO
    try {
        if (Test-Path -LiteralPath $Script:DshBrowserPath) {
            Start-Process -FilePath $Script:DshBrowserPath -ArgumentList $url
        } else {
            Start-Process $url
        }
        Write-Host "  已在浏览器中打开 OpenCode 2 Web: $url" -ForegroundColor Magenta
        return $true
    } catch {
        Write-LauncherLog "打开 OpenCode 2 Web 失败: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Open-WslFeishuDashboard {
    <#
    .SYNOPSIS 浏览器打开飞书桥接 BotMux 管理面板 (默认 http://127.0.0.1:7891)
    #>
    $url = $Script:WslFeishuUrl
    Write-LauncherLog "打开飞书桥接管理面板: $url" -Level INFO
    try {
        if (Test-Path -LiteralPath $Script:DshBrowserPath) {
            Start-Process -FilePath $Script:DshBrowserPath -ArgumentList $url
        } else {
            Start-Process $url
        }
        Write-Host "  已在浏览器中打开飞书桥接管理面板: $url" -ForegroundColor Magenta
        return $true
    } catch {
        Write-LauncherLog "打开飞书桥接管理面板失败: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Show-WslFeishuLogs {
    <#
    .SYNOPSIS 查看飞书桥接与根服务日志
    #>
    param([string]$Target = 'all')
    Write-Host ''
    Write-Host "  --- 运行日志 ($Target) ---" -ForegroundColor Cyan
    $res = Invoke-WslHelper -Helper feishu -WslArgs @('logs', $Target)
    Show-WslHelperLines $res
    Write-Host ''
}

function Show-WslFeishuMenu {
    <#
    .SYNOPSIS 飞书机器人与根服务专区菜单 (OpenCode 2 + Antigravity 根服务/桥接/面板/日志 统一与独立控制)
    #>
    Write-LauncherLog '进入飞书机器人与根服务二级菜单' -Level INFO
    $inFeishuMenu = $true
    while ($inFeishuMenu) {
        $fs = Get-WslFeishuState
        Write-Host ''
        Write-Host '  ============================================================' -ForegroundColor DarkCyan
        Write-Host '   飞书机器人与根服务专区 (OpenCode 2 + Antigravity 协同体系)' -ForegroundColor White
        Write-Host '  ============================================================' -ForegroundColor DarkCyan
        Write-Host ''
        Write-Host '   【当前状态看板】' -ForegroundColor Cyan

        # 根服务
        $opCoreMark = if ($fs.Opencode2Core) { "[√] 运行中 (PID: $($fs.Opencode2CorePid)) $($fs.Opencode2CoreUrl)" } else { '[x] 未运行' }
        $agCoreMark = if ($fs.AntigravityCore) { "[√] 运行中 (PID: $($fs.AntigravityCorePid))" } else { '[x] 未运行' }
        Write-Host "     [底层根服务] OpenCode 2 核心根服务:    $opCoreMark" -ForegroundColor $(if ($fs.Opencode2Core) { 'Green' } else { 'DarkGray' })
        Write-Host "     [底层根服务] Antigravity 核心根服务:   $agCoreMark" -ForegroundColor $(if ($fs.AntigravityCore) { 'Green' } else { 'DarkGray' })

        # 飞书机器人
        $supMark  = if ($fs.Supervisor)  { "[√] 运行中 (PID: $($fs.Pids['supervisor']))" } else { '[x] 未运行' }
        $agMark   = if ($fs.Antigravity) { "[√] 运行中 (PID: $($fs.Pids['antigravity']))" } elseif ($fs.AntigravityDisabled) { '[-] 已关闭 (未启用)' } else { '[x] 未运行' }
        $opMark   = if ($fs.OpenCode2)   { "[√] 运行中 (PID: $($fs.Pids['opencode2']))" } elseif ($fs.OpenCode2Disabled) { '[-] 已关闭 (未启用)' } else { '[x] 未运行' }
        $dashMark = if ($fs.Dashboard)   { "[√] 运行中 (http://127.0.0.1:$($fs.Port))" } else { '[x] 未运行' }
        Write-Host "     [飞书桥接]   守护总管 (Supervisor):   $supMark" -ForegroundColor $(if ($fs.Supervisor) { 'Green' } else { 'DarkGray' })
        Write-Host "     [飞书桥接]   OpenCode 2 飞书机器人:   $opMark" -ForegroundColor $(if ($fs.OpenCode2) { 'Green' } elseif ($fs.OpenCode2Disabled) { 'DarkYellow' } else { 'DarkGray' })
        Write-Host "     [飞书桥接]   Antigravity 飞书机器人:  $agMark" -ForegroundColor $(if ($fs.Antigravity) { 'Green' } elseif ($fs.AntigravityDisabled) { 'DarkYellow' } else { 'DarkGray' })
        Write-Host "     [控制面板]   Web 终端管理看板:        $dashMark" -ForegroundColor $(if ($fs.Dashboard) { 'Green' } else { 'DarkGray' })
        Write-Host ''
        Write-Host '   【全域一键协同操作】' -ForegroundColor Yellow
        Write-Host '    [1]  一键全部启动 (OpenCode 2 根+桥 + Antigravity 根+桥 全套拉起)' -ForegroundColor Green
        Write-Host '    [2]  一键全部关闭 (全套桥接 + 全套根服务 彻底停止)' -ForegroundColor Red
        Write-Host '    [3]  一键全部重启 (全套根服务与桥接热重启)' -ForegroundColor Green
        Write-Host '    [4]  仅关闭飞书双桥接 (保持底层根服务持续运行)' -ForegroundColor Red
        Write-Host ''
        Write-Host '   【OpenCode 2 专属控制】' -ForegroundColor Yellow
        Write-Host '    [5]  一键拉起 OpenCode 2 全套 (根服务 + 飞书桥接)' -ForegroundColor Green
        Write-Host '    [6]  单独启动 OpenCode 2 根服务 (后台 Web/API 服务)' -ForegroundColor Green
        Write-Host '    [7]  单独关闭 OpenCode 2 根服务' -ForegroundColor Red
        Write-Host '    [8]  单独启动 OpenCode 2 飞书桥接' -ForegroundColor Green
        Write-Host '    [9]  单独关闭 OpenCode 2 飞书桥接' -ForegroundColor Red
        Write-Host '    [10] 查看 OpenCode 2 配对凭据 (Pair Info / 密码)' -ForegroundColor Cyan
        Write-Host '    [11] 查看 OpenCode 2 飞书运行日志' -ForegroundColor Cyan
        Write-Host ''
        Write-Host '   【Antigravity 专属控制】' -ForegroundColor Yellow
        Write-Host '    [12] 一键拉起 Antigravity 全套 (根服务 + 飞书桥接)' -ForegroundColor Green
        Write-Host '    [13] 单独启动 Antigravity 根服务 (Remote-Control 核心守护)' -ForegroundColor Green
        Write-Host '    [14] 单独关闭 Antigravity 根服务' -ForegroundColor Red
        Write-Host '    [15] 单独启动 Antigravity 飞书桥接' -ForegroundColor Green
        Write-Host '    [16] 单独关闭 Antigravity 飞书桥接' -ForegroundColor Red
        Write-Host '    [17] 查看 Antigravity 飞书运行日志' -ForegroundColor Cyan
        Write-Host ''
        Write-Host '   【Web 控制台与综合运维】' -ForegroundColor Yellow
        Write-Host '    [18] 打开飞书桥接 Web 终端面板 (http://127.0.0.1:$($fs.Port))' -ForegroundColor Magenta
        Write-Host '    [19] 打开 OpenCode 2 Web 工作台 (http://127.0.0.1:$($Script:WslOpencode2Port))' -ForegroundColor Magenta
        Write-Host '    [20] 查看守护进程综合日志 (Supervisor & All Bots)' -ForegroundColor Cyan
        Write-Host ''
        Write-Host '    [R]   刷新当前状态' -ForegroundColor Cyan
        Write-Host '    [CLS] 清屏' -ForegroundColor DarkGray
        Write-Host '    [0]   返回统一启动器主菜单' -ForegroundColor Gray
        Write-Host ''
        Write-Host '  ============================================================' -ForegroundColor DarkCyan
        Write-Host ''

        $subChoice = Read-Host '  请选择操作 [0-20, R, CLS]'
        if ([string]::IsNullOrWhiteSpace($subChoice)) { continue }
        $subKey = $subChoice.Trim().ToLowerInvariant()

        switch ($subKey) {
            '1'  { $null = Start-WslFeishuBridge -Target 'all' }
            '2'  { $null = Stop-WslFeishuBridge -Target 'all' }
            '3'  { $null = Restart-WslFeishuBridge -Target 'all' }
            '4'  { $null = Stop-WslFeishuBridge -Target 'bridge-all' }
            '5'  { $null = Start-WslFeishuBridge -Target 'opencode2-all' }
            '6'  { $null = Start-WslFeishuBridge -Target 'opencode2-core' }
            '7'  { $null = Stop-WslFeishuBridge -Target 'opencode2-core' }
            '8'  { $null = Start-WslFeishuBot -Bot opencode2 }
            '9'  { $null = Stop-WslFeishuBot -Bot opencode2 }
            '10' { Show-Opencode2PairInfo }
            '11' { Show-WslFeishuLogs -Target 'opencode2' }
            '12' { $null = Start-WslFeishuBridge -Target 'antigravity-all' }
            '13' { $null = Start-WslFeishuBridge -Target 'antigravity-core' }
            '14' { $null = Stop-WslFeishuBridge -Target 'antigravity-core' }
            '15' { $null = Start-WslFeishuBot -Bot antigravity }
            '16' { $null = Stop-WslFeishuBot -Bot antigravity }
            '17' { Show-WslFeishuLogs -Target 'antigravity' }
            '18' { $null = Open-WslFeishuDashboard }
            '19' { $null = Open-Opencode2Web }
            '20' { Show-WslFeishuLogs -Target 'all' }
            'r' { continue }
            'cls' { Clear-Host; continue }
            'clear' { Clear-Host; continue }
            '0' {
                Write-Host '  已返回统一启动器主菜单。' -ForegroundColor Gray
                $inFeishuMenu = $false
                break
            }
            default {
                Write-Host '  无效选项，请重新输入。' -ForegroundColor Yellow
            }
        }
        if ($inFeishuMenu -and $subKey -notin @('r', 'cls', 'clear', '0')) {
            Wait-ActionPause -PromptText '操作已完成。按 [Enter] 键刷新并返回菜单...'
        }
    }
}

# ============================================================
# 主流程
# ============================================================


# ============================================================
# GLaDOS 自动签到与状态管理
# ============================================================

function Get-GladosAccountCount {
    if (Test-Path -LiteralPath $Script:GladosConfigFile) {
        try {
            $cfg = Get-Content -LiteralPath $Script:GladosConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($cfg.cookies) { return $cfg.cookies.Count }
        } catch {}
    }
    return 5
}

function Get-GladosPythonCmd {
    if (Test-Path -LiteralPath $Script:GladosPythonExe) {
        return $Script:GladosPythonExe
    }
    $py = Get-Command python -ErrorAction SilentlyContinue
    if ($py) { return $py.Source }
    return $null
}

function Invoke-GladosCheckin {
    <#
    .SYNOPSIS 执行 GLaDOS 一键自动签到并展示所有账号的详细状态（含当前积分、剩余天数等）
    #>
    [CmdletBinding()]
    param(
        [switch]$StatusOnly
    )

    $gladosCount = Get-GladosAccountCount
    $actionName = if ($StatusOnly) { 'GLaDOS 账号状态查询' } else { 'GLaDOS 一键自动签到' }
    Write-LauncherLog "$actionName 开始..." -Level INFO
    Write-Host ''
    Write-Host '  ============================================================' -ForegroundColor Cyan
    Write-Host "             $actionName ($gladosCount 个账号)" -ForegroundColor White
    Write-Host '  ============================================================' -ForegroundColor Cyan
    Write-Host ''

    $pythonExe = Get-GladosPythonCmd
    if (-not $pythonExe) {
        Write-LauncherLog "未找到 Python 运行环境 ($Script:GladosPythonExe)" -Level ERROR
        Write-Host '  [错误] 未找到 Python 运行环境，请检查 Python 安装路径！' -ForegroundColor Red
        return $false
    }
    if (-not (Test-Path -LiteralPath $Script:GladosScript)) {
        Write-LauncherLog "未找到 GLaDOS 脚本: $Script:GladosScript" -Level ERROR
        Write-Host "  [错误] 未找到 GLaDOS 脚本: $Script:GladosScript" -ForegroundColor Red
        return $false
    }

    $pyArgs = @('"' + $Script:GladosScript + '"')
    if ($StatusOnly) {
        $pyArgs += '--status-only'
    }

    Write-Host '  [1/2] 正在调用签到引擎，依次连接处理各账号...' -ForegroundColor DarkCyan
    Write-Host "        脚本位置: $Script:GladosScript" -ForegroundColor DarkGray
    Write-Host ''

    $rawLines = @()
    $accountResults = @()

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = $pythonExe
    $psi.Arguments = [string]::Join(' ', $pyArgs)
    $psi.WorkingDirectory = $Script:GladosDir
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.StandardOutputEncoding = [System.Text.Encoding]::UTF8
    $psi.StandardErrorEncoding = [System.Text.Encoding]::UTF8

    $proc = [System.Diagnostics.Process]::new()
    $proc.StartInfo = $psi

    try {
        $null = $proc.Start()
    } catch {
        Write-LauncherLog "启动 Python 进程失败: $($_.Exception.Message)" -Level ERROR
        Write-Host "  [错误] 启动 Python 进程失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }

    while (-not $proc.StandardOutput.EndOfStream) {
        $line = $proc.StandardOutput.ReadLine()
        if ($null -ne $line) {
            $rawLines += $line
            # 实时流式显示关键行
            if ($line -match '>>>\s*正在执行第\s*(?<idx>\d+/\d+)\s*个账号') {
                Write-Host "  $line" -ForegroundColor Yellow
            } elseif ($line -match '^【账号】') {
                Write-Host "  $line" -ForegroundColor Green
            } elseif ($line -match '^【(获取状态异常|状态查询失败|签到请求失败)】') {
                Write-Host "  $line" -ForegroundColor Red
            } elseif ($line -match '\[(提示|等待)\]') {
                Write-Host "  $line" -ForegroundColor DarkYellow
            }
        }
    }
    $errOut = $proc.StandardError.ReadToEnd()
    $proc.WaitForExit()

    # 解析各账号结果 (支持当前积分解析)
    $idx = 0
    foreach ($line in $rawLines) {
        if ($line -match '【账号】') {
            $idx++
            $acc = if ($line -match '【账号】(?<val>[^|]+)') { $Matches['val'].Trim() } else { '未知' }
            $pts = if ($line -match '【当前积分】(?<val>[^|]+)') { $Matches['val'].Trim() } else { '- 积分' }
            $todayGain = if ($line -match '【今日获得】(?<val>[^|]+)') { $Matches['val'].Trim() } `
                         elseif ($line -match 'Checkin!\s*Got\s*(?<val>\d+)\s*Points') { "+$($Matches['val']) 积分" } `
                         elseif ($line -match '\(\+(?<val>\d+)\)') { "+$($Matches['val']) 积分" } `
                         else { '0 积分' }
            $days = if ($line -match '【剩余天数】(?<val>\d+)\s*天') { $Matches['val'].Trim() } else { '0' }
            $res = if ($line -match '【签到结果】(?<val>.*)$') { $Matches['val'].Trim() } else { '无返回信息' }

            # 状态识别
            $statusText = '成功'
            $statusColor = 'Green'
            $displayResult = $res
            if ($res -match "Today's observation logged") {
                $statusText = '今日已签'
                $displayResult = '今日已签到 (记录已同步)'
            } elseif ($res -match 'Checkin!\s*Got\s*(?<pts>\d+)\s*Points') {
                $ptsVal = $Matches['pts']
                $statusText = '签到成功'
                $displayResult = "获得 +$ptsVal 点积分"
            } elseif ($res -match '仅查询') {
                $statusText = '状态正常'
                $displayResult = '账号状态正常 (仅查询)'
            } elseif ($res -match '失败' -or $res -match '异常') {
                $statusText = '签到异常'
                $statusColor = 'Red'
            }

            $accountResults += [PSCustomObject]@{
                Index         = $idx
                Account       = $acc
                Status        = $statusText
                StatusColor   = $statusColor
                TodayGain     = $todayGain
                Points        = $pts
                RemainingDays = "$days 天"
                RawDays       = [int]$days
                Result        = $displayResult
            }
        }
    }

    Write-Host ''
    Write-Host "  [2/2] 签到任务执行完毕，共 $($accountResults.Count) 个账号汇总报告如下：" -ForegroundColor Cyan
    Write-Host ''

    if ($accountResults.Count -gt 0) {
        Write-Host '  ┌─────┬──────────────────────────┬──────────────┬────────────┬────────────┬────────────┬──────────────────────────────────────┐' -ForegroundColor DarkCyan
        Write-Host '  │ 序号│ 账号邮箱                 │ 签到状态     │ 今日获得   │ 当前总积分 │ 剩余天数   │ 签到详细信息                         │' -ForegroundColor DarkCyan
        Write-Host '  ├─────┼──────────────────────────┼──────────────┼────────────┼────────────┼────────────┼──────────────────────────────────────┤' -ForegroundColor DarkCyan

        foreach ($item in $accountResults) {
            $idxStr = ("[{0}]" -f $item.Index).PadRight(4)
            $accStr = $item.Account.PadRight(24)
            $statusStr = ("[" + $item.Status + "]").PadRight(12)
            $todayStr = $item.TodayGain.PadRight(10)
            $ptsStr = $item.Points.PadRight(10)
            $daysStr = $item.RemainingDays.PadRight(10)
            $resStr = $item.Result.PadRight(36)

            Write-Host -NoNewline '  │ ' -ForegroundColor DarkCyan
            Write-Host -NoNewline $idxStr -ForegroundColor White
            Write-Host -NoNewline '│ ' -ForegroundColor DarkCyan
            Write-Host -NoNewline $accStr -ForegroundColor Cyan
            Write-Host -NoNewline '│ ' -ForegroundColor DarkCyan
            Write-Host -NoNewline $statusStr -ForegroundColor ($item.StatusColor)
            Write-Host -NoNewline '│ ' -ForegroundColor DarkCyan
            Write-Host -NoNewline $todayStr -ForegroundColor Yellow
            Write-Host -NoNewline '│ ' -ForegroundColor DarkCyan
            Write-Host -NoNewline $ptsStr -ForegroundColor Green
            Write-Host -NoNewline '│ ' -ForegroundColor DarkCyan
            Write-Host -NoNewline $daysStr -ForegroundColor Magenta
            Write-Host -NoNewline '│ ' -ForegroundColor DarkCyan
            Write-Host -NoNewline $resStr -ForegroundColor Gray
            Write-Host ' │' -ForegroundColor DarkCyan
        }
        Write-Host '  └─────┴──────────────────────────┴──────────────┴────────────┴────────────┴────────────┴──────────────────────────────────────┘' -ForegroundColor DarkCyan
        Write-Host ''

        $successCount = ($accountResults | Where-Object { $_.Status -in @('成功', '今日已签', '签到成功', '状态正常') }).Count
        Write-LauncherLog "$actionName 完成: 共 $($accountResults.Count) 个账号，正常/成功 $successCount 个" -Level INFO
        Write-Host "  [统计] 共处理 $($accountResults.Count) 个账号，正常/成功: $successCount 个，异常: $($accountResults.Count - $successCount) 个。" -ForegroundColor $(if ($successCount -eq $accountResults.Count) { 'Green' } else { 'Yellow' })
        Write-Host "  [日志] 详细日志已记录至: $Script:GladosLogFile" -ForegroundColor DarkGray
        return ($successCount -eq $accountResults.Count)
    } else {
        Write-LauncherLog "$actionName 未能解析出账号结果" -Level WARN
        Write-Host '  [警告] 未能解析到账号签到结果，原始输出如下：' -ForegroundColor Yellow
        $rawLines | ForEach-Object { Write-Host "    $_" -ForegroundColor Gray }
        if (-not [string]::IsNullOrWhiteSpace($errOut)) {
            Write-Host "  [错误流] $errOut" -ForegroundColor Red
        }
        return $false
    }
}

function Show-GladosStatus {
    <#
    .SYNOPSIS 查看 GLaDOS 最新签到历史与各账号状态（含当前积分与剩余天数）
    #>
    $targetCount = Get-GladosAccountCount
    Write-Host "  -- GLaDOS 自动签到历史看板 ($targetCount 个账号) --" -ForegroundColor Cyan

    if (-not (Test-Path -LiteralPath $Script:GladosLogFile)) {
        Write-Host "  暂无签到日志文件 ($Script:GladosLogFile)" -ForegroundColor Yellow
        return
    }

    # 从 checkin.log 倒序读取最近一次完整记录
    $lines = Get-Content -LiteralPath $Script:GladosLogFile -Tail 150 -Encoding UTF8
    $lastRecords = @()
    $lastTime = $null

    for ($i = $lines.Count - 1; $i -ge 0; $i--) {
        $line = $lines[$i]
        if ($line -match '^\[(?<time>\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\].*?【账号】') {
            if (-not $lastTime) { $lastTime = $Matches['time'] }
            $acc = if ($line -match '【账号】(?<val>[^|]+)') { $Matches['val'].Trim() } else { '未知' }
            $pts = if ($line -match '【当前积分】(?<val>[^|]+)') { $Matches['val'].Trim() } else { '- 积分' }
            $todayGain = if ($line -match '【今日获得】(?<val>[^|]+)') { $Matches['val'].Trim() } `
                         elseif ($line -match 'Checkin!\s*Got\s*(?<val>\d+)\s*Points') { "+$($Matches['val']) 积分" } `
                         elseif ($line -match '\(\+(?<val>\d+)\)') { "+$($Matches['val']) 积分" } `
                         else { '0 积分' }
            $days = if ($line -match '【剩余天数】(?<val>\d+)\s*天') { $Matches['val'].Trim() + ' 天' } `
                    elseif ($line -match '【剩余天数】(?<val>\d+)') { $Matches['val'].Trim() + ' 天' } `
                    else { '0 天' }
            $res = if ($line -match '【签到结果】(?<val>.*)$') { $Matches['val'].Trim() } else { '无记录' }

            # 避免重复
            if (-not ($lastRecords | Where-Object { $_.Account -eq $acc })) {
                $lastRecords += [PSCustomObject]@{
                    Time        = $Matches['time']
                    Account     = $acc
                    TodayGain   = $todayGain
                    Points      = $pts
                    Days        = $days
                    Result      = $res
                }
            }
            if ($lastRecords.Count -ge $targetCount) { break }
        }
    }

    if ($lastRecords.Count -gt 0) {
        Write-Host "  最近签到执行时间: $lastTime" -ForegroundColor Gray
        $idx = 0
        foreach ($rec in ($lastRecords | Sort-Object Account)) {
            $idx++
            Write-Host "    [$idx] $($rec.Account) : 今日获得 $($rec.TodayGain) | 当前总计 $($rec.Points) | 剩余 $($rec.Days) | $($rec.Result)" -ForegroundColor Green
        }
    } else {
        Write-Host '  日志中尚未检索到完整的账号签到记录。' -ForegroundColor Yellow
    }
}

function Invoke-MenuAction {
    <#
    .SYNOPSIS 执行菜单选项对应的逻辑
    #>
    param([string]$Choice)

    switch ($Choice) {
        '1' {
            # 启动 AI Study Tauri
            Start-AIStudyTauri
        }
        '2' {
            # 启动 DeepSeek Harness (dsh Web)，自动打开 Dashboard
            $null = Start-Dsh
        }
        '3' {
            # 运行 DeepSeek Harness 一次性任务 (CLI)
            Start-DshHeadless
        }
        '4' {
            # 启动冠志通 Web 工作台
            $null = Start-GuanZhiWeb
        }
        '5' {
            # 同时启动全部
            Write-Host ''
            Write-Host '  同时启动 AI Study Tauri、DeepSeek Harness 和冠志通 Web ...' -ForegroundColor Green
            Start-AIStudyTauri
            $null = Start-Dsh
            $null = Start-GuanZhiWeb
        }
        '6' {
            # 查看状态
            Show-PlatformStatus
        }
        '7' {
            # 停止 AI Study Tauri
            Stop-AIStudyTauri
        }
        '8' {
            # 停止 DeepSeek Harness
            Stop-Dsh
        }
        '9' {
            # 停止冠志通 Web
            Stop-GuanZhiWeb
        }
        '10' {
            # 停止全部
            Write-Host ''
            Write-Host '  停止全部平台 ...' -ForegroundColor Red
            Stop-AIStudyTauri
            Stop-Dsh
            Stop-GuanZhiWeb
        }
        '11' {
            # 开启冠志通 Docker Web Wi‑Fi 局域网访问
            $null = Start-GuanZhiLanAccess
        }
        '12' {
            # 关闭冠志通 Docker Web Wi‑Fi 局域网访问
            $null = Stop-GuanZhiLanAccess
        }
        '13' {
            # 查看冠志通 Docker Web 局域网状态
            Show-GuanZhiLanStatus
        }
        '14' {
            # 一键启动冠志通 Docker Web 并开启 Wi‑Fi 局域网访问
            $null = Start-GuanZhiLanSession
        }
        '15' {
            # 一键关闭局域网访问并停止冠志通 Docker Web
            $null = Stop-GuanZhiLanSession
        }
        '16' {
            # 进入 AI 桌面工具协同组合子菜单
            Show-AiSuiteMenu
        }
        '17' {
            # GLaDOS 一键自动签到
            $null = Invoke-GladosCheckin
        }
        '18' {
            # 查看 GLaDOS 最新签到历史与账号状态
            Show-GladosStatus
        }
        '19' {
            # 进入 WSL 专区二级菜单
            Show-WslMenu
        }
        'wsl' {
            Show-WslMenu
        }
        '20' {
            # 进入飞书机器人桥接专区菜单 (包含 OpenCode 2 与 Antigravity 启动/关闭/重启/面板)
            Show-WslFeishuMenu
        }
        '21' {
            # 兼容历史选项编号，进入飞书机器人桥接专区菜单
            Show-WslFeishuMenu
        }
        'feishu' {
            Show-WslFeishuMenu
        }
        'botmux' {
            Show-WslFeishuMenu
        }
        'bridge' {
            Show-WslFeishuMenu
        }
        '22' {
            # 启动 StudyPower Web 工作台
            $null = Start-StudyPower
        }
        '23' {
            # 停止 StudyPower Web 工作台
            $null = Stop-StudyPower
        }
        '24' {
            # 进入 MSDS-Engine 智能处理专区二级菜单
            Show-MsdsEngineMenu
        }
        '25' {
            # 启动 MSDS-Engine Web 工作台
            $null = Start-MsdsEngineWeb
        }
        '26' {
            # 停止 MSDS-Engine 全部服务 (Web / API)
            $null = Stop-MsdsEngineAll
        }
        'msds' {
            Show-MsdsEngineMenu
        }
        'msds-engine' {
            Show-MsdsEngineMenu
        }
        'msds-web' {
            $null = Start-MsdsEngineWeb
        }
        'msds-api' {
            $null = Start-MsdsEngineApi
        }
        'ai' {
            Show-AiSuiteMenu
        }
        'suite' {
            Show-AiSuiteMenu
        }
        'aitools' {
            Show-AiSuiteMenu
        }
        'e1' {
            # 打开 DeepSeek Harness 网页
            Open-DshDashboard
        }
        'cls' {
            Clear-Host
        }
        'clear' {
            Clear-Host
        }
        '0' {
            # 退出
            Write-LauncherLog '用户选择退出' -Level INFO
            Write-Host ''
            Write-Host '  已退出启动器。' -ForegroundColor Gray
            return $false
        }
        default {
            Write-Host ''
            Write-Host '  无效选项，请重新输入。' -ForegroundColor Yellow
        }
    }
    return $true
}

function Invoke-UrlTarget {
    <#
    .SYNOPSIS url/open 动词的目标分发：打开对应平台网页
    #>
    param([string]$Target)
    $ok = $false
    switch ($Target) {
        'opencode2' { $ok = Open-Opencode2Web }
        'opencode'  { $ok = Open-Opencode2Web }
        'dsh'         { Open-DshDashboard; $ok = $true }
        'deepseek'    { Open-DshDashboard; $ok = $true }
        'deepseek-harness' { Open-DshDashboard; $ok = $true }
        'harness'     { Open-DshDashboard; $ok = $true }
        'dsh-wsl'     { $ok = Open-WslDshDashboard }
        'wsl-dsh'     { $ok = Open-WslDshDashboard }
        'feishu'      { $ok = Open-WslFeishuDashboard }
        'botmux'      { $ok = Open-WslFeishuDashboard }
        'bridge'      { $ok = Open-WslFeishuDashboard }
        'msds'        { $null = Open-MsdsEngineWeb; $ok = $true }
        'msds-web'    { $null = Open-MsdsEngineWeb; $ok = $true }
        'msds-engine' { $null = Open-MsdsEngineWeb; $ok = $true }
        'msds-api'    { $null = Open-MsdsEngineApi; $ok = $true }
        'web'         { $null = Open-GuanZhiWeb; $ok = $true }
        'guanzhi'     { $null = Open-GuanZhiWeb; $ok = $true }
        'guanzhi-web' { $null = Open-GuanZhiWeb; $ok = $true }
        default { Write-Host "url 支持目标: dsh | dsh-wsl | web" -ForegroundColor Yellow }
    }
    if ($ok -eq $false) { exit 1 }
}

function Main {
    <#
    .SYNOPSIS 主入口：支持命令行参数或交互菜单
    #>
    param(
        [string]$Action,
        [string]$Target
    )

    $knownTargets = @(
        'dsh', 'deepseek', 'deepseek-harness', 'harness',
        'aistudy', 'tauri', 'system', 'aistudy-tauri',
        'web', 'guanzhi', 'guanzhi-web', 'guanzhitong-lan', 'compliance',
        'studypower', 'study-power', 'study',
        'msds', 'msds-engine', 'msds-web', 'msds-api', 'msds-all',
        'all',
        'glados', 'checkin', 'glados-checkin',
        'ai-suite', 'aisuite', 'aitools', 'antigravity', 'antigravity-ide', 'ide', 'chatgpt', 'cockpit',
        'dsh-wsl', 'wsl-dsh', 'wsl-suite', 'wsl',
        'antigravity-wsl', 'wsl-antigravity', 'agw', 'antigravity-ide-wsl', 'ide-wsl', 'cockpit-wsl',
        'feishu', 'botmux', 'bridge', 'feishu-bridge', 'opencode2-feishu', 'antigravity-feishu'
    )

    # 快捷执行：wll checkin / wll glados 直接触发签到
    if ($Action -and ($Action.ToLower() -in @('checkin', 'glados', 'glados-checkin'))) {
        $ok = Invoke-GladosCheckin
        exit $(if ($ok) { 0 } else { 1 })
    }

    # 便捷调用：wll dsh / wll aistudy 直接等价于 start 对应平台
    if ($Action -and $Action -in $knownTargets -and -not $Target) {
        Write-LauncherLog "便捷调用: wll $Action 等价于 start $Action" -Level INFO
        $Target = $Action
        $Action = 'start'
    }

    # 命令行模式
    if ($Action) {
        Write-LauncherLog "命令行模式: $Action $Target" -Level INFO
        switch ($Action.ToLower()) {
            'pair' {
                Show-Opencode2PairInfo
                exit 0
            }
            'checkin' {
                $ok = Invoke-GladosCheckin
                exit $(if ($ok) { 0 } else { 1 })
            }
            'glados' {
                $ok = Invoke-GladosCheckin
                exit $(if ($ok) { 0 } else { 1 })
            }
            'glados-checkin' {
                $ok = Invoke-GladosCheckin
                exit $(if ($ok) { 0 } else { 1 })
            }
            'start' {
                $ok = $false
                switch ($Target) {
                    'aistudy'     { $ok = Start-AIStudyTauri }
                    'tauri'       { $ok = Start-AIStudyTauri }
                    'system'      { $ok = Start-AIStudyTauri }
                    'aistudy-tauri' { $ok = Start-AIStudyTauri }
                    'dsh'         { $ok = Start-Dsh }
                    'deepseek'    { $ok = Start-Dsh }
                    'deepseek-harness' { $ok = Start-Dsh }
                    'harness'     { $ok = Start-Dsh }
                    'web'         { $ok = Start-GuanZhiWeb }
                    'guanzhi'     { $ok = Start-GuanZhiWeb }
                    'guanzhi-web' { $ok = Start-GuanZhiWeb }
                    'studypower'  { $ok = Start-StudyPower }
                    'study-power' { $ok = Start-StudyPower }
                    'study'       { $ok = Start-StudyPower }
                    'msds'        { $ok = Start-MsdsEngineWeb }
                    'msds-engine' { $ok = Start-MsdsEngineWeb }
                    'msds-web'    { $ok = Start-MsdsEngineWeb }
                    'msds-api'    { $ok = Start-MsdsEngineApi }
                    'msds-all'    {
                        $w = Start-MsdsEngineWeb
                        $a = Start-MsdsEngineApi
                        $ok = ($w -and $a)
                    }
                    'guanzhitong-lan' { $ok = Start-GuanZhiLanSession }
                    'compliance' { $ok = Start-GuanZhiCompliance }
                    'glados'     { $ok = Invoke-GladosCheckin }
                    'checkin'    { $ok = Invoke-GladosCheckin }
                    'ai-suite'        { $ok = Start-AiSuite }
                    'aisuite'         { $ok = Start-AiSuite }
                    'aitools'         { $ok = Start-AiSuite }
                    'antigravity'     { $ok = Start-AntigravityApp }
                    'antigravity-ide' { $ok = Start-AntigravityIdeApp }
                    'ide'             { $ok = Start-AntigravityIdeApp }
                    'chatgpt'         { $ok = Start-ChatGptApp }
                    'cockpit'         { $ok = Start-CockpitApp }
                    'dsh-wsl'         { $ok = Start-WslDsh }
                    'wsl-dsh'         { $ok = Start-WslDsh }
                    'antigravity-wsl' { $ok = Start-WslAntigravity -Component gui }
                    'wsl-antigravity' { $ok = Start-WslAntigravity -Component gui }
                    'agw'             { $ok = Start-WslAntigravity -Component gui }
                    'antigravity-ide-wsl' { $ok = Start-WslAntigravity -Component ide }
                    'ide-wsl'         { $ok = Start-WslAntigravity -Component ide }
                    'cockpit-wsl'     { $ok = Start-WslAntigravity -Component cockpit }
                    'wsl-suite'       { $ok = Start-WslSuite }
                    'wsl'             { $ok = Start-WslSuite }
                    'feishu'          { $ok = Start-WslFeishuBridge -Target all }
                    'botmux'          { $ok = Start-WslFeishuBridge -Target all }
                    'bridge'          { $ok = Start-WslFeishuBridge -Target all }
                    'feishu-bridge'   { $ok = Start-WslFeishuBridge -Target all }
                    'feishu-bridge-only' { $ok = Start-WslFeishuBridge -Target bridge-all }
                    'feishu-opencode' { $ok = Start-WslFeishuBridge -Target opencode2-all }
                    'opencode-feishu' { $ok = Start-WslFeishuBridge -Target opencode2-all }
                    'opencode2-feishu' { $ok = Start-WslFeishuBridge -Target opencode2-all }
                    'feishu-ag'       { $ok = Start-WslFeishuBridge -Target antigravity-all }
                    'ag-feishu'       { $ok = Start-WslFeishuBridge -Target antigravity-all }
                    'antigravity-feishu' { $ok = Start-WslFeishuBridge -Target antigravity-all }
                    'opencode2-core'  { $ok = Start-WslFeishuBridge -Target opencode2-core }
                    'opencode-core'   { $ok = Start-WslFeishuBridge -Target opencode2-core }
                    'ag-core'         { $ok = Start-WslFeishuBridge -Target antigravity-core }
                    'antigravity-core' { $ok = Start-WslFeishuBridge -Target antigravity-core }
                    'all'    {
                        $a = Start-AIStudyTauri
                        $h = Start-Dsh
                        $w = Start-GuanZhiWeb
                        $ok = ($a -and $h -and $w)
                    }
                    default { Write-Host "未知目标: $Target" -ForegroundColor Red }
                }
                if ($ok -eq $false) { exit 1 }
            }
            'stop' {
                $ok = $false
                switch ($Target) {
                    'aistudy'     { $ok = Stop-AIStudyTauri }
                    'tauri'       { $ok = Stop-AIStudyTauri }
                    'system'      { $ok = Stop-AIStudyTauri }
                    'dsh'         { $ok = Stop-Dsh }
                    'deepseek'    { $ok = Stop-Dsh }
                    'deepseek-harness' { $ok = Stop-Dsh }
                    'harness'     { $ok = Stop-Dsh }
                    'web'         { $ok = Stop-GuanZhiWeb }
                    'guanzhi'     { $ok = Stop-GuanZhiWeb }
                    'guanzhi-web' { $ok = Stop-GuanZhiWeb }
                    'studypower'  { $ok = Stop-StudyPower }
                    'study-power' { $ok = Stop-StudyPower }
                    'study'       { $ok = Stop-StudyPower }
                    'msds'        { $ok = Stop-MsdsEngineAll }
                    'msds-engine' { $ok = Stop-MsdsEngineAll }
                    'msds-web'    { $ok = Stop-MsdsEngineWeb }
                    'msds-api'    { $ok = Stop-MsdsEngineApi }
                    'msds-all'    { $ok = Stop-MsdsEngineAll }
                    'guanzhitong-lan' { $ok = Stop-GuanZhiLanSession }
                    'compliance' { $ok = Stop-GuanZhiWeb }
                    'ai-suite'        { $ok = Stop-AiSuite }
                    'aisuite'         { $ok = Stop-AiSuite }
                    'aitools'         { $ok = Stop-AiSuite }
                    'antigravity'     { $ok = Stop-AntigravityApp }
                    'antigravity-ide' { $ok = Stop-AntigravityIdeApp }
                    'ide'             { $ok = Stop-AntigravityIdeApp }
                    'chatgpt'         { $ok = Stop-ChatGptApp }
                    'cockpit'         { $ok = Stop-CockpitApp }
                    'dsh-wsl'         { $ok = Stop-WslDsh }
                    'wsl-dsh'         { $ok = Stop-WslDsh }
                    'antigravity-wsl' { $ok = Stop-WslAntigravity -Component gui }
                    'wsl-antigravity' { $ok = Stop-WslAntigravity -Component gui }
                    'agw'             { $ok = Stop-WslAntigravity -Component gui }
                    'antigravity-ide-wsl' { $ok = Stop-WslAntigravity -Component ide }
                    'ide-wsl'         { $ok = Stop-WslAntigravity -Component ide }
                    'cockpit-wsl'     { $ok = Stop-WslAntigravity -Component cockpit }
                    'wsl-suite'       { $ok = Stop-WslSuite }
                    'wsl'             { $ok = Stop-WslSuite }
                    'feishu'          { $ok = Stop-WslFeishuBridge -Target all }
                    'botmux'          { $ok = Stop-WslFeishuBridge -Target all }
                    'bridge'          { $ok = Stop-WslFeishuBridge -Target all }
                    'feishu-bridge'   { $ok = Stop-WslFeishuBridge -Target all }
                    'feishu-bridge-only' { $ok = Stop-WslFeishuBridge -Target bridge-all }
                    'feishu-opencode' { $ok = Stop-WslFeishuBot -Bot opencode2 }
                    'opencode-feishu' { $ok = Stop-WslFeishuBot -Bot opencode2 }
                    'opencode2-feishu' { $ok = Stop-WslFeishuBot -Bot opencode2 }
                    'feishu-ag'       { $ok = Stop-WslFeishuBot -Bot antigravity }
                    'ag-feishu'       { $ok = Stop-WslFeishuBot -Bot antigravity }
                    'antigravity-feishu' { $ok = Stop-WslFeishuBot -Bot antigravity }
                    'opencode2-core'  { $ok = Stop-WslFeishuBridge -Target opencode2-core }
                    'opencode-core'   { $ok = Stop-WslFeishuBridge -Target opencode2-core }
                    'ag-core'         { $ok = Stop-WslFeishuBridge -Target antigravity-core }
                    'antigravity-core' { $ok = Stop-WslFeishuBridge -Target antigravity-core }
                    'all'    {
                        $a = Stop-AIStudyTauri
                        $h = Stop-Dsh
                        $w = Stop-GuanZhiWeb
                        $ok = ($a -and $h -and $w)
                    }
                    default      { Write-Host "未知目标: $Target" -ForegroundColor Red; $ok = $false }
                }
                if ($ok -eq $false) { exit 1 }
            }
            'restart' {
                $ok = $false
                switch ($Target) {
                    'dsh'         { $null = Stop-Dsh; $ok = Start-Dsh }
                    'deepseek'    { $null = Stop-Dsh; $ok = Start-Dsh }
                    'deepseek-harness' { $null = Stop-Dsh; $ok = Start-Dsh }
                    'harness'     { $null = Stop-Dsh; $ok = Start-Dsh }
                    'dsh-wsl'     { $ok = Restart-WslDsh }
                    'wsl-dsh'     { $ok = Restart-WslDsh }
                    'antigravity-wsl'     { $ok = Restart-WslAntigravity -Component gui }
                    'wsl-antigravity'     { $ok = Restart-WslAntigravity -Component gui }
                    'agw'                 { $ok = Restart-WslAntigravity -Component gui }
                    'antigravity-ide-wsl' { $ok = Restart-WslAntigravity -Component ide }
                    'ide-wsl'             { $ok = Restart-WslAntigravity -Component ide }
                    'cockpit-wsl'         { $ok = Restart-WslAntigravity -Component cockpit }
                    'wsl-suite'   {
                        $d = Stop-WslSuite
                        $ok = Start-WslSuite
                    }
                    'wsl'         {
                        $d = Stop-WslSuite
                        $ok = Start-WslSuite
                    }
                    'feishu'        { $ok = Restart-WslFeishuBridge -Target all }
                    'botmux'        { $ok = Restart-WslFeishuBridge -Target all }
                    'bridge'        { $ok = Restart-WslFeishuBridge -Target all }
                    'feishu-bridge' { $ok = Restart-WslFeishuBridge -Target all }
                    'feishu-opencode' { $ok = Restart-WslFeishuBot -Bot opencode2 }
                    'opencode-feishu' { $ok = Restart-WslFeishuBot -Bot opencode2 }
                    'opencode2-feishu' { $ok = Restart-WslFeishuBot -Bot opencode2 }
                    'feishu-ag'     { $ok = Restart-WslFeishuBot -Bot antigravity }
                    'ag-feishu'     { $ok = Restart-WslFeishuBot -Bot antigravity }
                    'antigravity-feishu' { $ok = Restart-WslFeishuBot -Bot antigravity }
                    'opencode2-core' { $ok = Restart-WslFeishuBridge -Target opencode2-core }
                    'ag-core'       { $ok = Restart-WslFeishuBridge -Target antigravity-core }
                    'msds'        { $null = Stop-MsdsEngineWeb; $ok = Start-MsdsEngineWeb }
                    'msds-web'    { $null = Stop-MsdsEngineWeb; $ok = Start-MsdsEngineWeb }
                    'msds-api'    { $null = Stop-MsdsEngineApi; $ok = Start-MsdsEngineApi }
                    default { Write-Host "restart 支持目标: dsh | dsh-wsl | antigravity-wsl | antigravity-ide-wsl | cockpit-wsl | wsl-suite" -ForegroundColor Yellow }
                }
                if ($ok -eq $false) { exit 1 }
            }
            'url'  { Invoke-UrlTarget -Target $Target }
            'open' { Invoke-UrlTarget -Target $Target }
            'status'  {
                if ($Target -in @('glados', 'checkin', 'glados-checkin')) {
                    Show-GladosStatus
                    exit 0
                }
                if ($Target -in @('wsl', 'wsl-suite', 'dsh-wsl', 'wsl-dsh', 'antigravity-wsl', 'wsl-antigravity', 'agw', 'antigravity-ide-wsl', 'ide-wsl', 'cockpit-wsl')) {
                    Write-Host ''
                    Show-WslSummary
                    Write-Host ''
                    exit 0
                }
                if ($Target -in @('feishu', 'botmux', 'bridge', 'feishu-bridge')) {
                    Write-Host ''
                    Show-WslFeishuSummary
                    Write-Host ''
                    exit 0
                }
                if ($Target -in @('ai-suite', 'aisuite', 'aitools', 'ai')) {
                    Write-Host ''
                    Write-Host '  -- AI 桌面协同组合状态 (Antigravity / IDE / ChatGPT / Cockpit) --' -ForegroundColor Cyan
                    Show-AiSuiteSummary
                    exit 0
                }
                if ($Target -in @('msds', 'msds-engine', 'msds-web', 'msds-api')) {
                    Write-Host ''
                    Show-MsdsEngineSummary
                    Write-Host ''
                    exit 0
                }
                Show-PlatformStatus
                exit 0
            }
            'lan' {
                $lanCommand = if ([string]::IsNullOrWhiteSpace($Target)) { 'status' } else { $Target.ToLowerInvariant() }
                if ($lanCommand -notin @('on','off','status')) {
                    Write-Host "用法: .\Workflow-Launcher.ps1 lan [on|off|status]" -ForegroundColor Yellow
                    exit 1
                }
                $ok = Invoke-GuanZhiLanCommand -Command $lanCommand
                if ($ok -eq $false) { exit 1 }
            }
            'logs' {
                switch ($Target.ToLowerInvariant()) {
                    'glados' {
                        Write-Host ''
                        Write-Host '  --- GLaDOS checkin.log (最近 30 行) ---' -ForegroundColor Cyan
                        if (Test-Path $Script:GladosLogFile) {
                            Get-Content -LiteralPath $Script:GladosLogFile -Tail 30 -Encoding UTF8
                        } else {
                            Write-Host '  (暂无日志文件)'
                        }
                        Write-Host ''
                        exit 0
                    }
                    'feishu' {
                        Show-WslFeishuLogs -Target 'all'
                        exit 0
                    }
                    'feishu-ag' {
                        Show-WslFeishuLogs -Target 'antigravity'
                        exit 0
                    }
                    'feishu-opencode' {
                        Show-WslFeishuLogs -Target 'opencode2'
                        exit 0
                    }
                    'msds' {
                        Show-MsdsEngineLogs
                        exit 0
                    }
                    'msds-engine' {
                        Show-MsdsEngineLogs
                        exit 0
                    }
                    'msds-web' {
                        Show-MsdsEngineLogs
                        exit 0
                    }
                    'msds-api' {
                        Show-MsdsEngineLogs
                        exit 0
                    }
                    'dsh' {
                        $dshOut = Join-Path $Script:DshRoot 'dsh-web.out.log'
                        $dshErr = Join-Path $Script:DshRoot 'dsh-web.err.log'
                        Write-Host ''
                        Write-Host '  --- dsh-web.out.log (最近 30 行) ---' -ForegroundColor Cyan
                        if (Test-Path $dshOut) { Get-Content -LiteralPath $dshOut -Tail 30 } else { Write-Host '  (无输出日志)' }
                        Write-Host ''
                        Write-Host '  --- dsh-web.err.log (最近 30 行) ---' -ForegroundColor Cyan
                        if (Test-Path $dshErr) { Get-Content -LiteralPath $dshErr -Tail 30 } else { Write-Host '  (无错误日志)' }
                        Write-Host ''
                    }
                    default { Write-Host "用法: .\Workflow-Launcher.ps1 logs [dsh]" -ForegroundColor Yellow }
                }
            }
            default { Write-Host "用法: .\Workflow-Launcher.ps1 [start|stop|restart|status|url|lan|logs] [aistudy|dsh|dsh-wsl|antigravity-wsl|antigravity-ide-wsl|cockpit-wsl|studypower|web|guanzhitong-lan|compliance|ai-suite|wsl|feishu|all]" -ForegroundColor Yellow; exit 1 }
        }
        return
    }

    # 交互菜单模式
    Write-LauncherLog '启动器启动 (交互菜单)' -Level INFO
    Clear-Host
    $running = $true
    while ($running) {
        Write-Menu
        $choice = Read-Host '  请选择操作 [0-26, E1, CLS, 0]'
        $running = Invoke-MenuAction -Choice $choice
        if ($running) {
            $cleanChoice = if ($choice) { $choice.Trim().ToLowerInvariant() } else { '' }
            if ($cleanChoice -in @('cls', 'clear', '16', 'ai', 'suite', 'aitools', '19', 'wsl', '20', '21', 'feishu', 'botmux', 'bridge', '24', 'msds', 'msds-engine')) {
                continue
            }
            Wait-ActionPause -PromptText '操作执行完毕。按 [Enter] 键返回主菜单...'
        }
    }
}

# 入口
try {
    if ($args.Count -ge 2) {
        Main -Action $args[0] -Target $args[1]
    } elseif ($args.Count -eq 1) {
        Main -Action $args[0]
    } else {
        Main
    }
} catch {
    Write-LauncherLog "启动器异常终止: $($_.Exception.Message)" -Level ERROR
    Write-Host ''
    Write-Host "  发生错误: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "  详细信息已写入日志: $Script:LogFile" -ForegroundColor Yellow
    exit 1
}
