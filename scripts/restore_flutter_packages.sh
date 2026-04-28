#!/usr/bin/env bash
# Run this script on the AIR-GAPPED machine after transferring the project.
# It points Flutter to the pre-downloaded pub_cache/ directory and resolves
# all packages without any network access.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FRONTEND_DIR="$PROJECT_ROOT/pulse_frontend"
PUB_CACHE_DIR="$PROJECT_ROOT/pub_cache"

echo "==> Flutter offline package restore"
echo "    Frontend : $FRONTEND_DIR"
echo "    Pub cache: $PUB_CACHE_DIR"
echo ""

if ! command -v flutter &>/dev/null; then
  echo "ERROR: 'flutter' not found in PATH. The Flutter SDK must be pre-installed."
  exit 1
fi

if [ ! -d "$PUB_CACHE_DIR/hosted" ]; then
  echo "ERROR: pub_cache/ directory not found or empty."
  echo "       Run scripts/pre_download_flutter_packages.sh on an internet-connected"
  echo "       machine first, then transfer the pub_cache/ folder here."
  exit 1
fi

flutter --version

echo ""
echo "==> Restoring packages from local cache (no network) ..."
(
  cd "$FRONTEND_DIR"
  PUB_CACHE="$PUB_CACHE_DIR" flutter pub get --offline
)

echo ""
echo "==> Package restore complete."
echo ""
echo "    For subsequent flutter commands (build, run, test), prefix with:"
echo "      PUB_CACHE=\"$PUB_CACHE_DIR\" flutter <command>"
echo ""
echo "    Or export it for the current shell session:"
echo "      export PUB_CACHE=\"$PUB_CACHE_DIR\""
