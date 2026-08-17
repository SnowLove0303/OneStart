# Syntax check helper script
param([string]$FilePath)

$tokens = $null
$errors = $null
$null = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$tokens, [ref]$errors)

if ($errors.Count -gt 0) {
    Write-Host "Found $($errors.Count) parse error(s):" -ForegroundColor Red
    $errors | ForEach-Object {
        Write-Host "  Line $($_.Extent.StartLineNumber): $($_.Message)" -ForegroundColor Red
    }
    exit 1
} else {
    Write-Host "PARSE CHECK PASSED: No syntax errors." -ForegroundColor Green
}

# Count functions
$ast = [System.Management.Automation.Language.Parser]::ParseFile($FilePath, [ref]$null, [ref]$null)
$funcs = $ast.FindAll({ $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $false)
Write-Host "Functions found: $($funcs.Count)"
$funcs | ForEach-Object { Write-Host "  - $($_.Name)" }

# Check for dangerous commands
$content = Get-Content $FilePath -Raw
$dangerous = @('docker volume rm', 'docker rm -f', 'docker rmi', '-v ', 'Remove-Item -Recurse')
$found = @()
foreach ($d in $dangerous) {
    if ($content -match [regex]::Escape($d)) {
        $found += $d
    }
}
if ($found.Count -gt 0) {
    Write-Host "WARNING: Potentially dangerous commands found:" -ForegroundColor Yellow
    $found | ForEach-Object { Write-Host "  - $_" -ForegroundColor Yellow }
} else {
    Write-Host "SAFETY CHECK: No dangerous volume/image deletion commands found." -ForegroundColor Green
}
