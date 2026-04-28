# Terminal-specific behavior
DISABLE_AUTO_TITLE="true"

function set_window_title() {
  [[ "$TERM_PROGRAM" == "ghostty" ]] && return
  print -Pn "\e]2;%~\a"
}

autoload -Uz add-zsh-hook
add-zsh-hook precmd set_window_title
