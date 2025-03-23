@echo off
set nvimdir=%USERPROFILE%\AppData\Local\nvim
rmdir /S /Q %nvimdir%
mkdir %nvimdir%
xcopy /E nvim %nvimdir%

mkdir %APPDATA%\alacritty
copy alacritty\alacritty.toml %APPDATA%\alacritty

mkdir \devel
copy scripts\vs.bat \devel

:: pre-reqs = oh-my-posh, clink
:: oh-my-posh font install meslo
:: clink set ohmyposh.theme "%USERPROFILE%/.dotfiles/themes/velvet.omp.json"
