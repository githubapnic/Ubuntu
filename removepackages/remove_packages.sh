#!/bin/bash
# Date Created: 2nd March 2020
# Purpose:
# This script automates the removal of extra packages installed on Ubuntu 18.04 LTS.
# Ensure the packagelist, credentials and ports specified in the variables below are 
# what you want.

# Credit: Script based on GNS3 installation script
# https://github.com/rhelshane/Install-GNS3-Server

# Example command to remove Ubuntu Bloatware (used to populate packagelist file)
# https://gist.github.com/NickSeagull/ed43a80db6a54d69ded3e18f8babaf19
# https://askubuntu.com/questions/719955/list-of-safe-to-remove-applications


# Declare variables
CURRENT_DIR=$(pwd)
LOG_FILE="packagelist_removal.log"


# Ensure script is run as root user (not a super secure script)
function checkRoot()
{
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
  fi
}


# Check whether package is installed and in path
function checkSuccess()
{
  which $1 >> /dev/null && echo "Success!"
} 


function removePackages()
{
  echo "###### Deleting Packages" | tee -a $LOG_FILE
  apt-get update -qq >> $LOG_FILE
  apt-get upgrade -qq >> $LOG_FILE
  apt-get remove --purge -qq $(cat packagelist) >> $LOG_FILE
  dpkg -l $(cat packagelist) &> /dev/null && echo "Not removed!" 
  apt-get clean -qq >> $LOG_FILE
  apt-get autoremove -qq >> $LOG_FILE
  apt-get update -qq >> $LOG_FILE
}

# Run the functions 
checkRoot
removePackages

