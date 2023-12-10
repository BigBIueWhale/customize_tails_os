#!/bin/bash

# customize_tails.sh
# Allow OS to live-boot from internal SSD and disable unnecessary security overhead.

# Find and loop through all .cfg files in the ./tails-i386-1.3/ directory and its subdirectories
find ./build/customized_tails/ -type f -name '*.cfg' | while read file; do
    # Use sed to replace the specified text
    sed -i 's/config live-media=removable apparmor=1/config ive-media=removable apparmor=0/g' "$file"
done

# Call the other batch file in a terminal in which you can modify that tails OS.
sudo chroot ./build/tails-squashfs/ ./customize_squashfs.sh
