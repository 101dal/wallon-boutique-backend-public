#!/bin/bash

if ! command -v bun &> /dev/null; then
    echo "Error: 'bun' is not installed. Please install it from bun.sh before running this script."
    exit 1
fi

# Config 
REPO="101dal/wallon-boutique-backend-public"
ASSETS_DIR="./server" 
BACKUP_DIR="./backups"
LOG_DIR="./logs"

# Every how many seconds it should check the new release
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

# Create new log file
START_TIME=$(date +%Y%m%d%H%M%S)
LOG_FILE="$LOG_DIR/server_$START_TIME.log"

touch "$LOG_FILE"

# Stop server
kill $(pgrep -f bun)

(cd $ASSETS_DIR && bun run "server.js" | tee -a "../$LOG_FILE" 2>&1 &)

while true; do

    # Restart timer
    START_TIME=$(date +%Y%m%d%H%M%S)

    # Check for new release every $CHECK_TIME seconds
    if [ $(($(date +%s) - $START_TIME)) -ge $CHECK_TIME ]; then

        # Create new log file
        LOG_FILE="$LOG_DIR/server_$START_TIME.log"

        touch "$LOG_FILE"
      
        # Stop server
        kill $(pgrep -f bun)

        # Get latest tag
        TAG=$(curl -s https://api.github.com/repos/$REPO/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

        # Check if backup already exists 
        if [ ! -f "$BACKUP_DIR/$TAG.zip" ]; then

            echo "$(date +"%Y-%m-%d %H:%M:%S") Backing up current version" >> $LOG_FILE

            # Backup current version
            (cd $ASSETS_DIR && zip -r $BACKUP_DIR/$TAG.zip .) 

        fi

        # Download latest release 
        curl -L -o "/tmp/$TAG.zip" https://github.com/$REPO/releases/download/$TAG/release.zip

        # Extract release
        unzip -o "/tmp/$TAG.zip" -d $ASSETS_DIR

        # Preserve .env and assets
        cp $ASSETS_DIR/backup/.env $ASSETS_DIR/
        cp -r $ASSETS_DIR/backup/assets $ASSETS_DIR/

        if install_new_version; then
            # Start server
            (cd $ASSETS_DIR && bun run "server.js" | tee -a "../$LOG_FILE" 2>&1 &)
        else
            echo "Installation of the new version skipped."
        fi
    fi

    # Loop
    sleep $CHECK_TIME

done
