#!/bin/bash

# Check if the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please switch to root ('sudo su') before running it." >&2
    exit 1
fi

function printvoid() {
    echo
    echo
    echo
    echo
}

printvoid
read -p "The process of installation is ongoing... Continue the installation [Yy/Nn]" answer
if [[ "$answer" == [Yy] ]]; then
    echo "Installing..."
else
    exit 0
fi

printvoid

echo "Checking all the modules..."

apt update

# Check if curl is installed
if ! command -v curl &>/dev/null; then
    echo "Error: 'curl' is not installed. Installing curl..."
    apt install curl
fi

# Check if unzip is installed
if ! command -v unzip &>/dev/null; then
    echo "Error: 'unzip' is not installed. Installing unzip..."
    apt install unzip
fi

# Check if bun is installed
if ! command -v bun &>/dev/null; then
    echo "Error: 'bun' is not installed. Installing bun..."
    curl -fsSL https://bun.sh/install | bash
fi

# Check if systemctl is installed
if ! command -v systemctl &>/dev/null; then
    echo "Error: 'systemctl' is not installed. Installing systemctl"
    apt install systemd
fi

# Check if PostgreSQL is installed
if ! command -v psql &>/dev/null; then
    echo "Installing PostgreSQL..."
    apt install -y postgresql postgresql-contrib
fi

# Start PostgreSQL
systemctl start postgresql

# Check if PostgreSQL service started successfully for install_pg.sh
if [ $? -ne 0 ]; then
    echo "Error: PostgreSQL service failed to start."
    exit 1
fi

# Enable PostgreSQL to start at boot
systemctl enable postgresql

printvoid
echo "All the modules have been checked... Now installing the server..."
echo
echo

pg_host=""
read -p "Do you want to install the database (if you already have a database, answer N/n)? [Yy/Nn]" answer
if [[ "$answer" == [Yy] ]]; then
    echo "Installing the database..."

    bash ./pg_install.sh

    # Read information from the temporary file
    pg_info=$(cat /tmp/pg_info.txt)

    # Extract individual pieces of information
    pg_username=$(echo "$pg_info" | grep "Username" | awk -F ': ' '{print $2}')
    pg_password=$(echo "$pg_info" | grep "Password" | awk -F ': ' '{print $2}')
    pg_database=$(echo "$pg_info" | grep "Database" | awk -F ': ' '{print $2}')
    pg_port=$(echo "$pg_info" | grep "Port" | awk -F ': ' '{print $2}')

    # Display extracted information
    echo "Username: $pg_username"
    echo "Password: $pg_password"
    echo "Database: $pg_database"
    echo "Port: $pg_port"

    rm "/tmp/pg_info.txt"

else
    echo "Please enter the current information for the database:"
    echo
    read -p "Enter PostgreSQL username: " pg_username
    read -p "Enter PostgreSQL password: " pg_password
    read -p "Enter PostgreSQL database name: " pg_database
    read -p "Enter PostgreSQL host: " pg_host
    read -p "Enter PostgreSQL port (press Enter for default 5432): " pg_port

    echo
    echo "Username: $pg_username"
    echo "Password: $pg_password"
    echo "Database: $pg_database"
    echo "Port: $pg_port"
fi

printvoid

# Generate a random 16-character string
secret=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)

echo "Installing the server with all the information"
echo
read -p "Do you want to start the server after the installation? [Yy/Nn]" answer
if [[ "$answer" == [Yy] ]]; then
    bash ./install.sh --db-user "$pg_username" --db-password "$pg_password" --db-name "$pg_database" --db-host "$pg_host" --secret "$secret" --start-line 1
else
    bash ./install.sh --db-user "$pg_username" --db-password "$pg_password" --db-name "$pg_database" --db-host "$pg_host" --secret "$secret"
fi
