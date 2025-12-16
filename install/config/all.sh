#!/bin/bash

# Maleo - Configuration Deployment

print_step "Deploying configurations..."

deploy_hyprland_config() {
    print_substep "Deploying Hyprland configuration..."
    
    local hypr_config_dir="$HOME/.config/hypr"
    local maleo_hypr_config="$MALEO_PATH/config/hypr"
    
    # Backup existing config
    if [ -d "$hypr_config_dir" ]; then
        backup_file "$hypr_config_dir"
    fi
    
    # Create config directory
    mkdir -p "$hypr_config_dir"
    
    # Copy default configs
    cp -r "$maleo_hypr_config/"* "$hypr_config_dir/"
    
    log_success "Hyprland configuration deployed"
}

deploy_waybar_config() {
    print_substep "Deploying Waybar configuration..."
    
    local waybar_config_dir="$HOME/.config/waybar"
    local maleo_waybar_config="$MALEO_PATH/config/waybar"
    
    mkdir -p "$waybar_config_dir"
    cp -r "$maleo_waybar_config/"* "$waybar_config_dir/"
    
    log_success "Waybar configuration deployed"
}

deploy_mako_config() {
    print_substep "Deploying Mako configuration..."
    
    local mako_config_dir="$HOME/.config/mako"
    local maleo_mako_config="$MALEO_PATH/config/mako"
    
    mkdir -p "$mako_config_dir"
    cp -r "$maleo_mako_config/"* "$mako_config_dir/"
    
    log_success "Mako configuration deployed"
}

deploy_terminal_configs() {
    print_substep "Deploying terminal configurations..."
    
    # Alacritty
    if [ -d "$MALEO_PATH/config/alacritty" ]; then
        mkdir -p "$HOME/.config/alacritty"
        cp -r "$MALEO_PATH/config/alacritty/"* "$HOME/.config/alacritty/"
    fi
    
    # Kitty
    if [ -d "$MALEO_PATH/config/kitty" ]; then
        mkdir -p "$HOME/.config/kitty"
        cp -r "$MALEO_PATH/config/kitty/"* "$HOME/.config/kitty/"
    fi
    
    log_success "Terminal configurations deployed"
}

set_default_theme() {
    print_substep "Setting default theme..."
    
    local theme_dir="$HOME/.config/maleo"
    mkdir -p "$theme_dir/current"
    
    # Create symlink to default theme (Catppuccin)
    ln -sf "$MALEO_PATH/themes/catppuccin" "$theme_dir/current/theme"
    
    log_success "Default theme set to Catppuccin"
}

# Deploy all configurations
deploy_hyprland_config
deploy_waybar_config
deploy_mako_config
deploy_terminal_configs
set_default_theme

log_success "Configuration deployment completed"
