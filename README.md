# Vim Plugins and Development Environment

This repository contains a collection of vim plugins and a development environment setup using Docker and distrobox.

## Vim Plugin Installation

To install the vim plugins directly:

```bash
git clone --recurse-submodules -j8 https://github.com/KUKARAF/vim_plugins ~/.vim/
```

## Using with Distrobox

### Prerequisites

1. Install distrobox on your system:
   ```bash
   sudo dnf install distrobox   # Fedora
   # or
   sudo apt install distrobox   # Ubuntu/Debian
   ```

2. Make sure you have podman installed:
   ```bash
   sudo dnf install podman      # Fedora
   # or
   sudo apt install podman      # Ubuntu/Debian
   ```

### Setup and Usage

1. Create a new distrobox container using this image:
   ```bash
   distrobox create -i ghcr.io/kukaraf/devpod:main -n dev
   ```

2. Enter the container:
   ```bash
   distrobox enter dev
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
