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
LOG_DIR="./logs"
VERSION_FILE="./version.txt"

# Every how many seconds it should check for a new release
CHECK_TIME=30

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

function prompt_user() {
    xterm -e "bash -c 'install_new_version; bash'"  # Open a new terminal for user input
}

# Trap the exit signal to perform cleanup
trap cleanup EXIT

# Create new log file
START_TIME=$(date +%Y%m%d%H%M%S)
LOG_FILE="$LOG_DIR/server_$START_TIME.log"
touch "$LOG_FILE"

# Stop server
kill $(pgrep -f bun)

(cd $ASSETS_DIR && bun run "server.js" | tee -a "../$LOG_FILE" 2>&1 &)

while true; do

    # Check for new release every $CHECK_TIME seconds
    sleep $CHECK_TIME

    echo "$(date +"%Y-%m-%d %H:%M:%S") Checking for a new version..." >> $LOG_FILE

    # Get installed and latest versions
    INSTALLED_VERSION=$(get_installed_version)
    LATEST_VERSION=$(get_latest_release)

    if [ "$INSTALLED_VERSION" != "$LATEST_VERSION" ]; then

        # Prompt the user to know if we should download the new version
        install_new_version || continue

        # Create new log file
        START_TIME=$(date +%Y%m%d%H%M%S)
        LOG_FILE="$LOG_DIR/server_$START_TIME.log"
        touch "$LOG_FILE"
      
        # Stop server
        kill $(pgrep -f bun)

        # Check if backup already exists 
        if [ ! -f "$BACKUP_DIR/$LATEST_VERSION.zip" ]; then
            echo "$(date +"%Y-%m-%d %H:%M:%S") Backing up current version" >> $LOG_FILE
            # Backup current version
            (cd $ASSETS_DIR && zip -r $BACKUP_DIR/$LATEST_VERSION.zip .) 
        fi

        # Prompt user in a new terminal window
        prompt_user

        # Download latest release 
        curl -L -o "/tmp/$LATEST_VERSION.zip" https://github.com/$REPO/releases/download/$LATEST_VERSION/release.zip

        # Extract release
        unzip -o "/tmp/$LATEST_VERSION.zip" -d $ASSETS_DIR

        # Preserve .env and assets
        cp $ASSETS_DIR/backup/.env $ASSETS_DIR/
        cp -r $ASSETS_DIR/backup/assets $ASSETS_DIR/

        # Update version file
        echo "$LATEST_VERSION" > "$VERSION_FILE"

        (cd $ASSETS_DIR && bun run "server.js" | tee -a "../$LOG_FILE" 2>&1 &)
    else
        echo "$(date +"%Y-%m-%d %H:%M:%S") No new version found." >> $LOG_FILE
    fi
done
