# Main nu config, loaded on every start after env.nu.

$env.config.show_banner = false

# zellij
alias ze = zellij

# Debug an executable in Visual Studio: `dbg build\cmake\game.exe [args...]`
# Finds devenv.exe through vswhere, so it follows whatever VS version is installed.
def dbg [exe: path, ...args: string] {
    let vswhere = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'
    let devenv = (^$vswhere -latest -property productPath | str trim)
    ^$devenv /debugexe $exe ...$args
}
