#!/bin/bash

# Define paths
SCRIPT_DIR=$(dirname "$(realpath "$0")")
ISO_PATH="$SCRIPT_DIR/tails-i386-1.3.iso"
MOUNT_DIR="$SCRIPT_DIR/build/tails-iso"
SQUASHFS_DIR="$SCRIPT_DIR/build/tails-squashfs"
NEW_TAILS_DIR="$SCRIPT_DIR/build/customized_tails"

# Create necessary directories
mkdir -p "$MOUNT_DIR" "$NEW_TAILS_DIR"

# Mount the ISO
sudo mount -o loop,ro "$ISO_PATH" "$MOUNT_DIR"

# Copy ISO contents
cp -r "$MOUNT_DIR/"* "$NEW_TAILS_DIR/"
cp -r "$MOUNT_DIR/.disk" "$NEW_TAILS_DIR/"

# Extract the SquashFS filesystem
sudo unsquashfs -d "$SQUASHFS_DIR" "$MOUNT_DIR/live/filesystem.squashfs"

# Cleanup
sudo umount "$MOUNT_DIR"
rm -r "$MOUNT_DIR"
