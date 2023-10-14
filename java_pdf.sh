#!/bin/bash
# This script takes a directory name as an argument and converts all the .java files in it to .pdf files
# Usage: ./convert.sh dirname

# Check if the argument is a valid directory
if [ -d "$1" ]; then
  # Loop through all the .java files in the directory
  for file in "$1"/*.java; do
    # Get the file name without the extension
    filename="${file%.*}"
    #deduce format of filename
    format="${filename##*.}"
    # Convert the file to a .pdf file using pandoc
    pandoc "$file" -o "$filename.pdf"
    # Print a message
    echo "Converted $file to $filename.pdf"
    #change file permission to 0755
    chmod 0755 "$filename.pdf"
  done
else
  # Print an error message
  echo "Invalid directory: $1"
fi


