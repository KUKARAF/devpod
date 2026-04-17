#!/usr/bin/env bash
# Prerequisites for Debian-based systems (Debian, Ubuntu, Pop!_OS, etc.)
# Uses Docker (from the official Docker repo) and distrobox instead of toolbox/podman.
set -e

# --- Docker ---
if ! command -v docker &>/dev/null; then
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg

    sudo install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/debian/gpg \
        | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    sudo chmod a+r /etc/apt/keyrings/docker.gpg

    # Detect distro (Debian vs Ubuntu/derivatives)
    . /etc/os-release
    DISTRO_ID="${ID}"
    if [[ "$DISTRO_ID" != "debian" ]]; then
        # Ubuntu or derivative — use ubuntu keyserver URL
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
            | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" \
            | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    else
        echo \
            "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/debian \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
            | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    fi

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    sudo usermod -aG docker "$USER"
    echo "Docker installed. You may need to log out and back in for group membership to take effect."
else
    echo "Docker already installed, skipping."
fi

# --- Core packages ---
echo "Installing core packages..."
sudo apt-get install -y stow btop fzf android-tools-adb android-tools-fastboot

# --- Tailscale ---
if ! command -v tailscale &>/dev/null; then
    echo "Installing Tailscale..."
    curl -fsSL https://tailscale.com/install.sh | sh
else
    echo "Tailscale already installed, skipping."
fi

# --- Syncthing ---
if ! command -v syncthing &>/dev/null; then
    echo "Installing Syncthing..."
    sudo apt-get install -y syncthing
else
    echo "Syncthing already installed, skipping."
fi

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

# --- Distrobox ---
if ! command -v distrobox &>/dev/null; then
    echo "Installing distrobox..."
    curl -s https://raw.githubusercontent.com/89luca89/distrobox/main/install | sh -s -- --prefix ~/.local
else
    echo "Distrobox already installed, skipping."
fi

echo "Done. Please log out and back in (or reboot) for Docker group and path changes to take effect."
