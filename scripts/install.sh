#!/bin/bash

# Check if bun command is available
if ! command -v bun &>/dev/null; then
    echo "Error: 'bun' is not installed. Please install it from bun.sh before running this script."
    exit 1
fi

# Config
REPO="101dal/wallon-boutique-backend-public"
RELEASE_URL="https://github.com/$REPO/releases"
SERVER_DIR="./server"
BACKUP_DIR="./backups"
ENV_FILE="$SERVER_DIR/.env"
VERSION_FILE="./version"

# Make directories
if [ ! -d "$SERVER_DIR" ]; then
    mkdir -p "$SERVER_DIR"
fi
if [ ! -d "$BACKUP_DIR" ]; then
    mkdir -p "$BACKUP_DIR"
fi

# Get latest release tag
TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')

echo "Installing the last stable version: $TAG"

# Download release
curl -L -o "$BACKUP_DIR/$TAG.zip" "$RELEASE_URL/download/$TAG/release.zip"

# Extract release
unzip -o "$BACKUP_DIR/$TAG.zip" -d "$SERVER_DIR"

# Initialize backup
cp -r "$SERVER_DIR/assets" "$SERVER_DIR/backup"
cp "$SERVER_DIR/.env" "$SERVER_DIR/backup/.env"

# Install dependencies
(cd "$SERVER_DIR" && bun install)

# Set the version into the file
echo "$TAG" > "$VERSION_FILE"

# Create .env file
if [ ! -f "$ENV_FILE" ]; then
    cat >"$ENV_FILE" <<EOF
# Database configuration for POSTGRESQL
DB_USER=
DB_PASSWORD=
DB_NAME=
DB_HOST=
DB_PORT=5432

# Server configuration
PORT=3000
ASSETS_FOLDER=\${PWD}/assets
LOGGING_FOLDER=\${PWD}/../logs

# JWT configuration
SECRET=# Server side secret DO NOT SHARE FOR MORE SECURITY
TOKEN_EXPIRE_MS=0
TOKEN_EXPIRE_S=0
TOKEN_EXPIRE_M=0
TOKEN_EXPIRE_H=0
TOKEN_EXPIRE_D=7

# The api configuration for the rate limits
RATE_DURATION=60000 # The time between two resets of the rate (in ms)
RATE_MAX=1000 # The max amount of requests for a given ip in the duration timespan (an integer)
EOF
fi

# Download the latest INSTALLER.zip
INSTALLER_TAG="INSTALLER-$TAG"
curl -L -o "$BACKUP_DIR/$INSTALLER_TAG.zip" "$RELEASE_URL/download/$TAG/INSTALLER.zip"

# Extract INSTALLER.zip
unzip -o "$BACKUP_DIR/$INSTALLER_TAG.zip" -d .

echo -e "\nInstallation complete!\n"

if [ "$1" ]; then
    bash ./start.sh
fi
