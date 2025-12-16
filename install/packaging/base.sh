#!/bin/bash

# Maleo - Package Installation

print_step "Installing packages..."

# Enable RPM Fusion repositories
enable_rpm_fusion() {
    print_substep "Enabling RPM Fusion repositories..."
    
    if ! package_installed rpmfusion-free-release; then
        sudo dnf install -y \
            https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
            https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        log_success "RPM Fusion enabled"
    else
        log_info "RPM Fusion already enabled"
    fi
}

# Enable COPR repositories for Hyprland and other packages
enable_copr_repos() {
    print_substep "Enabling COPR repositories..."
    
    # Hyprland
    enable_copr "solopasha/hyprland"
    
    # Additional tools that might not be in main repos
    # enable_copr "atim/starship" # if needed
}

# Install base packages
install_base_packages() {
    print_substep "Installing base packages..."
    
    local packages_file="$MALEO_INSTALL/maleo-base.packages"
    
    if [ ! -f "$packages_file" ]; then
        log_error "Package list not found: $packages_file"
        exit 1
    fi
    
    # Read packages from file (skip comments and empty lines)
    local packages=$(grep -v '^#' "$packages_file" | grep -v '^$' | tr '\n' ' ')
    
    log_info "Installing packages from $packages_file"
    
    # Install packages, continue on error for packages that don't exist
    sudo dnf install -y $packages || {
        log_warning "Some packages failed to install, continuing..."
    }
    
    log_success "Base packages installed"
}

# Install Flatpak apps for packages not available in DNF
install_flatpak_apps() {
    print_substep "Setting up Flatpak..."
    
    if ! command_exists flatpak; then
        sudo dnf install -y flatpak
    fi
    
    # Add Flathub repository
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    
    # Install apps that are better via Flatpak
    local flatpak_apps=(
        "com.spotify.Client"
        "com.obsidian.Obsidian"
        "org.signal.Signal"
    )
    
    for app in "${flatpak_apps[@]}"; do
        if ! flatpak list | grep -q "$app"; then
            log_info "Installing $app via Flatpak..."
            flatpak install -y flathub "$app" || log_warning "Failed to install $app"
        fi
    done
    
    log_success "Flatpak apps installed"
}

# Main package installation
enable_rpm_fusion
enable_copr_repos
install_base_packages
install_flatpak_apps

log_success "Package installation completed"
