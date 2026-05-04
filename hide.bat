@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-RestMethod http://127.0.0.1:17321/hide | ConvertTo-Json -Compress } catch { Write-Host 'Robot pet is not running. Run start.bat first.'; exit 1 }"
