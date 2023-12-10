#!/bin/bash

# customize_tails.sh
# Allow OS to live-boot from internal SSD and disable unnecessary security overhead.

# Find and loop through all .cfg files in the ./tails-i386-1.3/ directory and its subdirectories
find ./build/customized_tails/ -type f -name '*.cfg' | while read file; do
    # Use sed to replace the specified text
    sed -i 's/config live-media=removable apparmor=1/config ive-media=removable apparmor=0/g' "$file"
done

# Define the path to the script and the target chroot directory
script_path="./customize_squashfs.sh"
chroot_directory="./build/tails-squashfs/"

# Check if the script exists at the specified path
if [ -f "$script_path" ]; then
    # Copy the script to the chroot directory
    cp "$script_path" "$chroot_directory"

    # Verify if the copy was successful
    if [ -f "${chroot_directory}customize_squashfs.sh" ]; then
        echo "Script successfully copied to the chroot directory."
    else
        echo "Failed to copy the script to the chroot directory."
    fi
else
    echo "Script not found at the specified path: $script_path"
fi

# Call the other batch file in a terminal in which you can modify that tails OS.
sudo chroot ./build/tails-squashfs/ ./customize_squashfs.sh
