# dotfiles

Personal dotfiles for macOS, managed with automated setup scripts.

## Features

- **Organized structure** - Configs separated by type (shell, git, config, scripts)
- **Automated setup** - Bootstrap script for fresh machine setup
- **Safe installation** - Automatic backup of existing configs
- **Git config split** - Public settings in repo, private details in local file
- **Sensitive data protection** - Templates for configs with secrets

## What's Included

### Shell Configuration
- **Zsh** - Main shell with oh-my-zsh, syntax highlighting, autosuggestions
- **Starship** - Modern prompt for interactive shells, including Ghostty and Warp
- **Bash** - Compatibility configs

### Development Tools
- **Git** - Config with GPG signing, LFS support
- **GitHub CLI** - Authentication and host config
- **SSH** - Config for multiple GitHub accounts (personal, work)
- **Package Managers** - npm, yarn, pnpm configs

### Applications
- **Zed** - Editor settings with LSP, formatter, agent config
- **OpenCode** - AI agent config with custom instructions and skills
- **Claude Code** - AI agent config with shared instructions
- **Warp** - Terminal emulator with keybindings, launch configs, and custom themes
- **Ghostty** - Terminal emulator config
- **Pi** - Custom light/dark themes, extensions, and skills for the Pi coding agent
- **Amp** - Remote thread creation settings
- **Brewfile** - 67+ packages, casks, and VSCode extensions

## Prerequisites

- macOS (tested on Apple Silicon)
- Xcode Command Line Tools (bootstrap script will install)

## Fresh Machine Setup

For setting up a brand new Mac:

```bash
# Clone this repo
git clone https://github.com/YOUR_USERNAME/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run bootstrap script (installs everything)
./scripts/bootstrap.sh
```

The bootstrap script will:
1. Install Xcode Command Line Tools (if needed)
2. Install Homebrew (if needed)
3. Install all packages from Brewfile
4. Install oh-my-zsh and plugins
5. Create symlinks for all configs
6. Provide post-installation instructions

## Manual Installation

If you already have dependencies installed and just want to symlink configs:

```bash
cd ~/.dotfiles
./scripts/install.sh
```

This is idempotent - safe to run multiple times.

## Post-Installation Steps

### 1. Create Git Local Config

```bash
cp git/.gitconfig.local.example ~/.gitconfig.local
```

Then edit `~/.gitconfig.local` with your details:
```ini
[user]
    email = your.email@example.com
    name = Your Name
    signingkey = YOUR_GPG_KEY_ID
```

### 2. Create NPM Config (if needed)

```bash
cp config/.npmrc.example ~/.npmrc
```

Add your auth tokens if publishing packages.

### 3. Set Up SSH Keys

```bash
# Generate new key
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to GitHub
cat ~/.ssh/id_ed25519.pub
# Copy and add to https://github.com/settings/keys
```

### 4. Verify GPG Signing (Optional)

GPG commit signing is enabled by default. The `gpg-agent` oh-my-zsh plugin handles `GPG_TTY` setup automatically.

```bash
# Verify your GPG key is available
gpg --list-secret-keys --keyid-format=long

# Test signing (should prompt for passphrase)
echo "test" | gpg --clearsign
```

If you don't have a GPG key, you can disable signing in `~/.gitconfig.local`:
```ini
[commit]
    gpgsign = false
```

### 5. Configure GitHub CLI

```bash
gh auth login
```

### 6. Restart Shell

```bash
source ~/.zshrc
# Or restart your terminal
```

## Repository Structure

```
.dotfiles/
├── shell/              # Shell configs (.zshrc, .zshenv, .bashrc, etc.)
│   └── zsh/            # Modular zsh config (exports, prompt, completions, aliases, local overrides)
├── git/                # Git config (public + template for private)
├── config/             # XDG configs
│   ├── zed/           # Zed editor settings
│   ├── opencode/      # OpenCode AI agent config
│   ├── claude/        # Claude Code config
│   ├── warp/          # Warp terminal config (keybindings, launch configs, themes)
│   ├── ghostty/       # Ghostty terminal config
│   ├── gh/            # GitHub CLI config
│   ├── pi/            # Pi coding agent config (themes/extensions)
│   ├── amp/           # Amp configuration
│   ├── agents/        # Shared agent skills
│   ├── starship.toml  # Starship prompt config
│   ├── ssh_config     # SSH config (no private keys)
│   └── .yarnrc        # Yarn config
├── scripts/
│   ├── bootstrap.sh        # Fresh machine setup
│   ├── install.sh          # Create symlinks
│   ├── update-brewfile.sh  # Regenerate Brewfile
│   └── lib/utils.sh        # Shared functions
├── Brewfile           # Homebrew packages
└── README.md
```

## Maintenance

### Update Brewfile

After installing new packages with Homebrew:

```bash
./scripts/update-brewfile.sh
git add Brewfile
git commit -m "Update Brewfile"
```

### Pull Latest Changes

```bash
cd ~/.dotfiles
git pull
```

Changes to symlinked files take effect immediately.

### Add New Config

1. Add file to the appropriate directory in the repo (`config/pi/` for Pi themes/extensions, `config/agents/skills/` for shared skills, `config/` for XDG apps, etc.)
2. Update `scripts/install.sh` to create the symlink
3. Commit and push changes

## Customization

### Shell Aliases

Edit `shell/zsh/aliases.zsh`.

### Machine-Specific Zsh Overrides

Keep one-off or private shell tweaks in `shell/zsh/local.zsh`.

```bash
cp shell/zsh/local.zsh.example shell/zsh/local.zsh
```

That file is ignored by git and loaded automatically if present.

### Git Config

Personal settings go in `~/.gitconfig.local` (not tracked).
Global settings go in `git/.gitconfig` (tracked).

### AI Agent Instructions

Shared instructions live in the root `AGENTS.md`. Harness-specific files link to this master file:

- Amp: `~/.config/amp/AGENTS.md`
- Claude Code: `~/.claude/CLAUDE.md`
- Codex: `~/.codex/AGENTS.md`
- OpenCode: `~/.config/opencode/AGENTS.md`
- Pi: `~/.pi/agent/AGENTS.md`

### Pi Themes

Custom Pi themes live in `config/pi/agent/themes/` and are linked to `~/.pi/agent/themes/`.

### Pi Extensions & Skills

- Extensions live in `config/pi/agent/extensions/` and are linked to `~/.pi/agent/extensions/`
- Shared skills live in `config/agents/skills/` and are linked to `~/.pi/agent/skills/`

### Environment Variables

- Add zsh session PATH / tooling config to `shell/zsh/exports.zsh`
- Add zsh-wide minimal environment variables to `shell/.zshenv`
- Add POSIX login-shell environment variables to `shell/.profile`
- Add zsh login-shell setup to `shell/.zprofile`

## Sensitive Data

The following files are excluded from git:

- `~/.gitconfig.local` - User email, name, GPG key
- `~/.npmrc` - NPM auth tokens
- `~/.aws/` - AWS credentials
- `~/.ssh/id_*` - SSH private keys
- `config/zed/conversations/` - Personal AI chats
- `config/zed/embeddings/` - Generated data

Templates are provided in the repo (`.example` files).

## Key Technologies

- **Shell**: zsh with oh-my-zsh (git, zsh-syntax-highlighting, zsh-autosuggestions, gpg-agent)
- **Prompt**: Starship
- **Terminal**: Ghostty and Warp
- **Editor**: Zed
- **AI Agent**: OpenCode, Claude Code
- **Package Manager**: Homebrew, pnpm
- **Version Control**: Git with GPG signing via pinentry-mac

## License

Personal dotfiles - use at your own discretion.
