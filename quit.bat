@echo off
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-RestMethod http://127.0.0.1:17321/quit | ConvertTo-Json -Compress } catch { Write-Host 'Robot pet is not running.'; exit 1 }"
