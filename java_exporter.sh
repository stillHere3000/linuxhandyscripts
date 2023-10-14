#!/bin/bash
# This script takes a directory name as an argument and converts all the .java files in it to .txt files
# Usage: ./convert.sh dirname

# Check if the argument is a valid directory
if [ -d "$1" ]; then
  # Loop through all the .java files in the directory
  for file in "$1"/*.java; do
    # Get the file name without the extension
    filename="${file%.*}"
    # Copy the file as a .txt file
    cp "$file" "$filename.txt"
    # Print a message
    echo "Converted $file to $filename.txt"
  done
else
  # Print an error message
  echo "Invalid directory: $1"
fi
