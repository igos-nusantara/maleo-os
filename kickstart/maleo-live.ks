# Maleo Fedora Remix - Base Kickstart Configuration
# Based on Fedora 43

# System language
lang en_US.UTF-8

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System timezone
timezone America/New_York --utc

# Root password (temporary, cleared in %post)
rootpw --plaintext maleo

# User creation
user --name=maleo --groups=wheel --plaintext --password=maleo

# System authorization
authselect select sssd

# SELinux configuration (permissive for Nix compatibility)
selinux --permissive

# Firewall configuration
firewall --enabled --service=mdns

# Network information
# network --bootproto=dhcp --device=link --activate
# network --hostname=maleo

# Use network installation
url --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-43&arch=x86_64"

# Repositories
repo --name=fedora --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=fedora-43&arch=x86_64"
repo --name=updates --mirrorlist="https://mirrors.fedoraproject.org/mirrorlist?repo=updates-released-f43&arch=x86_64"
# repo --name=rpmfusion-free --metalink="https://mirrors.rpmfusion.org/metalink?repo=free-fedora-43&arch=x86_64"
# repo --name=rpmfusion-nonfree --metalink="https://mirrors.rpmfusion.org/metalink?repo=nonfree-fedora-43&arch=x86_64"
repo --name=rpmfusion-free --baseurl="http://mirror.web-ster.com/rpmfusion/free/fedora/releases/43/Everything/x86_64/os/"
repo --name=rpmfusion-nonfree --baseurl="http://mirror.web-ster.com/rpmfusion/nonfree/fedora/releases/43/Everything/x86_64/os/"
repo --name=solopasha-hyprland --baseurl="https://download.copr.fedorainfracloud.org/results/solopasha/hyprland/fedora-43-x86_64/"

# System bootloader configuration
bootloader --location=mbr --boot-drive=sda --timeout=5 --append="rhgb quiet"

# Clear the Master Boot Record
zerombr

# Partition clearing information
clearpart --all --initlabel

# Disk partitioning (BTRFS with subvolumes)
part /boot/efi --fstype="efi" --size=512 --fsoptions="umask=0077,shortname=winnt"
part /boot --fstype="ext4" --size=1024
part btrfs.01 --fstype="btrfs" --grow --size=1
btrfs none --label=fedora --data=single btrfs.01
btrfs / --subvol --name=root LABEL=fedora
btrfs /home --subvol --name=home LABEL=fedora

# Reboot after installation
reboot

# Package selection
%packages
@^custom-environment
@base-x
# Bootloader and Kernel
kernel
kernel-modules
kernel-modules-extra
grub2
grub2-efi
shim
syslinux
dracut-live
@fonts
@hardware-support
@multimedia
@networkmanager-submodules

# Remove unnecessary packages
-@gnome-desktop
-@kde-desktop

# System utilities
bash-completion
vim
nano
wget
curl
git
htop
btop

# Desktop Environment
sddm
hyprland
waybar
mako
rofi-wayland
kitty
lxpolkit
xdg-desktop-portal-hyprland
thunar
network-manager-applet
blueman

# Theme
sddm-kcm

%end

# Post-installation script
%post --log=/root/maleo-kickstart-post.log

# Enable graphical login
systemctl set-default graphical.target
systemctl enable sddm

# Allow empty passwords
sed -i 's/nullok_secure/nullok/' /etc/pam.d/system-auth
sed -i 's/nullok_secure/nullok/' /etc/pam.d/password-auth

# Remove passwords for root and maleo
passwd -d root
passwd -d maleo

# Configure SDDM autologin (optional, but good for Live)
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/autologin.conf << EOF
[Autologin]
User=maleo
Session=hyprland
EOF

# Create maleo directory
mkdir -p /usr/share/maleo

# Download Maleo installer
cd /tmp
git clone https://github.com/igos-nusantara/maleo-os.git
cp -r maleo-os/* /usr/share/maleo/

# Pre-configure 'maleo' user
echo "Configuring maleo user..."
MALEO_HOME="/home/maleo"
MALEO_SHARE="$MALEO_HOME/.local/share/maleo"
MALEO_CONFIG="$MALEO_HOME/.config"

# Create directories
mkdir -p "$MALEO_SHARE"
mkdir -p "$MALEO_CONFIG"

# Copy Maleo files
cp -r /usr/share/maleo/* "$MALEO_SHARE/"

# Deploy configs
cp -r "$MALEO_SHARE/config/"* "$MALEO_CONFIG/"

# Set default theme (Catppuccin)
mkdir -p "$MALEO_CONFIG/maleo/current"
ln -sf "$MALEO_SHARE/themes/catppuccin" "$MALEO_CONFIG/maleo/current/theme"

# Fix permissions
chown -R maleo:maleo "$MALEO_HOME"

# Create first-run script (updated to reflect pre-install)
cat > /etc/profile.d/maleo-first-run.sh << 'EOF'
if [ ! -f "$HOME/.maleo-installed" ]; then
    echo "Welcome to Maleo Fedora Remix!"
    touch "$HOME/.maleo-installed"
fi
EOF

# Create maleo-install command
cat > /usr/local/bin/maleo-install << 'EOF'
#!/bin/bash
cp -r /usr/share/maleo ~/.local/share/maleo
cd ~/.local/share/maleo
./install/install.sh
touch ~/.maleo-installed
EOF

chmod +x /usr/local/bin/maleo-install

%end
