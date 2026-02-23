#!/usr/bin/env bash
# Bootstrap script for nix-toolbox environment.
# Run once after cloning and stowing dotfiles inside nix-toolbox-42.
set -e

if [ ! -d /nix ]; then
    echo "Error: /nix not found. Are you inside the nix-toolbox?" >&2
    exit 1
fi

if ! command -v home-manager &>/dev/null; then
    echo "Error: home-manager not found. Has nix-toolbox initialised? (open a new shell first)" >&2
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "Stowing dotfiles from $DOTFILES_DIR..."
stow -t ~ --adopt -d "$DOTFILES_DIR" .

echo "Applying home-manager configuration..."
home-manager switch

echo "Done. Re-open your shell for all changes to take effect."
