#!/usr/bin/env bash
set -euo pipefail

# Run after build_linux.sh / build_windows.sh / build_mac.sh.
# Produces ready-to-upload archives in dist/ for itch.io.
#
# Usage:
#   ./package.sh               # version pulled from git tag or commit
#   VERSION=1.0.0 ./package.sh # override version manually

GAME_NAME="sdrl"
VERSION="${VERSION:-$(git describe --tags --always --dirty 2>/dev/null || echo "1.0.0")}"

echo "Packaging $GAME_NAME $VERSION..."

# Linux
if [ -f "dist/linux/$GAME_NAME" ]; then
    cp README.md dist/linux/
    tar -czf "dist/${GAME_NAME}-linux-x64-${VERSION}.tar.gz" \
        -C dist/linux .
    echo "  dist/${GAME_NAME}-linux-x64-${VERSION}.tar.gz"
fi

# Windows
if [ -f "dist/windows/${GAME_NAME}.exe" ]; then
    cp README.md dist/windows/
    (cd dist/windows && zip -r "../${GAME_NAME}-windows-x64-${VERSION}.zip" .)
    echo "  dist/${GAME_NAME}-windows-x64-${VERSION}.zip"
fi

# macOS
if [ -f "dist/macos/$GAME_NAME" ]; then
    cp README.md dist/macos/
    tar -czf "dist/${GAME_NAME}-macos-universal-${VERSION}.tar.gz" \
        -C dist/macos .
    echo "  dist/${GAME_NAME}-macos-universal-${VERSION}.tar.gz"
fi

echo "Done. Upload the archives above to itch.io."
