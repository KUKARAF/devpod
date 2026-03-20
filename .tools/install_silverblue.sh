#!/usr/bin/env bash
set -e

echo "Installing Silverblue prerequisites..."
rpm-ostree install stow btop distrobox steam-devices adb fastboot

echo "Installing additional packages..."
rpm-ostree install tailscale syncthing fzf

echo "Please reboot for changes to take effect."
