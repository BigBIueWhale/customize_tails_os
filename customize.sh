#!/bin/bash

# customize_tails.sh
# Allow OS to live-boot from internal SSD and disable unnecessary security overhead.

# Find and loop through all .cfg files in the ./tails-i386-1.3/ directory and its subdirectories
find ./build/customized_tails/ -type f -name '*.cfg' | while read file; do
    # Use sed to replace the specified text
    sed -i 's/config live-media=removable apparmor=1/config ive-media=removable apparmor=0/g' "$file"
done

# Define the path to the menu.cfg file
CONFIG_FILE=./build/customized_tails/isolinux/menu.cfg
# Check if the configuration file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found at $CONFIG_FILE"
    exit 1
fi
# Change the timeout setting to minimal (0 is infinite).
# Unit is 0.1 seconds.
sed -i 's/timeout [0-9]*/timeout 1/' "$CONFIG_FILE"
# Check if sed command was successful
if [ $? -eq 0 ]; then
    echo "Successfully updated the timeout setting in $CONFIG_FILE"
else
    echo "Failed to update the timeout setting in $CONFIG_FILE"
fi

# Define the path to the script and the target chroot directory
script_path="./customize_squashfs.sh"
downloaded_path="./packages/downloaded/"
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

# Copy the downloaded folder into chroot_directory
if [ -d "$downloaded_path" ]; then
    # Copy the directory recursively
    cp -r "$downloaded_path" "${chroot_directory}"

    # Verify if the copy was successful
    if [ -d "${chroot_directory}downloaded" ]; then
        echo "Downloaded folder successfully copied to the chroot directory."
    else
        echo "Failed to copy the downloaded folder to the chroot directory."
    fi
else
    echo "Downloaded folder not found at the specified path: $downloaded_path"
fi

# Call the other batch file in a terminal in which you can modify that tails OS.
sudo chroot ./build/tails-squashfs/ ./customize_squashfs.sh

# Check if the downloaded folder exists in the chroot directory
if [ -d "${chroot_directory}downloaded" ]; then
    # Delete the downloaded folder
    rm -rf "${chroot_directory}downloaded"

    # Verify if the folder has been successfully deleted
    if [ ! -d "${chroot_directory}downloaded" ]; then
        echo "Downloaded folder successfully deleted from the chroot directory."
    else
        echo "Failed to delete the downloaded folder from the chroot directory."
    fi
else
    echo "Downloaded folder not found in the chroot directory: ${chroot_directory}downloaded"
fi
