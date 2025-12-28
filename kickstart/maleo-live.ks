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
user --name=maleo --groups=wheel --plaintext --password=maleo --uid=1000

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
# Set a large fixed size to ensure livecd-creator allocates enough space for the build image
part / --fstype="ext4" --size=8192 --grow

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
# Omadora Packages
alacritty
bat
bind-utils
brightnessctl
btop
# cascadia-code-nf-fonts (use fedora standard if needed, or omit)
# cascadia-mono-nf-fonts
chromium
clang
dbus-tools
du-dust
evince
fastfetch
fcitx5
fcitx5-configtool
fcitx5-gtk
fcitx5-qt
fd-find
fontawesome-fonts-all
fzf
gnome-calculator
gnome-themes-extra
google-noto-fonts-common
gum
gvfs-mtp
gvfs-smb
hypridle
hyprland
# hyprland-qtutils (missing)
hyprlock
# hyprpicker
# hyprpolkitagent (missing)
hyprshot
# hyprsunset (missing)
imv
iputils
iwd
kvantum-qt5
mako

mpv
nautilus
neovim
network-manager-applet
pciutils
pipewire-devel
pipx
playerctl
plocate
plymouth
plymouth-plugin-*
power-profiles-daemon
ripgrep
rofi-wayland
satty
sddm
sddm-kcm
slurp
sushi
swaybg
tar
thunar
tldr
unzip
usbutils
# uwsm (missing)
waybar
wf-recorder
wget
whois
wl-clipboard
wofi
xdg-desktop-portal-gtk
xdg-desktop-portal-hyprland
xdg-user-dirs
xmlstarlet
yaru-icon-theme
zoxide

# Theme
sddm-kcm

%end

# Post-installation script
%post --log=/root/maleo-kickstart-post.log

# Create maleo user manually (kickstart user command doesn't work reliably for livecd)
echo "Creating maleo user..."
useradd -m -u 1000 -G wheel -s /bin/bash maleo
echo "maleo:maleo" | chpasswd

# Enable graphical login
systemctl set-default graphical.target
systemctl enable sddm

# Allow empty passwords for PAM
sed -i 's/nullok_secure/nullok/' /etc/pam.d/system-auth 2>/dev/null || true
sed -i 's/nullok_secure/nullok/' /etc/pam.d/password-auth 2>/dev/null || true

# Remove password for root (keep maleo with password for now)
passwd -d root

# Configure SDDM
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/autologin.conf << EOF
[Autologin]
User=maleo
Session=hyprland
EOF

cat > /etc/sddm.conf.d/users.conf << EOF
[Users]
MaximumUid=60000
MinimumUid=1000
HideShells=
RememberLastUser=false
EOF

# Grant passwordless sudo to wheel group
echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel-nopasswd
chmod 440 /etc/sudoers.d/wheel-nopasswd

%end

# Post-installation script (nochroot)
%post --nochroot

echo "Configuring Maleo..."
INSTALL_ROOT=$INSTALL_ROOT

# Copy configs from omadora (locally cloned)
if [ -d /maleo-os/omadora ]; then
    echo "Copying Omadora configs..."
    mkdir -p $INSTALL_ROOT/etc/skel/.config
    mkdir -p $INSTALL_ROOT/etc/skel/.local/share/maleo
    mkdir -p $INSTALL_ROOT/usr/local/bin

    # Copy configs
    cp -r /maleo-os/omadora/config/* $INSTALL_ROOT/etc/skel/.config/
    
    # Copy themes/assets if available (checking structure)
    if [ -d /maleo-os/omadora/themes ]; then
        cp -r /maleo-os/omadora/themes $INSTALL_ROOT/etc/skel/.local/share/maleo/
    fi

    # Copy binaries
    if [ -d /maleo-os/omadora/bin ]; then
        cp -r /maleo-os/omadora/bin/* $INSTALL_ROOT/usr/local/bin/
        chmod +x $INSTALL_ROOT/usr/local/bin/*
    fi
else
    echo "Warning: omadora not found in build context!"
fi

# Rebrand Omadora -> Maleo in all copied configs
find $INSTALL_ROOT/etc/skel/.config -type f -exec sed -i 's/Omadora/Maleo/g' {} +
find $INSTALL_ROOT/etc/skel/.config -type f -exec sed -i 's/omadora/maleo/g' {} +

# Fix hyprland.conf imports to point to ~/.config instead of ~/.local/share/omadora/default
# Omadora uses a complex include structure. We might need to simplify it or ensure defaults are copied.
# Checking omadora configs: it sources ~/.local/share/omadora/default/...
# We need to copy 'default' folder to ~/.local/share/maleo/default

if [ -d /maleo-os/omadora/default ]; then
    mkdir -p $INSTALL_ROOT/etc/skel/.local/share/maleo/default
    cp -r /maleo-os/omadora/default/* $INSTALL_ROOT/etc/skel/.local/share/maleo/default/
fi

# Fix paths in hyprland.conf
sed -i 's|~/.local/share/omadora|~/.local/share/maleo|g' $INSTALL_ROOT/etc/skel/.config/hypr/hyprland.conf || true

echo "Maleo configuration installed."

%end


