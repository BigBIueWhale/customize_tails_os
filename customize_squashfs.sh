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


cd /lib/modules

# Find directories ending with -686 (use amd64 if your iso is 64-bit)
matching_dirs=($(find . -maxdepth 1 -type d -name "*-686"))

# Count the matching directories
dir_count=${#matching_dirs[@]}

# Check if there's more than one matching directory
if [ "$dir_count" -gt 1 ]; then
    echo "Error: More than one match found."
    exit 1
elif [ "$dir_count" -eq 0 ]; then
    echo "Error: No match found."
    exit 1
fi

# Store the path in a variable
kernel_dir_path="/lib/modules/${matching_dirs[0]#./}"

echo Equivalent of "/lib/modules/\$(shell uname -r)" found: $kernel_dir_path

kernel_name=$(basename "$kernel_dir_path")

echo Compiling user-provided executables from files_to_include_in_os
# Save the current working directory
original_dir=$(pwd)

cd /files_to_include_in_os/program1
./compile.sh

cd /files_to_include_in_os/program2
./compile.sh

# The program1 and program2 are just examples, delete those lines.
# Compile your program(s) here


echo Compiling drivers against kernel $kernel_name

cd /files_to_include_in_os/driver1
make KERNEL_NAME=$kernel_name
cp ./driver1.ko /files_to_include_in_os/driver_files/
make KERNEL_NAME=$kernel_name clean

cd /files_to_include_in_os/driver2
make KERNEL_NAME=$kernel_name
cp ./driver2.ko /files_to_include_in_os/driver_files/
make KERNEL_NAME=$kernel_name clean

# The driver1 and driver2 are just examples, delete those lines.
# Add any .ko driver files compilation here
# so that the .ko file is compatible with the specific linux kernel
# version of this Tails OS.
# Note that the Makefile for your driver shouldn't use "uname -r"
# because that will report the kernel name of the Pop!_OS host.
# That's why we explicitly use $kernel_name.
# Then programmatically copy the resulting .ko file(s) into
# /files_to_include_in_os/driver_files

# Return to the original directory
cd "$original_dir"

# Insert the command to execute run_at_boot.sh before the 'exit 0' line in /etc/rc.local
sed -i '/^exit 0/i /files_to_include_in_os/run_at_boot.sh' /etc/rc.local

# Make sure /etc/rc.local is executable
sudo chmod +x /etc/rc.local


extra_kernel_modules_dir="${kernel_dir_path}/extra/"

echo Create kernel modules dir: $extra_kernel_modules_dir
# Create the directory for extra modules if it doesn't exist
sudo mkdir -p $extra_kernel_modules_dir

echo Copy ko files to $extra_kernel_modules_dir
# Copy the .ko files from the driver_files folder to the extra modules directory
sudo cp /files_to_include_in_os/driver_files/*.ko $extra_kernel_modules_dir

echo depmod with kernel name: $kernel_name
# Run depmod to rebuild the module dependencies
sudo depmod $kernel_name

# Collect and add custom kernel module names to /etc/modules
echo "Adding custom kernel modules to /etc/modules so that all of the .ko files are loaded on boot"

# Directory where compiled kernel modules are stored
compiled_modules_dir="/files_to_include_in_os/driver_files/"

# Find all .ko files and extract module names
for ko_file in "$compiled_modules_dir"*.ko; do
    if [ -e "$ko_file" ]; then
        module_name=$(basename "$ko_file" .ko)
        echo "$module_name" >> /etc/modules
        echo "Added module $module_name to /etc/modules."
    fi
done

echo "Custom kernel module names added to /etc/modules."
