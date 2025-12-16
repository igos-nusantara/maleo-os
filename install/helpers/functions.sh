#!/bin/bash

# Maleo - Helper Functions

print_step() {
    echo -e "\n${BLUE}==>${NC} $1"
}

print_substep() {
    echo -e "  ${GREEN}→${NC} $1"
}

ask_yes_no() {
    local question="$1"
    local default="${2:-n}"
    
    if [ "$default" = "y" ]; then
        prompt="[Y/n]"
    else
        prompt="[y/N]"
    fi
    
    read -p "$question $prompt " -n 1 -r
    echo
    
    if [ -z "$REPLY" ]; then
        REPLY="$default"
    fi
    
    [[ $REPLY =~ ^[Yy]$ ]]
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

package_installed() {
    rpm -q "$1" &>/dev/null
}

enable_copr() {
    local copr_repo="$1"
    log_info "Enabling COPR repository: $copr_repo"
    sudo dnf copr enable -y "$copr_repo"
}

backup_file() {
    local file="$1"
    if [ -f "$file" ]; then
        local backup="${file}.maleo-backup.$(date +%Y%m%d-%H%M%S)"
        log_info "Backing up $file to $backup"
        cp "$file" "$backup"
    fi
}

create_symlink() {
    local source="$1"
    local target="$2"
    
    # Backup existing file/symlink
    if [ -e "$target" ] || [ -L "$target" ]; then
        backup_file "$target"
        rm -rf "$target"
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"
    
    # Create symlink
    ln -sf "$source" "$target"
    log_success "Created symlink: $target -> $source"
}

install_from_url() {
    local url="$1"
    local output="$2"
    
    log_info "Downloading from $url"
    curl -fsSL "$url" -o "$output"
}
