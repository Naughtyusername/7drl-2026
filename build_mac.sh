#!/usr/bin/env bash
set -euo pipefail

# Run this ON a Mac, or via GitHub Actions (see .github/workflows/release.yml).
# Cross-compiling macOS from Linux requires osxcross + Apple SDK — not worth the setup.
# Easiest options:
#   1. Run this script on a Mac (any Intel or Apple Silicon Mac)
#   2. Push a git tag and let the GitHub Actions workflow handle it

BINARY="sdrl"
OUT_DIR="dist/macos"

mkdir -p "$OUT_DIR"

# Detect architecture and build accordingly, then combine into a universal binary.
# If you only have one architecture available, just remove the other block and skip lipo.

echo "Building for macOS arm64 (Apple Silicon)..."
odin build . \
    -out:"${OUT_DIR}/${BINARY}_arm64" \
    -target:darwin_arm64 \
    -o:speed \
    -no-bounds-check

echo "Building for macOS amd64 (Intel)..."
odin build . \
    -out:"${OUT_DIR}/${BINARY}_amd64" \
    -target:darwin_amd64 \
    -o:speed \
    -no-bounds-check

echo "Creating universal binary..."
lipo -create -output "$OUT_DIR/$BINARY" \
    "${OUT_DIR}/${BINARY}_arm64" \
    "${OUT_DIR}/${BINARY}_amd64"

rm "${OUT_DIR}/${BINARY}_arm64" "${OUT_DIR}/${BINARY}_amd64"
chmod +x "$OUT_DIR/$BINARY"

echo "Done: $OUT_DIR/$BINARY"
