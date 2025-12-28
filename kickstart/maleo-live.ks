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
repo --name=epel-10 --baseurl="https://dl.fedoraproject.org/pub/epel/10/Everything/x86_64/"

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

# Create basic Hyprland config for maleo user
mkdir -p /etc/skel/.config/hypr
mkdir -p /etc/skel/.config/waybar

# Waybar Config
cat > /etc/skel/.config/waybar/config << 'WAYBARCONF'
{
    "layer": "top",
    "position": "top",
    "height": 30,
    "modules-left": ["hyprland/workspaces"],
    "modules-center": ["clock"],
    "modules-right": ["network", "pulseaudio", "battery", "tray"],
    "tray": {
        "spacing": 10
    },
    "clock": {
        "format": "{:%H:%M}  ",
        "format-alt": "{:%A, %B %d, %Y}  "
    },
    "network": {
        "format-wifi": "{essid} ({signalStrength}%) ",
        "format-ethernet": "{ipaddr}/{cidr} ",
        "tooltip-format": "{ifname} via {gwaddr} ",
        "format-linked": "{ifname} (No IP) ",
        "format-disconnected": "Disconnected ⚠",
        "format-alt": "{ifname}: {ipaddr}/{cidr}"
    },
    "pulseaudio": {
        "format": "{volume}% {icon}",
        "format-muted": "",
        "format-icons": {
            "default": ["", ""]
        },
        "on-click": "pavucontrol"
    }
}
WAYBARCONF

# Waybar Style
cat > /etc/skel/.config/waybar/style.css << 'WAYBARSTYLE'
* {
    border: none;
    border-radius: 0;
    font-family: "Roboto", sans-serif;
    font-size: 13px;
    min-height: 0;
}

window#waybar {
    background: rgba(43, 48, 59, 0.5);
    border-bottom: 3px solid rgba(100, 114, 125, 0.5);
    color: #ffffff;
}

#workspaces button {
    padding: 0 5px;
    background-color: transparent;
    color: #ffffff;
}

#workspaces button:hover {
    background: rgba(0, 0, 0, 0.2);
}

#workspaces button.active {
    background-color: #64727D;
    border-bottom: 3px solid #ffffff;
}

#clock,
#battery,
#cpu,
#memory,
#disk,
#network,
#pulseaudio,
#tray {
    padding: 0 10px;
    color: #ffffff;
}

#clock {
    background-color: #64727D;
}
WAYBARSTYLE
cat > /etc/skel/.config/hypr/hyprland.conf << 'HYPREOF'
# Maleo Basic Hyprland Config
monitor=,preferred,auto,1

exec-once = waybar
exec-once = mako
exec-once = nm-applet --indicator

input {
    kb_layout = us
    follow_mouse = 1
}

general {
    gaps_in = 5
    gaps_out = 10
    border_size = 2
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)
    layout = dwindle
}

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

animations {
    enabled = yes
    bezier = myBezier, 0.05, 0.9, 0.1, 1.05
    animation = windows, 1, 7, myBezier
    animation = windowsOut, 1, 7, default, popin 80%
    animation = border, 1, 10, default
    animation = fade, 1, 7, default
    animation = workspaces, 1, 6, default
}

$mainMod = SUPER
bind = $mainMod, Q, exec, kitty
bind = $mainMod, M, exit,
bind = $mainMod, E, exec, thunar
bind = $mainMod, V, togglefloating,
bind = $mainMod, R, exec, rofi -show drun

bind = $mainMod, left, movefocus, l
bind = $mainMod, right, movefocus, r
bind = $mainMod, up, movefocus, u
bind = $mainMod, down, movefocus, d

bind = $mainMod, 1, workspace, 1
bind = $mainMod, 2, workspace, 2
bind = $mainMod, 3, workspace, 3
bind = $mainMod, 4, workspace, 4
bind = $mainMod, 5, workspace, 5
bind = $mainMod, 6, workspace, 6
bind = $mainMod, 7, workspace, 7
bind = $mainMod, 8, workspace, 8
bind = $mainMod, 9, workspace, 9
bind = $mainMod, 0, workspace, 10

bind = $mainMod SHIFT, 1, movetoworkspace, 1
bind = $mainMod SHIFT, 2, movetoworkspace, 2
bind = $mainMod SHIFT, 3, movetoworkspace, 3
bind = $mainMod SHIFT, 4, movetoworkspace, 4
bind = $mainMod SHIFT, 5, movetoworkspace, 5
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow
HYPREOF

%end

# Post-installation script (nochroot)



