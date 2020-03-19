#!/bin/bash
# This script automates the setup of workshops on Ubuntu 18.04 LTS.
# Ensure the directories, credentials and ports specified in the variables below are 
# what you want.

# Credit: Script based on GNS3 installation script
# https://github.com/rhelshane/Install-GNS3-Server


# Declare variables
CURRENT_DIR=$(pwd)
WORKSHOP_DYNAMIPS_DIR="$HOME/Virtual_labs/rpki"
SCRIPT_DIR="$HOME/Documents/scripts/"
IMAGE_DIR="$HOME/Virtual_labs/images"
CONFIG_DIR="$HOME/.config"
LOG_FILE="install.log"
NAME="rpki.apnictraining.net"
NETPLAN_IP="192.168.30.240"

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

# Copy LXC template
function copyLXC()
{
  HOSTNAME="$1"
  IP="$2"
  echo "###### Copying template.apnictraining.net to $HOSTNAME ...." | tee -a $LOG_FILE
  if [[ $(lxc-ls -f | grep template | awk '{print $2}') == "RUNNING" ]]; then
    lxc-stop -n template.apnictraining.net >> $LOG_FILE
  fi
  lxc-copy -n template.apnictraining.net -N $HOSTNAME >> $LOG_FILE
  echo "###### Update IP and Host details to: " | tee -a $LOG_FILE
  # Update the IP address
  sed -i 's/192.168.30.100/'"$IP"'/' /var/lib/lxc/$HOSTNAME/rootfs/etc/netplan/10-lxc.yaml
  more /var/lib/lxc/$HOSTNAME/rootfs/etc/netplan/10-lxc.yaml | grep address | tee -a $LOG_FILE
  # Update host file
  sed -i 's/template.apnictraining.net/'"$HOSTNAME"'/' /var/lib/lxc/$HOSTNAME/rootfs/etc/hosts
  more /var/lib/lxc/$HOSTNAME/rootfs/etc/hosts | grep 127.0.1.1 | tee -a $LOG_FILE
}

# Create LXC template
function createLXCtemplate()
{
  if [[ $(lxc-ls -f | grep template | awk -F . '{print $1}') == "template" ]]; then
    echo "###### template.apnictraining.net already configured" | tee -a $LOG_FILE
  else
    echo "###### Creating template.apnictraining.net" | tee -a $LOG_FILE
    # add a template for Ubuntu-apnic
    # This sets the default user name to apnic and password to training
    sudo cp /usr/share/lxc/templates/lxc-ubuntu /usr/share/lxc/templates/lxc-ubuntu-apnic >> $LOG_FILE
    sudo sed -i 's/user=\$4/user=apnic/' /usr/share/lxc/templates/lxc-ubuntu-apnic >> $LOG_FILE
    sudo sed -i 's/user=\"ubuntu\"/user=apnic/' /usr/share/lxc/templates/lxc-ubuntu-apnic >> $LOG_FILE
    sudo sed -i 's/password=\"ubuntu\"/password=training/' /usr/share/lxc/templates/lxc-ubuntu-apnic >> $LOG_FILE
    # Download and create a container
    sudo lxc-create -n template.apnictraining.net -t ubuntu-apnic >> $LOG_FILE
    echo "###### Update IP details to 192.168.30.100" | tee -a $LOG_FILE
    # Update the IP address
    sudo cp 10-lxc.yaml /var/lib/lxc/template.apnictraining.net/rootfs/etc/netplan/10-lxc.yaml >> $LOG_FILE
    sudo lxc-stop -n template.apnictraining.net >> $LOG_FILE
    #updateLXCtemplate
  fi
}

function updateLXCtemplate()
{
  echo "###### Updating template.apnictraining.net" | tee -a $LOG_FILE
  sudo lxc-start -d -n template.apnictraining.net >> $LOG_FILE
  sudo lxc-attach --name template.apnictraining.net >> $LOG_FILE
  updatePackages
  installSSH
  # Trick to pass Ctrl+D to the CLI to exit lxc container
  cat /dev/null | read eofvar >> $LOG_FILE
  $eofvar >> $LOG_FILE
  echo "###### SSH installed on template" | tee -a $LOG_FILE
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

# Install LXC
function installLXC()
{
  if [[ $(checkSuccess lxctl) == "Success!" ]]; then
    echo "###### LXC already installed" | tee -a $LOG_FILE
  else
    echo "###### Installing LXC LXCTL LXC-Templates" | tee -a $LOG_FILE
    apt-get update -qq >> $LOG_FILE
    apt-get install -qq lxc lxctl lxc-templates >> $LOG_FILE
    checkSuccess lxc
  fi
}

# Setup RPKI container
function SetupRPKIContainer()
{
  if [[ $(lxc-ls -f | grep rpki | awk -F . '{print $1}') == "rpki" ]]; then
    echo "###### Removing RPKI container" | tee -a $LOG_FILE
    if [[ $(lxc-ls -f | grep rpki | awk '{print $2}') == "RUNNING" ]]; then 
      lxc-stop -n $NAME >> $LOG_FILE
    fi
    lxc-destroy -n $NAME >> /dev/null >> $LOG_FILE
  fi
    echo "###### Creating RPKI container" | tee -a $LOG_FILE
    copyLXC $NAME $NETPLAN_IP
    # cd /var/lib/lxc/$NAME/
    # tar --numeric-owner -xzvf $NAME.tar.gz .
    #checkSuccess lxc
}

# Copy scripts to the Documents folder
function copyScripts()
{
  mkdir -p $SCRIPT_DIR >> $LOG_FILE
  cp scripts/*.* $SCRIPT_DIR/. >> $LOG_FILE
  chmod u+x $SCRIPT_DIR/*.sh >> $LOG_FILE
}

# Copy scripts to the Documents folder
function setupDynamips()
{
  mkdir -p $WORKSHOP_DYNAMIPS_DIR $IMAGE_DIR >> $LOG_FILE
  cp -R dynamips/*.* $WORKSHOP_DYNAMIPS_DIR/. >> $LOG_FILE
  chmod u+x $WORKSHOP_DYNAMIPS_DIR/*.sh >> $LOG_FILE
}


# Run the functions 
checkRoot
checkUbuntu
updatePackages
installSSH
installDynamips
installDynagen
enableForwarding
installLXC
createLXCtemplate
SetupRPKIContainer
copyScripts
setupDynamips
echo "####### Installation Finished. Workshop files are located:" | tee -a $LOG_FILE
echo "####### $WORKSHOP_DYNAMIPS_DIR" | tee -a $LOG_FILE
echo "####### $CURRENT_DIR" | tee -a $LOG_FILE
echo "####### $HOME/Documents/scripts/" | tee -a $LOG_FILE
echo "####### /var/lib/lxc/$NAME/" | tee -a $LOG_FILE
