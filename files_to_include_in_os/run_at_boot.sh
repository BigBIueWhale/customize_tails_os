#!/bin/bash

# Array of absolute paths to the executables
executables=("/files_to_include_in_os/executable1" "/files_to_include_in_os/executable2")

# Loop through the array and execute each program
for exec_path in "${executables[@]}"; do
    # Get the directory of the executable
    exec_dir=$(dirname "$exec_path")

    # Extract the filename without extension for log file naming
    exec_name=$(basename "$exec_path")
    log_file="${exec_dir}/${exec_name}.log.txt"  # Log file in the same directory as the executable

    # Execute the program asynchronously and redirect output to its log file
    "$exec_path" > "$log_file" 2>&1 &
done

exit 0
