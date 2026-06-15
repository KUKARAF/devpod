#!/bin/bash
set -e

VERSION="0.44.3"
DOWNLOAD_URL="https://github.com/zellij-org/zellij/releases/download/v${VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz"
INSTALL_DIR="/usr/local/bin"

echo "Installing zellij v${VERSION}..."
cd /tmp
curl -sL "$DOWNLOAD_URL" -o zellij.tar.gz
tar xzf zellij.tar.gz
install -m 755 zellij "$INSTALL_DIR/zellij"
rm -f zellij.tar.gz zellij
echo "Zellij installed to $INSTALL_DIR/zellij"
