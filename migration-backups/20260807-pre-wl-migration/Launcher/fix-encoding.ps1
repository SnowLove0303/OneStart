# Fix bat files to use CRLF line endings
$batFiles = @(
    'E:\MorenAnzhuangLujing\Huangjingdajian\Launcher\wl.bat',
    'E:\MorenAnzhuangLujing\Huangjingdajian\Launcher\Workflow-Launcher.bat'
)
foreach ($f in $batFiles) {
    $content = Get-Content $f -Raw
    $content = $content -replace "`r`n", "`n"
    $content = $content -replace "`n", "`r`n"
    [System.IO.File]::WriteAllText($f, $content, [System.Text.Encoding]::ASCII)
    Write-Host "Fixed: $f"
}
