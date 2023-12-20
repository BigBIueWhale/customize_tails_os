#!/bin/bash

# Directory of the script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Create a build directory and navigate into it
mkdir -p "$DIR/build"
cd "$DIR/build"

# Run the Makefile to compile the program
make -f ../Makefile
