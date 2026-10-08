<#
.SYNOPSIS
  Workflow-Launcher in-process execution wrapper.
#>
$launcher = Join-Path $PSScriptRoot 'Workflow-Launcher.ps1'
if (Test-Path -LiteralPath $launcher) {
    & $launcher @args
} else {
    Write-Error "Workflow-Launcher.ps1 not found in $PSScriptRoot"
}