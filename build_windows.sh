#!/usr/bin/env bash
set -euo pipefail

# Cross-compile to Windows from Linux.
# Requires MinGW-w64: sudo pacman -S mingw-w64-gcc
# Odin will pick up x86_64-w64-mingw32-gcc automatically when targeting windows_amd64.

BINARY="sdrl.exe"
OUT_DIR="dist/windows"

mkdir -p "$OUT_DIR"

echo "Building for Windows (amd64)..."
odin build . \
    -out:"$OUT_DIR/$BINARY" \
    -target:windows_amd64 \
    -o:speed \
    -no-bounds-check

echo "Done: $OUT_DIR/$BINARY"
