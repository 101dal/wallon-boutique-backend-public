#!/bin/bash

echo "Installing postgresql database..."

echo "If you encounter an error, fix it and restart this script with ./install_pg.sh"

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
  echo "Please run as root or using sudo."
  exit
fi

# Update package list
apt update

# Check if the systemctl command exists
if ! command -v systemctl &> /dev/null; then
    echo "Error: 'systemctl' is not installed."
    apt install systemd
fi

# Install PostgreSQL
apt install -y postgresql postgresql-contrib

# Start PostgreSQL service
systemctl start postgresql

# Check if PostgreSQL service started successfully
if [ $? -ne 0 ]; then
  echo "Error: PostgreSQL service failed to start."
  exit 1
fi

# Enable PostgreSQL service to start on boot
systemctl enable postgresql

# Prompt for PostgreSQL configuration
read -p "Enter PostgreSQL username: " pg_username
read -p "Enter PostgreSQL password: " pg_password
read -p "Enter a name for the new database: " pg_database
read -p "Enter PostgreSQL port (press Enter for default 5432): " pg_port

# Use default port if not provided
pg_port=${pg_port:-5432}

# Create a new PostgreSQL user and database
sudo -u postgres psql -c "CREATE USER \"$pg_username\" WITH PASSWORD '$pg_password';"
sudo -u postgres createdb $pg_database
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE \"$pg_database\" TO \"$pg_username\";"

# Display configuration details
echo
echo
echo "PostgreSQL server setup complete."
echo "Username: $pg_username"
echo "Password: $pg_password"
echo "Database: $pg_database"
echo "Port: $pg_port"
echo "Database URL: postgresql://$pg_username:$pg_password@localhost:$pg_port/$pg_database"

echo
echo

echo "Now you have to enter all the needed information into the .env file and you are free to use the server"