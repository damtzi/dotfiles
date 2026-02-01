#!/bin/bash

# Update Brewfile with currently installed packages

set -e

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source utility functions
source "$SCRIPT_DIR/lib/utils.sh"

log_header "Updating Brewfile"

# Check if brew is installed
if ! command_exists brew; then
    log_error "Homebrew is not installed"
    exit 1
fi

BREWFILE="$DOTFILES_DIR/Brewfile"

log_info "Generating fresh Brewfile..."

# Generate Brewfile
brew bundle dump --force --describe --file="$BREWFILE"

log_success "Brewfile updated at: $BREWFILE"
log_info "Review the changes and commit them to your repo"
echo ""
