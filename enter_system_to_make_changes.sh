#!/bin/bash

sudo chroot ./build/tails-squashfs/
# Now you're in a terminal in which you can modify that tails OS.
# For example, to disable GUI run:
# sudo apt-get purge xorg*
# sudo apt-get purge gnome*
# sudo apt-get autoremove
# sudo apt-get clean
