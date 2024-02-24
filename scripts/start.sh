#!/bin/bash

# Check if the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please switch to root ('sudo su') before running it." >&2
    exit 1
fi

if ! command -v bun &>/dev/null; then
    echo "Error: 'bun' is not installed. Please install it from bun.sh before running this script."
    exit 1
fi

echo "Server starting..."

# Config
REPO="101dal/wallon-boutique-backend-public"
ASSETS_DIR="./server"
BACKUP_DIR="./backups"
VERSION_FILE="./version"

# Every how many seconds it should check for a new release
CHECK_TIME=86400

function check_new_version() {
    INSTALLED_VERSION=$(get_installed_version)
    LATEST_VERSION=$(get_latest_release)
    if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then
        echo -n "A new version is available : $LATEST_VERSION. Current version : $INSTALLED_VERSION. Do you want to install it? (y/n): "
        read -r answer
        if [[ "$answer" == [Yy] ]]; then
            # Start the installation of the new version and then stop the process while the install.sh script is executing
            bash ./install.sh 1 # With $1 = 1
            exit 0
        else
            return 1
        fi
    else
        return 1
    fi
}

function get_installed_version() {
    if [ -f "$VERSION_FILE" ]; then
        cat "$VERSION_FILE"
    else
        echo "0.0.0" # Default version if the version file doesn't exist
    fi
}

function get_latest_release() {
    TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')
    echo "$TAG"
}

function cleanup() {
    # Stop the bun server
    pkill -f bun
    echo "Server stopped."
    exit 0
}

# Trap the exit signal to perform cleanup
trap cleanup EXIT

# Stop server
pkill -f bun

check_new_version

while true; do
    (cd "$ASSETS_DIR" && bun run "server.js")

    # Check for a new release every $CHECK_TIME seconds
    sleep "$CHECK_TIME"

    check_new_version

    pkill -f bun
done
