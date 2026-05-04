@echo off
setlocal
cd /d "%~dp0"

where node >nul 2>nul
if errorlevel 1 (
  echo Node.js was not found.
  echo Please install Node.js LTS from https://nodejs.org/
  pause
  exit /b 1
)

where npm >nul 2>nul
if errorlevel 1 (
  echo npm was not found. Please reinstall Node.js LTS.
  pause
  exit /b 1
)

if not exist "node_modules\electron\dist\electron.exe" (
  echo Preparing Windows dependencies. This may take a few minutes on first run...
  if exist "node_modules" rmdir /s /q "node_modules"
  call npm install
  if errorlevel 1 (
    echo npm install failed.
    pause
    exit /b 1
  )
)

echo Starting OpenClaw Robot Pet from pet2...
start "OpenClaw Robot Pet pet2" cmd /k npm start
exit /b 0
