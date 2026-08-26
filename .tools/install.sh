#!/usr/bin/env bash
set -e

#toolbox create --image ghcr.io/thrix/nix-toolbox:42
#toolbox enter nix-toolbox-42

if [ -d /nix ] && command -v home-manager &>/dev/null; then
    echo "nix-toolbox detected — running home-manager switch..."
    home-manager switch
else
    echo "Standard install — flatpaks + python venv..."
    # Flatpaks used to be read out of the recipe's default-flatpaks module.
    # That module is gone: installing 2.2 GB of apps before login starved the
    # desktop on first boot. The image now ships devpod-apps, an interactive
    # picker, and the catalogue lives at /usr/share/devpod/flatpaks.tsv.
    if command -v devpod-apps >/dev/null; then
        devpod-apps
    else
        echo "  devpod-apps not found (not running the devpod image?); skipping flatpaks."
    fi
    uv venv -p 3.11
    source .venv/bin/activate
    uv pip install -r requirements.txt
fi
