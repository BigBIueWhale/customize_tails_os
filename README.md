# Customize Tails OS

## Overview
This project aims to create a customized version of the Tails OS, known for its strong emphasis on security and privacy. Our version, however, shifts focus from security to functionality and reliability. The primary objective is to develop a Tails OS variant without a GUI that runs a single program- an app-container-os.

The essence of this project lies in leveraging Tails OS's unique feature of not storing data on the disk. This property is exploited to embed custom software into the Tails bootable medium, akin to a hardware-embedded Docker container. The result is a highly reliable system where, upon physical restart, the software functions as if it's running for the first time.

This kind of OS is watchdog-friendly. It can be killed at any moment with minimal risk of corruption, which allows for high reliability.

## Implemented Customizations
- **Boot from Internal SSD/HDD**: Modifications to allow the OS to live-boot from internal storage devices.
- **Disabled Security Overheads**: Certain security features have been disabled to prioritize functionality for specific use cases.
- **Add default root user**: Username: "user", password: "password".
- **No GUI- only tty terminal**: Stripped-down version of Tails OS without a graphical user interface.
- **Disable startup delay**: Make the OS-app-container recover faster from a watchdog reset.
- **Include build-essential**: And any additional .deb files that are placed into /packages/downloaded folder. By default, Tails OS doesn't come with make, gcc etc. With the customization you get GCC 4.9.2 and GNU Make 4.0
- **Run program at boot- Planned**: Runs a custom program at boot, designed for specific operational requirements.
- **Custom driver- Planned**: Load a .ko file permanently and by default into the OS
- **Remove bloatware- Planned**: Remove some installed-by-default software such as libre office

## Usage Instructions
1. **System Requirements**:
   - Tested on Pop!OS 22.04 as of 10 December 2023.
   - Ensure `tails-i386-2.12.iso` is downloaded and placed in the root directory of the project.
   - Tested on the last version of 32-bit Tails (from 2017) [tails-i386-2.12](https://iso-history.tails.boum.org/tails-i386-2.12/) with SHA256: 4228d1f88b999a6dee4c4bebd95e983e852cad59ad834eed72f8897ac278f5c4.

2. **Installation of Dependencies**:
   - Run `sudo ./install_dependencies.sh` to install necessary tools for handling ISO files.

3. **Execution**:
   - Execute `sudo ./run_as_sudo.sh` to start the customization process.
   - The script sequentially runs `clean.sh`, `extract_iso.sh`, `customize.sh`, and `package_iso.sh`.

4. **Input and Output**:
   - **Input**: The script expects `tails-i386-2.12.iso` in the project's root directory.
   - **Output**: The customized Tails OS ISO is output as `custom_tails.iso` in the `./build/` directory.

## Customize

### Overview of Customization Folders
This project provides two primary folders for customization, each serving a distinct purpose in the customization process of Tails OS:

1. **customized_tails**: This folder is a direct copy of the original Tails ISO's file structure. It is the primary location where the bootable file structure of the Tails OS resides. Customizations in this folder directly impact the boot process and the basic setup of the OS.

2. **tails-squashfs**: This folder contains the SquashFS filesystem, extracted from the original Tails ISO. SquashFS is a compressed, read-only filesystem used in Tails OS. Modifications in this folder are more in-depth and relate to the OS's core functionalities and structure. Use `sudo chroot ./build/tails-squashfs/` to enter a terminal where you can remove specific packages that you don't want (using `sudo apt-get remove`).

3. **packages/downloaded**: Delete packages/downloaded and then do `cd packages`. Run `python3 update_package_list.py` and then `python3 download_recursive_deps.py build-essential gcc make perl add any additional required packages here` assuming you're using `Python 3.10.12` on Pop!OS 22.04. By default the repo comes with build-essential and its dependencies for `tails-i386-2.12.iso`. If you're using a different OS or a different version, you'll have to customize `update_package_list.py`.

4. **run_at_boot.sh**: Planned- will allow you to perform actions at boot time

5. **driver_files/*.ko**: Planned- Any kernel module files in the folder will be placed into the OS. You will have to compile your kernel module from within `sudo chroot ./build/tails-squashfs/` after build-essential has already been installed.

6. **files_to_include_in_os**: Planned- The contents of this folder will be placed in the root directory of the tails-squashfs. For example: you can put an executable file here, and have run_at_boot.sh call: "/my_executable" at startup.

### Customization Process
To ensure a streamlined and consistent customization process, Modifications ti the ISO file structure (and bootloader) should be made to the `customize.sh` script. Modifications to the Tails filesystem (packages, users, files) should be done through `customize_squashfs.sh` which runs as if we're in the OS itself (because of `chroot` command in customize.sh).

### Customization in Practice

#### Customizing `customized_tails`
- **Purpose**: Modifying files in this folder affects the bootable environment and initial settings of the OS.
- **Practical Application**: You can add or modify configuration files, scripts, or other elements that are needed during the boot process or for initial system setup.

#### Customizing `tails-squashfs`
- **Purpose**: Changes here are more profound, impacting the operating system's inner workings.
- **Practical Application**: Ideal for adding or modifying system applications, libraries, or other deep-rooted components of the OS.

### Permissions and Considerations

1. **Required Permissions**:
   - To modify contents in both folders, you will need `root` privileges, as many of the files within these directories are system files with restricted access.

2. **Safety and Stability**:
   - Ensure that changes made, especially in the `tails-squashfs` directory, do not destabilize the system. Since these modifications are deeper, they can significantly impact the OS's stability and functionality.

By understanding and carefully managing these two key folders, users can effectively tailor the Tails OS to meet specific requirements, whether for personal use, development, or specialized applications.

## Disclaimer
This project is not concerned with the inherent security features of Tails OS. It focuses on the non-persistent storage aspect to ensure the embedded software's reliability and consistency. This customization may compromise the security measures typical of Tails OS, and thus, is not recommended for users seeking a security-focused solution.

## Contributing
Fork it and do your own thing, each project and individual has their own preferences and requirements for customizations
