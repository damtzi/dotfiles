# Path to your oh-my-zsh installation.
export ZSH="/Users/damitzi/.oh-my-zsh"

# Disable oh-my-zsh theme (using Starship instead)
ZSH_THEME=""


# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
DISABLE_AUTO_TITLE="true"

# Function to set the terminal title to the current directory
function set_window_title {
  print -Pn "\e]2;%~\a"
}

# Call this function before showing the prompt
precmd() {
  set_window_title
}

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Oh-my-zsh plugins
plugins=(git zsh-syntax-highlighting zsh-autosuggestions gpg-agent)

source $ZSH/oh-my-zsh.sh

# ===== PATH Configuration =====

export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# pnpm
export PNPM_HOME="/Users/damitzi/Library/pnpm"
export PATH="$PNPM_HOME:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ===== Prompt Configuration =====
# Use Starship prompt for Warp
if [[ $TERM_PROGRAM == "WarpTerminal" ]]; then
    eval "$(starship init zsh)"
fi

# ===== Shell Completions =====
# bun
[ -s "/Users/damitzi/.bun/_bun" ] && source "/Users/damitzi/.bun/_bun"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# kiro
[[ "$TERM_PROGRAM" == "kiro" ]] && . "$(kiro --locate-shell-integration-path zsh)"

# ruby
export PATH="$HOME/.rbenv/bin:$PATH"
eval "$(rbenv init - zsh)"

# ===== Aliases =====
alias lzd='lazydocker'
alias lzg='lazygit'
alias oc='opencode'

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/damitzi/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/damitzi/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/damitzi/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/damitzi/google-cloud-sdk/completion.zsh.inc'; fi
export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"
export PATH="$JAVA_HOME/bin:$PATH"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin"
