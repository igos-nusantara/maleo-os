#!/bin/bash

# Maleo - Preflight Checks

print_step "Running preflight checks..."

# Check disk space
check_disk_space() {
    local required_gb=20
    local available_gb=$(df -BG / | awk 'NR==2 {print $4}' | sed 's/G//')
    
    print_substep "Checking disk space..."
    if [ "$available_gb" -lt "$required_gb" ]; then
        log_error "Insufficient disk space! Required: ${required_gb}GB, Available: ${available_gb}GB"
        exit 1
    fi
    log_success "Disk space OK (${available_gb}GB available)"
}

# Check if running in VM
check_vm() {
    print_substep "Checking if running in VM..."
    if systemd-detect-virt -q; then
        VM_TYPE=$(systemd-detect-virt)
        log_warning "Running in virtual machine: $VM_TYPE"
        log_info "Some features may not work optimally in VMs"
    fi
}

# Update system
update_system() {
    print_substep "Updating system packages..."
    sudo dnf upgrade -y --refresh
    log_success "System updated"
}

check_disk_space
check_vm
update_system

log_success "Preflight checks completed"
