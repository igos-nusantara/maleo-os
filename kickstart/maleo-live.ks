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

# Create basic Hyprland config for all users
mkdir -p /etc/skel/.config/hypr
cat > /etc/skel/.config/hypr/hyprland.conf << 'HYPREOF'
# Maleo Hyprland Configuration
exec-once = waybar
exec-once = mako

# Monitor configuration
monitor=,preferred,auto,1

# Input configuration
input {
    kb_layout = us
    follow_mouse = 1
}

# General settings
general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

# Decoration
decoration {
    rounding = 10
    blur {
        enabled = true
        size = 3
        passes = 1
    }
    drop_shadow = yes
    shadow_range = 4
    shadow_render_power = 3
}

# Animations
animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

# Keybindings
$mainMod = SUPER
bind = $mainMod, RETURN, exec, kitty
bind = $mainMod, Q, killactive,
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, D, exec, rofi -show drun

# Move focus
bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

# Switch workspaces
bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5

# Move window to workspace
bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
HYPREOF

# Copy install scripts to system (they're already in the build context)
# Note: The install/ directory from the repo is available during build
mkdir -p /usr/share/maleo
if [ -d /maleo-os/install ]; then
    cp -r /maleo-os/install /usr/share/maleo/
    cp -r /maleo-os/config /usr/share/maleo/ 2>/dev/null || true
    cp -r /maleo-os/themes /usr/share/maleo/ 2>/dev/null || true
fi

# Create maleo-install command for post-boot configuration
cat > /usr/local/bin/maleo-install << 'INSTALLEOF'
#!/bin/bash

# Check if install scripts exist
if [ ! -d /usr/share/maleo/install ]; then
    echo "Error: Maleo install scripts not found!"
    echo "Please clone the repository: git clone https://github.com/igos-nusantara/maleo-os.git"
    exit 1
fi

# Copy to user directory
mkdir -p ~/.local/share/maleo
cp -r /usr/share/maleo/* ~/.local/share/maleo/

# Run installer
cd ~/.local/share/maleo
if [ -f install/install.sh ]; then
    ./install/install.sh
    touch ~/.maleo-installed
else
    echo "Error: install.sh not found!"
    exit 1
fi
INSTALLEOF

chmod +x /usr/local/bin/maleo-install

# Create welcome message
cat > /etc/profile.d/maleo-welcome.sh << 'WELCOMEEOF'
if [ ! -f "$HOME/.maleo-installed" ] && [ -n "$PS1" ]; then
    echo ""
    echo "Welcome to MaleoOS!"
    echo "To install additional configurations, run: maleo-install"
    echo ""
fi
WELCOMEEOF

%end
