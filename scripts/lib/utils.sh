#!/bin/bash

# Utility functions for dotfiles installation

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

log_error() {
    echo -e "${RED}✗${NC} $1"
}

log_header() {
    echo ""
    echo -e "${BLUE}==>${NC} $1"
    echo ""
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get macOS version
get_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Get dotfiles directory (parent of scripts directory)
get_dotfiles_dir() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
    echo "$(cd "$script_dir/.." && pwd)"
}

# Create backup directory if it doesn't exist
create_backup_dir() {
    local backup_dir="$HOME/.dotfiles.backup"
    if [[ ! -d "$backup_dir" ]]; then
        mkdir -p "$backup_dir"
        log_info "Created backup directory: $backup_dir" >&2
    fi
    echo "$backup_dir"
}

# Backup a file if it exists and is not a symlink
backup_file() {
    local file="$1"
    local backup_dir="$(create_backup_dir)"
    
    if [[ -e "$file" && ! -L "$file" ]]; then
        local filename="$(basename "$file")"
        local timestamp="$(date +%Y%m%d_%H%M%S)"
        local backup_path="$backup_dir/${filename}.${timestamp}.bak"
        
        cp -RP "$file" "$backup_path"
        log_info "Backed up: $file → $backup_path"
        return 0
    fi
    return 1
}

# Create a symlink safely (with backup if needed)
link_file() {
    local source="$1"
    local target="$2"
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        log_error "Source does not exist: $source"
        return 1
    fi
    
    # If target exists and is a symlink pointing to the correct source, skip
    if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
        log_info "Already linked: $target → $source"
        return 0
    fi
    
    # Backup existing file if it's not a symlink
    if [[ -e "$target" ]]; then
        if [[ -L "$target" ]]; then
            log_warning "Removing old symlink: $target"
            rm "$target"
        else
            backup_file "$target"
            rm -rf "$target"
        fi
    fi
    
    # Create parent directory if it doesn't exist
    local parent_dir="$(dirname "$target")"
    if [[ ! -d "$parent_dir" ]]; then
        mkdir -p "$parent_dir"
    fi
    
    # Create the symlink
    ln -sf "$source" "$target"
    log_success "Linked: $target → $source"
    return 0
}

# Ask for user confirmation
ask_confirmation() {
    local question="$1"
    local default="${2:-n}"
    
    if [[ "$default" == "y" ]]; then
        local prompt="[Y/n]"
    else
        local prompt="[y/N]"
    fi
    
    read -p "$question $prompt " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        return 0
    elif [[ -z $REPLY && "$default" == "y" ]]; then
        return 0
    else
        return 1
    fi
}
