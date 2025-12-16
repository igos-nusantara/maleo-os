#!/bin/bash

# Maleo Fedora Remix - ISO Builder
# Requires: Fedora 43+, livecd-tools

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if running on Fedora
if [ ! -f /etc/fedora-release ]; then
    log_error "This script must be run on Fedora!"
    exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    log_error "Please run as root (use sudo)"
    exit 1
fi

# Check for required tools
if ! command -v livecd-creator &> /dev/null; then
    log_error "livecd-tools not found. Installing..."
    dnf install -y livecd-tools spin-kickstarts
fi

# Variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
KICKSTART_DIR="$PROJECT_ROOT/kickstart"
OUTPUT_DIR="$PROJECT_ROOT/output"
CACHE_DIR="/var/cache/maleo-build"
ISO_NAME="maleo-$(date +%Y%m%d).iso"

log_info "Maleo Fedora Remix ISO Builder"
log_info "================================"
log_info "Project root: $PROJECT_ROOT"
log_info "Kickstart: $KICKSTART_DIR/maleo-live.ks"
log_info "Output: $OUTPUT_DIR/$ISO_NAME"

# Create directories
mkdir -p "$OUTPUT_DIR"
mkdir -p "$CACHE_DIR"

# Validate kickstart file
log_info "Validating kickstart file..."
if command -v ksvalidator &> /dev/null; then
    ksvalidator "$KICKSTART_DIR/maleo-live.ks" || {
        log_error "Kickstart validation failed!"
        exit 1
    }
    log_success "Kickstart validation passed"
else
    log_info "ksvalidator not found, skipping validation"
fi

# Build ISO
log_info "Building ISO (this may take a while)..."
livecd-creator \
    --verbose \
    --config="$KICKSTART_DIR/maleo-live.ks" \
    --fslabel="Maleo-Fedora-Remix" \
    --cache="$CACHE_DIR" \
    --tmpdir="/tmp" \
    --product="Maleo Fedora Remix" \
    --releasever=43

# Move ISO to output directory
if [ -f "Maleo-Fedora-Remix.iso" ]; then
    mv "Maleo-Fedora-Remix.iso" "$OUTPUT_DIR/$ISO_NAME"
    log_success "ISO created successfully: $OUTPUT_DIR/$ISO_NAME"
    
    # Generate checksums
    log_info "Generating checksums..."
    cd "$OUTPUT_DIR"
    sha256sum "$ISO_NAME" > "$ISO_NAME.sha256"
    log_success "Checksum created: $ISO_NAME.sha256"
    
    # Show ISO size
    ISO_SIZE=$(du -h "$ISO_NAME" | cut -f1)
    log_info "ISO size: $ISO_SIZE"
else
    log_error "ISO creation failed!"
    exit 1
fi

log_success "Build completed successfully!"
log_info "You can now burn the ISO to a USB drive using:"
log_info "  sudo dd if=$OUTPUT_DIR/$ISO_NAME of=/dev/sdX bs=4M status=progress"
log_info "  (Replace /dev/sdX with your USB device)"
