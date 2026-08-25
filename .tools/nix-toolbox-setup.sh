#!/usr/bin/env bash
# Bootstrap script for nix-toolbox environment.
# Run by devenv inside the toolbox, after dotfiles are stowed on the host.
set -e

if [ ! -d /nix ]; then
    echo "Error: /nix not found. Are you inside the nix-toolbox?" >&2
    exit 1
fi

if ! command -v home-manager &>/dev/null; then
    echo "Error: home-manager not found. Has nix-toolbox initialised? (open a new shell first)" >&2
    exit 1
fi

# Dotfiles are stowed on the host by devenv before this runs. $HOME is shared
# with the container, so the symlinks are already visible here -- re-stowing
# would just fail, since stow lives in the host image and not in the toolbox.

echo "Applying home-manager configuration..."
home-manager switch

echo "Done. Re-open your shell for all changes to take effect."
