#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Determine container runtime
if command -v docker &> /dev/null; then
    RUNTIME="docker"
elif command -v podman &> /dev/null; then
    RUNTIME="podman"
else
    echo "Error: Neither docker nor podman found."
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

log_info "Using container runtime: $RUNTIME"

# Build the builder image
log_info "Building builder image..."
$RUNTIME build -t maleo-builder "$SCRIPT_DIR/docker"

# Run the build
log_info "Starting build in container..."
log_info "Note: This requires privileged mode for livecd-creator"

$RUNTIME run --privileged --rm -it \
    -v "$PROJECT_ROOT:/maleo-os" \
    maleo-builder \
    -c "cd build && ./build-iso.sh"

log_success "Container finished."
