@echo off
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0Workflow-Launcher.ps1" %*
if %ERRORLEVEL% neq 0 pause
