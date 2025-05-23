# Vim Plugins and Development Environment

This repository contains a collection of vim plugins and a development environment setup using Docker and distrobox.

## Quick Setup

### 1. Install Vim Plugins

Run this command to set up vim plugins:
```bash
curl -sSL https://raw.githubusercontent.com/KUKARAF/vim_plugins/main/setup_vim_plugins.sh | bash
```

## Using with Distrobox

### Prerequisites
- distrobox
-  wget 


### Setup and Usage

1. Create the development container using the provided configuration:
   ```bash
   git clone git@github.com:KUKARAF/devpod.git ~/.config/dotfiles && cd ~/.config/dotfiles && stow -t ~ --adopt .
   distrobox assemble create --file distrobox.ini
   ```

2. Verify the exported tools:
   ```bash
   which vim ag fzf rg zoxide git
   ```

The container comes with:
- Vim with pre-configured plugins
- Development tools and build essentials
- Node.js (via asdf version manager)
- UV (fast Python package installer)
- FZF (fuzzy finder)
- The Silver Searcher (ag)
- Shell-ask
- Zoxide
- Aider

### Features
- Seamless integration with host system
- Persistent home directory
- Access to host system's display and audio
- Shared SSH keys and config
