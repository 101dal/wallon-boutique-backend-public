#!/bin/bash

# Define directories and files for the first script
SOURCE_DIR_1="/mnt/c/Users/augus/Desktop/server/wallon-boutique-backend-public/scripts"
OUTPUT_DIR_1="/mnt/c/Users/augus/Desktop/server/wallon-boutique-backend-public"
INCLUDE_FILES_1=("install.sh" "start.sh" "total_install.sh" "../IMPORTANT.txt" "../LICENSE.md" "../README.md")
ZIP_FILE_1="INSTALLER.zip"

# Check if the source directory for the first script exists
if [ ! -d "$SOURCE_DIR_1" ]; then
    echo "Error: Source directory $SOURCE_DIR_1 does not exist for the first script."
    exit 1
fi

# Create a temporary directory for the zip for the first script
TEMP_DIR_1=$(mktemp -d)

# Copy specified files to temporary directory for the first script excluding specified directories
for file in "${INCLUDE_FILES_1[@]}"; do
    cp "$SOURCE_DIR_1/$file" "$TEMP_DIR_1"
done

# Change to the temporary directory for the first script
cd "$TEMP_DIR_1" || exit 1

# Create the zip file for the first script
zip -r "$ZIP_FILE_1" .

# Move the zip file to the original directory for the first script
mv "$ZIP_FILE_1" "$OUTPUT_DIR_1"

# Clean up temporary directory for the first script
rm -rf "$TEMP_DIR_1"

echo "Compression complete. Zip file: $OUTPUT_DIR_1/$ZIP_FILE_1"

# Define directories and files for the second script
SOURCE_DIR_2="/mnt/c/Users/augus/Desktop/server/wallon-boutique-backend-public/src"
OUTPUT_DIR_2="/mnt/c/Users/augus/Desktop/server/wallon-boutique-backend-public"
INCLUDE_FILES_2=("index.html" "package.json" "server.js")
ZIP_FILE_2="release.zip"

# Check if the source directory for the second script exists
if [ ! -d "$SOURCE_DIR_2" ]; then
    echo "Error: Source directory $SOURCE_DIR_2 does not exist for the second script."
    exit 1
fi

# Create a temporary directory for the zip for the second script
TEMP_DIR_2=$(mktemp -d)

# Copy specified files to temporary directory for the second script excluding specified directories
for file in "${INCLUDE_FILES_2[@]}"; do
    cp "$SOURCE_DIR_2/$file" "$TEMP_DIR_2"
done

# Change to the temporary directory for the second script
cd "$TEMP_DIR_2" || exit 1

# Create the zip file for the second script
zip -r "$ZIP_FILE_2" .

# Move the zip file to the original directory for the second script
mv "$ZIP_FILE_2" "$OUTPUT_DIR_2"

# Clean up temporary directory for the second script
rm -rf "$TEMP_DIR_2"

echo "Compression complete. Zip file: $OUTPUT_DIR_2/$ZIP_FILE_2"
