#!/bin/bash

echo "Please follow the instructions very carefully."

# Check if the script is running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root. Please switch to root ('sudo su') before running it." >&2
    exit 1
fi

bash ./install.sh
bash ./install_pg.sh

# Loop until the user confirms they have modified the .env parameters
while true; do
    echo "Have you modified the .env parameters according to your environment? (yes/no)"
    read -r response

    # Convert the response to lowercase
    response=$(echo "$response" | tr '[:upper:]' '[:lower:]')

    # Check the response
    if [ "$response" == "yes" ]; then
        echo "Starting the application..."
        bash ./start.sh
        break  # Exit the loop if the answer is yes
    else
        echo "Please modify the .env parameters to proceed."
    fi
done
