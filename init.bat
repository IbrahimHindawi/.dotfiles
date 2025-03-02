@echo off
mkdir %USERPROFILE%\AppData\Local\nvim
copy nvim\init.lua %USERPROFILE%\AppData\Local\nvim\init.lua
xcopy nvim\lua %USERPROFILE%\AppData\Local\nvim\lua
xcopy nvim\LuaSnip %USERPROFILE%\AppData\Local\nvim\LuaSnip

mkdir %APPDATA%\alacritty
copy alacritty\alacritty.toml %APPDATA%\alacritty

mkdir \devel
copy scripts\vs.bat \devel

:: pre-reqs = oh-my-posh, clink
:: oh-my-posh font install meslo
:: clink set ohmyposh.theme "%USERPROFILE%/.dotfiles/themes/velvet.omp.json"
