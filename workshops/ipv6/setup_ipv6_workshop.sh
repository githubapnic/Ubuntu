#!/bin/bash
# This script automates the setup of workshops on Ubuntu 18.04 LTS.
# Ensure the directories, credentials and ports specified in the variables below are 
# what you want.

# Credit: Script based on GNS3 installation script
# https://github.com/rhelshane/Install-GNS3-Server

##########################################
# Declare variables
##########################################

CURRENT_DIR=$(pwd)
WORKSHOP_DYNAMIPS_DIR="$HOME/virtual_labs/ipv6"
SCRIPT_DIR="$HOME/Documents/scripts/"
IMAGE_DIR="$HOME/virtual_labs/images"
LOG_FILE="install.log"

##########################################
# Define Functions
##########################################


# Ensure script is run as root user (not a super secure script)
function checkRoot()
{
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
  fi
}

# Ensure script is run on Ubuntu 18.04 (not a super secure script)
function checkUbuntu()
{
  if [[ $(lsb_release -rs) == "18.04" ]]; then
  date >> $LOG_FILE
  echo "###### Checking Ubuntu Version" | tee -a $LOG_FILE
  else
    echo "This script is for Ubuntu version 18.04. This is version $(lsb_release -rs)"
    exit 1
  fi
}

# Check whether package is installed and in path
function checkSuccess()
{
  which $1 >> /dev/null && echo "Success!"
} 

# Update packages via apt
function updatePackages()
{
  echo "###### Updating Packages" | tee -a $LOG_FILE
  apt-get update -qq >> $LOG_FILE
  apt-get dist-upgrade -qq >> $LOG_FILE
}

# Install SSH if not already installed
function installSSH()
{
  if [[ $(checkSuccess ssh) == "Success!" ]]; then
    echo "###### SSH already installed" | tee -a $LOG_FILE
  else
    echo "####### Installing SSH server" | tee -a $LOG_FILE
    apt-get install -qq openssh-server >> $LOG_FILE
    checkSuccess ssh
  fi
}

# Install Screen if not already installed
function installScreen()
{
  if [[ $(checkSuccess screen) == "Success!" ]]; then
    echo "###### Screen already installed" | tee -a $LOG_FILE
  else
    echo "####### Installing Screen" | tee -a $LOG_FILE
    apt-get install -y -qq screen >> $LOG_FILE
    checkSuccess screen
  fi
}

# Install the 32-bit version of dynamips (more stable)
function installDynamips()
{
  if [[ $(checkSuccess dynamips) == "Success!" ]]; then
    echo "###### Dynamips already installed" | tee -a $LOG_FILE
  else
    echo "###### Installing dynamips" | tee -a $LOG_FILE
    dpkg --add-architecture i386 >> $LOG_FILE
    apt-get update -qq >> $LOG_FILE
    apt-get install -qq dynamips:i386 >> $LOG_FILE
    checkSuccess dynamips
  fi
}


# Install dynagen
function installDynagen()
{
  if [[ $(checkSuccess dynagen) == "Success!" ]]; then
    echo "###### Dynagen already installed" | tee -a $LOG_FILE
  else
    echo "###### Installing dynagen" | tee -a $LOG_FILE
    apt-get update -qq >> $LOG_FILE
    apt-get install -qq dynagen >> $LOG_FILE
    checkSuccess dynagen
  fi
}

# Enable IPv4 and IPv6 forwarding
function enableForwarding()
{
  echo "###### Enable IPv4 and IPv6 Forwarding" | tee -a $LOG_FILE
  sudo cp /etc/sysctl.conf /etc/sysctl.conf.bak >> $LOG_FILE
  sudo sed -i 's/^#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf >> $LOG_FILE
  sudo sed -i 's/^#net.ipv6.conf.all.forwarding=1/net.ipv6.conf.all.forwarding=1/' /etc/sysctl.conf >> $LOG_FILE
  sysctl -p /etc/sysctl.conf | tee -a $LOG_FILE
}

# Copy the files to the IPv6 dynamips folder
function setupDynamips()
{
  echo "###### Copy IPv6 topology files" | tee -a $LOG_FILE
  mkdir -p $WORKSHOP_DYNAMIPS_DIR $IMAGE_DIR >> $LOG_FILE
  chown -R $SUDO_USER:$SUDO_USER $IMAGE_DIR >> $LOG_FILE
  cp -R dynamips/* $WORKSHOP_DYNAMIPS_DIR/. >> $LOG_FILE
  chmod u+x $WORKSHOP_DYNAMIPS_DIR/*.sh >> $LOG_FILE
  chmod u+x $WORKSHOP_DYNAMIPS_DIR/run* >> $LOG_FILE
  chown -R $SUDO_USER:$SUDO_USER $WORKSHOP_DYNAMIPS_DIR >> $LOG_FILE
}

# Fix for dynagen to run on Ubuntu 18.04
function setTimeZone()
{
  echo "###### Change Timezone to NYC for dynamips to work" | tee -a $LOG_FILE
  ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime
}

# Display message about where files are located
function displayMessage()
{
  echo "##########################################################" | tee -a $LOG_FILE
  echo "####### Installation Finished. Workshop files are located:" | tee -a $LOG_FILE
  echo "$WORKSHOP_DYNAMIPS_DIR" | tee -a $LOG_FILE
  echo "$CURRENT_DIR" | tee -a $LOG_FILE
  echo
  echo "####### Please update $WORKSHOP_DYNAMIPS_DIR/topology.net file with the IOS image." | tee -a $LOG_FILE
  echo "####### Current image name in $IMAGE_DIR:" | tee -a $LOG_FILE
  echo "$(ls ~/virtual_labs/images | grep 720)" | tee -a $LOG_FILE
  echo
  echo "####### Current image name in topology file:" | tee -a $LOG_FILE
  echo "$(head $WORKSHOP_DYNAMIPS_DIR/topology.net | grep image)" | tee -a $LOG_FILE
  echo "##########################################################" | tee -a $LOG_FILE
}
##########################################
# Run the functions 
##########################################

checkRoot
checkUbuntu
updatePackages
installSSH
installScreen
installDynamips
installDynagen
enableForwarding
setupDynamips
setTimeZone
displayMessage

