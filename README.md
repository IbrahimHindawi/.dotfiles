# dotfiles

Windows dev environment: **nushell** in **WezTerm (nightly)**, with **zellij** for tabs, panes and sessions, plus a small fleet of machines driven from one main machine over SSH.

> **Status:** in transition. The old `init.bat` is being replaced by `bootstrap.bat` + `setup.nu`, which aren't written yet. Until then, configs on the main machine are wired up by hand as described below.

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
| `init.bat`, `init.sh`, `init_nvim.bat` | **legacy**, to be replaced (see below) |

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
- WezTerm must be **nightly**. The last stable release (20240203) adds a line per keystroke with nu's OSC 133 prompt markers.
- cmd + Clink remain installed as a fallback for now.

## zellij

Runs a build of upstream `main` with local patches, instead of the 0.45.1 release:
- **Windows session-rename hang:** fixed upstream on `main` (#5513), but not yet released.
- **Pipe pairing:** a local patch. The server paired each client's command and reply pipes by arrival order; one half-connected client desynced it for good. The patch pairs them by client process ID.

Plan: maintain a fork (`main` mirrors upstream, `rax` carries the patches), build locally on a dev machine, and copy the binary to the other machines over SSH. Builds need Rust, VS (MSVC), protoc, and Strawberry Perl + NASM for the vendored OpenSSL.

## Fleet

One main machine (the only one that SSHes out) drives the others through nested zellij: one local session, one tab per machine, each running that machine's zellij.

Machines are defined in the private repo, in `~/.dotfiles-private/ssh/machines`. Each `Host` block is a machine, and its `Host` name is the nickname (e.g. `blade`).

Connect to a machine:

```
ssh -t blade zellij attach -c main options --support-kitty-keyboard-protocol false
```

Then press `Ctrl+G` to lock the outer zellij and drive the remote one; press `Ctrl+G` again to come back.

### Windows 10 workers

Windows 10's console layer mangles modern escape sequences in both directions, so:
- **Kitty keyboard protocol must be off** for the remote zellij, or key combos are dropped. The connect command above handles that.
- **Automatic nested-session detection doesn't work**, so use manual lock (`Ctrl+G`). Its announcement shows up briefly as `26661nCgo...` text when you connect; that's harmless.

### Worker setup (manual for now, later `setup.nu --remote`)

- **OpenSSH server:** `Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0`, then start it and set it to start automatically.
- **Firewall:** port 22 allowed only from the home LAN subnet.
- **Main machine's public key** goes in **both** `C:\ProgramData\ssh\administrators_authorized_keys` and `~\.ssh\authorized_keys`. Admin accounts only read the first, and it needs restricted ACLs.
- **`AddressFamily inet`** in the machine's entry in `ssh/machines`. Otherwise SSH tries IPv6 first, the IPv4-only firewall drops it, and SSH looks hung.

Headless machines need an **HDMI/DisplayPort dummy plug** (4K@60, matched to a free GPU port) and auto-login, so games and screen recording have a real display and desktop.

## Planned setup (replaces `init.bat`)

- **`bootstrap.bat`:** the double-click entry point. It elevates once, installs git and nu, clones this repo and runs `setup.nu`.
- **`setup.nu --tools`:** installs via winget:
  - WezTerm nightly, IosevkaTerm Nerd Font, nu, oh-my-posh, git
  - LLVM, CMake, ninja, VS Build Tools (C++), Rust
  - Node LTS, Python 3.13, rclone, ripgrep
  - npm globals: Codex, tree-sitter-cli
  - zellij from the fork
- **`setup.nu --configs`:** creates the pointers above, and **appends** to PATH (never overwrites it).
- **`setup.nu --remote`:** OpenSSH server, firewall, main machine's key, nu as the SSH shell.
- **Later:**
  - a fleet layout (`ze fleet`)
  - `on-all` and `zellij-deploy` commands
  - Tailscale, for reaching machines off the home network

Notes:
- clang-cl + CMake + Ninja build fine without the MSVC dev environment (no `vcvars`), so no shell wrapper is needed.
- Not yet captured anywhere: the Clink hooks in `%LOCALAPPDATA%\clink\`. They're cmd-only and will be dropped along with Clink.
