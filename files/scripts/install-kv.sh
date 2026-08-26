#!/bin/bash
# Install the kv CLI into the image from an upstream GitHub release.
#
# Pinned, like zellij: this image rebuilds nightly, so tracking "latest" would
# let kv change with no commit behind it. Bump VERSION and SHA256 together.
#
# Unlike zellij, upstream publishes no .sha256sum asset and the binary is
# dynamically linked (libc/libm/libgcc_s), so the checksum is recorded here and
# the /run/host symlink trick is NOT used -- inside the toolbox, kv comes from
# home-manager's kv-cli instead.
set -euo pipefail

VERSION="0.1.8cc108d"
SHA256="cfbb48e8c5c57518a9a4c31bc1cb179562ad493c5cc0275f45fdaa91e937884a"
ASSET="kv-linux-amd64.tar.gz"
BASE="https://github.com/KUKARAF/kv_cli/releases/download/${VERSION}"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"

echo "==> Downloading kv ${VERSION}..."
curl -fsSL "${BASE}/${ASSET}" -o kv.tar.gz
tar xzf kv.tar.gz

actual="$(sha256sum kv | awk '{print $1}')"
if [ "$SHA256" != "$actual" ]; then
    echo "ERROR: kv checksum mismatch" >&2
    echo "  expected $SHA256" >&2
    echo "  actual   $actual" >&2
    exit 1
fi
echo "==> Checksum verified: ${actual}"

# /usr/local is a symlink into /var on ostree and is not shipped in the image.
install -Dm755 kv /usr/bin/kv
[ -f kv.1 ] && install -Dm644 kv.1 /usr/share/man/man1/kv.1
echo "==> kv ${VERSION} installed to /usr/bin/kv"
