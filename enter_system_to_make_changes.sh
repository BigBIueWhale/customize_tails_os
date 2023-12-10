#!/bin/bash

sudo chroot ./build/tails-squashfs/
# Now you're in a terminal in which you can modify that tails OS.
# For example:
# sudo apt-get purge <package-name>
# sudo apt-get autoremove
# sudo apt-get clean
