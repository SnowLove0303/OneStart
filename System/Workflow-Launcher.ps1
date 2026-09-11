<#
  Workflow Launcher (指令: wll)
  本机统一启动器：管理 AI Study Tauri、DeepSeek Harness (dsh) 与冠志通 Docker Web 的启动、停止、状态与日志。

  用法：
    .\Workflow-Launcher.ps1                  显示交互菜单
    .\Workflow-Launcher.ps1 start dsh        启动 DeepSeek Harness (Web)
    .\Workflow-Launcher.ps1 start aistudy    启动 AI Study Tauri
    .\Workflow-Launcher.ps1 start web        启动冠志通 Web 工作台
    .\Workflow-Launcher.ps1 start guanzhitong-lan 一键启动冠志通 Docker Web 并开启 Wi‑Fi 局域网访问
    .\Workflow-Launcher.ps1 start compliance 启动合规性判断工作台应用
    .\Workflow-Launcher.ps1 start all        同时启动全部平台
    .\Workflow-Launcher.ps1 stop all         停止全部平台
    .\Workflow-Launcher.ps1 stop guanzhitong-lan 一键关闭局域网访问并停止冠志通 Docker Web
    .\Workflow-Launcher.ps1 status           查看运行状态
    .\Workflow-Launcher.ps1 logs dsh         查看 dsh 运行日志
    .\Workflow-Launcher.ps1 dsh              便捷写法，等价于 start dsh
    .\Workflow-Launcher.ps1 web              便捷写法，等价于 start web
    .\Workflow-Launcher.ps1 guanzhitong-lan   便捷写法，等价于 start guanzhitong-lan
    .\Workflow-Launcher.ps1 compliance       便捷写法，打开合规性判断工作台应用
    .\Workflow-Launcher.ps1 lan on           开启当前 Wi‑Fi 局域网访问
    .\Workflow-Launcher.ps1 lan off          关闭当前 Wi‑Fi 局域网访问
    .\Workflow-Launcher.ps1 lan status       查看 Docker Web 局域网状态
    .\Workflow-Launcher.ps1 start ai-suite   一键启动 AI 桌面协同组合 (Antigravity/IDE/ChatGPT/Cockpit)
    .\Workflow-Launcher.ps1 stop ai-suite    一键关闭 AI 桌面协同组合
    .\Workflow-Launcher.ps1 status ai-suite  查看 AI 桌面协同组合状态
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
$Script:GuanZhiDockerBackendRuleDisplayName = 'Docker Desktop Backend'

# --- AI 桌面工具协同组合 (Antigravity / IDE / ChatGPT / Cockpit) 配置 ---
$Script:AntigravityExe          = Join-Path $env:LOCALAPPDATA 'Programs\antigravity\Antigravity.exe'
$Script:AntigravityAltLauncher  = 'D:\APP\AI app\Antigravity\Antigravity-launcher.cmd'
$Script:AntigravityIdeExe       = 'D:\APP\AI app\Antigravity\Antigravity IDE\Antigravity IDE.exe'
$Script:CockpitExe              = 'D:\APP\AI app\Cockpit\cockpit-tools.exe'
$Script:CockpitDir              = 'D:\APP\AI app\Cockpit'
$Script:ChatGptPackageFamily    = 'OpenAI.Codex_2p2nqsd0c76g0'
$Script:ChatGptAppId            = 'OpenAI.Codex_2p2nqsd0c76g0!App'

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

function Test-DshRunning {
    <#
    .SYNOPSIS 检测 DeepSeek Harness Web 是否正在运行
    .NOTES dsh 首页会保持流式响应，不能用 Invoke-WebRequest 等待响应结束；
           通过固定端口和正式 CLI 入口确认唯一运行实例。
    #>
    try {
        $listeners = @(Get-NetTCPConnection -LocalAddress '127.0.0.1' -LocalPort $Script:DshPort -State Listen -ErrorAction Stop)
        if ($listeners.Count -eq 0) { return $false }

        $dshPids = @(Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
            Where-Object {
                $_.ProcessId -in @($listeners | Select-Object -ExpandProperty OwningProcess) -and
                $_.Name -eq 'node.exe' -and
                $_.CommandLine -like "*$($Script:DshCliBin)*" -and
                $_.CommandLine -like "*--port $($Script:DshPort)*"
            })
        return ($dshPids.Count -gt 0)
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
        $dshWorkDir = $Script:DshRoot
        # 路径含空格，必须显式加引号；Start-Process -ArgumentList 数组拼接不会自动加引号
        $dshArgs = "`"$($Script:DshCliBin)`" web --patch apps/cli/config/examples/schedule/cordis.yml --port $($Script:DshPort)"
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
        'all',
        'ai-suite', 'aisuite', 'aitools', 'antigravity', 'antigravity-ide', 'ide', 'chatgpt', 'cockpit'
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
                    'web'         { $ok = Start-GuanZhiWeb }
                    'guanzhi'     { $ok = Start-GuanZhiWeb }
                    'guanzhi-web' { $ok = Start-GuanZhiWeb }
                    'guanzhitong-lan' { $ok = Start-GuanZhiLanSession }
                    'compliance' { $ok = Start-GuanZhiCompliance }
                    'ai-suite'        { $ok = Start-AiSuite }
                    'aisuite'         { $ok = Start-AiSuite }
                    'aitools'         { $ok = Start-AiSuite }
                    'antigravity'     { $ok = Start-AntigravityApp }
                    'antigravity-ide' { $ok = Start-AntigravityIdeApp }
                    'ide'             { $ok = Start-AntigravityIdeApp }
                    'chatgpt'         { $ok = Start-ChatGptApp }
                    'cockpit'         { $ok = Start-CockpitApp }
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
            'status'  {
                if ($Target -in @('ai-suite', 'aisuite', 'aitools', 'ai')) {
                    Write-Host ''
                    Write-Host '  -- AI 桌面协同组合状态 (Antigravity / IDE / ChatGPT / Cockpit) --' -ForegroundColor Cyan
                    Show-AiSuiteSummary
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
            default { Write-Host "用法: .\Workflow-Launcher.ps1 [start|stop|status|lan|logs] [aistudy|dsh|web|guanzhitong-lan|compliance|ai-suite|antigravity|antigravity-ide|chatgpt|cockpit|all]" -ForegroundColor Yellow; exit 1 }
        }
        return
    }

    # 交互菜单模式
    Write-LauncherLog '启动器启动 (交互菜单)' -Level INFO
    Clear-Host
    $running = $true
    while ($running) {
        Write-Menu
        $choice = Read-Host '  请选择操作 [0-16, E1, CLS, 0]'
        $running = Invoke-MenuAction -Choice $choice
        if ($running) {
            if ($choice -and $choice.Trim().ToLowerInvariant() -in @('cls', 'clear')) {
                continue
            }
            Write-Host ''
            Write-Host '  ------------------------------------------------------------' -ForegroundColor DarkGray
            Write-Host '  [提示] 鼠标划选按 Ctrl+C 复制 | 按 [C] 复制最新日志 | 按 [Enter] 返回主菜单...' -ForegroundColor DarkCyan
            Write-Host '         (完整执行记录已同步写入: System\logs\launcher.log，输入 cls 可手动清屏)' -ForegroundColor DarkGray
            try {
                while ($true) {
                    $key = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
                    # 忽略纯修饰键 (Shift: 16, Ctrl: 17, Alt: 18, Win: 91/92)
                    if ($key.VirtualKeyCode -in 16, 17, 18, 91, 92) { continue }
                    # 若按下 Ctrl+C 执行文本复制，已由控制台处理，不退出等待
                    $isCtrl = [bool]($key.ControlKeyState -band ([System.Management.Automation.Host.ControlKeyStates]::RightCtrlPressed -bor [System.Management.Automation.Host.ControlKeyStates]::LeftCtrlPressed))
                    if ($isCtrl -and $key.VirtualKeyCode -eq 67) { continue }
                    # 按 C 键一键将最近日志复制到系统剪贴板
                    if ($key.Character -in 'c', 'C') {
                        try {
                            if (Test-Path -LiteralPath $Script:LogFile) {
                                $tail = (Get-Content -LiteralPath $Script:LogFile -Tail 30) -join [Environment]::NewLine
                                if (-not [string]::IsNullOrWhiteSpace($tail)) {
                                    Set-Clipboard -Value $tail
                                    Write-Host '  [√] 已将最近 30 行执行日志复制到系统剪贴板！' -ForegroundColor Green
                                }
                            }
                        } catch {
                            Write-Host "  复制失败: $($_.Exception.Message)" -ForegroundColor Red
                        }
                        continue
                    }
                    # 按 Enter 键确认返回菜单
                    if ($key.VirtualKeyCode -eq 13) { break }
                }
            } catch {
                $null = Read-Host
            }
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
