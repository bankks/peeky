#!/usr/bin/env bash
set -euo pipefail

SCHEME="Peeky"
CONFIG="${1:-Release}"
BUILD_DIR="$(pwd)/build"

echo "→ Building $SCHEME ($CONFIG)..."

xcodebuild build \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -derivedDataPath "$BUILD_DIR" \
  -quiet

APP_PATH=$(find "$BUILD_DIR" -name "Peeky.app" -maxdepth 6 | head -1)

if [ -z "$APP_PATH" ]; then
  echo "✗ Peeky.app not found in build output"
  exit 1
fi

mkdir -p dist
rm -rf dist/Peeky.app
cp -r "$APP_PATH" dist/Peeky.app
echo "✓ Built → dist/Peeky.app"
