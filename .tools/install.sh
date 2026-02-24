#!/usr/bin/env bash
set -e

#toolbox create --image ghcr.io/thrix/nix-toolbox:42
#toolbox enter nix-toolbox-42

if [ -d /nix ] && command -v home-manager &>/dev/null; then
    echo "nix-toolbox detected — running home-manager switch..."
    home-manager switch
else
    echo "Standard install — flatpaks + python venv..."
    xargs -I{} flatpak install -y fedora {} < flatpaks/fedora.txt
    xargs -I{} flatpak install -y flathub {} < flatpaks/flathub.txt
    uv venv -p 3.11
    source .venv/bin/activate
    uv pip install -r requirements.txt
fi
