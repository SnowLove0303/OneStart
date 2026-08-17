# Fix bat files to use CRLF line endings
$batFiles = @(
    'F:\正式项目与模块化内容\统一启动器\System\wl.bat',
    'F:\正式项目与模块化内容\统一启动器\System\Workflow-Launcher.bat'
)
foreach ($f in $batFiles) {
    $content = Get-Content $f -Raw
    $content = $content -replace "`r`n", "`n"
    $content = $content -replace "`n", "`r`n"
    [System.IO.File]::WriteAllText($f, $content, [System.Text.Encoding]::ASCII)
    Write-Host "Fixed: $f"
}
