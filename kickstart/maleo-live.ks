# Maleo Fedora Remix - Base Kickstart Configuration
# Based on Fedora 43

# System language
lang en_US.UTF-8

# Keyboard layouts
keyboard --vckeymap=us --xlayouts='us'

# System timezone
timezone America/New_York --utc

# Root password (will be disabled, use sudo)
rootpw --lock

# User creation (will be done by installer)
# user --name=maleo --password=maleo --groups=wheel

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

# Wayland and Hyprland will be installed post-install
# as they require COPR repositories

%end

# Post-installation script
%post --log=/root/maleo-kickstart-post.log

# Create maleo directory
mkdir -p /usr/share/maleo

# Download Maleo installer
cd /tmp
git clone https://github.com/igos-nusantara/maleo-os.git
cp -r maleo-os/* /usr/share/maleo/

# Create first-run script
cat > /etc/profile.d/maleo-first-run.sh << 'EOF'
if [ ! -f "$HOME/.maleo-installed" ]; then
    echo "Welcome to Maleo Fedora Remix!"
    echo "Run 'maleo-install' to complete the installation."
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
