#!/usr/bin/env bash
set -e

#toolbox create --image ghcr.io/thrix/nix-toolbox:42
#toolbox enter nix-toolbox-42

if [ -d /nix ] && command -v home-manager &>/dev/null; then
    echo "nix-toolbox detected — running home-manager switch..."
    home-manager switch
else
    echo "Standard install — flatpaks + python venv..."
    python3 -c "
import yaml, sys
recipe = yaml.safe_load(open('recipes/recipe.yml'))
for mod in recipe.get('modules', []):
    if mod.get('type') == 'default-flatpaks':
        for cfg in mod.get('configurations', []):
            remote = cfg['repo']['name']
            for pkg in cfg.get('install', []):
                print(remote, pkg)
" | xargs -L1 sh -c 'flatpak install -y "$0" "$1"'
    uv venv -p 3.11
    source .venv/bin/activate
    uv pip install -r requirements.txt
fi
