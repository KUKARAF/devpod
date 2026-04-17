#!/usr/bin/env bash
set -e

echo "Installing Silverblue prerequisites..."
rpm-ostree install stow btop distrobox steam-devices adb fastboot

echo "Installing additional packages..."
rpm-ostree install tailscale syncthing fzf

# --- kv CLI ---
if ! command -v kv &>/dev/null; then
    echo "Installing kv CLI..."
    _kv_tmp="$(mktemp -d)"
    _kv_tag="$(curl -fsSL https://api.github.com/repos/kukARAF/kv_cli/releases/latest | grep '"tag_name"' | cut -d'"' -f4)"
    _kv_arch="$(uname -m)"
    case "$_kv_arch" in
        x86_64)  _kv_arch="x86_64" ;;
        aarch64) _kv_arch="aarch64" ;;
        *)       echo "Unsupported arch: $_kv_arch" >&2; exit 1 ;;
    esac
    curl -fsSL "https://github.com/kukARAF/kv_cli/releases/download/${_kv_tag}/kv-linux-${_kv_arch}" \
        -o "${_kv_tmp}/kv"
    chmod +x "${_kv_tmp}/kv"
    mkdir -p ~/.local/bin
    mv "${_kv_tmp}/kv" ~/.local/bin/kv
    rm -rf "$_kv_tmp"
    echo "kv CLI installed to ~/.local/bin/kv"
else
    echo "kv CLI already installed, skipping."
fi

# --- debrid_collector ---
if ! command -v debrid_collector &>/dev/null; then
    echo "Installing debrid_collector..."
    _dc_tmp="$(mktemp -d)"
    _dc_tag="$(curl -fsSL https://api.github.com/repos/KUKARAF/debrid_collector/releases/latest | grep '"tag_name"' | cut -d'"' -f4)"
    _dc_arch="$(uname -m)"
    case "$_dc_arch" in
        x86_64)  _dc_arch="x86_64" ;;
        aarch64) _dc_arch="aarch64" ;;
        *)       echo "Unsupported arch: $_dc_arch" >&2; exit 1 ;;
    esac
    curl -fsSL "https://github.com/KUKARAF/debrid_collector/releases/download/${_dc_tag}/debrid_collector-linux-${_dc_arch}" \
        -o "${_dc_tmp}/debrid_collector"
    chmod +x "${_dc_tmp}/debrid_collector"
    mkdir -p ~/.local/bin
    mv "${_dc_tmp}/debrid_collector" ~/.local/bin/debrid_collector
    rm -rf "$_dc_tmp"
    echo "debrid_collector installed to ~/.local/bin/debrid_collector"
else
    echo "debrid_collector already installed, skipping."
fi

echo "Please reboot for changes to take effect."
