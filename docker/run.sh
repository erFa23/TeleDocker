#!/bin/bash

#-----------------------------------------------------------------------
# Settings (I'll use a config file later)
#-----------------------------------------------------------------------

PORT=8080 # Port to run the bot on
background=true # Run in background by default type

#-----------------------------------------------------------------------
# Requirement Checks
#-----------------------------------------------------------------------

echo "do you want to see logs(if you say no the bot will run in background)? (y/n)"
read show_logs
if [ "$show_logs" == "n" ]; then
    background=true
elif [ "$show_logs" == "y" ]; then
    background=false
else
    echo "Invalid input. Please enter 'y' or 'n'."
    exit 1
fi

echo "Checking the necessary requirements for running the bot..."

# Checking network connection
echo "  - Checking network connection..."
# دریافت آرگومان‌ها از Bash
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

docker rm -f telegram-smart-reminder-container &> /dev/null

if [ "$background" = true ] ; then
    docker run --restart unless-stopped -d -p $PORT:$PORT --name telegram-smart-reminder-container telegram-smart-reminder
    echo "The bot is running in the background."
    echo "Use: 'docker logs -f telegram-smart-reminder-container' to view logs."
    echo
    exit 0
elif [ "$background" = false ] ; then
    docker run -p $PORT:$PORT --name telegram-smart-reminder-container telegram-smart-reminder
else
    echo "Invalid background setting. Please set it to true or false (in the top of ./docker/run.sh after '# Settings')."
    echo
    exit 1
fi