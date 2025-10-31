#!/bin/bash
set -e

# Parse arguments
CONFIG="config.toml"
MODE="modern"

if [[ "$1" == "--legacy" ]]; then
    CONFIG="config-legacy.toml"
    MODE="legacy"
fi

echo "Starting Hugo development server ($MODE mode)..."
echo ""
echo "Server will be available at:"
echo "  → http://localhost:1313"
echo ""
echo "Features:"
echo "  ✓ Hot reloading enabled"
echo "  ✓ Auto-rebuild on file changes"
echo "  ✓ Draft posts visible"
echo ""
echo "Press Ctrl+C to stop"
echo ""

docker run --rm -it \
  --user $(id -u):$(id -g) \
  -v $(pwd):/src \
  -p 1313:1313 \
  hugomods/hugo:exts \
  hugo server \
    --bind 0.0.0.0 \
    --config $CONFIG \
    --buildDrafts \
    --watch
