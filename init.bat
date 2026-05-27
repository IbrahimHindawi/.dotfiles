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

copy /Y .wezterm.lua "%USERPROFILE%\" >nul

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
"%winget%" install --id chrisant996.Clink -e
"%winget%" install --id Starship.Starship -e

"%winget%" install --id Microsoft.VisualStudio.2022.BuildTools -e --override "--wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"

set "fontfound=0"

dir "%LOCALAPPDATA%\Microsoft\Windows\Fonts\*IosevkaTerm*Nerd*Regular*.ttf" >nul 2>nul
if not errorlevel 1 set "fontfound=1"

dir "C:\Windows\Fonts\*IosevkaTerm*Nerd*Regular*.ttf" >nul 2>nul
if not errorlevel 1 set "fontfound=1"

if "%fontfound%"=="0" (
  set "fontzip=%USERPROFILE%\.dotfiles\cache\IosevkaTerm.zip"
  set "fontdir=%TEMP%\iosevka-term-nerd-font"

  mkdir "%USERPROFILE%\.dotfiles\cache" 2>nul
  rmdir /S /Q "%fontdir%" 2>nul
  mkdir "%fontdir%" 2>nul

  if not exist "%fontzip%" (
    curl.exe -L --progress-bar -o "%fontzip%" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/IosevkaTerm.zip"
  )

  powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "Expand-Archive '%fontzip%' -DestinationPath '%fontdir%' -Force;" ^
    "$fonts=(New-Object -ComObject Shell.Application).Namespace(0x14);" ^
    "Get-ChildItem '%fontdir%' -Filter '*.ttf' | ForEach-Object { $fonts.CopyHere($_.FullName, 0x10) }"
)

if exist "C:\Program Files (x86)\clink\clink.bat" (
  call "C:\Program Files (x86)\clink\clink.bat" autorun install
)

mkdir "%LOCALAPPDATA%\clink" 2>nul
echo load(io.popen('starship init cmd'):read("*a"))() > "%LOCALAPPDATA%\clink\starship.lua"

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
set "cleanpath=%cleanpath%;C:\Program Files (x86)\clink"
set "cleanpath=%cleanpath%;%LOCALAPPDATA%\Programs\starship\bin"
set "cleanpath=%cleanpath%;C:\devel"

setx PATH "%cleanpath%" >nul

endlocal
