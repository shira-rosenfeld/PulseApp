#!/usr/bin/env bash
# Run this script on an internet-connected machine BEFORE deploying to the
# air-gapped environment. It downloads all pub packages defined in
# pubspec.lock into a self-contained pub_cache/ directory inside the project,
# so they can be transferred alongside the source code.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FRONTEND_DIR="$PROJECT_ROOT/pulse_frontend"
PUB_CACHE_DIR="$PROJECT_ROOT/pub_cache"

echo "==> Flutter offline package pre-download"
echo "    Frontend : $FRONTEND_DIR"
echo "    Pub cache: $PUB_CACHE_DIR"
echo ""

if ! command -v flutter &>/dev/null; then
  echo "ERROR: 'flutter' not found in PATH. Install the Flutter SDK first."
  exit 1
fi

flutter --version

mkdir -p "$PUB_CACHE_DIR"

echo ""
echo "==> Downloading packages into $PUB_CACHE_DIR ..."
(
  cd "$FRONTEND_DIR"
  PUB_CACHE="$PUB_CACHE_DIR" flutter pub get
)

echo ""
echo "==> Verifying cache contents ..."
PACKAGE_COUNT=$(find "$PUB_CACHE_DIR/hosted" -maxdepth 3 -name "pubspec.yaml" 2>/dev/null | wc -l | tr -d ' ')
echo "    Cached packages: $PACKAGE_COUNT"

echo ""
echo "==> Pre-download complete."
echo "    Transfer the following to the air-gapped machine (keep relative paths):"
echo "      pub_cache/"
echo "      pulse_frontend/"
echo ""
echo "    Then run:  scripts/restore_flutter_packages.sh"
