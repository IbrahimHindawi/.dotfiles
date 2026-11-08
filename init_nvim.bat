@echo off
setlocal

set "root=%~dp0"
set "src=%root%nvim"
set "dst=%LOCALAPPDATA%\nvim"

if not exist "%src%\" (
  echo FAILED: source nvim folder missing: "%src%"
  exit /b 1
)

echo Syncing "%src%" to "%dst%"

rmdir /S /Q "%dst%" 2>nul
mkdir "%dst%" 2>nul

xcopy /E /I /Y "%src%" "%dst%" >nul
if errorlevel 1 (
  echo FAILED: xcopy returned errorlevel %errorlevel%
  exit /b %errorlevel%
)

echo DONE
