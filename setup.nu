# setup.nu: idempotent machine setup for this dotfiles repo (Windows).
# Run elevated (bootstrap.bat does that). Safe to re-run: every step checks first.
#
#   nu setup.nu                    # --tools --dev --configs
#   nu setup.nu --tools            # shell, terminal, editor, agents
#   nu setup.nu --dev              # compilers, build tools, runtimes
#   nu setup.nu --configs          # config pointers + PATH
#   nu setup.nu --remote           # SSH server for fleet workers (not part of the default run)
#
# Keep this compatible with the oldest nu in the fleet (0.114): no $nu.home-dir etc.

const TOOLS = [
    Git.Git
    Nushell.Nushell
    JanDeDobbeleer.OhMyPosh
    wez.wezterm.nightly
    Neovim.Neovim
    BurntSushi.ripgrep.MSVC
]

const DEV = [
    LLVM.LLVM
    Kitware.CMake
    Ninja-build.Ninja
    Rustlang.Rustup
    OpenJS.NodeJS.LTS
    Python.Python.3.13
    Rclone.Rclone
]

# VS 18 C++ build tools (MSVC linker + Windows SDK; clang-cl needs no vcvars on top)
const VS_BUILDTOOLS = 'Microsoft.VisualStudio.BuildTools'
const VS_OVERRIDE = '--wait --quiet --norestart --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended'

const NPM_GLOBALS = ['@openai/codex' 'tree-sitter-cli']

def main [
    --tools     # shell, terminal, editor, agents
    --dev       # compilers, build tools, runtimes
    --configs   # config pointers + PATH
    --remote    # SSH server for fleet workers
] {
    let all = not ($tools or $dev or $configs or $remote)
    if not (is-admin) {
        print $"(ansi yellow)warning:(ansi reset) not elevated; machine-wide installs and --remote will fail"
    }
    if $tools or $all { install-tools }
    if $dev or $all { install-dev }
    if $configs or $all { link-configs }
    if $remote { setup-remote }
    print $"(ansi green)done(ansi reset)"
}

# ---------- helpers ----------

def step [msg: string] { print $"(ansi cyan)==>(ansi reset) ($msg)" }
def ok [msg: string] { print $"    ($msg)" }
def warn [msg: string] { print $"    (ansi yellow)($msg)(ansi reset)" }

def home [rel: string] { $"~/($rel)" | path expand }

# Re-read PATH from the registry so freshly installed tools are callable in this run.
def --env refresh-path [] {
    let machine = (^powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('Path','Machine')" | str trim)
    let user = (^powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('Path','User')" | str trim)
    $env.Path = ($"($machine);($user)" | split row ';' | where {|p| $p != '' } | uniq)
}

def winget-installed [id: string] {
    let r = (do { ^winget list --id $id -e --accept-source-agreements --disable-interactivity } | complete)
    ($r.exit_code == 0) and ($r.stdout | str contains $id)
}

def winget-install [id: string, override?: string] {
    if (winget-installed $id) { ok $"($id): already installed"; return }
    ok $"($id): installing"
    let args = [install --id $id -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity]
    let r = if $override == null {
        do { ^winget ...$args } | complete
    } else {
        do { ^winget ...$args --override $override } | complete
    }
    if $r.exit_code != 0 {
        warn $"($id): winget exit code ($r.exit_code)"
        print ($r.stdout | lines | where {|l| ($l | str trim) != '' } | last 4 | str join "\n")
    }
}

def set-user-env [name: string, value: string] {
    ^powershell -NoProfile -Command $"[Environment]::SetEnvironmentVariable\('($name)', '($value)', 'User'\)"
}

# Write a small pointer/config file; back up an existing different file first.
def write-file [path: string, content: string] {
    if ($path | path exists) {
        if (open --raw $path) == $content { ok $"($path): up to date"; return }
        let backup = $"($path).bak-(date now | format date '%Y%m%d-%H%M%S')"
        cp $path $backup
        ok $"($path): backed up to ($backup)"
    }
    mkdir ($path | path dirname)
    $content | save --force $path
    ok $"($path): written"
}

# ---------- tools ----------

def install-tools [] {
    step "tools"
    # nightly replaces stable (the stable build mangles nu's prompt markers); both can't coexist
    if (winget-installed 'wez.wezterm') {
        if (ps | where name =~ 'wezterm' | is-not-empty) {
            warn "WezTerm stable is installed but running; close it and re-run to switch to nightly"
        } else {
            ok "wez.wezterm (stable): uninstalling in favor of nightly"
            do { ^winget uninstall --id wez.wezterm -e --silent --disable-interactivity } | complete | ignore
        }
    }
    for id in $TOOLS { winget-install $id }
    refresh-path

    # Claude Code: native installer (self-updating), not the winget package
    if (home '.local/bin/claude.exe' | path exists) {
        ok "claude: already installed"
    } else {
        ok "claude: installing"
        ^powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://claude.ai/install.ps1 | iex"
    }

    # Nerd Font used by WezTerm
    let font_dirs = [($env.LOCALAPPDATA | path join Microsoft Windows Fonts) 'C:\Windows\Fonts']
    let has_font = ($font_dirs | where {|d| $d | path exists } | each {|d| ls $d | where name =~ 'IosevkaTerm' } | flatten | is-not-empty)
    if $has_font {
        ok "IosevkaTerm Nerd Font: already installed"
    } else if (which oh-my-posh | is-not-empty) {
        ok "IosevkaTerm Nerd Font: installing"
        ^oh-my-posh font install IosevkaTerm
    } else {
        warn "IosevkaTerm Nerd Font: oh-my-posh not on PATH yet; re-run to install the font"
    }

    # zellij isn't installed here: it's our patched build, copied from the main machine
    if (which zellij | is-empty) { warn "zellij: not found; deploy the build from the main machine" }
}

def install-dev [] {
    step "dev"
    for id in $DEV { winget-install $id }
    winget-install $VS_BUILDTOOLS $VS_OVERRIDE
    refresh-path
    if (which npm | is-empty) { warn "npm not on PATH yet; re-run for npm globals"; return }
    let have = (do { ^npm ls -g --depth=0 --json } | complete | get stdout | from json | get -o dependencies | default {} | columns)
    for pkg in $NPM_GLOBALS {
        if $pkg in $have { ok $"($pkg): already installed" } else {
            ok $"($pkg): installing"
            ^npm install -g $pkg
        }
    }
}

# ---------- configs ----------

def link-configs [] {
    step "configs"
    let dot = (home '.dotfiles')

    # nushell: one-line pointers into the repo
    let nudir = ($env.APPDATA | path join nushell)
    for f in [env.nu config.nu] {
        write-file ($nudir | path join $f) $"source ~/.dotfiles/nu/($f)"
    }

    # zellij: config dir via env var
    let zdir = ($dot | path join zellij)
    if ($env.ZELLIJ_CONFIG_DIR? == $zdir) { ok "ZELLIJ_CONFIG_DIR: up to date" } else {
        set-user-env ZELLIJ_CONFIG_DIR $zdir
        ok $"ZELLIJ_CONFIG_DIR: set to ($zdir)"
    }

    # WezTerm: pointer that loads the repo copy and watches it
    write-file (home '.wezterm.lua') ([
        "-- Real config lives in dotfiles; this file only points at it."
        "local wezterm = require 'wezterm'"
        "local path = wezterm.home_dir .. '/.dotfiles/.wezterm.lua'"
        "wezterm.add_to_config_reload_watch_list(path)"
        "return dofile(path)"
        ""
    ] | str join "\n")

    # SSH client: shared config (Includes the private machine list, if this machine has it)
    write-file (home '.ssh/config') "# Real config lives in dotfiles; this file only points at it.\nInclude ~/.dotfiles/ssh/config\n"

    # nvim: no pointer mechanism, so a directory junction (no admin needed)
    let nvim = ($env.LOCALAPPDATA | path join nvim)
    let target = ($dot | path join nvim)
    let is_junction = ($nvim | path exists) and ((do { ^fsutil reparsepoint query $nvim } | complete).exit_code == 0)
    if $is_junction { ok $"($nvim): junction in place" } else {
        if ($nvim | path exists) {
            let backup = $"($nvim).bak-(date now | format date '%Y%m%d-%H%M%S')"
            mv $nvim $backup
            ok $"($nvim): old copy moved to ($backup)"
        }
        ^cmd /c mklink /J $nvim $target | ignore
        ok $"($nvim): junction -> ($target)"
    }

    # Drop a stale Clink AutoRun (cmd complains on every start when its target is gone)
    let autorun = (do { ^reg query 'HKCU\Software\Microsoft\Command Processor' /v AutoRun } | complete)
    if ($autorun.exit_code == 0) and ($autorun.stdout =~ 'clink') {
        let clink_bat = ($autorun.stdout | parse --regex '"(?<p>[^"]*clink\.bat)"' | get -o 0.p)
        if ($clink_bat == null) or not ($clink_bat | path exists) {
            do { ^reg delete 'HKCU\Software\Microsoft\Command Processor' /v AutoRun /f } | complete | ignore
            ok "cmd AutoRun: removed stale Clink entry"
        }
    }

    # PATH: append missing entries only, never rewrite
    let wanted = [
        (home '.local/bin')
        (home '.cargo/bin')
        ($env.LOCALAPPDATA | path join Programs zellij)
    ]
    let current = (^powershell -NoProfile -Command "[Environment]::GetEnvironmentVariable('Path','User')" | str trim | split row ';' | where {|p| $p != '' })
    let missing = ($wanted | where {|p| $p not-in $current })
    if ($missing | is-empty) { ok "PATH: up to date" } else {
        let new = ($current | append $missing | str join ';')
        set-user-env Path $new
        ok $"PATH: appended ($missing | str join ', ')"
    }
}

# ---------- remote (fleet worker) ----------

def setup-remote [] {
    step "remote"
    let cap = (^powershell -NoProfile -Command "(Get-WindowsCapability -Online -Name 'OpenSSH.Server*').State" | str trim)
    if $cap == 'Installed' { ok "OpenSSH server: installed" } else {
        ok "OpenSSH server: installing"
        ^powershell -NoProfile -Command "Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0 | Out-Null"
    }
    ^powershell -NoProfile -Command "Set-Service sshd -StartupType Automatic; Start-Service sshd"

    # Firewall: only from the machine's own subnet, and only on networks marked Private
    # (Windows marks unknown networks Public, so cafe Wi-Fi never matches this rule)
    ^powershell -NoProfile -Command ([
        "Get-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -ErrorAction SilentlyContinue | Remove-NetFirewallRule"
        "New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Direction Inbound -Protocol TCP -LocalPort 22 -Action Allow -RemoteAddress LocalSubnet -Profile Private | Out-Null"
    ] | str join '; ')
    ok "firewall: port 22 from the local subnet, Private profile only"

    # Trust the main machine's key (from the private repo)
    let key_file = (home '.dotfiles-private/ssh/main.pub')
    if ($key_file | path exists) {
        let key = (open --raw $key_file | str trim)
        for f in ['C:\ProgramData\ssh\administrators_authorized_keys' (home '.ssh/authorized_keys')] {
            let have = if ($f | path exists) { open --raw $f } else { '' }
            if ($have | str contains $key) { ok $"($f): key present" } else {
                mkdir ($f | path dirname)
                $"($key)\n" | save --append $f
                ok $"($f): key added"
            }
        }
        ^icacls 'C:\ProgramData\ssh\administrators_authorized_keys' /inheritance:r /grant '*S-1-5-32-544:F' /grant '*S-1-5-18:F' | ignore
    } else {
        warn $"($key_file) not found (private repo not cloned); skipping key install"
    }

    # Key-only logins; validate before restarting so a bad edit can't lock us out
    let cfg = 'C:\ProgramData\ssh\sshd_config'
    let text = (open --raw $cfg)
    mut lines = ($text | lines)
    for opt in [PasswordAuthentication KbdInteractiveAuthentication] {
        if ($lines | any {|l| $l =~ $'^#?\s*($opt)\b' }) {
            $lines = ($lines | each {|l| if $l =~ $'^#?\s*($opt)\b' { $"($opt) no" } else { $l } })
        } else {
            $lines = ([$"($opt) no"] | append $lines)
        }
    }
    let new_text = ($lines | str join "\n")
    if $new_text == ($text | lines | str join "\n") { ok "sshd: key-only already" } else {
        cp $cfg $"($cfg).bak-(date now | format date '%Y%m%d-%H%M%S')"
        $new_text | save --force $cfg
        let sshd = 'C:\Windows\System32\OpenSSH\sshd.exe'
        let check = (do { ^$sshd -t } | complete)
        if $check.exit_code != 0 {
            $text | save --force $cfg
            warn $"sshd config invalid, restored: ($check.stderr)"
        } else {
            ok "sshd: key-only (restart pending)"
        }
    }

    # nu as the SSH login shell
    let nu_exe = ($env.LOCALAPPDATA | path join Programs nu bin nu.exe)
    ^reg add 'HKLM\SOFTWARE\OpenSSH' /v DefaultShell /t REG_SZ /d $nu_exe /f | ignore
    ^reg add 'HKLM\SOFTWARE\OpenSSH' /v DefaultShellCommandOption /t REG_SZ /d '-c' /f | ignore
    ok $"SSH login shell: ($nu_exe)"
    warn "restart sshd to apply (Restart-Service sshd -Force); open sessions survive it"
}
