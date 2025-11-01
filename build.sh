#!/bin/bash
set -e

echo "Building Hugo site..."

# Clean previous build
rm -rf public

# Build with modern config
echo "→ Building modern version..."
docker run --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/src \
  hugomods/hugo:exts \
  hugo --config config.toml --destination public/modern

echo "✓ Modern build complete"

# Build with legacy config
echo "→ Building legacy version..."
docker run --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/src \
  hugomods/hugo:exts \
  hugo --config config-legacy.toml --destination public/legacy

echo "✓ Legacy build complete"

echo ""
echo "Build complete!"
echo "  Modern: public/modern/"
echo "  Legacy: public/legacy/"
