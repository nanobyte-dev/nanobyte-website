#!/bin/bash
set -e

echo "Building Hugo site..."

# Clean previous build
rm -rf generated/public

# Preprocess diagrams
echo "[1/4] Preprocessing Graphviz diagrams..."
docker run --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/work \
  -w /work \
  python:3.11-alpine \
  sh -c "apk add --no-cache graphviz && pip install --no-cache-dir pyyaml && python3 preprocess_diagrams.py"

echo "      Diagram preprocessing complete"

# Copy diagrams to static directory for Hugo
echo "[2/4] Copying diagrams to static directory..."
mkdir -p static/diagrams
cp -r generated/diagrams/* static/diagrams/ 2>/dev/null || echo "      No diagrams to copy"

echo "      Diagrams copied"

# Build with modern config
echo "[3/4] Building modern version..."
docker run --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/src \
  hugomods/hugo:exts \
  hugo --config config.toml --contentDir generated/content --destination generated/public/modern

echo "      Modern build complete"

# Build with legacy config
echo "[4/4] Building legacy version..."
docker run --rm \
  --user $(id -u):$(id -g) \
  -v $(pwd):/src \
  hugomods/hugo:exts \
  hugo --config config-legacy.toml --contentDir generated/content --destination generated/public/legacy

echo "      Legacy build complete"

echo ""
echo "Build complete!"
echo "  Modern: generated/public/modern/"
echo "  Legacy: generated/public/legacy/"
