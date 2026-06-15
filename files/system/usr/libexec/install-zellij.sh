#!/bin/bash
set -e

INSTALL_DIR="/usr/local/bin"

echo "Fetching latest zellij release..."
VERSION=$(curl -s https://api.github.com/repos/zellij-org/zellij/releases/latest | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//')
DOWNLOAD_URL="https://github.com/zellij-org/zellij/releases/download/v${VERSION}/zellij-x86_64-unknown-linux-musl.tar.gz"

echo "Installing zellij v${VERSION}..."
cd /tmp
curl -sL "$DOWNLOAD_URL" -o zellij.tar.gz
tar xzf zellij.tar.gz
install -m 755 zellij "$INSTALL_DIR/zellij"
rm -f zellij.tar.gz zellij
echo "Zellij v${VERSION} installed to $INSTALL_DIR/zellij"
