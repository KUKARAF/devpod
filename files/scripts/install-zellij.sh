#!/bin/bash
# Install zellij into the image from an upstream GitHub release.
#
# Pinned deliberately: this image rebuilds nightly from master, so tracking
# "latest" would let zellij change with no commit behind it. Bump VERSION here
# to upgrade, and the change shows up in git like everything else.
#
# The musl build is a static binary with no library dependencies, so the copy
# in /usr/bin also runs inside the toolbox via /run/host/usr/bin. That is why
# zellij is installed here rather than by home-manager: /nix does not exist on
# the host, so a nix-installed zellij is unusable outside the toolbox.
set -euo pipefail

VERSION="0.45.0"
TARGET="x86_64-unknown-linux-musl"
BASE="https://github.com/zellij-org/zellij/releases/download/v${VERSION}"

# /usr/local is a symlink into /var on ostree and is not shipped in the image.
INSTALL_DIR="/usr/bin"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

echo "==> Downloading zellij v${VERSION} (${TARGET})..."
curl -fsSL "${BASE}/zellij-${TARGET}.tar.gz"    -o zellij.tar.gz
curl -fsSL "${BASE}/zellij-${TARGET}.sha256sum" -o zellij.sha256sum

tar xzf zellij.tar.gz

# Upstream checksums the extracted binary, not the tarball.
expected="$(awk '{print $1}' zellij.sha256sum)"
actual="$(sha256sum zellij | awk '{print $1}')"
if [ "$expected" != "$actual" ]; then
    echo "ERROR: zellij checksum mismatch" >&2
    echo "  expected $expected" >&2
    echo "  actual   $actual" >&2
    exit 1
fi
echo "==> Checksum verified: ${actual}"

install -m 755 zellij "${INSTALL_DIR}/zellij"
echo "==> zellij v${VERSION} installed to ${INSTALL_DIR}/zellij"
