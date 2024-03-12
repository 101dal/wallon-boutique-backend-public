# Prompt for PostgreSQL configuration for install_pg.sh
read -p "Enter PostgreSQL username: " pg_username
read -p "Enter PostgreSQL password: " pg_password
read -p "Enter a name for the new database: " pg_database
read -p "Enter PostgreSQL port (press Enter for default 5432): " pg_port

# Use default port if not provided for install_pg.sh
pg_port=${pg_port:-5432}

# Create a new PostgreSQL user and database for install_pg.sh
sudo -u postgres psql -c "CREATE USER \"$pg_username\" WITH PASSWORD '$pg_password';"
sudo -u postgres createdb $pg_database
sudo -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE \"$pg_database\" TO \"$pg_username\";"

# Display configuration details for install_pg.sh
echo
echo
echo "PostgreSQL server setup complete."
echo "Username: $pg_username"
echo "Password: $pg_password"
echo "Database: $pg_database"
echo "Port: $pg_port"
echo "Database URL: postgresql://$pg_username:$pg_password@localhost:$pg_port"

# Write configuration details to a temporary file
echo "Username: $pg_username" >> /tmp/pg_info.txt
echo "Password: $pg_password" >> /tmp/pg_info.txt
echo "Database: $pg_database" >> /tmp/pg_info.txt
echo "Port: $pg_port" >> /tmp/pg_info.txt
