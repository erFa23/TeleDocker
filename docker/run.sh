#!/bin/bash

#-----------------------------------------------------------------------
# Settings (I'll use a config file later)
#-----------------------------------------------------------------------

PORT=8080 # Port to run the bot on
background=true # Run in background by default type (WARNING: If you change this to false you should open container terminal manually using 'docker exec -it telegram-smart-reminder-container /bin/bash' in another terminal)

#-----------------------------------------------------------------------
# Requirement Checks
#-----------------------------------------------------------------------

echo "Checking the necessary requirements for running the bot..."

# Checking network connection
echo "  - Checking network connection..."

if ! ping -c 1 google.com &> /dev/null
then
    echo "-------------------------------------------------------"
    echo "Error: No network connection detected."
    echo "Please check your internet connection and try again."
    echo "-------------------------------------------------------"
    echo
    exit 1
fi
echo "    Network connection is active."
echo

# Checking if curl is installed

if ! curl -s --max-time 5 https://google.com &> /dev/null
then
    echo "-------------------------------------------------------"
    echo "Error: curl is not installed"
    echo "Please install curl and try again."
    echo "You can use this command to install curl:"
    echo "'sudo apt install curl' on Ubuntu/Debian/Debian-based systems"
    echo "-------------------------------------------------------"
    echo
    exit 1
fi

# Checking the connectivity to Telegram servers
echo "  - Checking connectivity to Telegram servers..."

if ! curl -s --max-time 5 https://api.telegram.org &> /dev/null
then
    echo "-------------------------------------------------------"
    echo "Error: Unable to connect to Telegram servers."
    echo "Please check your network settings and try again."
    echo "-------------------------------------------------------"
    echo
    exit 1
fi
echo "    Connectivity to Telegram servers is verified."
echo

# An End-to-End check using Native python3 script
echo "  - Performing end-to-end network integrity check using Python script..."
TEST_MESSAGE="CONNECTION_OK"
if ! python3 network_check.py $PORT $TEST_MESSAGE; then
    echo "Requirement check failed. exiting..."
    exit 1
fi

# Check if Docker is installed

echo "- Checking if Docker is installed"
if ! command -v docker &> /dev/null
then
    echo "-------------------------------------------------------"
    echo "Error: Docker is not installed on this system."
    echo "Please install Docker first, then run this script. You can use this command to install Docker:"
    echo ""sudo apt install docker.io" on Ubuntu/Debian/Debian-based systems"
    echo "-------------------------------------------------------"
    exit 1
fi

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

if [ "$background" = true ] ; then
    echo "Running in background..."
    docker run \
    -d \
    -it \
    --volume ../data:/data \
    -p $PORT:$PORT \
    --name telegram-smart-reminder-container \
    telegram-smart-reminder && \
    docker exec -it telegram-smart-reminder-container bash -c "echo 'The container is running in the background. This is a terminal session inside the container.' && echo 'Type \"exit\" to leave this session, or \"kill 1\" to stop the container.' && echo && echo 'You can open another terminal on your host and use:' && echo '  docker exec -it telegram-smart-reminder-container /bin/bash  # To open a new shell' && echo '  docker logs -f telegram-smart-reminder-container       # To view logs' && echo && bash"

elif [ "$background" = false ] ; then
    echo "Container is running in the foreground. Use Ctrl+C to stop the container."
    echo "To access the container terminal while it is running, open another terminal window and use:"
    echo "docker exec -it telegram-smart-reminder-container /bin/bash"
    docker run \
    --volume ../data:/data \
    -p $PORT:$PORT \
    --name telegram-smart-reminder-container \
    telegram-smart-reminder

else
    echo "Invalid background setting. Please set it to true or false (in the top of ./docker/run.sh after '# Settings')."
    echo
    exit 1
fi

