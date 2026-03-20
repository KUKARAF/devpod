#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "Installing flatpaks..."
xargs -a "$DOTFILES_DIR/flatpaks.txt" flatpak install -y
