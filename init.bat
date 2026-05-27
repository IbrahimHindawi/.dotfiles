@echo off
setlocal

set "winget=%LOCALAPPDATA%\Microsoft\WindowsApps\winget.exe"

if not exist "%winget%" (
  exit /b 1
)

set "nvimdir=%USERPROFILE%\AppData\Local\nvim"
rmdir /S /Q "%nvimdir%" 2>nul
mkdir "%nvimdir%" 2>nul
xcopy /E /I /Y nvim "%nvimdir%" >nul

mkdir "%APPDATA%\alacritty" 2>nul
copy /Y alacritty\alacritty.toml "%APPDATA%\alacritty\" >nul

mkdir C:\devel 2>nul

"%winget%" install --id LLVM.LLVM -e
"%winget%" install --id Kitware.CMake -e
"%winget%" install --id Ninja-build.Ninja -e
"%winget%" install --id OpenJS.NodeJS.LTS -e
"%winget%" install --id Python.Python.3.13 -e
"%winget%" install --id Python.Launcher -e
"%winget%" install --id Rclone.Rclone -e

"%winget%" install --id Microsoft.VisualStudio.2022.BuildTools -e --override "--quiet --wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"

set "cleanpath=%USERPROFILE%\AppData\Local\Programs\Python\Python313"
set "cleanpath=%cleanpath%;%USERPROFILE%\AppData\Local\Programs\Python\Python313\Scripts"
set "cleanpath=%cleanpath%;%LOCALAPPDATA%\Microsoft\WindowsApps"
set "cleanpath=%cleanpath%;%LOCALAPPDATA%\Microsoft\WinGet\Links"
set "cleanpath=%cleanpath%;%APPDATA%\npm"
set "cleanpath=%cleanpath%;C:\Program Files\Git\cmd"
set "cleanpath=%cleanpath%;C:\Program Files\Neovim\bin"
set "cleanpath=%cleanpath%;C:\Program Files\WezTerm"
set "cleanpath=%cleanpath%;C:\Program Files\LLVM\bin"
set "cleanpath=%cleanpath%;C:\Program Files\CMake\bin"
set "cleanpath=%cleanpath%;C:\Program Files\nodejs"
set "cleanpath=%cleanpath%;C:\devel"

setx PATH "%cleanpath%" >nul

endlocal
