#!/usr/bin/env bash
set -e

if [ -d /nix ] && command -v home-manager &>/dev/null; then
    echo "nix-toolbox detected — running home-manager switch..."
    home-manager switch
else
    echo "Standard install — flatpaks + python venv..."
    xargs -a flatpaks.txt flatpak install -y
    uv venv -p 3.11
    source .venv/bin/activate
    uv pip install -r requirements.txt
fi
