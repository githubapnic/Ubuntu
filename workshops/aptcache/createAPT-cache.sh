#!/bin/bash

# Purpose: Use this to install and update an apt-cache server
# Usage: sudo ./createAPT-cache.sh apt.apnictraining.net 192.168.30.248
# Reference: https://www.tecmint.com/apt-cache-server-in-ubuntu/

# Declare variables
HOSTNAME="$1"
IP="$2"

# Check if 2 parameters entered into the command line
function checkParameters()
{
	if test "$#" -ne 2; then
		echo "Not enough values typed for the command."
		echo "Usage: $0 HOSTNAME IP"
		exit
	fi
}

# Ensure script is run as root user (not a super secure script)
function checkRoot()
{
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
  fi
}

# Install the apt-cache server
function installAPTCACHE()
{
	# First update the server and install application
	sudo apt-get update && sudo apt-get dist-upgrade
	sudo apt-get install -y apt-cacher-ng

	# Update the configuration file
	sudo cp -p /etc/apt-cacher-ng/acng.conf /etc/apt-cacher-ng/acng.conf.bak

	sudo sed -i 's/\# Port\:3142/Port\:3142/' /etc/apt-cacher-ng/acng.conf
	sudo sed -i 's/publicNameOnMainInterface/'"$HOSTNAME"'/' /etc/apt-cacher-ng/acng.conf
	sudo sed -i 's/192.168.7.254/'"$IP"'/' /etc/apt-cacher-ng/acng.conf
	sudo sed -i 's/\# BindAddress\:/BindAddress\:/' /etc/apt-cacher-ng/acng.conf
	sudo sed -i 's/Remap-cygwin/\#Remap-cygwin/' /etc/apt-cacher-ng/acng.conf
	sudo sed -i 's/Remap-sfnet/\#Remap-sfnet/' /etc/apt-cacher-ng/acng.conf
	sudo sed -i 's/Remap-alxrep/\#Remap-alxrep/' /etc/apt-cacher-ng/acng.conf
	sudo sed -i 's/Remap-fedora/\#Remap-fedora/' /etc/apt-cacher-ng/acng.conf
	sudo sed -i 's/Remap-epel/\#Remap-epel/' /etc/apt-cacher-ng/acng.conf
	sudo sed -i 's/Remap-slrep/\#Remap-slrep/' /etc/apt-cacher-ng/acng.conf
	sudo sed -i 's/Remap-gentoo/\#Remap-gentoo/' /etc/apt-cacher-ng/acng.conf
	sudo sed -i 's/\# PidFile\:/PidFile\:/' /etc/apt-cacher-ng/acng.conf

	# restart the APT cache service: 
	sudo systemctl restart apt-cacher-ng
}
# Display message about where files are located
function displayMessage()
{
  echo "##########################################################" 
  echo "## Log into the clients and point to the apt-cache server"
  echo "edit the /etc/apt/sources.list"
  echo "insert $IP:3142 before every source list"
  echo ""
  echo "Example: "
  echo "deb http://$IP:3142/archive.ubuntu.com/ubuntu genial main restricted universe multiverse"  
  echo " "
  echo "May be able to use the sed command to search and replace"
  echo "  sudo cp -p /etc/apt/sources.list /etc/apt/sources.list.bak"
  echo "  sed -i 's/http\:\/\//http\:\/\/$IP:3142\//' /etc/apt/sources.list"
  echo "then run an update to check it works"
  echo "  sudo apt-get update"
  echo "##########################################################" 
}

# Run the functions 
checkRoot
# checkParameters
installAPTCACHE
displayMessage







