<#
  Workflow Launcher
  管理本机 n8n、Dify 和 Cogpit 的启动、停止、状态查询和日志查看。

  用法：
    .\Workflow-Launcher.ps1              显示交互菜单
    .\Workflow-Launcher.ps1 start n8n    直接启动 n8n
    .\Workflow-Launcher.ps1 start dify   直接启动 Dify
    .\Workflow-Launcher.ps1 start cogpit 直接启动 Cogpit Dashboard
    .\Workflow-Launcher.ps1 start all    同时启动 n8n、Dify 和 Cogpit
    .\Workflow-Launcher.ps1 stop all     停止全部
    .\Workflow-Launcher.ps1 status       查看运行状态
    .\Workflow-Launcher.ps1 logs n8n     查看 n8n 日志
#>

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# ============================================================
# 全局配置 — 所有路径、地址、服务名集中定义于此
# ============================================================

# --- 项目根目录 ---
$Script:LauncherRoot   = $PSScriptRoot
# 启动器迁移到独立目录后，业务平台仍保留在原项目根目录。
# 不再根据 Launcher 所在位置推导 n8n/Dify 路径，避免迁移后指向错误目录。
$Script:ProjectsRoot   = 'E:\MorenAnzhuangLujing\Huangjingdajian'

# --- 日志 ---
$Script:LogFile        = Join-Path $LauncherRoot 'logs\launcher.log'

# --- Docker Desktop ---
$Script:DockerDesktopPath = 'E:\morenhuancunlujing\Docker\Docker Desktop.exe'
$Script:DockerEngineTimeout = 120   # 等待 Docker Engine 就绪的最大秒数

# --- n8n 配置 ---
$Script:N8nDir         = Join-Path $ProjectsRoot 'n8n'
$Script:N8nComposeFile = Join-Path $N8nDir 'docker-compose.yml'
$Script:N8nProject     = 'n8n'
$Script:N8nServices    = @('postgres', 'n8n', 'n8n-runner')
$Script:N8nPort        = 5678
$Script:N8nUrl         = 'http://127.0.0.1:5678'
$Script:N8nHealthUrl   = 'http://127.0.0.1:5678/healthz'

# --- Dify 配置 ---
$Script:DifyDir         = Join-Path $ProjectsRoot 'Dify\docker'
$Script:DifyComposeFile = Join-Path $DifyDir 'docker-compose.yaml'
$Script:DifyProject     = 'dify'
$Script:DifyServices    = @(
    'api', 'worker', 'worker_beat', 'web',
    'db_postgres', 'redis', 'sandbox',
    'plugin_daemon', 'ssrf_proxy', 'nginx'
)
$Script:DifyNginxPort   = 80
$Script:DifyUrl         = 'http://localhost'
$Script:DifyHealthPort  = 80

# --- Cogpit 配置 ---
$Script:CogpitRoot      = 'F:\AIAPP\Claude Code'
$Script:CogpitStartScript = Join-Path $Script:CogpitRoot 'start-cogpit.ps1'
$Script:CogpitStopScript  = Join-Path $Script:CogpitRoot 'stop-cogpit.ps1'
$Script:CogpitPort      = 19384
$Script:CogpitUrl       = 'http://127.0.0.1:19384'
$Script:CogpitHealthUrl = 'http://127.0.0.1:19384/api/projects'

# --- Msds Editor (结构读取) 配置 ---
$Script:MsdsEditorDir         = 'F:\正式项目与模块化内容\冠志\MSDS\Word 覆写模块\结构读取'
$Script:MsdsEditorPs1         = Join-Path $Script:MsdsEditorDir 'Msds-Editor.ps1'
$Script:MsdsEditorMainPy      = Join-Path $Script:MsdsEditorDir 'main.py'
$Script:PythonExe             = 'E:\MorenAnzhuangLujing\Anaconda\python.exe'

# --- AI Study Tauri 配置 ---
$Script:AIStudyTauriDir       = 'F:\正式项目与模块化内容\AI study tauri\System'

# --- DeepSeek Harness (dsh) 配置 ---
$Script:DshRoot              = 'F:\AIAPP\Deepseek Harness'
# 预编译 CLI：dsh 的发布产物。用它启动避开 tsx 源码即时转译（实测启动 ~95s -> ~4s）。
$Script:DshCliBin            = Join-Path $Script:DshRoot 'apps\cli\lib\bin.js'
$Script:DshPnpmCmd           = 'E:\MorenAnzhuangLujing\Huangjingdajian\npm-global\pnpm.cmd'
$Script:DshHome              = Join-Path $Script:DshRoot '.dsh-home'
$Script:DshPort              = 3080
$Script:DshUrl               = 'http://127.0.0.1:3080'
$Script:DshHealthUrl         = 'http://127.0.0.1:3080'
$Script:DshReadyTimeoutSec   = 60
$Script:DshAutoOpenBrowser   = $true   # 启动成功后自动用浏览器打开 Dashboard
$Script:DshBrowserPath       = 'E:\MorenAnzhuangLujing\Chrome\Chrome\Application\chrome.exe'

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

    # 确保日志目录存在
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
    Write-Host '   Workflow Launcher (n8n / Dify / Cogpit / MSDS / AI Study / DSH)' -ForegroundColor White
    Write-Host '  ============================================================' -ForegroundColor Cyan
    Write-Host ''
    Write-Host '    [1]  启动 n8n'                      -ForegroundColor Green
    Write-Host '    [2]  启动 Dify'                     -ForegroundColor Green
    Write-Host '    [3]  启动 Cogpit Dashboard'         -ForegroundColor Green
    Write-Host '    [4]  启动 Msds Editor (结构读取/导入/读取/覆写指向)' -ForegroundColor Green
    Write-Host '    [5]  启动 AI Study Tauri 系统 (最新动态构建版)' -ForegroundColor Green
    Write-Host '    [6]  启动 DeepSeek Harness (dsh Web)' -ForegroundColor Green
    Write-Host '    [7]  运行 DeepSeek Harness 一次性任务 (CLI 输入)' -ForegroundColor Green
    Write-Host '    [8]  同时启动全部平台'               -ForegroundColor Green
    Write-Host ''
    Write-Host '    [9]  查看全部运行状态'               -ForegroundColor Yellow
    Write-Host ''
    Write-Host '    [10]  停止 n8n'                      -ForegroundColor Red
    Write-Host '    [11]  停止 Dify'                     -ForegroundColor Red
    Write-Host '    [12] 停止 Cogpit Dashboard'         -ForegroundColor Red
    Write-Host '    [13] 停止 DeepSeek Harness'          -ForegroundColor Red
    Write-Host '    [14] 停止全部平台'                   -ForegroundColor Red
    Write-Host ''
    Write-Host '    [E1] 打开 n8n 网页'                 -ForegroundColor Magenta
    Write-Host '    [E2] 打开 Dify 网页'                -ForegroundColor Magenta
    Write-Host '    [E3] 打开 Cogpit 网页'              -ForegroundColor Magenta
    Write-Host '    [E4] 打开 DeepSeek Harness 网页'    -ForegroundColor Magenta
    Write-Host ''
    Write-Host '    [0]  退出'                          -ForegroundColor Gray
    Write-Host ''
    Write-Host '  ============================================================' -ForegroundColor Cyan
    Write-Host ''
}

# ============================================================
# Docker 引擎管理
# ============================================================

function Test-DockerEngine {
    <#
    .SYNOPSIS 检测 Docker Engine 是否可用
    #>
    try {
        $null = & docker info 2>&1
        return $true
    } catch {
        return $false
    }
}

function Start-DockerDesktop {
    <#
    .SYNOPSIS 启动 Docker Desktop
    #>
    Write-LauncherLog '正在启动 Docker Desktop...' -Level INFO

    if (-not (Test-Path $Script:DockerDesktopPath)) {
        Write-LauncherLog "Docker Desktop 未找到: $Script:DockerDesktopPath" -Level ERROR
        return $false
    }

    try {
        Start-Process -FilePath $Script:DockerDesktopPath -WindowStyle Minimized
        Write-LauncherLog 'Docker Desktop 启动命令已发送' -Level INFO
        return $true
    } catch {
        Write-LauncherLog "启动 Docker Desktop 失败: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

function Wait-DockerEngine {
    <#
    .SYNOPSIS 循环等待 Docker Engine 就绪
    #>
    param(
        [int]$TimeoutSeconds = 120,
        [int]$IntervalSeconds = 3
    )

    Write-LauncherLog "等待 Docker Engine 就绪 (最长 ${TimeoutSeconds}s)..." -Level INFO
    $elapsed = 0

    while ($elapsed -lt $TimeoutSeconds) {
        if (Test-DockerEngine) {
            Write-LauncherLog 'Docker Engine 已就绪' -Level INFO
            return $true
        }
        Write-Host '.' -NoNewline -ForegroundColor DarkGray
        Start-Sleep -Seconds $IntervalSeconds
        $elapsed += $IntervalSeconds
    }

    Write-Host ''
    Write-LauncherLog "等待超时: Docker Engine 在 ${TimeoutSeconds}s 内未就绪" -Level ERROR
    return $false
}

function Ensure-DockerReady {
    <#
    .SYNOPSIS 确保 Docker 可用：先检测，不可用则启动 Desktop 并等待
    #>
    if (Test-DockerEngine) { return $true }
    if (-not (Start-DockerDesktop)) { return $false }
    return Wait-DockerEngine -TimeoutSeconds $Script:DockerEngineTimeout
}

# ============================================================
# 端口检查
# ============================================================

function Test-PortIsDocker {
    <#
    .SYNOPSIS 检查端口是否被 Docker 进程占用（即自己的容器）
    #>
    param([int]$Port)
    try {
        $pids = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue |
                Select-Object -ExpandProperty OwningProcess -Unique
        foreach ($pid in $pids) {
            $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
            if ($proc -and $proc.ProcessName -match 'docker') {
                return $true
            }
        }
    } catch {}
    return $false
}

function Test-PortAvailability {
    <#
    .SYNOPSIS 检查指定端口是否被占用，占用时显示进程信息
    #>
    param([int]$Port)

    try {
        $connections = Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue |
                       Where-Object { $_.State -ne 'Listen' -or $_.LocalPort -eq $Port }

        # 也检查 Listening 状态
        $listeners = Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue

        $all = @()
        if ($connections) { $all += $connections }
        if ($listeners)   { $all += $listeners }

        # 去重
        $all = $all | Sort-Object LocalAddress,LocalPort,OwningProcess -Unique

        if ($all.Count -eq 0) { return $true }

        Write-LauncherLog "端口 $Port 已被占用:" -Level WARN
        foreach ($conn in $all) {
            $pid  = $conn.OwningProcess
            $proc = Get-Process -Id $pid -ErrorAction SilentlyContinue
            $name = if ($proc) { $proc.ProcessName } else { 'Unknown' }
            $msg  = "  端口: $Port  PID: $pid  进程: $name  状态: $($conn.State)"
            Write-LauncherLog $msg -Level WARN
            Write-Host $msg -ForegroundColor Yellow
        }
        return $false
    } catch {
        # 回退到 netstat（仅检查 LISTENING 状态）
        Write-LauncherLog "Get-NetTCPConnection 不可用，使用 netstat 检测" -Level WARN
        $netstat = & netstat -ano 2>&1 | Select-String ":$Port\s+.*LISTENING"
        if ($netstat) {
            Write-LauncherLog "端口 $Port 已被占用 (netstat): $netstat" -Level WARN
            return $false
        }
        return $true
    }
}

# ============================================================
# 平台状态
# ============================================================

function Get-ComposeProjectName {
    <#
    .SYNOPSIS 通过 docker ps label 自动检测 Compose 实际项目名
    #>
    param(
        [Parameter(Mandatory)][string]$ComposeFile
    )
    try {
        $result = & docker ps -a --format '{{.Names}}' --filter "label=com.docker.compose.project.config_files=$ComposeFile" 2>&1
        if ($LASTEXITCODE -eq 0 -and $result) {
            $firstContainer = ($result | Select-Object -First 1).Trim()
            if ($firstContainer) {
                # 用 json 格式避免模板解析问题
                $json = & docker inspect $firstContainer 2>&1 | ConvertFrom-Json
                if ($json -and $json.Config.Labels.'com.docker.compose.project') {
                    return $json.Config.Labels.'com.docker.compose.project'
                }
            }
        }
    } catch {}
    return $null
}

function Get-PlatformStatus {
    <#
    .SYNOPSIS 获取指定项目的 Compose 服务状态（自动检测实际项目名）
    #>
    param(
        [Parameter(Mandatory)][string]$Project,
        [string]$ComposeFile
    )

    # 先用指定项目名查
    try {
        $dockerArgs = @('compose', '-p', $Project)
        if ($ComposeFile) { $dockerArgs += '-f'; $dockerArgs += $ComposeFile }
        $dockerArgs += 'ps', '-a'
        $result = & docker @dockerArgs 2>&1
        # 必须有数据行（排除仅标题行的情况）
        if ($LASTEXITCODE -eq 0 -and $result -and ($result | Measure-Object).Count -gt 1) {
            return $result
        }
    } catch {}

    # 回退：自动检测实际项目名
    if ($ComposeFile) {
        $actualProject = Get-ComposeProjectName -ComposeFile $ComposeFile
        if ($actualProject -and $actualProject -ne $Project) {
            Write-LauncherLog "检测到实际项目名: $actualProject (非预期的 $Project)" -Level INFO
            try {
                $dockerArgs2 = @('compose', '-p', $actualProject, '-f', $ComposeFile, 'ps', '-a')
                $result2 = & docker @dockerArgs2 2>&1
                if ($LASTEXITCODE -eq 0 -and $result2 -and ($result2 | Measure-Object).Count -gt 1) {
                    return $result2
                }
            } catch {}
        }
    }

    return $null
}

function Get-ActualProjectName {
    <#
    .SYNOPSIS 获取平台实际运行的 Compose 项目名（用于 stop 等操作）
    #>
    param(
        [Parameter(Mandatory)][string]$DefaultProject,
        [Parameter(Mandatory)][string]$ComposeFile
    )
    $detected = Get-ComposeProjectName -ComposeFile $ComposeFile
    if ($detected) { return $detected }
    return $DefaultProject
}

function Show-PlatformStatus {
    <#
    .SYNOPSIS 显示所有平台的运行状态
    #>
    Write-LauncherLog '查询全部运行状态...' -Level INFO
    Write-Host ''
    Write-Host '  ---------- n8n 状态 ----------' -ForegroundColor Cyan
    $n8nStatus = Get-PlatformStatus -Project $Script:N8nProject -ComposeFile $Script:N8nComposeFile
    if ($n8nStatus) { $n8nStatus | ForEach-Object { Write-Host "  $_" } }
    else { Write-Host '  (无法获取状态)' -ForegroundColor Yellow }

    Write-Host ''
    Write-Host '  -------- Dify 状态 ----------' -ForegroundColor Cyan
    $difyStatus = Get-PlatformStatus -Project $Script:DifyProject -ComposeFile $Script:DifyComposeFile
    if ($difyStatus) { $difyStatus | ForEach-Object { Write-Host "  $_" } }
    else { Write-Host '  (无法获取状态)' -ForegroundColor Yellow }

    Write-Host ''
    Write-Host '  ------ Cogpit 状态 ----------' -ForegroundColor Cyan
    if (Test-CogpitRunning) {
        Write-Host '  Cogpit: 运行中' -ForegroundColor Green
        Write-Host "  URL: $($Script:CogpitUrl)"
    } else {
        Write-Host '  Cogpit: 未运行' -ForegroundColor Yellow
    }

    Write-Host ''
    Write-Host '  -- DeepSeek Harness 状态 --' -ForegroundColor Cyan
    if (Test-DshRunning) {
        Write-Host '  DeepSeek Harness: 运行中' -ForegroundColor Green
        Write-Host "  URL: $($Script:DshUrl)"
    } else {
        Write-Host '  DeepSeek Harness: 未运行' -ForegroundColor Yellow
    }

    Write-Host ''
}

# ============================================================
# 启动后健康检查
# ============================================================

function Wait-N8nReady {
    <#
    .SYNOPSIS 等待 n8n 核心服务就绪（检查 Web 端口 + 健康端点）
    #>
    param(
        [int]$MaxRetries = 30,
        [int]$IntervalSeconds = 2
    )

    Write-LauncherLog "等待 n8n 就绪 (最多 ${MaxRetries} 次检查)..." -Level INFO

    # 1) 先等端口可用
    $portReady = $false
    for ($i = 0; $i -lt $MaxRetries; $i++) {
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $tcp.Connect('127.0.0.1', $Script:N8nPort)
            $tcp.Close()
            $portReady = $true
            break
        } catch {
            Start-Sleep -Seconds $IntervalSeconds
        }
    }

    if (-not $portReady) {
        Write-LauncherLog 'n8n 端口 5678 未就绪' -Level ERROR
        return $false
    }

    # 2) 再检查健康端点
    for ($i = 0; $i -lt 10; $i++) {
        try {
            $response = Invoke-WebRequest -Uri $Script:N8nHealthUrl -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-LauncherLog 'n8n 健康检查通过' -Level INFO
                return $true
            }
        } catch {
            Start-Sleep -Seconds $IntervalSeconds
        }
    }

    Write-LauncherLog 'n8n 健康检查未通过，但端口已监听' -Level WARN
    return $true  # 端口已通，可能是健康端点路径不同
}

function Wait-DifyReady {
    <#
    .SYNOPSIS 等待 Dify 核心服务就绪（检查 nginx 端口 + Web 响应）
    #>
    param(
        [int]$MaxRetries = 40,
        [int]$IntervalSeconds = 3
    )

    Write-LauncherLog "等待 Dify 就绪 (最多 ${MaxRetries} 次检查)..." -Level INFO

    # 1) 等 nginx 端口
    $portReady = $false
    for ($i = 0; $i -lt $MaxRetries; $i++) {
        try {
            $tcp = New-Object System.Net.Sockets.TcpClient
            $tcp.Connect('127.0.0.1', $Script:DifyHealthPort)
            $tcp.Close()
            $portReady = $true
            break
        } catch {
            Start-Sleep -Seconds $IntervalSeconds
        }
    }

    if (-not $portReady) {
        Write-LauncherLog 'Dify nginx 端口 80 未就绪' -Level ERROR
        return $false
    }

    # 2) 检查 Web 响应
    for ($i = 0; $i -lt 15; $i++) {
        try {
            $response = Invoke-WebRequest -Uri $Script:DifyUrl -TimeoutSec 10 -UseBasicParsing -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-LauncherLog 'Dify Web 检查通过' -Level INFO
                return $true
            }
        } catch {
            Start-Sleep -Seconds $IntervalSeconds
        }
    }

    Write-LauncherLog 'Dify Web 检查未通过，但端口已监听' -Level WARN
    return $true
}

function Show-UnreadyServices {
    <#
    .SYNOPSIS 显示未就绪的服务及其最近日志
    #>
    param(
        [Parameter(Mandatory)][string]$Project,
        [string]$ComposeFile,
        [string[]]$ExpectedServices,
        [int]$LogTailLines = 15
    )

    Write-Host ''
    Write-Host "  检查 $Project 各服务状态..." -ForegroundColor Yellow

    foreach ($svc in $ExpectedServices) {
        try {
            $args = @('compose', '-f', $ComposeFile, '-p', $Project, 'ps', '-a', '--format', '{{.State}}', $svc)
            $state = (& docker @args 2>&1) | Out-String
            $state = $state.Trim()

            if ($state -notmatch 'running|Up') {
                Write-Host "  [!] $svc : $state" -ForegroundColor Red
                Write-LauncherLog "$Project 服务 $svc 未运行: $state" -Level WARN

                # 显示最近日志
                $logArgs = @('compose', '-f', $ComposeFile, '-p', $Project, 'logs', '--tail', "$LogTailLines", $svc)
                $logs = (& docker @logArgs 2>&1) | Out-String
                if ($logs) {
                    Write-Host "      最近日志:" -ForegroundColor DarkGray
                    $logs -split "`n" | Select-Object -Last 8 | ForEach-Object {
                        Write-Host "        $_" -ForegroundColor DarkGray
                    }
                }
            }
        } catch {
            Write-Host "  [?] $svc : 状态检查失败 - $($_.Exception.Message)" -ForegroundColor Yellow
        }
    }
    Write-Host ''
}

# ============================================================
# 启动平台
# ============================================================

function Start-N8n {
    <#
    .SYNOPSIS 启动 n8n 平台
    #>
    Write-Host ''
    Write-Host '  正在启动 n8n ...' -ForegroundColor Green
    Write-LauncherLog '========== 启动 n8n ==========' -Level INFO

    # 1. Docker 引擎检查
    if (-not (Ensure-DockerReady)) {
        Write-LauncherLog 'Docker Engine 不可用，无法启动 n8n' -Level ERROR
        return $false
    }

    # 2. 检查是否已在运行（端口检查之前，避免已运行时误报端口冲突）
    $status = Get-PlatformStatus -Project $Script:N8nProject -ComposeFile $Script:N8nComposeFile
    if ($status -match 'running|Up') {
        Write-LauncherLog 'n8n 已在运行，跳过启动' -Level INFO
        Write-Host '  n8n 已在运行中。' -ForegroundColor Yellow
        return $true
    }

    # 3. Compose 文件检查
    if (-not (Test-Path $Script:N8nComposeFile)) {
        Write-LauncherLog "n8n Compose 文件不存在: $($Script:N8nComposeFile)" -Level ERROR
        return $false
    }

    # 4. 端口冲突检查（排除 Docker 自身占用）
    if (-not (Test-PortAvailability -Port $Script:N8nPort)) {
        if (Test-PortIsDocker -Port $Script:N8nPort) {
            Write-LauncherLog "端口 $($Script:N8nPort) 被 Docker 占用，视为 n8n 已运行" -Level INFO
            Write-Host "  端口 $($Script:N8nPort) 被 Docker 占用，n8n 已在运行。" -ForegroundColor Yellow
            return $true
        }
        Write-LauncherLog "端口 $($Script:N8nPort) 被占用，n8n 启动中止" -Level ERROR
        Write-Host "  端口 $($Script:N8nPort) 被其他程序占用，请先释放。" -ForegroundColor Red
        return $false
    }

    # 5. 启动
    Write-LauncherLog "执行: docker compose -f $($Script:N8nComposeFile) -p $($Script:N8nProject) up -d" -Level INFO
    try {
        Push-Location $Script:N8nDir
        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        $output = & docker compose -f $Script:N8nComposeFile -p $Script:N8nProject up -d 2>&1
        $exitCode = $LASTEXITCODE
        $ErrorActionPreference = $prevEAP
        Pop-Location

        foreach ($line in $output) {
            Write-LauncherLog "  [docker] $line" -Level INFO
        }

        if ($exitCode -ne 0) {
            Write-LauncherLog "docker compose up 退出码: $exitCode" -Level ERROR
            return $false
        }
    } catch {
        Pop-Location
        Write-LauncherLog "启动 n8n 异常: $($_.Exception.Message)" -Level ERROR
        return $false
    }

    # 6. 等待就绪
    Start-Sleep -Seconds $Script:PostStartWaitSeconds
    $ready = Wait-N8nReady

    if (-not $ready) {
        Write-LauncherLog 'n8n 启动后健康检查未通过，检查各服务状态...' -Level WARN
        Show-UnreadyServices -Project $Script:N8nProject -ComposeFile $Script:N8nComposeFile -ExpectedServices $Script:N8nServices
    }

    Write-LauncherLog 'n8n 启动完成' -Level INFO
    return $ready
}

function Test-DifyRunning {
    <#
    .SYNOPSIS 通过 docker ps 检查 Dify 容器是否在运行（不依赖项目名）
    #>
    $result = & docker ps --format '{{.Names}}' 2>&1
    if ($LASTEXITCODE -ne 0) { return $false }
    # Dify 容器名包含 api、nginx、web、redis 等关键词
    $difyContainers = @('api', 'nginx', 'web', 'redis', 'db_postgres', 'worker')
    foreach ($line in $result) {
        $name = $line.Trim().ToLower()
        foreach ($kw in $difyContainers) {
            if ($name -match $kw) { return $true }
        }
    }
    return $false
}

function Start-Dify {
    <#
    .SYNOPSIS 启动 Dify 平台
    #>
    Write-Host ''
    Write-Host '  正在启动 Dify ...' -ForegroundColor Green
    Write-LauncherLog '========== 启动 Dify ==========' -Level INFO

    # 1. Docker 引擎检查
    if (-not (Ensure-DockerReady)) {
        Write-LauncherLog 'Docker Engine 不可用，无法启动 Dify' -Level ERROR
        return $false
    }

    # 2. 检查是否已在运行（不依赖项目名，直接查 docker ps）
    if (Test-DifyRunning) {
        Write-LauncherLog 'Dify 已在运行，跳过启动' -Level INFO
        Write-Host '  Dify 已在运行中。' -ForegroundColor Yellow
        return $true
    }

    # 3. Compose 文件检查
    if (-not (Test-Path $Script:DifyComposeFile)) {
        Write-LauncherLog "Dify Compose 文件不存在: $($Script:DifyComposeFile)" -Level ERROR
        return $false
    }

    # 4. 端口冲突检查（排除 Docker 自身占用）
    foreach ($port in @($Script:DifyNginxPort, 443, 5003)) {
        if (-not (Test-PortAvailability -Port $port)) {
            if (Test-PortIsDocker -Port $port) {
                Write-LauncherLog "端口 $port 被 Docker 占用，视为 Dify 已运行" -Level INFO
                Write-Host "  端口 $port 被 Docker 占用，Dify 已在运行。" -ForegroundColor Yellow
                return $true
            }
            Write-LauncherLog "端口 $port 被占用，Dify 启动中止" -Level ERROR
            Write-Host "  端口 $port 被其他程序占用，请先释放。" -ForegroundColor Red
            return $false
        }
    }

    # 5. 启动（使用默认项目名，确保新启动用统一名称）
    $project = $Script:DifyProject
    Write-LauncherLog "执行: docker compose -f $($Script:DifyComposeFile) -p $project up -d" -Level INFO
    try {
        Push-Location $Script:DifyDir
        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        $output = & docker compose -f $Script:DifyComposeFile -p $project up -d 2>&1
        $exitCode = $LASTEXITCODE
        $ErrorActionPreference = $prevEAP
        Pop-Location

        foreach ($line in $output) {
            Write-LauncherLog "  [docker] $line" -Level INFO
        }

        if ($exitCode -ne 0) {
            Write-LauncherLog "docker compose up 退出码: $exitCode" -Level ERROR
            return $false
        }
    } catch {
        Pop-Location
        Write-LauncherLog "启动 Dify 异常: $($_.Exception.Message)" -Level ERROR
        return $false
    }

    # 6. 等待就绪
    Start-Sleep -Seconds $Script:PostStartWaitSeconds
    $ready = Wait-DifyReady

    if (-not $ready) {
        Write-LauncherLog 'Dify 启动后健康检查未通过，检查各服务状态...' -Level WARN
        Show-UnreadyServices -Project $project -ComposeFile $Script:DifyComposeFile -ExpectedServices $Script:DifyServices
    }

    Write-LauncherLog 'Dify 启动完成' -Level INFO
    return $ready
}

# ============================================================
# 停止平台
# ============================================================

function Stop-N8n {
    <#
    .SYNOPSIS 安全停止 n8n（docker compose down，不删除卷）
    #>
    Write-Host ''
    Write-Host '  正在停止 n8n ...' -ForegroundColor Red
    Write-LauncherLog '========== 停止 n8n ==========' -Level INFO

    if (-not (Test-DockerEngine)) {
        Write-LauncherLog 'Docker Engine 不可用，无法停止 n8n' -Level ERROR
        return $false
    }

    $project = Get-ActualProjectName -DefaultProject $Script:N8nProject -ComposeFile $Script:N8nComposeFile
    Write-LauncherLog "n8n 实际项目名: $project" -Level INFO

    try {
        Push-Location $Script:N8nDir
        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        $output = & docker compose -f $Script:N8nComposeFile -p $project down 2>&1
        $exitCode = $LASTEXITCODE
        $ErrorActionPreference = $prevEAP
        Pop-Location

        foreach ($line in $output) {
            Write-LauncherLog "  [docker] $line" -Level INFO
        }

        if ($exitCode -ne 0) {
            Write-LauncherLog "docker compose down 退出码: $exitCode" -Level ERROR
            return $false
        }
    } catch {
        Pop-Location
        Write-LauncherLog "停止 n8n 异常: $($_.Exception.Message)" -Level ERROR
        return $false
    }

    Write-LauncherLog 'n8n 已停止' -Level INFO
    return $true
}

function Stop-Dify {
    <#
    .SYNOPSIS 安全停止 Dify（docker compose down，不删除卷）
    #>
    Write-Host ''
    Write-Host '  正在停止 Dify ...' -ForegroundColor Red
    Write-LauncherLog '========== 停止 Dify ==========' -Level INFO

    if (-not (Test-DockerEngine)) {
        Write-LauncherLog 'Docker Engine 不可用，无法停止 Dify' -Level ERROR
        return $false
    }

    $project = Get-ActualProjectName -DefaultProject $Script:DifyProject -ComposeFile $Script:DifyComposeFile
    Write-LauncherLog "Dify 实际项目名: $project" -Level INFO

    try {
        Push-Location $Script:DifyDir
        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        $output = & docker compose -f $Script:DifyComposeFile -p $project down 2>&1
        $exitCode = $LASTEXITCODE
        $ErrorActionPreference = $prevEAP
        Pop-Location

        foreach ($line in $output) {
            Write-LauncherLog "  [docker] $line" -Level INFO
        }

        if ($exitCode -ne 0) {
            Write-LauncherLog "docker compose down 退出码: $exitCode" -Level ERROR
            return $false
        }
    } catch {
        Pop-Location
        Write-LauncherLog "停止 Dify 异常: $($_.Exception.Message)" -Level ERROR
        return $false
    }

    Write-LauncherLog 'Dify 已停止' -Level INFO
    return $true
}

# ============================================================
# Cogpit Dashboard
# ============================================================

function Test-CogpitRunning {
    <#
    .SYNOPSIS 检测 Cogpit 是否正在运行
    #>
    try {
        $response = Invoke-WebRequest -UseBasicParsing -Uri $Script:CogpitHealthUrl -TimeoutSec 2 -ErrorAction SilentlyContinue
        return ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500)
    } catch {
        return $false
    }
}

function Start-Cogpit {
    <#
    .SYNOPSIS 启动 Cogpit Dashboard
    #>
    Write-Host ''
    Write-Host '  正在启动 Cogpit Dashboard ...' -ForegroundColor Green
    Write-LauncherLog '========== 启动 Cogpit ==========' -Level INFO

    # 已在运行
    if (Test-CogpitRunning) {
        Write-LauncherLog 'Cogpit 已在运行，跳过启动' -Level INFO
        Write-Host '  Cogpit 已在运行中。' -ForegroundColor Green
        return $true
    }

    # 检查启动脚本
    if (-not (Test-Path $Script:CogpitStartScript)) {
        Write-LauncherLog "Cogpit 启动脚本不存在: $($Script:CogpitStartScript)" -Level ERROR
        Write-Host '  Cogpit 启动脚本不存在。' -ForegroundColor Red
        return $false
    }

    # 启动
    Write-LauncherLog "执行: $Script:CogpitStartScript" -Level INFO
    try {
        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        & $Script:CogpitStartScript
        $exitCode = $LASTEXITCODE
        $ErrorActionPreference = $prevEAP

        if ($exitCode -ne 0) {
            Write-LauncherLog "Cogpit 启动脚本退出码: $exitCode" -Level ERROR
            return $false
        }
    } catch {
        Write-LauncherLog "启动 Cogpit 异常: $($_.Exception.Message)" -Level ERROR
        return $false
    }

    # 等待就绪
    Write-LauncherLog "等待 Cogpit 就绪..." -Level INFO
    $ready = $false
    for ($i = 0; $i -lt 30; $i++) {
        Start-Sleep -Seconds 1
        if (Test-CogpitRunning) {
            $ready = $true
            break
        }
    }

    if ($ready) {
        Write-LauncherLog 'Cogpit 启动完成' -Level INFO
        Write-Host "  Cogpit Dashboard 已就绪: $($Script:CogpitUrl)" -ForegroundColor Green
        return $true
    } else {
        Write-LauncherLog 'Cogpit 启动超时' -Level WARN
        Write-Host '  Cogpit 启动超时，请检查日志。' -ForegroundColor Yellow
        return $false
    }
}

function Stop-Cogpit {
    <#
    .SYNOPSIS 停止 Cogpit Dashboard
    #>
    Write-Host ''
    Write-Host '  正在停止 Cogpit Dashboard ...' -ForegroundColor Red
    Write-LauncherLog '========== 停止 Cogpit ==========' -Level INFO

    if (-not (Test-CogpitRunning)) {
        Write-LauncherLog 'Cogpit 未在运行' -Level INFO
        Write-Host '  Cogpit 未在运行。' -ForegroundColor Yellow
        return $true
    }

    # 检查停止脚本
    if (-not (Test-Path $Script:CogpitStopScript)) {
        Write-LauncherLog "Cogpit 停止脚本不存在: $($Script:CogpitStopScript)" -Level ERROR
        Write-Host '  Cogpit 停止脚本不存在。' -ForegroundColor Red
        return $false
    }

    # 停止
    Write-LauncherLog "执行: $Script:CogpitStopScript" -Level INFO
    try {
        $prevEAP = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        & $Script:CogpitStopScript 2>&1 | Out-Null
        $ErrorActionPreference = $prevEAP

        # 确认已停止
        Start-Sleep -Seconds 2
        if (-not (Test-CogpitRunning)) {
            Write-LauncherLog 'Cogpit 已停止' -Level INFO
            return $true
        } else {
            Write-LauncherLog 'Cogpit 似乎仍在运行' -Level WARN
            return $false
        }
    } catch {
        Write-LauncherLog "停止 Cogpit 异常: $($_.Exception.Message)" -Level ERROR
        return $false
    }
}

# ============================================================
# Msds Editor (结构读取 / main.py)
# ============================================================

function Start-MsdsEditor {
    <#
    .SYNOPSIS 启动 Msds Editor (结构读取\Msds-Editor.ps1 → main.py GUI)
    #>
    Write-Host ''
    Write-Host '  正在启动 Msds Editor (结构读取) ...' -ForegroundColor Green
    Write-LauncherLog '========== 启动 Msds Editor ==========' -Level INFO

    if (-not (Test-Path $Script:MsdsEditorMainPy)) {
        Write-LauncherLog "Msds Editor 入口不存在: $Script:MsdsEditorMainPy" -Level ERROR
        Write-Host "  Msds Editor 入口不存在: $Script:MsdsEditorMainPy" -ForegroundColor Red
        return $false
    }

    try {
        Write-LauncherLog "执行: $Script:PythonExe $Script:MsdsEditorMainPy" -Level INFO
        Start-Process -FilePath $Script:PythonExe -ArgumentList "`"$Script:MsdsEditorMainPy`"" -WorkingDirectory $Script:MsdsEditorDir
        Write-Host '  Msds Editor 界面已成功启动打开！' -ForegroundColor Green
        return $true
    } catch {
        Write-LauncherLog "启动 Msds Editor 异常: $($_.Exception.Message)" -Level ERROR
        Write-Host "  启动失败: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# ============================================================
# AI Study Tauri System
# ============================================================

function Get-OfficialAIStudyExe {
    <#
    .SYNOPSIS 返回 AI Study Tauri 唯一正式构建产物。
    .DESCRIPTION
    只扫描正式打包脚本生成的 cargo-target-latest-* 目录，并选择最新的完整 EXE。
    preview、final-fixed-corners 和其他历史目录不参与 wl 默认启动。
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

function Stop-MsdsEditor {
    <# 停止由 main.py (结构读取) 启动的 Msds Editor 进程 #>
    Write-Host ''
    Write-Host '  正在停止 Msds Editor ...' -ForegroundColor Red
    Write-LauncherLog '========== 停止 Msds Editor ==========' -Level INFO

    try {
        $processes = Get-CimInstance Win32_Process -Filter "Name = 'python.exe' OR Name = 'pythonw.exe'" -ErrorAction SilentlyContinue |
            Where-Object { $_.CommandLine -and $_.CommandLine -like '*结构读取*main.py*' }
        foreach ($process in $processes) {
            Stop-Process -Id $process.ProcessId -Force -ErrorAction Stop
        }
        Write-LauncherLog 'Msds Editor 已停止' -Level INFO
        return $true
    } catch {
        Write-LauncherLog "停止 Msds Editor 异常: $($_.Exception.Message)" -Level ERROR
        return $false
    }
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

    # wl 只允许存在一个 AI Study Tauri 实例，避免旧版窗口继续占据用户视图。
    # 这里按进程名收口，因为提升权限的旧实例可能无法返回 ExecutablePath，
    # 但 AIstudy.exe 是本统一启动器管理的唯一 Tauri 主程序名。
    $existingProcesses = @(Get-CimInstance Win32_Process -Filter "Name = 'AIstudy.exe'" -ErrorAction SilentlyContinue)
    foreach ($process in $existingProcesses) {
        try {
            Stop-Process -Id $process.ProcessId -Force -ErrorAction Stop
            Write-LauncherLog "启动前关闭历史 AIstudy 进程: PID=$($process.ProcessId)" -Level INFO
        } catch {
            Write-LauncherLog "启动前无法关闭历史 AIstudy 进程: PID=$($process.ProcessId), 原因=$($_.Exception.Message)" -Level ERROR
            Write-Host "  无法关闭旧版 AI Study Tauri 进程 PID=$($process.ProcessId)，请以管理员身份运行 wl 后重试。" -ForegroundColor Red
            return $false
        }
    }
    Start-Sleep -Milliseconds 300
    $remainingProcesses = @(Get-CimInstance Win32_Process -Filter "Name = 'AIstudy.exe'" -ErrorAction SilentlyContinue)
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
    <# 停止所有由统一启动器管理的 AI Study Tauri 实例 #>
    Write-Host ''
    Write-Host '  正在停止 AI Study Tauri 正式构建版 ...' -ForegroundColor Red
    Write-LauncherLog '========== 停止 AI Study Tauri ==========' -Level INFO

    try {
        $processes = @(Get-CimInstance Win32_Process -Filter "Name = 'AIstudy.exe'" -ErrorAction SilentlyContinue)
        if ($processes.Count -eq 0) {
            Write-LauncherLog '未找到 AI Study Tauri 实例，按未运行处理' -Level WARN
            return $true
        }
        foreach ($process in $processes) {
            Stop-Process -Id $process.ProcessId -Force -ErrorAction Stop
            Write-LauncherLog "已停止 AIstudy 进程: PID=$($process.ProcessId)" -Level INFO
        }
        Start-Sleep -Milliseconds 300
        $remainingProcesses = @(Get-CimInstance Win32_Process -Filter "Name = 'AIstudy.exe'" -ErrorAction SilentlyContinue)
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

    if (-not (Test-Path $Script:DshRoot)) {
        Write-LauncherLog "DeepSeek Harness 目录不存在: $($Script:DshRoot)" -Level ERROR
        Write-Host "  未找到 DeepSeek Harness 目录: $Script:DshRoot" -ForegroundColor Red
        return $false
    }
    if (-not (Test-Path $Script:DshCliBin) -and -not (Test-Path $Script:DshPnpmCmd)) {
        Write-LauncherLog "DeepSeek Harness 预编译 CLI 与 pnpm 均不存在" -Level ERROR
        Write-Host "  未找到预编译 CLI: $($Script:DshCliBin)" -ForegroundColor Red
        Write-Host "  也未找到 pnpm: $($Script:DshPnpmCmd)" -ForegroundColor Red
        return $false
    }

    # 后台拉起 dsh web（分离进程，不阻塞 wl 菜单）。
    # 优先用预编译 CLI（node apps/cli/lib/bin.js），避免 pnpm+tsx 源码转译导致的 ~95s 冷启动；
    # 预编译产物缺失时回退到 pnpm dsh web。
    $dshOut = Join-Path $Script:DshRoot 'dsh-web.out.log'
    $dshErr = Join-Path $Script:DshRoot 'dsh-web.err.log'
    Remove-Item -LiteralPath $dshOut, $dshErr -ErrorAction SilentlyContinue
    try {
        $env:DSH_HOME = $Script:DshHome
        if (Test-Path -LiteralPath $Script:DshCliBin) {
            # 路径含空格，必须显式加引号；Start-Process -ArgumentList 数组拼接不会自动加引号
            $dshArgs = "`"$($Script:DshCliBin)`" web"
            Start-Process -FilePath 'node.exe' -ArgumentList $dshArgs `
                -WorkingDirectory $Script:DshRoot -WindowStyle Hidden `
                -RedirectStandardOutput $dshOut -RedirectStandardError $dshErr
            Write-LauncherLog "后台启动命令已发出: node $dshArgs (预编译 CLI)" -Level INFO
        } else {
            Start-Process -FilePath $Script:DshPnpmCmd -ArgumentList 'dsh', 'web' `
                -WorkingDirectory $Script:DshRoot -WindowStyle Hidden `
                -RedirectStandardOutput $dshOut -RedirectStandardError $dshErr
            Write-LauncherLog "后台启动命令已发出: $Script:DshPnpmCmd dsh web (回退 pnpm)" -Level INFO
        }
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

    if (-not (Test-Path $Script:DshRoot)) {
        Write-LauncherLog "DeepSeek Harness 目录不存在: $($Script:DshRoot)" -Level ERROR
        Write-Host "  未找到 DeepSeek Harness 目录: $Script:DshRoot" -ForegroundColor Red
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
        if (Test-Path -LiteralPath $Script:DshCliBin) {
            & 'node.exe' $Script:DshCliBin --profile headless $task
        } else {
            & $Script:DshPnpmCmd dsh --profile headless $task
        }
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
        # 1) 按端口 3080 定位持有进程（最可靠）
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
                ($_.CommandLine -like '*deepseek-harness*' -or
                 $_.CommandLine -like '*apps/cli/src/bin.ts*' -or
                 $_.CommandLine -like '*apps/cli/lib/bin.js*' -or
                 ($_.CommandLine -like '*pnpm*' -and $_.CommandLine -like '*dsh*'))
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
# 打开网页
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
            # 启动 n8n
            $ok = Start-N8n
            if ($ok) {
                $ans = Read-Host '  是否打开 n8n 网页? (Y/n)'
                if ($ans -ne 'n' -and $ans -ne 'N') {
                    Open-PlatformUrl -Name 'n8n' -Url $Script:N8nUrl
                }
            }
        }
        '2' {
            # 启动 Dify
            $ok = Start-Dify
            if ($ok) {
                $ans = Read-Host '  是否打开 Dify 网页? (Y/n)'
                if ($ans -ne 'n' -and $ans -ne 'N') {
                    Open-PlatformUrl -Name 'Dify' -Url $Script:DifyUrl
                }
            }
        }
        '3' {
            # 启动 Cogpit
            $ok = Start-Cogpit
            if ($ok) {
                $ans = Read-Host '  是否打开 Cogpit 网页? (Y/n)'
                if ($ans -ne 'n' -and $ans -ne 'N') {
                    Open-PlatformUrl -Name 'Cogpit' -Url $Script:CogpitUrl
                }
            }
        }
        '4' {
            # 启动 Msds Editor (结构读取)
            Start-MsdsEditor
        }
        '5' {
            # 启动 AI Study Tauri 系统 (最新动态构建版)
            Start-AIStudyTauri
        }
        '6' {
            # 启动 DeepSeek Harness (dsh Web)，自动打开 Dashboard
            $null = Start-Dsh
        }
        '7' {
            # 运行 DeepSeek Harness 一次性任务 (CLI)
            Start-DshHeadless
        }
        '8' {
            # 同时启动全部
            Write-Host ''
            Write-Host '  同时启动 n8n、Dify、Cogpit 和 DeepSeek Harness ...' -ForegroundColor Green
            $n8nOk   = Start-N8n
            $difyOk  = Start-Dify
            $cogOk   = Start-Cogpit
            $dshOk   = Start-Dsh

            if ($n8nOk) {
                $ans = Read-Host '  是否打开 n8n 网页? (Y/n)'
                if ($ans -ne 'n' -and $ans -ne 'N') {
                    Open-PlatformUrl -Name 'n8n' -Url $Script:N8nUrl
                }
            }
            if ($difyOk) {
                $ans = Read-Host '  是否打开 Dify 网页? (Y/n)'
                if ($ans -ne 'n' -and $ans -ne 'N') {
                    Open-PlatformUrl -Name 'Dify' -Url $Script:DifyUrl
                }
            }
            if ($cogOk) {
                $ans = Read-Host '  是否打开 Cogpit 网页? (Y/n)'
                if ($ans -ne 'n' -and $ans -ne 'N') {
                    Open-PlatformUrl -Name 'Cogpit' -Url $Script:CogpitUrl
                }
            }
            # DeepSeek Harness 已在 Start-Dsh 内自动打开 Dashboard
        }
        '9' {
            # 查看状态
            Show-PlatformStatus
        }
        '10' {
            # 停止 n8n
            Stop-N8n
        }
        '11' {
            # 停止 Dify
            Stop-Dify
        }
        '12' {
            # 停止 Cogpit
            Stop-Cogpit
        }
        '13' {
            # 停止 DeepSeek Harness
            Stop-Dsh
        }
        '14' {
            # 停止全部
            Write-Host ''
            Write-Host '  停止全部平台 ...' -ForegroundColor Red
            Stop-N8n
            Stop-Dify
            Stop-Cogpit
            Stop-Dsh
        }
        'e1' {
            # 打开 n8n 网页
            Open-PlatformUrl -Name 'n8n' -Url $Script:N8nUrl
        }
        'e2' {
            # 打开 Dify 网页
            Open-PlatformUrl -Name 'Dify' -Url $Script:DifyUrl
        }
        'e3' {
            # 打开 Cogpit 网页
            Open-PlatformUrl -Name 'Cogpit' -Url $Script:CogpitUrl
        }
        'e4' {
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

    # 命令行模式
    if ($Action) {
        Write-LauncherLog "命令行模式: $Action $Target" -Level INFO
        switch ($Action) {
            'start' {
                $ok = $false
                switch ($Target) {
                    'n8n'         { $ok = Start-N8n; if ($ok) { Open-PlatformUrl -Name 'n8n' -Url $Script:N8nUrl } }
                    'dify'        { $ok = Start-Dify; if ($ok) { Open-PlatformUrl -Name 'Dify' -Url $Script:DifyUrl } }
                    'cogpit'      { $ok = Start-Cogpit; if ($ok) { Open-PlatformUrl -Name 'Cogpit' -Url $Script:CogpitUrl } }
                    'editor'      { $ok = Start-MsdsEditor }
                    'wordeditor'  { $ok = Start-MsdsEditor }
                    'msds'        { $ok = Start-MsdsEditor }
                    'msdseditor'  { $ok = Start-MsdsEditor }
                    'aistudy'     { $ok = Start-AIStudyTauri }
                    'tauri'       { $ok = Start-AIStudyTauri }
                    'system'      { $ok = Start-AIStudyTauri }
                    'aistudy-tauri' { $ok = Start-AIStudyTauri }
                    'dsh'         { $ok = Start-Dsh }
                    'deepseek'    { $ok = Start-Dsh }
                    'deepseek-harness' { $ok = Start-Dsh }
                    'harness'     { $ok = Start-Dsh }
                    'all'    {
                        $n = Start-N8n; $d = Start-Dify; $c = Start-Cogpit; $h = Start-Dsh
                        if ($n) { Open-PlatformUrl -Name 'n8n' -Url $Script:N8nUrl }
                        if ($d) { Open-PlatformUrl -Name 'Dify' -Url $Script:DifyUrl }
                        if ($c) { Open-PlatformUrl -Name 'Cogpit' -Url $Script:CogpitUrl }
                        # DeepSeek Harness 已在 Start-Dsh 内自动打开 Dashboard
                        $ok = ($n -and $d -and $c -and $h)
                    }
                    default { Write-Host "未知目标: $Target" -ForegroundColor Red }
                }
                if ($ok -eq $false) { exit 1 }
            }
            'stop' {
                switch ($Target) {
                    'n8n'        { $ok = Stop-N8n }
                    'dify'       { $ok = Stop-Dify }
                    'cogpit'     { $ok = Stop-Cogpit }
                    'editor'     { $ok = Stop-MsdsEditor }
                    'wordeditor' { $ok = Stop-MsdsEditor }
                    'msds'        { $ok = Stop-MsdsEditor }
                    'msdseditor'  { $ok = Stop-MsdsEditor }
                    'aistudy'    { $ok = Stop-AIStudyTauri }
                    'tauri'      { $ok = Stop-AIStudyTauri }
                    'system'     { $ok = Stop-AIStudyTauri }
                    'dsh'         { $ok = Stop-Dsh }
                    'deepseek'    { $ok = Stop-Dsh }
                    'deepseek-harness' { $ok = Stop-Dsh }
                    'harness'     { $ok = Stop-Dsh }
                    'all'        {
                        $n = Stop-N8n
                        $d = Stop-Dify
                        $c = Stop-Cogpit
                        $w = Stop-MsdsEditor
                        $a = Stop-AIStudyTauri
                        $h = Stop-Dsh
                        $ok = ($n -and $d -and $c -and $w -and $a -and $h)
                    }
                    default      { Write-Host "未知目标: $Target" -ForegroundColor Red; $ok = $false }
                }
                if ($ok -eq $false) { exit 1 }
            }
            'status'  { Show-PlatformStatus; exit 0 }
            'logs' {
                switch ($Target) {
                    'n8n'  {
                        $p = Get-ActualProjectName -DefaultProject $Script:N8nProject -ComposeFile $Script:N8nComposeFile
                        Push-Location $Script:N8nDir
                        & docker compose -f $Script:N8nComposeFile -p $p logs --tail 50 -f
                        Pop-Location
                    }
                    'dify' {
                        $p = Get-ActualProjectName -DefaultProject $Script:DifyProject -ComposeFile $Script:DifyComposeFile
                        Push-Location $Script:DifyDir
                        & docker compose -f $Script:DifyComposeFile -p $p logs --tail 50 -f
                        Pop-Location
                    }
                    default { Write-Host "用法: .\Workflow-Launcher.ps1 logs [n8n|dify]" -ForegroundColor Yellow }
                }
            }
            default { Write-Host "用法: .\Workflow-Launcher.ps1 [start|stop|status|logs] [n8n|dify|cogpit|editor|aistudy|dsh|all]" -ForegroundColor Yellow; exit 1 }
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
