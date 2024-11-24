#!/bin/bash

# Install Nix if not already installed
if ! command -v nix >/dev/null; then
    curl -L https://nixos.org/nix/install | sh -s -- --daemon
    exec $SHELL
fi

# Enable flakes if not already enabled
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf

# Enter the development shell
nix develop
