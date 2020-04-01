#!/bin/bash
# This script automates the setup of workshops on Ubuntu 18.04 LTS.
# Ensure the directories, credentials and ports specified in the variables below are 
# what you want.

# Credit: Script based on GNS3 installation script
# https://github.com/rhelshane/Install-GNS3-Server


# Declare variables
CURRENT_DIR=$(pwd)
WORKSHOP_DYNAMIPS_DIR="$HOME/virtual_labs/rpki"
SCRIPT_DIR="$HOME/Documents/scripts/"
IMAGE_DIR="$HOME/virtual_labs/images"
LXCWEBPANEL_DIR="$HOME/virtual_labs/lxcwebpanel/"
LOG_FILE="install.log"
NAME="rpki.apnictraining.net"
VETH_NAME="rpki"
NETPLAN_IP="192.168.30.240"
USERNAME=$1
PASSWORD=$2
#TEMPLATE_PACKAGES="openssh-server gcc curl build-essential rsync wget jansson"
TEMPLATE_PACKAGES="openssh-server,gcc,curl,build-essential,rsync,wget,jansson"

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

# Copy LXC template
function copyLXC()
{
  HOSTNAME="$1"
  IP="$2"
  VETH_NAME=$(echo $HOSTNAME | awk -F . '{print $1}')
  echo "###### Copying template.apnictraining.net to $HOSTNAME & $VETH_NAME" | tee -a $LOG_FILE
  if [[ $(lxc-ls -f | grep template | awk '{print $2}') == "RUNNING" ]]; then
    lxc-stop -n template.apnictraining.net >> $LOG_FILE
  fi
  lxc-copy -n template.apnictraining.net -N $HOSTNAME >> $LOG_FILE
  echo "###### Update IP and Host details to: " | tee -a $LOG_FILE
  # Update the IP address
  sudo cp -p /var/lib/lxc/template.apnictraining.net/rootfs/etc/netplan/10-lxc.yaml /var/lib/lxc/$HOSTNAME/rootfs/etc/netplan/10-lxc.yaml &>> $LOG_FILE
  sudo sed -i 's/192.168.30.100/'"$IP"'/' /var/lib/lxc/$HOSTNAME/rootfs/etc/netplan/10-lxc.yaml &>> $LOG_FILE
  sudo sed -i 's/lxc.net.0.veth.pair \= template/lxc.net.0.veth.pair \= '"$VETH_NAME"'/' /var/lib/lxc/$HOSTNAME/config &>> $LOG_FILE
  more /var/lib/lxc/$HOSTNAME/rootfs/etc/netplan/10-lxc.yaml | grep address | tee -a $LOG_FILE
  # Add script to help with installation of routinator
  mkdir -p /var/lib/lxc/$HOSTNAME/rootfs/home/apnic/scripts/ &>> $LOG_FILE
  sudo cp -p installRoutinator.sh /var/lib/lxc/$HOSTNAME/rootfs/home/apnic/scripts/installRoutinator.sh &>> $LOG_FILE
  chmod 744 /var/lib/lxc/$HOSTNAME/rootfs/home/apnic/scripts/installRoutinator.sh &>> $LOG_FILE
  # Update host file
  sudo sed -i 's/template.apnictraining.net/'"$HOSTNAME"'/' /var/lib/lxc/$HOSTNAME/rootfs/etc/hosts
  sudo sed -i 's/template.apnictraining.net/'"$HOSTNAME"'/' /var/lib/lxc/$HOSTNAME/rootfs/etc/hostname
  more /var/lib/lxc/$HOSTNAME/rootfs/etc/hosts | grep 127.0.1.1 | tee -a $LOG_FILE
}

# Create LXC template
function createLXCtemplate()
{
  if [[ $(lxc-ls -f | grep template | awk -F . '{print $1}') == "template" ]]; then
    echo "###### template.apnictraining.net already configured" | tee -a $LOG_FILE
  else
    echo "###### Creating template.apnictraining.net" | tee -a $LOG_FILE
	if [[ -z $USERNAME ]]; then
	  read -p 'Enter username for LXC template: ' user >> $LOG_FILE
      read -sp 'Enter password: ' password
	  echo
	else
      user=$USERNAME
      password=$PASSWORD
	fi
	echo "###### Please wait while template.apnictraining.net is downloaded and created ..." | tee -a $LOG_FILE
	echo "###### Depending on internet speed this may take more than 10 minutes"
    # add a template for Ubuntu-apnic
    sudo cp -p /usr/share/lxc/templates/lxc-ubuntu /usr/share/lxc/templates/lxc-ubuntu-apnic >> $LOG_FILE
	if [[ -z $TEMPLATE_PACKAGES ]]; then
	  sudo sed -i 's/apt-transport-https,ssh,vim/nano/' /usr/share/lxc/templates/lxc-ubuntu-apnic  >> $LOG_FILE
	else
	  sudo sed -i 's/apt-transport-https,ssh,vim/$TEMPLATE_PACKAGES,nano/' /usr/share/lxc/templates/lxc-ubuntu-apnic  >> $LOG_FILE
	fi
	#sudo sed -i 's/packages_template\=\"\${packages_t/\#packages_template\=\"\${packages_t/' /usr/share/lxc/templates/lxc-ubuntu-apnic >> $LOG_FILE
    # Download and create a container
	#sudo lxc-create -n template.apnictraining.net -t ubuntu-apnic -- --user $user --password $password --packages $TEMPLATE_PACKAGES --variant minbase >> $LOG_FILE
	sudo lxc-create -n template.apnictraining.net -t ubuntu-apnic -- --user $user --password $password &>> $LOG_FILE
    echo "###### Update IP details to 192.168.30.100" | tee -a $LOG_FILE
    # Update the IP address
	sudo mkdir -p /var/lib/lxc/template.apnictraining.net/rootfs/etc/netplan/ >> $LOG_FILE
    sudo cp 10-lxc.yaml /var/lib/lxc/template.apnictraining.net/rootfs/etc/netplan/10-lxc.yaml >> $LOG_FILE
	echo "lxc.net.0.veth.pair = template" >> /var/lib/lxc/template.apnictraining.net/config
	if [[ $(lxc-ls -f | grep template | awk '{print $2}') == "RUNNING" ]]; then 
      sudo lxc-stop -n template.apnictraining.net >> $LOG_FILE
    fi
	cat /var/lib/lxc/template.apnictraining.net/rootfs/etc/netplan/10-lxc.yaml | grep address | tee -a $LOG_FILE
	cat /var/lib/lxc/template.apnictraining.net/rootfs/etc/hosts | grep 127.0.1.1 | tee -a $LOG_FILE
    #updateLXCtemplate
  fi
}
# Create LXC template
function createAPTContainer()
{
  if [[ $(lxc-ls -f | grep apt | awk -F . '{print $1}') == "apt" ]]; then
    echo "###### apt.apnictraining.net already configured" | tee -a $LOG_FILE
  else
    echo "###### Creating apt.apnictraining.net" | tee -a $LOG_FILE
	if [[ -z $USERNAME ]]; then
	  read -p 'Enter username for APT container: ' user >> $LOG_FILE
      read -sp 'Enter password: ' password
	  echo
	else
      user=$USERNAME
      password=$PASSWORD
	fi
	echo "###### Please wait while apt.apnictraining.net is downloaded and created ..." | tee -a $LOG_FILE
	echo "###### Depending on internet speed this may take more than 10 minutes"
    # Download and create a container
	sudo lxc-create -n apt.apnictraining.net -t ubuntu-apnic -- --user $user --password $password &>> $LOG_FILE
    echo "###### Update IP details to 192.168.30.248" | tee -a $LOG_FILE
    # Update the IP address
	sudo mkdir -p /var/lib/lxc/apt.apnictraining.net/rootfs/etc/netplan/ >> $LOG_FILE
    sudo cp ../aptcache/10-lxc.yaml /var/lib/lxc/apt.apnictraining.net/rootfs/etc/netplan/10-lxc.yaml >> $LOG_FILE
	echo "lxc.net.0.veth.pair = apt" >> /var/lib/lxc/apt.apnictraining.net/config
	if [[ $(lxc-ls -f | grep apt | awk '{print $2}') == "RUNNING" ]]; then 
      sudo lxc-stop -n apt.apnictraining.net >> $LOG_FILE
    fi
	cat /var/lib/lxc/apt.apnictraining.net/rootfs/etc/netplan/10-lxc.yaml | grep address | tee -a $LOG_FILE
	cat /var/lib/lxc/apt.apnictraining.net/rootfs/etc/hosts | grep 127.0.1.1 | tee -a $LOG_FILE
    # Copy apt-cache install script to server
	sudo mkdir -p /var/lib/lxc/apt.apnictraining.net/rootfs/home/$USERNAME/scripts/ >> $LOG_FILE
    sudo cp ../aptcache/createAPT-cache.sh /var/lib/lxc/apt.apnictraining.net/rootfs/home/$USERNAME/scripts/. >> $LOG_FILE
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

# Install LXC web portal
function installLXCwebportal()
{
  mkdir -p $LXCWEBPANEL_DIR >> $LOG_FILE
  chown -R $SUDO_USER:$SUDO_USER $LXCWEBPANEL_DIR >> $LOG_FILE
  echo "###### Installing LXC Web Panel" | tee -a $LOG_FILE
  wget -P $LXCWEBPANEL_DIR https://lxc-webpanel.github.io/tools/install.sh -O - | bash | tee -a $LOG_FILE
  echo "###### Updating LXC Web Panel" | tee -a $LOG_FILE
  wget -P $LXCWEBPANEL_DIR https://lxc-webpanel.github.io/tools/update.sh -O - | bash | tee -a $LOG_FILE
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
  echo "###### Copy some useful LXC scripts" | tee -a $LOG_FILE
  mkdir -p $SCRIPT_DIR >> $LOG_FILE
  cp scripts/*.* $SCRIPT_DIR/. >> $LOG_FILE
  chmod u+x $SCRIPT_DIR/*.sh >> $LOG_FILE
  chown -R $SUDO_USER:$SUDO_USER $SCRIPT_DIR >> $LOG_FILE
}

# Copy the files to the rpki dynamips folder
function setupDynamips()
{
  echo "###### Copy RPKI topology files" | tee -a $LOG_FILE
  mkdir -p $WORKSHOP_DYNAMIPS_DIR $IMAGE_DIR >> $LOG_FILE
  chown -R $SUDO_USER:$SUDO_USER $IMAGE_DIR >> $LOG_FILE
  cp -R dynamips/* $WORKSHOP_DYNAMIPS_DIR/. >> $LOG_FILE
  # chmod u+x $WORKSHOP_DYNAMIPS_DIR/*.sh >> $LOG_FILE
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
  echo "$HOME/Documents/scripts/" | tee -a $LOG_FILE
  echo "/var/lib/lxc/$NAME/" | tee -a $LOG_FILE
  echo
  echo "####### Please update $WORKSHOP_DYNAMIPS_DIR/topology.net file with the IOS image." | tee -a $LOG_FILE
  echo "####### Current image name in $IMAGE_DIR:" | tee -a $LOG_FILE
  echo "$(ls ~/virtual_labs/images | grep 720)" | tee -a $LOG_FILE
  echo
  echo "####### Current image name in topology file:" | tee -a $LOG_FILE
  echo "$(head $WORKSHOP_DYNAMIPS_DIR/topology.net | grep image)" | tee -a $LOG_FILE
  echo "##########################################################" | tee -a $LOG_FILE
}

# Update lxc-net to use IP range 192.168.30
function configLXCnet()
{
  echo "####### Set lxcbr0 DHCP settings to 192.168.30.0 range" | tee -a $LOG_FILE
  sudo cp -p /etc/default/lxc-net /etc/default/lxc-net.bak >> $LOG_FILE
  sudo sed -i 's/10.0.3./192.168.30./' /etc/default/lxc-net >> $LOG_FILE
  sudo sed -i 's/10.0.3.254/192.168.30.94/' /etc/default/lxc-net >> $LOG_FILE
  sudo sed -i 's/192.168.30.2\,/192.168.30.65\,/' /etc/default/lxc-net >> $LOG_FILE
  sudo sed -i 's/192.168.30.1/192.168.30.254/' /etc/default/lxc-net >> $LOG_FILE
  sudo sed -i 's/253/30/' /etc/default/lxc-net >> $LOG_FILE
  sudo service lxc-net restart &>> $LOG_FILE
  sudo cat /etc/default/lxc-net | grep 192.168.30. | tee -a $LOG_FILE
}

# Update DNS resolver details
function updateDNSresolver()
{ 
  echo "####### Update name server details: " | tee -a $LOG_FILE
  sudo cp -p /etc/resolvconf/resolv.conf.d/head /etc/resolvconf/resolv.conf.d/head.bak >> $LOG_FILE
  sudo echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/head >> $LOG_FILE
  sudo echo "nameserver 8.8.4.4" >> /etc/resolvconf/resolv.conf.d/head >> $LOG_FILE
  sudo cat /etc/resolvconf/resolv.conf.d/head | grep nameserver | tee -a $LOG_FILE
}

# Run the functions 
checkRoot
checkUbuntu
updatePackages
installSSH
installScreen
installDynamips
installDynagen
enableForwarding
installLXC
# installLXCwebportal
createLXCtemplate
SetupRPKIContainer
createAPTContainer
configLXCnet
updateDNSresolver
copyScripts
setupDynamips
setTimeZone
displayMessage

