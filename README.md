# Customize Tails OS

## Overview
This project aims to create a customized version of the Tails OS, known for its strong emphasis on security and privacy. Our version, however, shifts focus from security to functionality and reliability. The primary objective is to develop a Tails OS variant without a GUI, capable of running on internal hard drives or SSDs, in addition to external thumb drives. This contrasts with the standard Tails OS, which is designed exclusively for external drive use.

The essence of this project lies in leveraging Tails OS's unique feature of not storing data on the disk. This property is exploited to embed custom software into the Tails bootable medium, akin to a hardware-embedded Docker container. The result is a highly reliable system where, upon physical restart, the software functions as if it's running for the first time.

## Key Features
- **No GUI- Planned**: Stripped-down version of Tails OS without a graphical user interface.
- **Flexible Boot Options**: Custom Tails OS can boot from internal SSD/HDD or external thumb drives.
- **Run program at boot- Planned**: Runs a custom program at boot, designed for specific operational requirements.
- **Custom driver- Planned**: Load a .ko file permanently and by default into the OS
- **Software Reliability**: System reset ensures the software operates consistently like new.

## Implemented Customizations
- **Boot from Internal SSD/HDD**: Modifications to allow the OS to live-boot from internal storage devices.
- **Disabled Security Overheads**: Certain security features have been disabled to prioritize functionality for specific use cases.

## Usage Instructions
1. **System Requirements**:
   - Tested on Pop!OS 22.04 as of 9 December 2023.
   - Ensure `tails-i386-1.3.iso` is downloaded and placed in the root directory of the project.

2. **Installation of Dependencies**:
   - Run `sudo ./install_dependencies.sh` to install necessary tools for handling ISO files.

3. **Execution**:
   - Execute `sudo ./run_as_sudo.sh` to start the customization process.
   - The script sequentially runs `clean.sh`, `extract_iso.sh`, `customize.sh`, and `package_iso.sh`.

4. **Input and Output**:
   - **Input**: The script expects `tails-i386-1.3.iso` in the project's root directory.
   - **Output**: The customized Tails OS ISO is output as `custom_tails.iso` in the `./build/` directory.

## Customize

### Overview of Customization Folders
This project provides two primary folders for customization, each serving a distinct purpose in the customization process of Tails OS:

1. **customized_tails**: This folder is a direct copy of the original Tails ISO's file structure. It is the primary location where the bootable file structure of the Tails OS resides. Customizations in this folder directly impact the boot process and the basic setup of the OS.

2. **tails-squashfs**: This folder contains the SquashFS filesystem, extracted from the original Tails ISO. SquashFS is a compressed, read-only filesystem used in Tails OS. Modifications in this folder are more in-depth and relate to the OS's core functionalities and structure.

### Customization Process
To ensure a streamlined and consistent customization process, all modifications should be made through the `customize.sh` script. This script acts as a central point of control for customizations, ensuring that changes are applied systematically and coherently across the Tails OS.

#### Why Use `customize.sh`?
- **Centralized Management**: `customize.sh` provides a single point of reference for all customizations. This makes tracking and managing changes more straightforward, reducing the risk of conflicting modifications.
- **Scripted Automation**: The script automates repetitive tasks, ensuring that customizations are applied uniformly across all relevant files and directories. This automation minimizes the risk of human error during the customization process.
- **Ease of Maintenance**: Future updates or modifications can be easily integrated by updating the `customize.sh` script. This approach simplifies maintaining and updating the customized OS.
- **Consistency and Reliability**: By centralizing customizations in one script, the consistency and reliability of the custom OS build are enhanced. It ensures that all parts of the OS are modified in sync, maintaining the overall integrity of the system.

#### How to Customize Using `customize.sh`
1. Open the `customize.sh` script in your preferred text editor.
2. Add or modify the commands within the script to apply your desired customizations.
3. Save your changes and run the script as part of the build process to apply these customizations.

### Important Note
While `customize.sh` is designed to handle a broad range of customizations, it is essential to have a basic understanding of shell scripting and the Tails OS architecture. This knowledge is crucial for making effective and safe modifications to the OS.

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
