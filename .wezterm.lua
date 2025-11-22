local wezterm = require 'wezterm'
local act = wezterm.action

local config = wezterm.config_builder()

-- ---------- Launcher: force new tabs + custom names ----------
local function launch_stack_env(window, pane)
  window:toast_notification("WezTerm", "🚀 Launching Stack Env…", nil, 2500)
  wezterm.log_info("Launching Stack Env...")

  local tabs = {
    { name = "todo",   cwd = [[C:\devel\njin]], cmd = [[\devel\vs.bat]] },
    { name = "engine", cwd = [[C:\devel\njin]], cmd = [[\devel\vs.bat]] },
    { name = "game",   cwd = [[C:\devel\njin]], cmd = [[\devel\vs.bat]] },
  }

  for _, t in ipairs(tabs) do
    window:perform_action(
      act.SpawnCommandInNewTab{
        domain = 'CurrentPaneDomain',
        cwd = t.cwd,
        args = { 'cmd.exe', '/k', t.cmd },
      },
      pane
    )

    -- rename the newly created tab
    local new_tab = window:mux_window():active_tab()
    if new_tab then
      new_tab:set_title(t.name)
    end
  end
end

wezterm.on('launch_stack_env', function(window, pane)
  launch_stack_env(window, pane)
end)

-- ---------- Prefs ----------
config.initial_cols = 220
config.initial_rows = 28
config.font_size = 10
config.font = wezterm.font 'IosevkaTerm Nerd Font Mono'
config.adjust_window_size_when_changing_font_size = false
config.default_prog = { 'cmd.exe' }

-- ---------- Keybinds ----------
config.keys = {
  { key = 'F2', mods = 'NONE', action = act.EmitEvent('launch_stack_env') },
  { key = 'F2', mods = 'CTRL', action = act.EmitEvent('launch_stack_env') },
}

return config
