#!/bin/bash

# Tested and working on Pop!OS 22.04 on 9 December 2023
# Make sure to download tails-i386-1.3.iso and place it at the root
# directory of the project before running this batch file

sudo ./clean.sh &&
sudo ./extract_iso.sh &&
sudo ./customize.sh &&
sudo ./package_iso.sh
