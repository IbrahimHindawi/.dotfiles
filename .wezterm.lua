local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- ---------- Prefs ----------
config.initial_cols = 220
config.initial_rows = 28
config.font_size = 10
config.font = wezterm.font 'IosevkaTerm NF'
config.adjust_window_size_when_changing_font_size = false
config.default_prog = { os.getenv('LOCALAPPDATA') .. '\\Programs\\nu\\bin\\nu.exe' }

-- ---------- Keybinds ----------
config.keys = {
  { key = 'x', mods = 'CTRL|SHIFT', action = act.ActivateCopyMode },
  { key = 'X', mods = 'CTRL|SHIFT', action = act.ActivateCopyMode },
  { key = '[', mods = 'CTRL', action = act.ActivateCopyMode },
}

-- ---------- No WezTerm tabs/panes (zellij handles those) ----------
config.enable_tab_bar = false

local function disable(mods, key)
  table.insert(config.keys, { key = key, mods = mods, action = act.DisableDefaultAssignment })
end

-- spawn / close tab
for _, k in ipairs { 'T', 't', 'W', 'w' } do
  disable('CTRL', k)
  disable('SHIFT|CTRL', k)
end
disable('SUPER', 't')
disable('SUPER', 'w')

-- switch tab by number (Ctrl+Shift+1..9 arrive as both digits and their shifted symbols)
for _, k in ipairs { '1', '2', '3', '4', '5', '6', '7', '8', '9', '!', '@', '#', '$', '%', '^', '&', '*', '(' } do
  disable('CTRL', k)
  disable('SHIFT|CTRL', k)
end
for i = 1, 9 do
  disable('SUPER', tostring(i))
end

-- next / previous / move tab
disable('CTRL', 'Tab')
disable('SHIFT|CTRL', 'Tab')
disable('CTRL', 'PageUp')
disable('CTRL', 'PageDown')
disable('SHIFT|CTRL', 'PageUp')
disable('SHIFT|CTRL', 'PageDown')
for _, k in ipairs { '[', ']', '{', '}' } do
  disable('SUPER', k)
  disable('SHIFT|SUPER', k)
end

-- split panes
for _, k in ipairs { '"', "'", '%', '5' } do
  disable('ALT|CTRL', k)
  disable('SHIFT|ALT|CTRL', k)
end

-- zoom / focus / resize panes
for _, k in ipairs { 'Z', 'z' } do
  disable('CTRL', k)
  disable('SHIFT|CTRL', k)
end
for _, k in ipairs { 'LeftArrow', 'RightArrow', 'UpArrow', 'DownArrow' } do
  disable('SHIFT|CTRL', k)
  disable('SHIFT|ALT|CTRL', k)
end

return config
