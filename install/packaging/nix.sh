#!/bin/bash

# Maleo - Nix Package Manager Installation

print_step "Installing Nix package manager..."

install_nix() {
    if command_exists nix; then
        log_info "Nix is already installed"
        return 0
    fi
    
    print_substep "Installing Nix using Determinate Systems installer..."
    
    # Use Determinate Systems installer (recommended for Fedora)
    # This handles SELinux and /nix directory properly
    curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm
    
    # Source Nix profile
    if [ -f /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh ]; then
        source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
    fi
    
    log_success "Nix installed successfully"
}

configure_nix() {
    print_substep "Configuring Nix..."
    
    # Create nix.conf if it doesn't exist
    sudo mkdir -p /etc/nix
    
    # Configure Nix settings
    sudo tee /etc/nix/nix.conf > /dev/null <<EOF
# Maleo Nix Configuration
experimental-features = nix-command flakes
max-jobs = auto
trusted-users = root $USER
EOF
    
    # Restart Nix daemon
    sudo systemctl restart nix-daemon
    
    log_success "Nix configured"
}

install_nix_packages() {
    print_substep "Installing default Nix packages..."
    
    # Packages that are better installed via Nix or not available in Fedora
    local nix_packages=(
        "nixpkgs#ghostty"
        "nixpkgs#mise"
    )
    
    for pkg in "${nix_packages[@]}"; do
        log_info "Installing $pkg..."
        nix profile install "$pkg" || log_warning "Failed to install $pkg"
    done
    
    log_success "Nix packages installed"
}

# Only install Nix if user wants it
if ask_yes_no "Install Nix package manager?" "y"; then
    install_nix
    configure_nix
    install_nix_packages
else
    log_info "Skipping Nix installation"
fi

log_success "Nix setup completed"
