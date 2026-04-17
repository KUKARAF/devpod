#!/usr/bin/env bash
# Bootstrap installer — safe to pipe into bash:
#   curl -fsSL https://raw.githubusercontent.com/KUKARAF/devpod/main/install.sh | bash
set -e

REPO="https://github.com/KUKARAF/devpod.git"
DOTFILES="$HOME/.config/dotfiles"

# ── 1. Clone or update ────────────────────────────────────────────────────────
if [ -d "$DOTFILES/.git" ]; then
    echo "Dotfiles already present at $DOTFILES — pulling latest..."
    git -C "$DOTFILES" pull --ff-only
else
    echo "Cloning $REPO → $DOTFILES ..."
    git clone "$REPO" "$DOTFILES"
fi

# ── 2. Stow ───────────────────────────────────────────────────────────────────
if ! command -v stow &>/dev/null; then
    echo "Error: 'stow' not found. Install it first (apt install stow / rpm-ostree install stow)." >&2
    exit 1
fi

echo "Stowing dotfiles..."
stow -t ~ --adopt -d "$DOTFILES" .

# ── 3. Distro-specific prerequisites ─────────────────────────────────────────
if [ ! -f /etc/os-release ]; then
    echo "Warning: /etc/os-release not found — skipping prerequisites." >&2
    exit 0
fi

. /etc/os-release

case "$ID" in
    fedora)
        if [ -f /run/ostree-booted ]; then
            echo "Detected Fedora Silverblue/Kinoite — running Silverblue prerequisites..."
        else
            echo "Detected Fedora (mutable) — running Silverblue prerequisites..."
        fi
        bash "$DOTFILES/.tools/install_silverblue.sh"
        ;;
    debian|ubuntu|linuxmint|pop|neon|elementary|zorin|kali)
        echo "Detected Debian-based distro ($ID) — running Debian prerequisites..."
        bash "$DOTFILES/.tools/debian_prerequisites_install.sh"
        ;;
    *)
        echo "Unknown distro '$ID' — skipping prerequisites."
        echo "You can run the appropriate script manually from $DOTFILES/.tools/"
        ;;
esac

echo ""
echo "Done! Open a new shell (or source ~/.bashrc) for all changes to take effect."
