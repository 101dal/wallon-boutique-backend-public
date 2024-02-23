#!/bin/bash

echo "Server starting..."

if ! command -v bun &> /dev/null; then
    echo "Error: 'bun' is not installed. Please install it from bun.sh before running this script."
    exit 1
fi

# Config 
REPO="101dal/wallon-boutique-backend-public"
ASSETS_DIR="./server" 
BACKUP_DIR="./backups"
VERSION_FILE="./version"

# Every how many seconds it should check for a new release
CHECK_TIME=86400

function install_new_version() {
    echo -n "A new version is available. Do you want to install it? (y/n): "
    read -r answer
    if [[ $answer == [Yy] ]]; then
        return 0
    else
        return 1
    fi
}

function get_installed_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "0.0.0"  # Default version if version file doesn't exist
    fi
}

function get_latest_release() {
    TAG=$(curl -s https://api.github.com/repos/$REPO/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
    echo "$TAG"
}

function cleanup() {
    # Stop the bun server
    kill $(pgrep -f bun)
    echo "Server stopped."
    exit 0
}

# Trap the exit signal to perform cleanup
trap cleanup EXIT

# Stop server
kill $(pgrep -f bun)

# Check for new release on startup
echo "$(date +"%d/%m/%Y à %H:%M:%S") Checking for a new version on startup..."

INSTALLED_VERSION=$(get_installed_version)
LATEST_VERSION=$(get_latest_release)
if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
    install_new_version || {
        (cd $ASSETS_DIR && bun run "server.js")
        continue
    }

    # Stop server
    kill $(pgrep -f bun)

    # Download latest release
    curl -L -o "/tmp/$LATEST_VERSION.zip" https://github.com/$REPO/releases/download/$LATEST_VERSION/release.zip

    # Extract release
    unzip -o "/tmp/$LATEST_VERSION.zip" -d $ASSETS_DIR

    # Update version file
    echo "$LATEST_VERSION" > "$VERSION_FILE"
fi

while true; do
    (cd $ASSETS_DIR && bun run "server.js")


    # Check for new release every $CHECK_TIME seconds
    sleep $CHECK_TIME

    echo "$(date +"%d/%m/%Y à %H:%M:%S") Checking for a new version on startup..."

    # Get installed and latest versions
    INSTALLED_VERSION=$(get_installed_version)
    LATEST_VERSION=$(get_latest_release)

    
    # Stop server
    kill $(pgrep -f bun)

    if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then

        # Prompt the user to know if we should download the new version
        install_new_version || continue

        # Download latest release 
        curl -L -o "/tmp/$LATEST_VERSION.zip" https://github.com/$REPO/releases/download/$LATEST_VERSION/release.zip

        # Extract release
        unzip -o "/tmp/$LATEST_VERSION.zip" -d $ASSETS_DIR

        # Update version file
        echo "$LATEST_VERSION" > "$VERSION_FILE"

    else
        echo "$(date +"%Y-%m-%d %H:%M:%S") No new version found."
    fi
done
