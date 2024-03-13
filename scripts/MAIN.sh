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

# Function to check and install a command if it's not available
check_and_install_command() {
    local command_name=$1
    if ! command -v "$command_name" &>/dev/null; then
        echo "Error: '$command_name' is not installed. Installing $command_name..."
        apt install "$command_name"
    fi
}

# Check and install required commands
check_and_install_command "tar"
check_and_install_command "curl"
check_and_install_command "unzip"
check_and_install_command "systemctl"

# Check if Bun is installed
if ! command -v "bun" &>/dev/null; then
    echo "Error: 'bun' is not installed. Installing bun..."
    curl -fsSL "https://bun.sh/install" | bash
    # Wait for the installation to be finished and source the user's .bashrc
    source "/$(whoami)/.bashrc"
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
echo "All the modules have been checked... Now checking if the server is already installed..."
echo
echo

# Check if the server is already installed
if [ -d "./server" ]; then
    read -p "The server is already installed. Do you want to start it directly? [Yy/Nn]" answer
    if [[ "$answer" == [Yy] ]]; then
        echo "Starting the server..."
        bash ./start.sh
        exit 0
    fi
fi

echo "Installing the server..."
echo
echo

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
    pg_host=$(echo "$pg_info" | grep "Host" | awk -F ': ' '{print $2}')
    pg_port=$(echo "$pg_info" | grep "Port" | awk -F ': ' '{print $2}')

    rm "/tmp/pg_info.txt"

else
    echo "Please enter the current information for the database:"
    echo
    read -p "Enter PostgreSQL username: " pg_username
    read -p "Enter PostgreSQL password: " pg_password
    read -p "Enter PostgreSQL database name: " pg_database
    read -p "Enter PostgreSQL host: " pg_host
    read -p "Enter PostgreSQL port (press Enter for default 5432): " pg_port

    if [ -z "$pg_port" ]; then
        pg_port="5432"
    fi

    if [ -z "$pg_port" ]; then
        pg_port="5432"
    fi

    
fi


# Display extracted information
echo
echo "Username: $pg_username"
echo "Password: $pg_password"
echo "Database: $pg_database"
echo "Host: $pg_host"
echo "Port: $pg_port"

printvoid

read -p "Enter the email key (it must be a RESEND key otherwise it will no work): " email_key

read -p "Enter the server full URL (leave empty if using http://localhost:PORT): " server_full_url

if [ -z "$server_full_url" ]; then
    server_full_url='http://localhost:${PORT}'
fi

read -p "Enter the email sender (leave empty to default wallonboutique@resend.dev but if saying something else you MUST have the right to do so in resend dashboard): " email_sender

if [ -z "$email_sender" ]; then
    email_sender="wallonboutique@resend.dev"
fi

printvoid

read -p "Do you want to boot the server in TEST_MODE. BE CAREFUL, ONLY BOOT IN TEST_MODE IF YOU ARE NOT DEPLOYING THE SERVER TO THE CLIENTS AND IF IT IS ONLY FOR TESTING PURPOSES [Yy/Nn] " test_mode

if [[ "$test_mode" == [Yy] ]]; then
    test_mode="true"
else
    test_mode="false"
fi

# Generate a random 16-character string
secret=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16)

echo "Installing the server with all the information"
echo
read -p "Do you want to start the server after the installation? [Yy/Nn]" answer
if [[ "$answer" == [Yy] ]]; then
    bash ./install.sh --db-user "$pg_username" --db-password "$pg_password" --db-name "$pg_database" --db-host "$pg_host" --test-mode "$test_mode" --email-key "$email_key" --server-full-url "$server_full_url" --email-sender "$email_sender" --secret "$secret" --start-line 1
else
    bash ./install.sh --db-user "$pg_username" --db-password "$pg_password" --db-name "$pg_database" --db-host "$pg_host" --test-mode "$test_mode" --email-key "$email_key" --server-full-url "$server_full_url" --email-sender "$email_sender" --secret "$secret"
fi
