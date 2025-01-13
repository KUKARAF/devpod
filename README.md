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

1. Install distrobox and podman on your system:
   ```bash
   # Fedora
   sudo dnf install distrobox podman
   # or Ubuntu/Debian
   sudo apt install distrobox podman
   ```

### Setup and Usage

1. Download the distrobox configuration and create the container:
   ```bash
   curl -sSL https://raw.githubusercontent.com/KUKARAF/vim_plugins/main/distrobox.ini -o distrobox.ini
   distrobox create --file distrobox.ini -n dev
   ```

2. Enter the container:
   ```bash
   distrobox enter dev
   ```

3. Verify the exported tools:
   ```bash
   which uv ask ag z zoxide fzf asdf
   ```

The container comes with:
- Vim with pre-configured plugins
- Development tools and build essentials
- Node.js (via asdf)
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
