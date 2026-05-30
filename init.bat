@echo off

set "PATH=%SystemRoot%\system32;%SystemRoot%;%SystemRoot%\System32\Wbem;%SystemRoot%\System32\WindowsPowerShell\v1.0;%SystemRoot%\System32\OpenSSH;%PATH%"

set "log=%USERPROFILE%\init-log.txt"
echo START > "%log%"

set "winget=%LOCALAPPDATA%\Microsoft\WindowsApps\winget.exe"

if not exist "%winget%" (
  echo FAILED: winget missing >> "%log%"
  pause
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
mkdir "%USERPROFILE%\.dotfiles\cache" 2>nul

"%winget%" install --id LLVM.LLVM -e
"%winget%" install --id Kitware.CMake -e
"%winget%" install --id OpenJS.NodeJS.LTS -e
"%winget%" install --id Python.Python.3.13 -e
"%winget%" install --id Python.Launcher -e
"%winget%" install --id Rclone.Rclone -e
"%winget%" install --id chrisant996.Clink -e
"%winget%" install --id JanDeDobbeleer.OhMyPosh -e
"%winget%" install --id BurntSushi.ripgrep.MSVC -e

set "wingetlinks=%LOCALAPPDATA%\Microsoft\WinGet\Links"
mkdir "%wingetlinks%" 2>nul

if not exist "%wingetlinks%\rg.exe" (
  for /f "delims=" %%F in ('dir /S /B "%LOCALAPPDATA%\Microsoft\WinGet\Packages\BurntSushi.ripgrep.MSVC_*\rg.exe" 2^>nul') do (
    copy /Y "%%F" "%wingetlinks%\rg.exe" >nul
    goto :rg_link_done
  )
)
:rg_link_done

"%winget%" install --id Microsoft.VisualStudio.2022.BuildTools -e --override "--wait --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended"

set "ninjazip=%USERPROFILE%\.dotfiles\cache\ninja-win.zip"
set "ninjadir=%LOCALAPPDATA%\Programs\ninja"

rmdir /S /Q "%ninjadir%" 2>nul
mkdir "%ninjadir%" 2>nul

if not exist "%ninjazip%" (
  curl.exe -L --progress-bar -o "%ninjazip%" "https://github.com/ninja-build/ninja/releases/latest/download/ninja-win.zip"
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "Expand-Archive '%ninjazip%' -DestinationPath '%ninjadir%' -Force"

if not exist "%ninjadir%\ninja.exe" (
  echo FAILED: ninja missing after extract >> "%log%"
  pause
  exit /b 1
)

set "PATH=%ninjadir%;%PATH%"

where npm >nul 2>nul
if not errorlevel 1 (
  call npm install -g @openai/codex
  call npm install -g tree-sitter-cli
)

where oh-my-posh >nul 2>nul
if not errorlevel 1 (
  if not exist "%LOCALAPPDATA%\Microsoft\Windows\Fonts\IosevkaTermNerdFont-Regular.ttf" (
    call oh-my-posh font install IosevkaTerm
  ) else (
    echo SKIP: IosevkaTerm font already installed >> "%log%"
  )
)

if exist "C:\Program Files (x86)\clink\clink.bat" (
  call "C:\Program Files (x86)\clink\clink.bat" autorun install
)

mkdir "%LOCALAPPDATA%\clink" 2>nul

where oh-my-posh >nul 2>nul
if not errorlevel 1 (
  call oh-my-posh init cmd --config "%USERPROFILE%\.dotfiles\themes\velvet.omp.json" > "%LOCALAPPDATA%\clink\oh-my-posh.lua"
)

where clink >nul 2>nul
if not errorlevel 1 (
  call clink set autosuggest.enable true
  call clink set autosuggest.inline true
  call clink set autosuggest.strategy history
  call clink set color.suggestion brightblack
)

set "cleanpath=%SystemRoot%\system32"
set "cleanpath=%cleanpath%;%SystemRoot%"
set "cleanpath=%cleanpath%;%SystemRoot%\System32\Wbem"
set "cleanpath=%cleanpath%;%SystemRoot%\System32\WindowsPowerShell\v1.0"
set "cleanpath=%cleanpath%;%SystemRoot%\System32\OpenSSH"
set "cleanpath=%cleanpath%;%USERPROFILE%\AppData\Local\Programs\Python\Python313"
set "cleanpath=%cleanpath%;%USERPROFILE%\AppData\Local\Programs\Python\Python313\Scripts"
set "cleanpath=%cleanpath%;%LOCALAPPDATA%\Microsoft\WindowsApps"
set "cleanpath=%cleanpath%;%LOCALAPPDATA%\Microsoft\WinGet\Links"
set "cleanpath=%cleanpath%;%APPDATA%\npm"
set "cleanpath=%cleanpath%;%LOCALAPPDATA%\Programs\ninja"
set "cleanpath=%cleanpath%;C:\Program Files\Git\cmd"
set "cleanpath=%cleanpath%;C:\Program Files\Neovim\bin"
set "cleanpath=%cleanpath%;C:\Program Files\WezTerm"
set "cleanpath=%cleanpath%;C:\Program Files\LLVM\bin"
set "cleanpath=%cleanpath%;C:\Program Files\CMake\bin"
set "cleanpath=%cleanpath%;C:\Program Files\nodejs"
set "cleanpath=%cleanpath%;C:\Program Files (x86)\clink"
set "cleanpath=%cleanpath%;%LOCALAPPDATA%\Programs\oh-my-posh\bin"
set "cleanpath=%cleanpath%;C:\devel"

set "CLEANPATH=%cleanpath%"
powershell -NoProfile -ExecutionPolicy Bypass -Command "[Environment]::SetEnvironmentVariable('Path', $env:CLEANPATH, 'User')"

set "PATH=%cleanpath%"

reg query HKCU\Environment /v Path >> "%log%"
echo DONE >> "%log%"
