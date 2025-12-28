#!/bin/bash

# Maleo Fedora Remix - Main Installation Script
# Adapted from Omarchy for Fedora

set -eEo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Define Maleo locations
export MALEO_PATH="$HOME/.local/share/maleo"
export MALEO_INSTALL="$MALEO_PATH/install"
export MALEO_INSTALL_LOG_FILE="/var/log/maleo-install.log"
export MALEO_CONFIG="$HOME/.config"
export PATH="$MALEO_PATH/bin:$PATH"

# ASCII Art
MALEO_ART='
 ███╗   ███╗ █████╗ ██╗     ███████╗ ██████╗ 
 ████╗ ████║██╔══██╗██║     ██╔════╝██╔═══██╗
 ██╔████╔██║███████║██║     █████╗  ██║   ██║
 ██║╚██╔╝██║██╔══██║██║     ██╔══╝  ██║   ██║
 ██║ ╚═╝ ██║██║  ██║███████╗███████╗╚██████╔╝
 ╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝ ╚═════╝ 
                                              
    Fedora Remix with Hyprland & Nix
'

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_fedora() {
    if [ ! -f /etc/fedora-release ]; then
        log_error "This script is designed for Fedora Linux only!"
        exit 1
    fi
    
    FEDORA_VERSION=$(rpm -E %fedora)
    log_info "Detected Fedora $FEDORA_VERSION"
    
    if [ "$FEDORA_VERSION" -lt 43 ]; then
        log_warning "Maleo is tested on Fedora 43+. Your version may not be fully supported."
        read -p "Continue anyway? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

check_root() {
    if [ "$EUID" -eq 0 ]; then
        log_error "Please do not run this script as root!"
        log_info "The script will ask for sudo password when needed."
        exit 1
    fi
}

check_internet() {
    log_info "Checking internet connection..."
    if ! ping -c 1 google.com &> /dev/null; then
        log_error "No internet connection detected!"
        exit 1
    fi
    log_success "Internet connection OK"
}

# Main installation
main() {
    #clear
    echo -e "${GREEN}${MALEO_ART}${NC}"
    
    log_info "Starting Maleo Fedora Remix installation..."
    
    # Preflight checks
    check_root
    check_fedora
    check_internet
    
    # Create log file
    sudo touch "$MALEO_INSTALL_LOG_FILE"
    sudo chmod 666 "$MALEO_INSTALL_LOG_FILE"
    
    # Source installation modules
    log_info "Loading installation modules..."
    
    source "$MALEO_INSTALL/helpers/all.sh"
    source "$MALEO_INSTALL/preflight/all.sh"
    source "$MALEO_INSTALL/packaging/all.sh"
    source "$MALEO_INSTALL/config/all.sh"
    source "$MALEO_INSTALL/post-install/all.sh"
    
    log_success "Maleo installation completed!"
    log_info "Please reboot your system and select Hyprland from the display manager."
    
    read -p "Reboot now? (y/N) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        systemctl reboot
    fi
}

# Run main installation
main "$@"
