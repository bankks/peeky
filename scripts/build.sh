#!/usr/bin/env bash
set -euo pipefail

SCHEME="Peeky"
CONFIG="${1:-Release}"
BUILD_DIR="$(pwd)/build"

# Regenerate Xcode project from project.yml (single source of truth)
if command -v xcodegen &>/dev/null; then
  echo "→ Regenerating Xcode project..."
  xcodegen generate --quiet
fi

echo "→ Building $SCHEME ($CONFIG)..."

xcodebuild build \
  -scheme "$SCHEME" \
  -configuration "$CONFIG" \
  -derivedDataPath "$BUILD_DIR" \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="-" \
  CODE_SIGNING_REQUIRED=YES \
  CODE_SIGNING_ALLOWED=YES \
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
