#!/bin/bash

# Config
REPO="101dal/wallon-boutique-backend-public"
RELEASE_URL="https://github.com/$REPO/releases"
ASSETS_DIR="./server"
BACKUP_DIR="./backups"
LOG_DIR="./logs"

# Make directories
mkdir -p $ASSETS_DIR
mkdir -p $BACKUP_DIR
mkdir -p $LOG_DIR

# Get latest release tag 
TAG=$(curl -s https://api.github.com/repos/$REPO/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')

echo "Installing the last stable version : $TAG"

# Download release
curl -L -o "$BACKUP_DIR/$TAG.zip" $RELEASE_URL/download/$TAG/release.zip

# Extract release
unzip -o "$BACKUP_DIR/$TAG.zip" -d $ASSETS_DIR 

# Initialize backup  
cp -r $ASSETS_DIR/assets $ASSETS_DIR/backup
cp $ASSETS_DIR/.env $ASSETS_DIR/backup/.env

# Install dependencies
(cd $ASSETS_DIR && bun install)

echo "Installation complete!"