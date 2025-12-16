#!/bin/bash

# Maleo - Post-Installation Tasks

print_step "Running post-installation tasks..."

enable_services() {
    print_substep "Enabling system services..."
    
    # Enable SDDM
    sudo systemctl enable sddm
    
    # Enable NetworkManager
    sudo systemctl enable NetworkManager
    
    # Enable Bluetooth
    sudo systemctl enable bluetooth
    
    # Enable CUPS (printing)
    sudo systemctl enable cups
    
    # Enable firewall
    sudo systemctl enable firewalld
    
    log_success "Services enabled"
}

configure_sddm() {
    print_substep "Configuring SDDM..."
    
    # Create SDDM config directory
    sudo mkdir -p /etc/sddm.conf.d
    
    # Configure SDDM to use Wayland
    sudo tee /etc/sddm.conf.d/maleo.conf > /dev/null <<EOF
[General]
DisplayServer=wayland

[Wayland]
SessionDir=/usr/share/wayland-sessions

[Theme]
Current=breeze
EOF
    
    log_success "SDDM configured"
}

create_maleo_commands() {
    print_substep "Creating Maleo utility commands..."
    
    local bin_dir="$HOME/.local/bin"
    mkdir -p "$bin_dir"
    
    # Create maleo-theme command
    cat > "$bin_dir/maleo-theme" <<'EOF'
#!/bin/bash
# Maleo theme switcher

MALEO_THEMES="$HOME/.local/share/maleo/themes"
CURRENT_THEME="$HOME/.config/maleo/current/theme"

case "$1" in
    list)
        echo "Available themes:"
        ls -1 "$MALEO_THEMES"
        ;;
    set)
        if [ -z "$2" ]; then
            echo "Usage: maleo-theme set <theme-name>"
            exit 1
        fi
        
        if [ ! -d "$MALEO_THEMES/$2" ]; then
            echo "Theme '$2' not found"
            exit 1
        fi
        
        ln -sf "$MALEO_THEMES/$2" "$CURRENT_THEME"
        echo "Theme set to: $2"
        echo "Please reload Hyprland (Super+Shift+R)"
        ;;
    *)
        echo "Usage: maleo-theme {list|set <theme-name>}"
        ;;
esac
EOF
    
    chmod +x "$bin_dir/maleo-theme"
    
    log_success "Maleo commands created"
}

setup_user_dirs() {
    print_substep "Setting up user directories..."
    
    # Ensure XDG user directories exist
    xdg-user-dirs-update
    
    log_success "User directories configured"
}

# Run post-installation tasks
enable_services
configure_sddm
create_maleo_commands
setup_user_dirs

log_success "Post-installation tasks completed"
