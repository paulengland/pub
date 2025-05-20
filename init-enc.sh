#!/bin/bash

# this script runs in a guest and sets up a virtual device as a luks encrypted disk and 
# mounts it on /datica


# --- Configuration ---
DEVICE="/dev/vdc"  # Replace with the actual device you want to encrypt
KEYFILE="/root/luks.key"   # Path to the keyfile
MNT_ROOT="/datica"
MNT_POINT="$MNT_ROOT/enc1"      # Mount point for the encrypted volume
MNT_POINT2="$MNT_ROOT/int2"      # Mount point for the encrypted volume
VOLUME_NAME="datica"     # Name of the LUKS volume

# --- Create Keyfile ---
echo "Creating keyfile: $KEYFILE"
dd if=/dev/urandom of="$KEYFILE" bs=4096 count=1 status=none
chmod 400 "$KEYFILE"  # Secure the keyfile

# --- Encrypt Device ---
echo "Encrypting device: $DEVICE"
cryptsetup luksFormat "$DEVICE" --key-file="$KEYFILE"  # Format and add keyfile

# --- Open LUKS Device ---
echo "Opening LUKS device: $DEVICE"
cryptsetup luksOpen "$DEVICE" "$VOLUME_NAME" --key-file="$KEYFILE" # Open using keyfile

# --- Format the volume ---
echo "Formatting the encrypted volume: /dev/mapper/$VOLUME_NAME"
mkfs.ext4 "/dev/mapper/$VOLUME_NAME"  # Format as ext4 (change as needed)

# --- Create Mount Point ---
echo "Creating encrypted mount point: $MNT_POINT"
mkdir -p "$MNT_POINT"  # Create the mount point directory

# --- Mount the Encrypted Volume ---
echo "Mounting encrypted volume to: $MNT_POINT"
mount "/dev/mapper/$VOLUME_NAME" "$MNT_POINT"  # Mount the decrypted volume
echo "LUKS encrypted volume successfully mounted on $MNT_POINT"

chmod 777 $MNT_POINT

# --- Mount the integrity protected volume (no dm-verity yet)
echo "Mounting measured volume to: $MNT_POINT2"
mkdir -p "$MNT_POINT2"  # Create the mount point directory
mount /dev/mapper/vdc "$MNT_POINT2"  # Mount the decrypted volume
echo "measured  encrypted volume successfully mounted on $MNT_POINT2scd"

