@echo off
setlocal

set "winget=%LOCALAPPDATA%\Microsoft\WindowsApps\winget.exe"

if not exist "%winget%" (
  echo ERROR: winget not found.
  echo Install/update "App Installer" from Microsoft Store.
  exit /b 1
)

set "nvimdir=%USERPROFILE%\AppData\Local\nvim"
rmdir /S /Q "%nvimdir%" 2>nul
mkdir "%nvimdir%"
xcopy /E /I /Y nvim "%nvimdir%"

mkdir "%APPDATA%\alacritty" 2>nul
copy /Y alacritty\alacritty.toml "%APPDATA%\alacritty\"

mkdir C:\devel 2>nul
copy /Y scripts\vs.bat C:\devel\

:: install tooling
"%winget%" install --id LLVM.LLVM -e
"%winget%" install --id Kitware.CMake -e
"%winget%" install --id Ninja-build.Ninja -e
"%winget%" install --id OpenJS.NodeJS.LTS -e
"%winget%" install --id Python.Python.3.13 -e
"%winget%" install --id Rclone.Rclone -e

:: install MSVC Build Tools + Windows SDK
"%winget%" install --id Microsoft.VisualStudio.2022.BuildTools -e --override "--quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"

:: add useful paths
set "PATH=%PATH%;%LOCALAPPDATA%\Microsoft\WindowsApps;%LOCALAPPDATA%\Microsoft\WinGet\Links;C:\Program Files\LLVM\bin;C:\Program Files\CMake\bin;C:\devel"

:: save PATH permanently
setx PATH "%PATH%"

echo.
echo Done. Close this terminal and open a new one.
echo.
echo Verify:
echo where winget
echo where clang
echo where cmake
echo where ninja
echo where node
echo where npm
echo where python
echo.
echo Versions:
echo clang --version
echo cmake --version
echo ninja --version
echo node --version
echo npm --version
echo python --version
echo.
echo IMPORTANT:
echo Run C:\devel\vs.bat before compiling native Windows projects.
echo.

endlocal
