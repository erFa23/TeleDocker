#!/bin/bash

#-----------------------------------------------------------------------
# Settings (I'll use a config file later)
#-----------------------------------------------------------------------

PORT=8080 # Port to run the bot on
START_MODE="shell" # Options: "shell" or "log". If "shell" is selected, the container will start with a bash shell. If "log" is selected, it will display the logs directly. (WARNING: If you change this to false you should open container terminal manually using 'docker exec -it telegram-smart-reminder-container /bin/bash' in another terminal)
#-----------------------------------------------------------------------
# Requirement Checks
#-----------------------------------------------------------------------

echo "** Checking the necessary requirements for running the bot **"

# Checking if curl is installed (Corrected Logic)
echo "  - Checking if curl is installed..."
if ! command -v curl &> /dev/null
then
    echo
    echo "-------------------------------------------------------"
    echo "Error: curl is not installed on this system."
    echo "Please install curl and try again."
    echo "You can use this command to install curl:"
    echo "  sudo apt update && sudo apt install curl"
    echo "-------------------------------------------------------"
    echo
    exit 1
fi
echo "    curl is installed."
echo

# Checking network connection
echo "  - Checking network connection..."

HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 5 https://www.google.com)

if [[ "$HTTP_STATUS" -lt 200 || "$HTTP_STATUS" -ge 400 ]]; then
    echo
    echo "-------------------------------------------------------"
    echo "Error: No network connection detected (HTTP Status: $HTTP_STATUS)."
    echo "Please check your internet connection and try again."
    echo "-------------------------------------------------------"
    echo
    exit 1
fi

echo "    Network connection is active (Status: $HTTP_STATUS)."
echo

# Checking connectivity to Telegram servers

echo "  - Checking connectivity to Telegram servers..."


TEL_HTTP_STATUS=$(curl -s -o /dev/null -L -w "%{http_code}" --connect-timeout 5 https://api.telegram.org)

if [[ "$TEL_HTTP_STATUS" -lt 200 || "$TEL_HTTP_STATUS" -ge 400 ]]; then
    echo
    echo "-------------------------------------------------------"
    echo "Error: Cannot connect to Telegram servers (HTTP Status: $TEL_HTTP_STATUS)."
    echo "-------------------------------------------------------"
    echo
    exit 1
fi
echo "    Connectivity to Telegram servers is verified. (Status: $TEL_HTTP_STATUS)."
echo

# An End-to-End check using native python3 script to verify network integrity
echo "  - Performing end-to-end network integrity check using Python script..."
TEST_MESSAGE="CONNECTION_OK"
if ! python3 ./docker/network_check.py $PORT $TEST_MESSAGE; then
    echo
    exit 1
fi

echo "    End-to-end network integrity check passed."
echo

# Check if Docker is installed

echo "- Checking if Docker is installed"
if ! command -v docker &> /dev/null
then
    echo "-------------------------------------------------------"
    echo "Error: Docker is not installed on this system."
    echo "Please install Docker first, then run this script. You can use this command to install Docker:"
    echo ""sudo apt install docker.io" on Ubuntu/Debian/Debian-based systems"
    echo "-------------------------------------------------------"
    echo
    exit 1
fi

echo "    Docker is installed."
echo

# All checks passed
echo "**All requirements are met.** Proceeding to the next step..."
echo

# building the Docker image

echo "Building the Docker image..."
echo

docker build -f docker/dockerfile -t telegram-smart-reminder .

echo "Running the Docker container..."
echo

docker stop telegram-smart-reminder-container &> /dev/null
docker rm telegram-smart-reminder-container &> /dev/null || true

if [ "$START_MODE" = "shell" ] ; then
    echo "Running in background..."
    docker run \
    -d \
    -it \
    --volume $(pwd)/data:/project/data \
    -p $PORT:$PORT \
    --name telegram-smart-reminder-container \
    telegram-smart-reminder && \
    docker exec -it telegram-smart-reminder-container bash -c "echo 'The container is running in the background. This is a terminal session inside the container.' && echo 'Type \"exit\" to leave this session, or \"kill 1\" to stop the container.' && echo && echo 'You can open another terminal on your host and use:' && echo '  docker exec -it telegram-smart-reminder-container /bin/bash  # To open a new shell' && echo '  docker logs -f telegram-smart-reminder-container       # To view logs' && echo && bash"

elif [ "$START_MODE" = "log" ] ; then
    echo "Container is running in the foreground. Use Ctrl+C to stop the container."
    echo "To access the container terminal while it is running, open another terminal window and use:"
    echo "docker exec -it telegram-smart-reminder-container /bin/bash"
    docker run \
    --volume $(pwd)/data:/project/data \
    -p $PORT:$PORT \
    --name telegram-smart-reminder-container \
    telegram-smart-reminder

else
    echo "Invalid background setting. Please set it to true or false (in the top of ./docker/run.sh after '# Settings')."
    echo
    exit 1
fi

