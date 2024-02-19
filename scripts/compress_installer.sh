#!/bin/bash

# Define directories and files
SOURCE_DIR="/mnt/c/Users/augus/Desktop/server/wallon-boutique-backend-public/scripts"
OUTPUT_DIR="/mnt/c/Users/augus/Desktop/server/wallon-boutique-backend-public"
INCLUDE_FILES=("install.sh" "start.sh" "../IMPORTANT.txt" "../LICENSE.txt" "../README.md" "../README.pdf")
ZIP_FILE="INSTALLER.zip"

# Check if the source directory exists
if [ ! -d "$SOURCE_DIR" ]; then
    echo "Error: Source directory $SOURCE_DIR does not exist."
    exit 1
fi

# Create a temporary directory for the zip
TEMP_DIR=$(mktemp -d)

# Copy specified files to temporary directory excluding specified directories
for file in "${INCLUDE_FILES[@]}"; do
    cp "$SOURCE_DIR/$file" "$TEMP_DIR"
done

# Change to the temporary directory
cd "$TEMP_DIR" || exit 1

# Create the zip file
zip -r "$ZIP_FILE" .

# Move the zip file to the original directory
mv "$ZIP_FILE" "$OUTPUT_DIR"

# Clean up temporary directory
rm -rf "$TEMP_DIR"

echo "Compression complete. Zip file: $OUTPUT_DIR/$ZIP_FILE"
