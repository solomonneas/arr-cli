#!/usr/bin/env bash
# arr-cli installer
set -euo pipefail

INSTALL_DIR="${1:-$HOME/bin}"

echo "Installing arr-cli to $INSTALL_DIR..."

mkdir -p "$INSTALL_DIR"
cp media "$INSTALL_DIR/media"
chmod +x "$INSTALL_DIR/media"

# Check if install dir is in PATH
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    echo ""
    echo "⚠️  $INSTALL_DIR is not in your PATH."
    echo "   Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
    echo "   export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo ""
echo "✅ Installed! Run 'media setup' to configure."
