# Maleo Fedora Remix - Installation Guide

## System Requirements

### Minimum Requirements
- **CPU**: 64-bit processor (x86_64)
- **RAM**: 4GB (8GB recommended)
- **Storage**: 20GB free disk space
- **Graphics**: GPU with Vulkan support (for Hyprland)
- **Display**: 1280x720 resolution minimum

### Recommended Requirements
- **CPU**: Modern multi-core processor
- **RAM**: 8GB or more
- **Storage**: 50GB+ SSD
- **Graphics**: Dedicated GPU with latest drivers
- **Display**: 1920x1080 or higher

## Installation Methods

### Method 1: ISO Installation (Recommended)

1. **Download ISO**
   - Get the latest ISO from [Releases](https://github.com/igos-nusantara/maleo-os/releases)
   - Verify checksum: `sha256sum -c maleo-*.iso.sha256`

2. **Create Bootable USB**
   
   **On Linux:**
   ```bash
   sudo dd if=maleo-*.iso of=/dev/sdX bs=4M status=progress
   sync
   ```
   
   **On Windows/macOS:**
   - Use [Fedora Media Writer](https://getfedora.org/en/workstation/download/)
   - Or use [Etcher](https://www.balena.io/etcher/)

3. **Boot from USB**
   - Insert USB drive
   - Restart computer
   - Enter BIOS/UEFI (usually F2, F12, Del, or Esc)
   - Select USB drive as boot device
   - Boot into Maleo installer

4. **Install Maleo**
   - Follow the graphical installer
   - Choose installation destination
   - Create user account
   - Wait for installation to complete
   - Reboot

5. **Post-Installation**
   - Log in to your new system
   - Run `maleo-install` to complete Hyprland setup
   - Reboot and select Hyprland from login screen

### Method 2: Install on Existing Fedora

If you already have Fedora 43+ installed:

1. **Clone Repository**
   ```bash
   git clone https://github.com/igos-nusantara/maleo-os.git
   cd maleo-os
   ```

2. **Run Installer**
   ```bash
   chmod +x install/install.sh
   ./install/install.sh
   ```

3. **Follow Prompts**
   - The installer will:
     - Update your system
     - Enable required repositories
     - Install Hyprland and dependencies
     - Install Nix (optional)
     - Deploy configurations
     - Configure SDDM

4. **Reboot**
   ```bash
   systemctl reboot
   ```

5. **Select Hyprland**
   - At login screen, select "Hyprland" session
   - Log in with your credentials

## First Boot

### Initial Setup

1. **Welcome Screen**
   - You'll see the Maleo welcome message
   - Waybar status bar at the top
   - Default Catppuccin theme

2. **Basic Navigation**
   - `Super + Return`: Open terminal
   - `Super + D`: Application launcher
   - `Super + Q`: Close window
   - `Super + 1-9`: Switch workspaces

3. **Configure Monitors**
   - Edit `~/.config/hypr/monitors.conf`
   - Reload Hyprland: `Super + Shift + R`

4. **Install Additional Software**
   
   **Via DNF:**
   ```bash
   sudo dnf install <package-name>
   ```
   
   **Via Flatpak:**
   ```bash
   flatpak install flathub <app-id>
   ```
   
   **Via Nix:**
   ```bash
   nix profile install nixpkgs#<package-name>
   ```

## Troubleshooting

### Hyprland Won't Start

1. Check logs:
   ```bash
   journalctl -xe
   cat ~/.hyprland.log
   ```

2. Verify GPU drivers:
   ```bash
   lspci -k | grep -A 3 -E "(VGA|3D)"
   ```

3. Try software rendering:
   ```bash
   WLR_RENDERER=pixman Hyprland
   ```

### No Audio

1. Check PipeWire status:
   ```bash
   systemctl --user status pipewire
   ```

2. Restart audio services:
   ```bash
   systemctl --user restart pipewire pipewire-pulse wireplumber
   ```

### Display Issues

1. Check monitor configuration:
   ```bash
   hyprctl monitors
   ```

2. Edit `~/.config/hypr/monitors.conf`

3. Reload configuration:
   ```bash
   hyprctl reload
   ```

## Getting Help

- **Documentation**: [docs/](../docs/)
- **GitHub Issues**: [Report a bug](https://github.com/igos-nusantara/maleo-os/issues)
- **Community**: Join our Discord/Matrix

## Next Steps

- [Configuration Guide](configuration.md)
- [Keybindings Reference](keybindings.md)
- [Customization Guide](customization.md)
