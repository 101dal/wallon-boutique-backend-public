#!/bin/bash

# Function to update .env file with provided values
update_env_file() {
  if [ -n "$DB_USER" ]; then
    sed -i "s/^DB_USER=.*/DB_USER=$DB_USER/" "$ENV_FILE"
  fi

  if [ -n "$DB_PASSWORD" ]; then
    sed -i "s/^DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" "$ENV_FILE"
  fi

  if [ -n "$DB_NAME" ]; then
    sed -i "s/^DB_NAME=.*/DB_NAME=$DB_NAME/" "$ENV_FILE"
  fi

  if [ -n "$DB_HOST" ]; then
    sed -i "s/^DB_HOST=.*/DB_HOST=$DB_HOST/" "$ENV_FILE"
  fi

  if [ -n "$TEST_MODE" ]; then
    sed -i "s/^TEST_MODE=.*/TEST_MODE=$TEST_MODE/" "$ENV_FILE"
  fi

  if [ -n "$EMAIL_KEY" ]; then
    sed -i "s/^EMAIL_KEY=.*/EMAIL_KEY=$EMAIL_KEY/" "$ENV_FILE"
  fi

  if [ -n "$SERVER_FULL_URL" ]; then
    sed -i "s#^SERVER_FULL_URL=.*#SERVER_FULL_URL=$SERVER_FULL_URL#" "$ENV_FILE"
  fi

  if [ -n "$EMAIL_SENDER" ]; then
    sed -i "s/^EMAIL_SENDER=.*/EMAIL_SENDER=$EMAIL_SENDER/" "$ENV_FILE"
  fi

  if [ -n "$SECRET" ]; then
    sed -i "s/^SECRET=.*/SECRET=$SECRET/" "$ENV_FILE"
  fi
}

# Function to start the script
start_script() {
  if [ -n "$START_LINE" ]; then
    bash ./start.sh
  fi
}

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
MAIN_DIR=$(pwd)

# Parse command-line arguments
while [[ $# -gt 0 ]]; do
  case "$1" in
    --db-user)
      DB_USER="$2"
      shift 2
      ;;
    --db-password)
      DB_PASSWORD="$2"
      shift 2
      ;;
    --db-name)
      DB_NAME="$2"
      shift 2
      ;;
    --db-host)
      DB_HOST="$2"
      shift 2
      ;;
    --test-mode)
      TEST_MODE="$2"
      shift 2
      ;;
    --email-key)
      EMAIL_KEY="$2"
      shift 2
      ;;
    --server-full-url)
      SERVER_FULL_URL="$2"
      shift 2
      ;;
    --email-sender)
      EMAIL_SENDER="$2"
      shift 2
      ;;
    --secret)
      SECRET="$2"
      shift 2
      ;;
    --start-line)
      START_LINE="$2"
      shift 2
      ;;
    *)
      echo "Invalid argument: $1"
      exit 1
      ;;
  esac
done

# Make directories
mkdir -p "$SERVER_DIR"
mkdir -p "$BACKUP_DIR"

# Get latest release tag
TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')

echo "Installing the last stable version: $TAG"

# Download release
curl -L -o "$BACKUP_DIR/$TAG.tar.gz" "$RELEASE_URL/download/$TAG/release.tar.gz"

# Extract release
tar -xzvf "$BACKUP_DIR/$TAG.tar.gz" -C "$SERVER_DIR" --strip-components=1

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

# DO NOT CHANGE TEST_MODE UNLESS YOU ARE SURE ABOUT THAT
TEST_MODE=

# JWT configuration
SECRET=# Server side secret DO NOT SHARE FOR MORE SECURITY
TOKEN_EXPIRE_MS=0
TOKEN_EXPIRE_S=0
TOKEN_EXPIRE_M=0
TOKEN_EXPIRE_H=0
TOKEN_EXPIRE_D=7

# Email sender system RESEND API
EMAIL_KEY=
SERVER_FULL_URL= # Example : http://localhost:3000
EMAIL_SENDER= # Example : example@example.com

# Unverified users expire
USER_EXPIRE_MS = 0
USER_EXPIRE_S = 0
USER_EXPIRE_M = 10
USER_EXPIRE_H = 0
USER_EXPIRE_D = 0

# The api configuration for the rate limits
RATE_DURATION=60000 # The time between two resets of the rate (in ms)
RATE_MAX=1000 # The max amount of requests for a given ip in the duration timespan (an integer)
EOF

  # Update .env file with provided values
  update_env_file
fi

# Download the latest INSTALLER.tar.gz
INSTALLER_TAG="INSTALLER-$TAG"
curl -L -o "$BACKUP_DIR/$INSTALLER_TAG.tar.gz" "$RELEASE_URL/download/$TAG/INSTALLER.tar.gz"

# Extract INSTALLER.tar.gz
tar -xzvf "$BACKUP_DIR/$INSTALLER_TAG.tar.gz" -C "$MAIN_DIR"

# Add debugging statements
ls -la "$MAIN_DIR"

echo
echo
echo "The server is installed, please refer to README.md is you have any questions. If you encounter a bug please signal it."
echo
echo

# Start the script
start_script
