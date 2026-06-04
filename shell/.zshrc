# Oh My Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""
plugins=(git zsh-syntax-highlighting zsh-autosuggestions gpg-agent)

source "$ZSH/oh-my-zsh.sh"

# Modular zsh config
ZSH_DOTFILES_DIR="$HOME/.dotfiles/shell/zsh"
for file in \
  "$ZSH_DOTFILES_DIR/terminal.zsh" \
  "$ZSH_DOTFILES_DIR/exports.zsh" \
  "$ZSH_DOTFILES_DIR/prompt.zsh" \
  "$ZSH_DOTFILES_DIR/completions.zsh" \
  "$ZSH_DOTFILES_DIR/aliases.zsh" \
  "$ZSH_DOTFILES_DIR/local.zsh"
do
  [ -f "$file" ] && source "$file"
done
export PATH="$HOME/.local/bin:$PATH"

. "$HOME/.atuin/bin/env"

eval "$(atuin init zsh)"
