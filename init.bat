@echo off
copy nvim\init.lua %USERPROFILE%\AppData\Local\nvim\init.lua
mkdir %APPDATA%\alacritty
copy alacritty\alacritty.toml %APPDATA%\alacritty
mkdir \devel
copy scripts\vs.bat \devel
