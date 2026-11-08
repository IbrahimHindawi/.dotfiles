# Main nu config, loaded on every start after env.nu.

$env.config.show_banner = false

# zellij
alias ze = zellij

# Shared "main" zellij session on a machine, mirrored: every attached screen follows
# the same tab and pane, so work driven from here shows live on that machine's display.
#   zm          on this machine (e.g. on the laptop's own screen)
#   zr blade    from the main machine, over SSH
# `zellij options --session-name` (not `attach NAME options ...`, which drops the name).
def zm [] {
    zellij options --session-name main --attach-to-session true --mirror-session true
}
def zr [host: string] {
    # kitty keyboard protocol off: Windows 10's console layer drops kitty-encoded keys
    ^ssh -t $host zellij options --session-name main --attach-to-session true --mirror-session true --support-kitty-keyboard-protocol false
}

# Debug an executable in Visual Studio: `dbg build\cmake\game.exe [args...]`
# Finds devenv.exe through vswhere, so it follows whatever VS version is installed.
def dbg [exe: path, ...args: string] {
    let vswhere = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'
    let devenv = (^$vswhere -latest -property productPath | str trim)
    ^$devenv /debugexe $exe ...$args
}
