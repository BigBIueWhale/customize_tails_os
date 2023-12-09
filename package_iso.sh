#!/bin/bash

# Define paths
SCRIPT_DIR=$(dirname "$(realpath "$0")")
NEW_TAILS_DIR="$SCRIPT_DIR/build/customized_tails"
SQUASHFS_DIR="$SCRIPT_DIR/build/tails-squashfs"
ISO_OUTPUT_PATH="$SCRIPT_DIR/build/custom_tails.iso"

# Remove the old SquashFS filesystem file
sudo rm -f "$NEW_TAILS_DIR/live/filesystem.squashfs"

# Repack the SquashFS filesystem
sudo mksquashfs "$SQUASHFS_DIR" "$NEW_TAILS_DIR/live/filesystem.squashfs" -comp xz -e boot

# Generate the new ISO
sudo genisoimage -o "$ISO_OUTPUT_PATH" \
                 -r -J -no-emul-boot -boot-load-size 4 \
                 -boot-info-table -b isolinux/isolinux.bin \
                 -c isolinux/boot.cat \
                 -V "TAILS_CUSTOM" "$NEW_TAILS_DIR"

# Make the ISO bootable
sudo isohybrid "$ISO_OUTPUT_PATH"
