local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- ---------- Prefs ----------
config.initial_cols = 220
config.initial_rows = 28
config.font_size = 10
config.font = wezterm.font 'IosevkaTerm NF'
config.adjust_window_size_when_changing_font_size = false
config.default_prog = { 'cmd.exe' }

-- ---------- Keybinds ----------
config.keys = {
  { key = 'F2', mods = 'NONE', action = act.EmitEvent('launch_stack_env') },
  { key = 'F2', mods = 'CTRL', action = act.EmitEvent('launch_stack_env') },
  { key = 'x', mods = 'CTRL|SHIFT', action = act.ActivateCopyMode },
  { key = 'X', mods = 'CTRL|SHIFT', action = act.ActivateCopyMode },
  { key = '[', mods = 'CTRL', action = act.ActivateCopyMode },
}

return config
