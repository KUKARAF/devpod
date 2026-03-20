#!/usr/bin/env bash
set -e

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"
echo "Setting up Python venv..."
uv venv -p 3.11
source .venv/bin/activate
uv pip install -r "$DOTFILES_DIR/requirements.txt"
