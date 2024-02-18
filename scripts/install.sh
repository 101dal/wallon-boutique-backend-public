#!/bin/bash

# Check if bun command is available
if ! command -v bun &> /dev/null; then
    echo "Error: 'bun' is not installed. Please install it from bun.sh before running this script."
    exit 1
fi

# Config
REPO="101dal/wallon-boutique-backend-public"
RELEASE_URL="https://github.com/$REPO/releases"
ASSETS_DIR="./server"
BACKUP_DIR="./backups"
LOG_DIR="./logs"
ENV_FILE="$ASSETS_DIR/.env"

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

# Create .env file
cat > $ENV_FILE <<EOF
# Database configuration for POSTGRESQL
DB_USER=
DB_PASSWORD=
DB_NAME=
DB_HOST=
DB_PORT=

# Server configuration
PORT=3000
ASSETS_FOLDER=${PWD}/assets

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

echo "Installation complete!"
