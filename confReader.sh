#!/bin/bash

# Check if an argument is provided
if [ $# -eq 0 ]; then
  echo "Please provide an argument for the command."
  exit 1
fi

# Store the argument in a variable
pattern="$1"

# Find the matching configuration files
files=$(find . -type f -name "*${pattern}*conf*")

# Iterate over the matching files and display their contents
for file in $files; do
  cat "$file"
  echo -e "............ \nYou will need the File Name to Restart"
  echo " $file  .  OR COPY the line below"
  filename=$(basename "$file")
  echo "service ${filename%.conf} restart"
  echo "............"
done
