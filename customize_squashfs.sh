#!/bin/bash

# Don't run this file directly, run it inside of a chroot environment as if we're inside of Tails OS itself.
# If you want to install packages here, run the entire customization process inside of Tails OS itself
# because otherwise you'll be network-blocked.

# Set DISABLE_GUI to 1 to disable GUI, or 0 to keep it enabled
DISABLE_GUI=0
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

echo Compiling user-provided executables from files_to_include_in_os
# Save the current working directory
original_dir=$(pwd)

# Change to the directory of program1
cd /files_to_include_in_os/program1
# Call the compile script
./compile.sh

# Change to the directory of program1
cd /files_to_include_in_os/program2
# Call the compile script
./compile.sh

# Those program1 and program2 are just examples, delete those lines.
# Compile your program(s) here

# Return to the original directory
cd "$original_dir"

# Add any .ko driver files compilation here
# so that the .ko file is compatible with the specific linux kernel
# version of this Tails OS.
# Then programmatically copy the resulting .ko file(s) into
# /files_to_include_in_os/driver_files

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
