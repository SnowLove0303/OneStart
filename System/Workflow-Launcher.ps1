<#
  Workflow Launcher (指令: wll)
  本机统一启动器：管理 AI Study Tauri 与 DeepSeek Harness (dsh) 的启动、停止、状态与日志。

  用法：
    .\Workflow-Launcher.ps1                  显示交互菜单
    .\Workflow-Launcher.ps1 start dsh        启动 DeepSeek Harness (Web)
    .\Workflow-Launcher.ps1 start aistudy    启动 AI Study Tauri
    .\Workflow-Launcher.ps1 start all        同时启动全部平台
    .\Workflow-Launcher.ps1 stop all         停止全部平台
    .\Workflow-Launcher.ps1 status           查看运行状态
    .\Workflow-Launcher.ps1 logs dsh         查看 dsh 运行日志
    .\Workflow-Launcher.ps1 dsh              便捷写法，等价于 start dsh
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

    $logDir = Split-Path $Script:LogFile -Parent
    if (-not (Test-Path $logDir)) {
        New-Item -ItemType Directory -Path $logDir -Force | Out-Null
    }
    Add-Content -Path $Script:LogFile -Value $entry -Encoding UTF8

    switch ($Level) {
        'INFO'  { Write-Host $entry -ForegroundColor Cyan }
        'WARN'  { Write-Host $entry -ForegroundColor Yellow }
        'ERROR' { Write-Host $entry -ForegroundColor Red }
    }
}

function Write-Menu {
    <#
    .SYNOPSIS 显示主菜单
    #>
    Clear-Host
    Write-Host ''
    Write-Host '  ============================================================' -ForegroundColor Cyan
    Write-Host '   Workflow Launcher (AI Study Tauri / DeepSeek Harness)' -ForegroundColor White
    Write-Host '  ============================================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '    [1]  启动 AI Study Tauri 系统 (最新正式构建版)' -ForegroundColor Green
    Write-Host '    [2]  启动 DeepSeek Harness (dsh Web)' -ForegroundColor Green
    Write-Host '    [3]  运行 DeepSeek Harness 一次性任务 (CLI 输入)' -ForegroundColor Green
    Write-Host '    [4]  同时启动全部平台' -ForegroundColor Green
    Write-Host ''
    Write-Host '    [5]  查看全部运行状态' -ForegroundColor Yellow
    Write-Host ''
    Write-Host '    [6]  停止 AI Study Tauri' -ForegroundColor Red
    Write-Host '    [7]  停止 DeepSeek Harness' -ForegroundColor Red
    Write-Host '    [8]  停止全部平台' -ForegroundColor Red
    Write-Host ''
    Write-Host '    [E1] 打开 DeepSeek Harness 网页' -ForegroundColor Magenta
    Write-Host ''
    Write-Host '    [0]  退出' -ForegroundColor Gray
    Write-Host ''
    Write-Host '  ============================================================' -ForegroundColor Cyan
    Write-Host ''
}

# ============================================================
# 平台状态
# ============================================================

function Test-DshRunning {
    <#
    .SYNOPSIS 检测 DeepSeek Harness Web 是否正在运行
    #>
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri $Script:DshHealthUrl -TimeoutSec 2 -ErrorAction SilentlyContinue
        return ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500)
    } catch {
        return $false
    }
}

function Get-AIStudyProcesses {
    <#
    .SYNOPSIS 返回本机所有 AIstudy.exe 进程（始终为数组）
    #>
    return ,@(Get-CimInstance Win32_Process -Filter "Name = 'AIstudy.exe'" -ErrorAction SilentlyContinue)
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
    Write-Host '  ------ AI Study Tauri 状态 ------' -ForegroundColor Cyan
    $aiStudyProcs = Get-AIStudyProcesses
    if ($aiStudyProcs.Count -gt 0) {
        Write-Host '  AI Study Tauri: 运行中' -ForegroundColor Green
        $aiStudyProcs | ForEach-Object { Write-Host "    PID: $($_.ProcessId)" -ForegroundColor Gray }
    } else {
        Write-Host '  AI Study Tauri: 未运行' -ForegroundColor Yellow
    }
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

function Open-DshDashboard {
    <#
    .SYNOPSIS 用指定浏览器打开 DeepSeek Harness Dashboard
    #>
    if (-not $Script:DshAutoOpenBrowser) { return }
    try {
        if (Test-Path -LiteralPath $Script:DshBrowserPath) {
            Start-Process -FilePath $Script:DshBrowserPath -ArgumentList $Script:DshUrl
            Write-LauncherLog "用浏览器打开 DeepSeek Harness: $Script:DshUrl" -Level INFO
            Write-Host "  已用 Chrome 打开 DeepSeek Harness Dashboard: $($Script:DshUrl)" -ForegroundColor Magenta
        } else {
            Open-PlatformUrl -Name 'DeepSeek Harness' -Url $Script:DshUrl
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
        Write-Host '  DeepSeek Harness 已在运行中。' -ForegroundColor Green
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

    # 后台拉起 dsh web（分离进程，不阻塞 wll 菜单）。
    # 优先用预编译 CLI（node apps/cli/lib/bin.js），避免 pnpm+tsx 源码转译导致的 ~95s 冷启动。
    $dshOut = Join-Path $Script:DshRoot 'dsh-web.out.log'
    $dshErr = Join-Path $Script:DshRoot 'dsh-web.err.log'
    Remove-Item -LiteralPath $dshOut, $dshErr -ErrorAction SilentlyContinue
    try {
        $env:DSH_HOME = $Script:DshHome
        $dshWorkDir = Join-Path $Script:DshRoot '会话'
        if (-not (Test-Path $dshWorkDir)) { $dshWorkDir = $Script:DshRoot }
        # 路径含空格，必须显式加引号；Start-Process -ArgumentList 数组拼接不会自动加引号
        $dshArgs = "`"$($Script:DshCliBin)`" web --port $($Script:DshPort)"
        Start-Process -FilePath 'node.exe' -ArgumentList $dshArgs `
            -WorkingDirectory $dshWorkDir -WindowStyle Hidden `
            -RedirectStandardOutput $dshOut -RedirectStandardError $dshErr
        Write-LauncherLog "后台启动命令已发出: node $dshArgs (工作目录: $dshWorkDir)" -Level INFO
    } catch {
        Write-LauncherLog "启动 DeepSeek Harness 异常: $($_.Exception.Message)" -Level ERROR
        Write-Host "  启动失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }

    # 等待就绪
    Write-LauncherLog "等待 DeepSeek Harness 就绪 (端口 $($Script:DshPort))..." -Level INFO
    $ready = $false
    for ($i = 0; $i -lt $Script:DshReadyTimeoutSec; $i++) {
        Start-Sleep -Seconds 1
        if (Test-DshRunning) {
            $ready = $true
            break
        }
    }

    if ($ready) {
        Write-LauncherLog 'DeepSeek Harness 启动完成' -Level INFO
        Write-Host "  DeepSeek Harness 已就绪: $($Script:DshUrl)" -ForegroundColor Green
        Open-DshDashboard
        return $true
    } else {
        Write-LauncherLog 'DeepSeek Harness 启动超时，请查看 dsh-web.err.log' -Level WARN
        Write-Host '  DeepSeek Harness 启动超时，请查看 dsh-web.err.log。' -ForegroundColor Yellow
        if (Test-Path $dshErr) {
            Get-Content -LiteralPath $dshErr -Tail 15 -Encoding UTF8 | ForEach-Object { Write-Host "    $_" -ForegroundColor DarkGray }
        }
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
# 主流程
# ============================================================

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
            # 同时启动全部
            Write-Host ''
            Write-Host '  同时启动 AI Study Tauri 和 DeepSeek Harness ...' -ForegroundColor Green
            Start-AIStudyTauri
            $null = Start-Dsh
        }
        '5' {
            # 查看状态
            Show-PlatformStatus
        }
        '6' {
            # 停止 AI Study Tauri
            Stop-AIStudyTauri
        }
        '7' {
            # 停止 DeepSeek Harness
            Stop-Dsh
        }
        '8' {
            # 停止全部
            Write-Host ''
            Write-Host '  停止全部平台 ...' -ForegroundColor Red
            Stop-AIStudyTauri
            Stop-Dsh
        }
        'e1' {
            # 打开 DeepSeek Harness 网页
            Open-PlatformUrl -Name 'DeepSeek Harness' -Url $Script:DshUrl
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
        'all'
    )

    # 便捷调用：wll dsh / wll aistudy 直接等价于 start 对应平台
    if ($Action -and $Action -in $knownTargets -and -not $Target) {
        Write-LauncherLog "便捷调用: wll $Action 等价于 start $Action" -Level INFO
        $Target = $Action
        $Action = 'start'
    }

    # 命令行模式
    if ($Action) {
        Write-LauncherLog "命令行模式: $Action $Target" -Level INFO
        switch ($Action) {
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
                    'all'    {
                        $a = Start-AIStudyTauri
                        $h = Start-Dsh
                        $ok = ($a -and $h)
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
                    'all'    {
                        $a = Stop-AIStudyTauri
                        $h = Stop-Dsh
                        $ok = ($a -and $h)
                    }
                    default      { Write-Host "未知目标: $Target" -ForegroundColor Red; $ok = $false }
                }
                if ($ok -eq $false) { exit 1 }
            }
            'status'  { Show-PlatformStatus; exit 0 }
            'logs' {
                switch ($Target) {
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
            default { Write-Host "用法: .\Workflow-Launcher.ps1 [start|stop|status|logs] [aistudy|dsh|all]" -ForegroundColor Yellow; exit 1 }
        }
        return
    }

    # 交互菜单模式
    Write-LauncherLog '启动器启动 (交互菜单)' -Level INFO
    $running = $true
    while ($running) {
        Write-Menu
        $choice = Read-Host '  请选择操作 [0-9]'
        $running = Invoke-MenuAction -Choice $choice
        if ($running) {
            Write-Host ''
            Write-Host '  按任意键返回菜单...' -ForegroundColor DarkGray
            $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
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