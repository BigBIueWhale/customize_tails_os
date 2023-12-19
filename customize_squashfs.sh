#!/bin/bash

# Don't run this file directly, run it inside of a chroot environment as if we're inside of Tails OS itself.
# If you want to install packages here, run the entire customization process inside of Tails OS itself
# because otherwise you'll be network-blocked.

# to disable GUI (but leave a tty terminal):
sudo apt-get purge xorg* -y
sudo apt-get purge gnome* -y

# Check if the downloaded directory exists and contains .deb files
downloaded_path="/downloaded"
deb_files=$(find "$downloaded_path" -maxdepth 1 -type f -name "*.deb")

if [ -d "$downloaded_path" ] && [ -n "$deb_files" ]; then
    # Install .deb packages
    sudo dpkg -i /downloaded/*.deb
    echo "Debian packages installed successfully."
else
    if [ ! -d "$downloaded_path" ]; then
        echo "Error: Downloaded directory not found."
    elif [ -z "$deb_files" ]; then
        echo "Error: No .deb files found in the downloaded directory."
    fi
fi

sudo apt-get autoremove -y
sudo apt-get clean

# Create the new user and set the password
useradd user
echo user:password | chpasswd

# Add the user to the sudoers file without requiring a password for sudo commands
echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

echo "User 'user' created and added to sudoers."
