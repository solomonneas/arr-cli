#!/usr/bin/env bash
# media-cli installer
#
# Usage: bash install.sh [INSTALL_DIR]   (default: ~/bin)
set -euo pipefail

INSTALL_DIR="${1:-$HOME/bin}"

echo "Installing media-cli to $INSTALL_DIR..."

mkdir -p "$INSTALL_DIR"
cp media "$INSTALL_DIR/media"
chmod +x "$INSTALL_DIR/media"

# Also install a `media-cli` alias so users who expect the package name as
# the binary name still get a working executable on their PATH.
ln -sf "$INSTALL_DIR/media" "$INSTALL_DIR/media-cli" 2>/dev/null || \
    cp "$INSTALL_DIR/media" "$INSTALL_DIR/media-cli"

# Check if install dir is in PATH
if ! echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
    echo ""
    echo "⚠️  $INSTALL_DIR is not in your PATH."
    echo "   Add this to your shell profile (~/.bashrc, ~/.zshrc, etc.):"
    echo "   export PATH=\"$INSTALL_DIR:\$PATH\""
fi

echo ""
echo "✅ Installed! Run 'media setup' to configure."
