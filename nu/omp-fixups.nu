
# --- appended to the oh-my-posh hook by ~/.dotfiles/nu/env.nu ---
# nu repaints the prompt on every keystroke and miscounts its height/width when the
# prompt starts with a newline or carries the window-title escape, so each keypress
# pushed the line down. Strip both from the prompt and emit them once, before it.
let _omp_primary = $env.PROMPT_COMMAND
$env.PROMPT_COMMAND = {||
    do $_omp_primary
    | str replace --all --regex "\e\\]0;[^\u{7}]*\u{7}" ""
    | str replace --regex "^[\r\n]+" ""
}
$env.config.hooks.pre_prompt = (
    $env.config.hooks.pre_prompt? | default [] | append {||
        # blank line between commands (the theme's "newline": true) + title " <folder> "
        print ""
        print --no-newline $"\e]0; (pwd | path basename) \u{7}"
    }
)
