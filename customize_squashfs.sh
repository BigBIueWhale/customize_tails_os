#!/bin/bash

# Don't run this file directly, run it inside of a chroot environment as if we're inside of Tails OS itself.
# If you want to install packages here, run the entire customization process inside of Tails OS itself
# because otherwise you'll be network-blocked.

# Set DISABLE_GUI to 1 to disable GUI, or 0 to keep it enabled
DISABLE_GUI=1
if [ "$DISABLE_GUI" -eq 1 ]; then
    # to disable GUI (but leave a tty terminal):
    sudo apt-get purge xorg* -y
    sudo apt-get purge gnome* -y
    sudo apt-get purge metacity -y
    sudo apt-get purge gcr -y
    sudo apt-get purge mutter -y
    
    # Remove remove all packages with the string "nautilus" in their name,
    # This also removes packages such as seahorse-nautilus
    dpkg -l | grep nautilus | awk '{print $2}' | xargs sudo apt-get purge -y

    # Only create a default root user if GUI is disabled
    # because this interferes with the welcome screen of the GUI.

    # Create the new user and set the password
    useradd user
    echo user:password | chpasswd

    # Add the user to the sudoers file without requiring a password for sudo commands
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

    echo "User 'user' created and added to sudoers."
fi

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

# Define the applications to remove
APPS_TO_REMOVE=(
  "torbrowser-launcher"
  "icedove"            # Icedove may now be known as Thunderbird in newer versions.
  "pidgin"             # Assuming pidgin is the package name.
  "keepassx"           # KeePassX package name.
  "audacity"
  "bookletimposer"
  "brasero"
  "dasher"
  "evince"
  "electrum"
  "evolution"
  "florence"
  "gedit"
  "gimp"
  "gobby"
  "torsocks"
  "gtkhash"
  "yelp"
  "ibus-anthy"
  "ibus-pinyin"
  "ibus-hangul"
  "eog"
  "inkscape"
  "libreoffice"
  "liferea"
  "mat"
  "onioncircuits"
  "seahorse"
  "pitivi"
  "poedit"
  "gksu"
  "scribus"
  "simple-scan"
  "sound-juicer"
  "synaptic"
  "tails-installer"
  "traverso"
  "totem"
  "vim"
  "whisperback"
  "libreoffice*"
  "myspell*"
  "uno-libs3"
  "ure"
)

# Remove the applications
for app in "${APPS_TO_REMOVE[@]}"; do
  echo "Removing bloatware $app ..."
  sudo apt-get remove --purge -y $app
done

sudo apt-get autoremove -y
sudo apt-get clean

# Remove Tor Browser directory since it can't be uninstalled via apt.
echo "Removing Tor Browser directory..."
sudo rm -rf /usr/local/lib/tor-browser

echo "Removing Tails documentation"
sudo rm -rf /usr/share/doc

# Define the shortcuts to remove
SHORTCUTS_TO_REMOVE=(
  "unsafe-browser.desktop"
  "tor-browser.desktop"
)

# Remove the shortcuts
for shortcut in "${SHORTCUTS_TO_REMOVE[@]}"; do
  echo "Removing shortcut $shortcut ..."
  sudo rm -f /usr/share/applications/$shortcut
done

echo "Shortcuts removed."


# Installing the kernel headers for Tails OS is not enough to
# be able to build drivers because Tails OS package repository
# contains kernel headers with a name different than uname -r.
# After installing the kernel header deb file, this folder
# is created: /lib/modules/4.9.0-0.bpo.2-686/
# Since drivers' Makefiles tend to rely on:
# /lib/modules/$(shell uname -r)/build
# they won't be able to find the build folder, so
# we need to copy the build folder into 
# uname -r, which is a different name.
# For example on tails-i386-2.12, the command: "uname -r" returns:
# 6.5.6-76060506-generic which is different than the deb file name.
existing_uname_path="/lib/modules/$(uname -r)/"
# According to the name of the file: packages/downloaded/linux-headers-4.9.0-0.bpo.2-686_4.9.13-1~bpo8+1_i386.deb
# Change this if you're using a different version of Tails OS
ability_to_build_drivers="/lib/modules/4.9.0-0.bpo.2-686/"
echo "Adding ability to build drivers by using ${ability_to_build_drivers} that we installed from the deb file to fill missing in ${existing_uname_path} which comes with Tails."
# Copy all folders / files in "${ability_to_build_drivers}" into "${existing_uname_path}"
# in addition to what already exists in "${existing_uname_path}", and prefer "${existing_uname_path}"
# upon conflict.
sudo cp -nr "${ability_to_build_drivers}." "${existing_uname_path}"

# After installing the kernel headers, at runtime "uname -r" will print
# 4.9.0-0.bpo.2-amd64 unless we remove these files.
# Essentially, we're avoiding changing the uname.
sudo rm /boot/config-*

echo Compiling user-provided executables from files_to_include_in_os
# Save the current working directory
original_dir=$(pwd)

cd /files_to_include_in_os/program1
./compile.sh

cd /files_to_include_in_os/program2
./compile.sh

# The program1 and program2 are just examples, delete those lines.
# Compile your program(s) here

cd /files_to_include_in_os/driver1
make
cp ./driver1.ko /files_to_include_in_os/driver_files/
make clean

cd /files_to_include_in_os/driver2
make
cp ./driver2.ko /files_to_include_in_os/driver_files/
make clean

# The driver1 and driver2 are just examples, delete those lines.
# Add any .ko driver files compilation here
# so that the .ko file is compatible with the specific linux kernel
# version of this Tails OS.
# Then programmatically copy the resulting .ko file(s) into
# /files_to_include_in_os/driver_files

# Return to the original directory
cd "$original_dir"

# Insert the command to execute run_at_boot.sh before the 'exit 0' line in /etc/rc.local
sed -i '/^exit 0/i /files_to_include_in_os/run_at_boot.sh' /etc/rc.local

# Make sure /etc/rc.local is executable
chmod +x /etc/rc.local


# Create the directory for extra modules if it doesn't exist
mkdir -p /lib/modules/$(uname -r)/extra

# Copy the .ko files from the driver_files folder to the extra modules directory
cp /files_to_include_in_os/driver_files/*.ko /lib/modules/$(uname -r)/extra/

# Run depmod to rebuild the module dependencies
depmod
