#!/usr/bin/env bash
set -euo pipefail

BINARY="sdrl"
OUT_DIR="dist/linux"

mkdir -p "$OUT_DIR"

echo "Building for Linux (amd64)..."
odin build . \
    -out:"$OUT_DIR/$BINARY" \
    -target:linux_amd64 \
    -o:speed \
    -no-bounds-check

chmod +x "$OUT_DIR/$BINARY"
echo "Done: $OUT_DIR/$BINARY"
