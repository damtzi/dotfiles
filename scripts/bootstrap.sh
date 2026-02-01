#!/bin/bash

# Bootstrap script for setting up a new Mac with dotfiles
# This script will install Homebrew, dependencies, and configure the system

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utility functions
source "$SCRIPT_DIR/lib/utils.sh"

log_header "Dotfiles Bootstrap"
log_info "Setting up your Mac with dotfiles from: $DOTFILES_DIR"
echo ""

# Check OS
if [[ "$(get_os)" != "macos" ]]; then
    log_error "This script is only supported on macOS"
    exit 1
fi

# Check for Xcode Command Line Tools
log_header "Checking for Xcode Command Line Tools"
if xcode-select -p &>/dev/null; then
    log_success "Xcode Command Line Tools already installed"
else
    log_info "Installing Xcode Command Line Tools..."
    xcode-select --install
    log_warning "Please complete the installation and re-run this script"
    exit 1
fi

# Check for Homebrew
log_header "Checking for Homebrew"
if command_exists brew; then
    log_success "Homebrew already installed"
    log_info "Updating Homebrew..."
    brew update
else
    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == "arm64" ]]; then
        echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    
    log_success "Homebrew installed"
fi

# Install from Brewfile
log_header "Installing Packages from Brewfile"
log_info "This may take a while..."
if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
    brew bundle --file="$DOTFILES_DIR/Brewfile"
    log_success "Packages installed from Brewfile"
else
    log_error "Brewfile not found at $DOTFILES_DIR/Brewfile"
    exit 1
fi

# Check for oh-my-zsh
log_header "Checking for oh-my-zsh"
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log_success "oh-my-zsh already installed"
else
    log_info "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    log_success "oh-my-zsh installed"
fi

# Install oh-my-zsh plugins
log_header "Installing oh-my-zsh Plugins"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

# zsh-syntax-highlighting
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]]; then
    log_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    log_success "zsh-syntax-highlighting installed"
else
    log_success "zsh-syntax-highlighting already installed"
fi

# zsh-autosuggestions
if [[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]]; then
    log_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
    log_success "zsh-autosuggestions installed"
else
    log_success "zsh-autosuggestions already installed"
fi

# Run install script to create symlinks
log_header "Creating Symlinks"
"$SCRIPT_DIR/install.sh"

# Post-installation instructions
echo ""
log_header "Bootstrap Complete!"
log_success "Your Mac has been set up with dotfiles"
echo ""
log_info "Important: Please complete the following steps:"
echo ""
echo "1. Create ~/.gitconfig.local:"
echo "   cp $DOTFILES_DIR/git/.gitconfig.local.example ~/.gitconfig.local"
echo "   # Then edit ~/.gitconfig.local with your details"
echo ""
echo "2. If using npm, create ~/.npmrc:"
echo "   cp $DOTFILES_DIR/config/.npmrc.example ~/.npmrc"
echo "   # Then add your auth tokens if needed"
echo ""
echo "3. Set up SSH keys (if needed):"
echo "   ssh-keygen -t ed25519 -C \"your.email@example.com\""
echo ""
echo "4. Configure GitHub CLI:"
echo "   gh auth login"
echo ""
echo "5. Restart your terminal or run:"
echo "   source ~/.zshrc"
echo ""
log_info "For AWS CLI configuration, run: aws configure"
echo ""
