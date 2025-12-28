#!/bin/bash

ISO_FILE="output/maleo-${1}.iso"
IMG_FILE="/tmp/maleo.img"

if [ ! -f "$ISO_FILE" ]; then
    echo "Error: ISO file $ISO_FILE not found!"
    exit 1
fi

if [ ! -f "$IMG_FILE" ]; then
    echo "Creating $IMG_FILE..."
    qemu-img create -f qcow2 "$IMG_FILE" 10G
else
    echo "Using existing $IMG_FILE"
fi

# Check for KVM
if [ -w /dev/kvm ]; then
    echo "KVM is available and accessible."
    ACCEL="-enable-kvm -cpu host"
else
    echo "WARNING: /dev/kvm is not accessible. Using software emulation (slow)."
    ACCEL="-cpu qemu64"
fi

echo "Starting QEMU with ${ISO_FILE}..."
echo "Connect via VNC at localhost:5900 (or :0)"

qemu-system-x86_64 \
  $ACCEL \
  -smp 4 \
  -m 4G \
  -drive file="$IMG_FILE",format=qcow2 \
  -cdrom "$ISO_FILE" \
  -boot menu=on \
  -vnc 0.0.0.0:0 \
  -k en-us