@echo off
setlocal
set "TEXT=%*"
if "%TEXT%"=="" set "TEXT=Hello"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$t=[uri]::EscapeDataString($env:TEXT); try { Invoke-RestMethod \"http://127.0.0.1:17321/say?text=$t\" | ConvertTo-Json -Compress } catch { Write-Host 'Robot pet is not running. Run start.bat first.'; exit 1 }"
