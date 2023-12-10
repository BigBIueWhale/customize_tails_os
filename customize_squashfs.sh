#!/bin/bash

# Don't run this file directly, run it inside of a chroot environment as if we're inside of Tails OS itself.
# If you want to install packages here, run the entire customization process inside of Tails OS itself
# because otherwise you'll be network-blocked.

# to disable GUI (but leave a tty terminal):
sudo apt-get purge xorg*
sudo apt-get purge gnome*
sudo apt-get autoremove
sudo apt-get clean

# Create the new user and set the password
useradd user
echo user:password | chpasswd

# Add the user to the sudoers file without requiring a password for sudo commands
echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

echo "User 'user' created and added to sudoers."
