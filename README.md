# Dotfiles and Development Environment

This repository contains dotfiles and scripts for setting up a development environment with a focus on modularity and flexibility.

## Key Changes from Previous Approach

- **Removed**: LLM and ask tools (no longer used)
- **Restructured**: Moved helper scripts from root to `.tools/*.sh` directory
- **Split installation**: Separated vim plugin installation from main setup
- **Updated distrobox**: Now uses `ghcr.io/kukaraf/devpod:latest` image
- **New prerequisites**: Added dedicated script for Silverblue setup

## Setup Guide

### 1. Prerequisites (Silverblue)

For Fedora Silverblue, run the prerequisites installer:
```bash
./.tools/silverblue_prerequisites_install.sh
```

This installs:
- `stow` (for dotfile management)
- `btop` (system monitor)
- `distrobox` (container management)

### 2. Main Installation

Run the main installer to set up basic tools and Python environment:
```bash
./.tools/install.sh
```

This will:
- Install Flatpak applications from `flatpaks.txt`
- Set up Python 3.11 virtual environment
- Install Python dependencies from `requirements.txt`

### 3. Vim Plugin Setup (Optional)

Install vim plugins separately:
```bash
./.tools/setup_vim_plugins.sh
```

### 4. Distrobox Setup (Optional)

To use with distrobox:
```bash
# Clone and stow dotfiles
git clone git@github.com:KUKARAF/devpod.git ~/.config/dotfiles && cd ~/.config/dotfiles && stow -t ~ --adopt .

# Create development container
distrobox create --image ghcr.io/kukaraf/devpod:latest --name devpod

# Enter the container
distrobox enter devpod
```

## Available Tools

### Helper Scripts (`.tools/`)
- `install.sh` - Main installation script
- `setup_vim_plugins.sh` - Vim plugin manager
- `silverblue_prerequisites_install.sh` - Silverblue prerequisites
- `adopt.sh` - Adopt existing configurations
- `start_syncthing.sh` - Syncthing startup helper

### Installed Components
- **Python**: Virtual environment with timefhuman, requests, pyyaml, playwright
- **Flatpaks**: KeePassXC, Wattage, DistroShelf, Nucleus, Whis, Obsidian, Gearlever, Grayjay, Webapps
- **Vim Plugins**: fugitive, jedi-vim, fzf.vim, commentary, vimwiki, yazi.vim

### Configuration Files
- `.bashrc`, `.vimrc`, `.zellijrc` - Shell and editor configurations
- `.config/` - Application-specific configurations (alacritty, starship, zellij, mise)
- `.runprompt/` - Custom prompt configurations and LLM automation tools

### Runprompt LLM Automations

The `.runprompt/` directory contains specialized LLM-powered automation tools that combine models with task-specific prompts:

**Available Prompts:**
- `bash.prompt` - Bash scripting assistant
- `create_download_sh.prompt` - Download script generator
- `estimate_today.prompt` - Daily task estimator
- `find.prompt` - File finding assistant
- `find_resources.prompt` - Resource discovery tool
- `improve_specs.prompt` - Specification improvement assistant
- `keyboard_query.prompt` - Keyboard shortcut lookup
- `new_project.prompt` - Project scaffolding with pomodoro integration
- `new_skill.prompt` - Skill learning assistant
- `resources.prompt` - Resource recommendation tool

**Python Tools:**
- `ask.py` - User interaction utilities
- `bash_help.py` - Bash help functions
- `download_tools.py` - Download utilities
- `find.py` - Enhanced file search
- `jina.py` - Jina AI integration
- `new_skill.py` - Skill learning tools
- `project_tools.py` - Project setup utilities
- `searxng_search.py` - Search engine integration
- `todo.py` - Task management

These tools enable automated workflows like:
- Project creation with git initialization and template setup
- Pomodoro timer integration for focused work sessions
- Task-specific LLM assistance with pre-configured models
- Resource discovery and recommendation systems

## Features

- **Modular Setup**: Install components separately as needed
- **Container Support**: Works with distrobox for isolated environments
- **Dotfile Management**: Uses GNU Stow for clean symlink management
- **Python Environment**: Pre-configured virtual environment with essential packages

## Usage Notes

- Vim plugins are managed separately for easier updates
- The distrobox image includes development tools and build essentials
- Python environment uses UV for fast package installation
- Flatpak applications provide GUI tools and utilities

## License

MIT License - see the repository for details.


