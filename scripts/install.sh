#!/bin/bash

# Dotfiles installation script
# Creates symlinks from home directory to dotfiles repo

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utility functions
source "$SCRIPT_DIR/lib/utils.sh"

log_header "Installing Dotfiles"

# Check OS
if [[ "$(get_os)" != "macos" ]]; then
    log_error "This script is only supported on macOS"
    exit 1
fi

log_info "Dotfiles directory: $DOTFILES_DIR"
echo ""

# Install shell configs
log_header "Shell Configuration"
link_file "$DOTFILES_DIR/shell/.zshrc" "$HOME/.zshrc"
link_file "$DOTFILES_DIR/shell/.zshenv" "$HOME/.zshenv"
link_file "$DOTFILES_DIR/shell/.bashrc" "$HOME/.bashrc"
link_file "$DOTFILES_DIR/shell/.profile" "$HOME/.profile"
link_file "$DOTFILES_DIR/shell/.zprofile" "$HOME/.zprofile"

# Install git config
log_header "Git Configuration"
link_file "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"

# Check if .gitconfig.local exists
if [[ ! -f "$HOME/.gitconfig.local" ]]; then
    log_warning "Missing ~/.gitconfig.local"
    log_info "Copy git/.gitconfig.local.example to ~/.gitconfig.local and fill in your details"
fi

# Install XDG configs
log_header "XDG Configuration"

# Ensure ~/.config exists
mkdir -p "$HOME/.config"

# Starship
link_file "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml"

# Ghostty
link_file "$DOTFILES_DIR/config/ghostty" "$HOME/.config/ghostty"

# Zed
link_file "$DOTFILES_DIR/config/zed" "$HOME/.config/zed"

# OpenCode
link_file "$DOTFILES_DIR/config/opencode" "$HOME/.config/opencode"

# GitHub CLI
link_file "$DOTFILES_DIR/config/gh" "$HOME/.config/gh"

# Warp
link_file "$DOTFILES_DIR/config/warp" "$HOME/.warp"

# SSH config
log_header "SSH Configuration"
link_file "$DOTFILES_DIR/config/ssh_config" "$HOME/.ssh/config"

# Package manager configs
log_header "Package Manager Configuration"
link_file "$DOTFILES_DIR/config/.yarnrc" "$HOME/.yarnrc"

if [[ ! -f "$HOME/.npmrc" ]]; then
    log_warning "Missing ~/.npmrc"
    log_info "Copy config/.npmrc.example to ~/.npmrc and add your auth tokens if needed"
fi

# Summary
echo ""
log_header "Installation Complete!"
log_success "All dotfiles have been symlinked"
echo ""
log_info "Next steps:"
echo "  1. Create ~/.gitconfig.local from git/.gitconfig.local.example"
echo "  2. Create ~/.npmrc from config/.npmrc.example (if needed)"
echo "  3. Restart your shell or run: source ~/.zshrc"
echo ""
