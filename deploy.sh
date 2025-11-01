#!/bin/bash
set -e

# Deployment script for Nanobyte Hugo Site
# Builds Docker image locally and transfers to server via SSH

# Load configuration
if [ -f .env.deploy ]; then
    source .env.deploy
else
    echo "Error: .env.deploy file not found!"
    echo "Please create .env.deploy with the following variables:"
    echo "  DEPLOY_USER=your-username"
    echo "  DEPLOY_HOST=your-server.com"
    echo "  DEPLOY_PATH=/path/to/deployment"
    exit 1
fi

# Verify required variables
if [ -z "$DEPLOY_USER" ] || [ -z "$DEPLOY_HOST" ] || [ -z "$DEPLOY_PATH" ]; then
    echo "Error: Missing required deployment variables in .env.deploy"
    echo "Required: DEPLOY_USER, DEPLOY_HOST, DEPLOY_PATH"
    exit 1
fi

DEPLOY_TARGET="${DEPLOY_USER}@${DEPLOY_HOST}"
IMAGE_NAME="nanobyte-site:latest"

echo "=========================================="
echo "  Deploying Nanobyte Site"
echo "=========================================="
echo "Image: ${IMAGE_NAME}"
echo "Target: ${DEPLOY_TARGET}:${DEPLOY_PATH}"
echo ""

# Build Docker image locally
echo "→ Building Docker image..."
docker build -t "${IMAGE_NAME}" .

echo "✓ Build complete"
echo ""

# Transfer image to server via SSH pipe
echo "→ Transferring image to server..."
echo "  (This may take a few minutes...)"
docker save "${IMAGE_NAME}" | ssh "${DEPLOY_TARGET}" docker load

echo "✓ Image transferred"
echo ""

# Copy docker-compose.prod.yml to server
echo "→ Copying docker-compose configuration to server..."
ssh "${DEPLOY_TARGET}" "mkdir -p ${DEPLOY_PATH}"
scp docker-compose.prod.yml "${DEPLOY_TARGET}:${DEPLOY_PATH}/docker-compose.yml"

echo "✓ Configuration copied"
echo ""

# SSH to server and restart container
echo "→ Restarting container on server..."
ssh "${DEPLOY_TARGET}" "cd ${DEPLOY_PATH} && \
    export DOCKER_IMAGE=${IMAGE_NAME} && \
    docker compose down && \
    docker compose up -d"

echo "✓ Container restarted"
echo ""

# Show container status
echo "→ Checking container status..."
ssh "${DEPLOY_TARGET}" "cd ${DEPLOY_PATH} && docker compose ps"

echo ""
echo "=========================================="
echo "  Deployment complete!"
echo "=========================================="
echo ""
echo "The site should now be running at:"
echo "  http://${DEPLOY_HOST}"
echo ""
echo "To view logs:"
echo "  ssh ${DEPLOY_TARGET} 'cd ${DEPLOY_PATH} && docker compose logs -f'"
