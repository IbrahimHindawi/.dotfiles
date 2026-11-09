# dotfiles

Windows dev environment: **nushell** in **WezTerm (nightly)**, with **zellij** for tabs, panes and sessions, plus a small fleet of machines driven from one main machine over SSH.

> **Status:** in transition. `bootstrap.bat` + `setup.nu` replace the old `init.bat`, `init.sh` and `init_nvim.bat`, which are kept for reference only.

## Layout

| Path | What |
|---|---|
| `nu/` | nushell config: `env.nu`, `config.nu`, `omp-fixups.nu` |
| `themes/` | oh-my-posh themes; `rax_config.omp.json` is the active one |
| `zellij/` | zellij config (`config.kdl`) |
| `ssh/` | SSH client config (shared settings only; it `Include`s the machine list from the private repo) |
| `.wezterm.lua` | WezTerm config (its tab/pane keys are disabled, since zellij does that) |
| `nvim/` | neovim config |
| `alacritty/` | Alacritty config (not currently used) |
| `scripts/` | AutoHotkey scripts (escape remap, transparency, borders, hide title bar) |
| `Blender/`, `Zbrush/` | app configs |
| `cache/` | download cache, git-ignored |
| `bootstrap.bat` | new-machine entry point: elevates, installs git + nu, clones this repo, runs `setup.nu` |
| `setup.nu` | the actual setup (see below) |
| `init.bat`, `init.sh`, `init_nvim.bat` | **legacy**, don't use |

## Private repo

Machine-specific data lives in a separate **private** repo, [`.dotfiles-private`](https://github.com/IbrahimHindawi/.dotfiles-private), cloned to `~/.dotfiles-private`:
- `ssh/machines`: the fleet machine list
- `ssh/main.pub`: the main machine's public key, which workers trust

This repo holds only code and generic configs. Anything with hostnames, usernames, keys or tokens goes in the private one. Real secrets should also be encrypted there, since a private repo is hidden, not encrypted.

## How configs are wired: pointers, not copies

Each program's usual config location holds a one-line pointer to the real file in this repo, so edits here apply right away and never drift. No symlinks needed.

| Program | Pointer |
|---|---|
| nushell | `%APPDATA%\nushell\{env,config}.nu` each contain `source ~/.dotfiles/nu/<file>` |
| zellij | user env var `ZELLIJ_CONFIG_DIR=%USERPROFILE%\.dotfiles\zellij` |
| SSH | `~/.ssh/config` contains `Include ~/.dotfiles/ssh/config` |
| WezTerm | `~/.wezterm.lua` `dofile`s `~/.dotfiles/.wezterm.lua` and watches it for reloads |

Junctions or symlinks are only for programs with no pointer mechanism (e.g. the nvim folder). Setup runs as admin anyway, so those work too.

## Shell: nushell

- **Prompt:** oh-my-posh with `themes/rax_config.omp.json`. `env.nu` regenerates the hook into nu's vendor autoload dir on every start; a saved copy pins one oh-my-posh session id and falls back to the default theme when its cache resets.
- **`omp-fixups.nu`** is appended to that hook. It strips the leading newline and the window-title escape from the prompt, then prints them once per prompt instead.
- `env.nu` also patches a type bug in oh-my-posh 29.x's nu script (duration string assigned to an int), which nu 0.116 rejects.
- **Commands:** `ze` (zellij), `dbg <exe> [args]` (debug in Visual Studio; finds `devenv.exe` via vswhere).
- WezTerm must be **nightly**. The last stable release (20240203) adds a line per keystroke with nu's OSC 133 prompt markers. Setup installs the **portable** nightly zip to `%LOCALAPPDATA%\Programs\WezTerm` (no admin, no installer) with a Start menu shortcut.
- cmd + Clink remain installed as a fallback for now.

## zellij

Runs a build of upstream `main` with local patches, instead of the 0.45.1 release:
- **Windows session-rename hang:** fixed upstream on `main` (#5513), but not yet released.
- **Pipe pairing:** a local patch. The server paired each client's command and reply pipes by arrival order; one half-connected client desynced it for good. The patch pairs them by client process ID.

The fork is [`IbrahimHindawi/zellij`](https://github.com/IbrahimHindawi/zellij): `main` mirrors upstream, `rax` carries the patches. No CI: build locally, then publish `zellij.exe` plus its `zellij.exe.sha256` as a new release, and every machine picks it up on its next `setup.nu --tools`. Builds need Rust, VS (MSVC), protoc, and Strawberry Perl + NASM for the vendored OpenSSL:

```
git checkout rax
$env.RUSTFLAGS = "-C target-feature=+crt-static"
cargo xtask ci build-release      # -> targeteleasezellij.exe
```

## Fleet

One main machine (the only one that SSHes out) drives the others through nested zellij: one local session, one tab per machine, each running that machine's zellij.

Machines are defined in the private repo, in `~/.dotfiles-private/ssh/machines`. Each `Host` block is a machine, and its `Host` name is the nickname (e.g. `blade`).

Each machine has one shared, **mirrored** zellij session called `main`. Every screen attached to it follows the same tab and pane, so work driven from the main machine shows live on that machine's own display:

```
zr blade    # from the main machine (nu command, in config.nu)
zm          # on the machine itself, e.g. the laptop's screen
```

Then press `Ctrl+G` to lock the outer zellij and drive the remote one; press `Ctrl+G` again to come back. The session keeps running on the machine when you disconnect.

Use `zellij options --session-name main ...`, not `zellij attach main options ...`: the latter silently creates a randomly named session.

**SSH login shell stays cmd.** nu runs external commands inside a Windows job object that kills them all when nu exits. With nu as the SSH shell, a zellij server started over SSH dies on disconnect. Panes inside zellij still run nu.

### Windows 10 workers

Windows 10's console layer mangles modern escape sequences in both directions, so:
- **Kitty keyboard protocol must be off** for the remote zellij, or key combos are dropped. The connect command above handles that.
- **Automatic nested-session detection doesn't work**, so use manual lock (`Ctrl+G`). Its announcement shows up briefly as `26661nCgo...` text when you connect; that's harmless.

### Worker setup (what `setup.nu --remote` does)

- **OpenSSH server:** `Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0`, then start it and set it to start automatically.
- **Firewall:** port 22 allowed only from the home LAN subnet.
- **Main machine's public key** goes in **both** `C:\ProgramData\ssh\administrators_authorized_keys` and `~\.ssh\authorized_keys`. Admin accounts only read the first, and it needs restricted ACLs.
- **`AddressFamily inet`** in the machine's entry in `ssh/machines`. Otherwise SSH tries IPv6 first, the IPv4-only firewall drops it, and SSH looks hung.

Headless machines need an **HDMI/DisplayPort dummy plug** (4K@60, matched to a free GPU port) and auto-login, so games and screen recording have a real display and desktop.

## Setup

### New machine

Download [`bootstrap.bat`](https://raw.githubusercontent.com/IbrahimHindawi/.dotfiles/main/bootstrap.bat) and run it. It asks for admin rights, installs git and nushell with winget, clones this repo to `~/.dotfiles` (or fast-forwards an existing clone), then runs `setup.nu`. Arguments are passed through:

```
bootstrap.bat              # --tools --dev --configs
bootstrap.bat --remote     # fleet workers only: SSH server
```

For a fleet worker, clone the private repo to `~/.dotfiles-private` first (it needs GitHub access), so `--remote` can install the main machine's key and `~/.ssh/config` finds the machine list. Without it those steps warn and skip.

### Re-running

Both scripts are idempotent: every step checks first, so re-running is safe. Once the repo is cloned, run `setup.nu` directly from an elevated terminal:

```
nu ~/.dotfiles/setup.nu [--tools] [--dev] [--configs] [--remote]
```

- **`--tools`:**
  - via winget: git, nu, oh-my-posh, Neovim, ripgrep
  - WezTerm nightly, portable zip; re-runs update it when the nightly changes (close WezTerm first)
  - zellij: our patched build, from the latest release on the fork ([`IbrahimHindawi/zellij`](https://github.com/IbrahimHindawi/zellij/releases), branch `rax`); re-runs update it when the release changes
  - Claude Code via its native installer, which updates itself
  - IosevkaTerm Nerd Font
- **`--dev`:**
  - via winget: LLVM, CMake, ninja, Rust, Node LTS, Python 3.13, rclone
  - VS 18 Build Tools (C++ workload)
  - npm globals: Codex, tree-sitter-cli
- **`--configs`:**
  - creates the pointers above, plus an nvim junction
  - removes a stale Clink AutoRun
  - **appends** to PATH, never overwrites it
- **`--remote`:**
  - OpenSSH server
  - firewall: home LAN, Private network profile only
  - main machine's key, taken from the private repo
  - key-only logins
  - keeps cmd as the SSH login shell (see Fleet)

Still to build:
- a fleet layout (`ze fleet`)
- `on-all` and `zellij-deploy` commands
- Tailscale, for reaching machines off the home network

Notes:
- clang-cl + CMake + Ninja build fine without the MSVC dev environment (no `vcvars`), so no shell wrapper is needed.
- Not yet captured anywhere: the Clink hooks in `%LOCALAPPDATA%\clink\`. They're cmd-only and will be dropped along with Clink.
