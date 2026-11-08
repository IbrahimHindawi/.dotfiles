# Runs first on every nu start, before config.nu.

# oh-my-posh prompt: regenerate the hook on every start (same as the clink setup).
# A saved copy pins one POSH_SESSION_ID and silently falls back to the default
# theme whenever oh-my-posh's per-session cache resets.
if (which oh-my-posh | is-not-empty) {
    let hook = ($nu.data-dir | path join vendor autoload oh-my-posh.nu)
    mkdir ($hook | path dirname)
    let theme = ('~/.dotfiles/themes/rax_config.omp.json' | path expand)
    let fixups = ('~/.dotfiles/nu/omp-fixups.nu' | path expand | open --raw)
    let script = (
        ^oh-my-posh init nu --config $theme --print
        # oh-my-posh 29.x assigns the duration string to an int `mut`; nu 0.116 rejects that
        | str replace '$execution_time = $env.CMD_DURATION_MS' '$execution_time = ($env.CMD_DURATION_MS | into int)'
    )
    [$script $fixups] | str join "\n" | save --force $hook
}
