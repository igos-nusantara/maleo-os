# Maleo Fedora Remix

![Maleo Logo](branding/logo.svg)

**Maleo** adalah Fedora Remix yang menggabungkan konfigurasi desktop Omarchy (Hyprland-based) dengan Nix package manager untuk memberikan pengalaman development yang modern, indah, dan fleksibel.

## 🎯 Fitur Utama

- **Hyprland Desktop Environment** - Modern tiling window manager berbasis Wayland
- **Omarchy-Inspired Configuration** - Konfigurasi desktop yang indah dan produktif
- **Nix Package Manager** - Fleksibilitas package management dengan Nix
- **Multiple Themes** - Catppuccin, Nord, Gruvbox, Tokyo Night, dan lainnya
- **Developer-Focused** - Pre-configured tools untuk development

## 📦 Apa yang Termasuk?

### Desktop Environment
- Hyprland - Tiling window manager
- Waybar - Status bar
- Mako - Notification daemon
- SDDM - Display manager
- Rofi/Walker - Application launcher

### Development Tools
- Neovim - Text editor
- Git - Version control
- Docker/Podman - Containerization
- Mise - Runtime version manager
- Lazygit/Lazydocker - TUI tools

### Applications
- Chromium/Firefox - Web browser
- Alacritty/Kitty - Terminal emulator
- Nautilus - File manager
- LibreOffice - Office suite
- MPV - Media player

## 🚀 Installation

### Option 1: ISO Installation

1. Download ISO dari [Releases](https://github.com/yourusername/maleo-fedora-remix/releases)
2. Burn ke USB menggunakan Fedora Media Writer atau `dd`
3. Boot dari USB dan ikuti installer

### Option 2: Install on Existing Fedora

```bash
# Clone repository
git clone https://github.com/yourusername/maleo-fedora-remix.git
cd maleo-fedora-remix

# Run installer
chmod +x install/install.sh
./install/install.sh
```

## 🎨 Themes

Maleo hadir dengan beberapa theme pre-installed:
- **Catppuccin** (default)
- Nord
- Gruvbox
- Tokyo Night
- Everforest
- Rose Pine

Ganti theme dengan:
```bash
maleo-theme set catppuccin
```

## 🔧 Configuration

Konfigurasi utama berada di:
- `~/.config/hypr/` - Hyprland configuration
- `~/.config/waybar/` - Waybar configuration
- `~/.config/mako/` - Notification configuration
- `~/.local/share/maleo/` - Maleo defaults

## 📚 Documentation

- [Installation Guide](docs/installation.md)
- [Configuration Guide](docs/configuration.md)
- [Keybindings](docs/keybindings.md)
- [Troubleshooting](docs/troubleshooting.md)

## 🛠️ Building from Source

Requirements:
- Fedora 43 or newer
- `livecd-tools` package
- At least 20GB free disk space

```bash
# Install build dependencies
sudo dnf install livecd-tools spin-kickstarts

# Build ISO
cd build
sudo ./build-iso.sh
```

## 🤝 Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## 📄 License

Maleo Fedora Remix is released under the MIT License. See [LICENSE](LICENSE) for details.

## 🙏 Credits

- **Omarchy** - Original configuration and inspiration by DHH
- **Fedora Project** - Base distribution
- **Hyprland** - Window manager
- **Nix** - Package manager

## ⚠️ Disclaimer

Maleo is a Fedora Remix and is not officially affiliated with or endorsed by the Fedora Project. Fedora and the Fedora logo are trademarks of Red Hat, Inc.
