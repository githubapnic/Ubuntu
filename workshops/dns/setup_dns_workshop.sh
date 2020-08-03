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
SCRIPT_DIR="$HOME/Documents/scripts/"
LXCWEBPANEL_DIR="$HOME/virtual_labs/lxcwebpanel/"
LOG_FILE="install.log"
ROOTSERVERNAME="x.root-servers.net"
ROOT_VETH_NAME="root"
ROOT_NETPLAN_IP="192.168.100.250"
GTLDSERVERNAME="x.gtld-servers.net"
GTLD_VETH_NAME="gtld"
GTLD_NETPLAN_IP="192.168.100.251"
ROOT_URL="https://github.com/githubapnic/Ubuntu/blob/master/workshops/dns/named-root.zip"
GTLD_URL="https://github.com/githubapnic/Ubuntu/blob/master/workshops/dns/named-gtld.zip"
USERNAME=$1
PASSWORD=$2


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

# Install wget if not already installed
function installWGET()
{
  if [[ $(checkSuccess wget) == "Success!" ]]; then
    echo "###### wget already installed" | tee -a $LOG_FILE
  else
    echo "####### Installing wget" | tee -a $LOG_FILE
    apt-get install -qq wget >> $LOG_FILE
    checkSuccess wget
  fi
}

# Install unzip if not already installed
function installunzip()
{
  if [[ $(checkSuccess unzip) == "Success!" ]]; then
    echo "###### unzip already installed" | tee -a $LOG_FILE
  else
    echo "####### Installing unzip" | tee -a $LOG_FILE
    apt-get install -qq unzip >> $LOG_FILE
    checkSuccess unzip
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

# Copy LXC template
function copyLXC()
{
  HOSTNAME="$1"
  IP="$2"
  VETH_NAME="$3"
  echo "###### Copying template.apnictraining.net to $HOSTNAME" | tee -a $LOG_FILE
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

# Setup root DNS container
function SetupRootContainer()
{
  if [[ $(lxc-ls -f | grep root | awk -F . '{print $1}') == "root" ]]; then
    echo "###### Removing Root container" | tee -a $LOG_FILE
    if [[ $(lxc-ls -f | grep root | awk '{print $2}') == "RUNNING" ]]; then 
      lxc-stop -n $ROOTSERVERNAME >> $LOG_FILE
    fi
    lxc-destroy -n $ROOTSERVERNAME >> /dev/null >> $LOG_FILE
  fi
    echo "###### Creating Root container" | tee -a $LOG_FILE
    copyLXC $ROOTSERVERNAME $ROOT_NETPLAN_IP $ROOT_VETH_NAME
	cp /var/lib/lxc/$ROOTSERVERNAME/rootfs/etc/netplan/10-lxc.yaml /var/lib/lxc/$ROOTSERVERNAME/rootfs/etc/netplan/10-lxc.yaml.old >> $LOG_FILE
	sudo sed -i 's/24/16/' /var/lib/lxc/$ROOTSERVERNAME/rootfs/etc/netplan/10-lxc.yaml >> $LOG_FILE
	# echo "lxc.net.0.veth.pair = $ROOT_VETH_NAME" >> /var/lib/lxc/$ROOTSERVERNAME/config
	wget -q $ROOT_URL >> $LOG_FILE || echo "Error downloading Root files." | tee -a $LOG_FILE
	mv /var/lib/lxc/$ROOTSERVERNAME/rootfs/etc/apt/sources.list /var/lib/lxc/$ROOTSERVERNAME/rootfs/etc/apt/sources.list.old
	cp /etc/apt/sources.list /var/lib/lxc/$ROOTSERVERNAME/rootfs/etc/apt/sources.list
	lxc-start $ROOTSERVERNAME
	lxc-attach -n $ROOTSERVERNAME -- cat /etc/netplan/10-lxc.yaml
	lxc-attach -n $ROOTSERVERNAME -- sudo apt-get update
	lxc-attach -n $ROOTSERVERNAME -- sudo apt-get -y upgrade
	lxc-attach -n $ROOTSERVERNAME -- sudo apt-get install -y build-essential dnsutils curl bind9 bind9utils bind9-doc net-tools screen unzip
	lxc-stop $ROOTSERVERNAME
	#mkdir -p /var/lib/lxc/$ROOTSERVERNAME/rootfs/var/named/master
	unzip -q named-root.zip -d /var/lib/lxc/$ROOTSERVERNAME/rootfs/etc/bind/ | tee -a $LOG_FILE
}

# Setup gtld DNS container
function SetupGtldContainer()
{
  if [[ $(lxc-ls -f | grep gtld | awk -F . '{print $1}') == "gtld" ]]; then
    echo "###### Removing GTLD container" | tee -a $LOG_FILE
    if [[ $(lxc-ls -f | grep gtld | awk '{print $2}') == "RUNNING" ]]; then 
      lxc-stop -n $GTLDSERVERNAME >> $LOG_FILE
    fi
    lxc-destroy -n $GTLDSERVERNAME >> /dev/null >> $LOG_FILE
  fi
    echo "###### Creating GTLD container" | tee -a $LOG_FILE
    copyLXC $GTLDSERVERNAME $GTLD_NETPLAN_IP $GTLD_VETH_NAME
	cp /var/lib/lxc/$GTLDSERVERNAME/rootfs/etc/netplan/10-lxc.yaml /var/lib/lxc/$GTLDSERVERNAME/rootfs/etc/netplan/10-lxc.yaml.old >> $LOG_FILE
	sed -i 's/24/16/' /var/lib/lxc/$GTLDSERVERNAME/rootfs/etc/netplan/10-lxc.yaml >> $LOG_FILE
	
	# echo "lxc.net.0.veth.pair = $GTLD_VETH_NAME" >> /var/lib/lxc/$GTLDSERVERNAME/config
	wget -q $GTLD_URL >> $LOG_FILE || echo "Error downloading GTLD." | tee -a $LOG_FILE
	mv /var/lib/lxc/$GTLDSERVERNAME/rootfs/etc/apt/sources.list /var/lib/lxc/$GTLDSERVERNAME/rootfs/etc/apt/sources.list.old
	cp /etc/apt/sources.list /var/lib/lxc/$GTLDSERVERNAME/rootfs/etc/apt/sources.list
	lxc-start $GTLDSERVERNAME
	lxc-attach -n $GTLDSERVERNAME -- sudo apt-get update | tee -a $LOG_FILE
	lxc-attach -n $GTLDSERVERNAME -- sudo apt-get -y upgrade | tee -a $LOG_FILE
	lxc-attach -n $GTLDSERVERNAME -- sudo apt-get install -y build-essential dnsutils curl bind9 bind9utils bind9-doc net-tools screen unzip
	lxc-stop $GTLDSERVERNAME
	#mkdir -p /var/lib/lxc/$GTLDSERVERNAME/rootfs/var/named/master
	unzip -q named-gtld.zip -d /var/lib/lxc/$GTLDSERVERNAME/rootfs/etc/bind/ | tee -a $LOG_FILE
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

# Update DNS resolver details
function updateDNSresolver()
{ 
  echo "####### Update name server details: " | tee -a $LOG_FILE
  sudo cp -p /etc/resolvconf/resolv.conf.d/head /etc/resolvconf/resolv.conf.d/head.bak >> $LOG_FILE
  sudo echo "nameserver 8.8.8.8" >> /etc/resolvconf/resolv.conf.d/head >> $LOG_FILE
  sudo echo "nameserver 8.8.4.4" >> /etc/resolvconf/resolv.conf.d/head >> $LOG_FILE
  sudo cat /etc/resolvconf/resolv.conf.d/head | grep nameserver | tee -a $LOG_FILE
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
  sudo sed -i 's/255.255.255.0/255.255.0.0/' /etc/default/lxc-net >> $LOG_FILE
  sudo service lxc-net restart &>> $LOG_FILE
  sudo cat /etc/default/lxc-net | grep 192.168.30. | tee -a $LOG_FILE
}

# Display message about where files are located
function displayMessage()
{
  echo "##########################################################" | tee -a $LOG_FILE
  echo "####### Installation Finished.   #########################" | tee -a $LOG_FILE
  echo "##########################################################" | tee -a $LOG_FILE
}

# Update IPtables to allow traffic from 192.168.100.0/16 to Internet
function updateIPtables()
{
  echo "####### Update iptables: " | tee -a $LOG_FILE
  if [[ $(checkSuccess iptables-persistent) == "Success!" ]]; then
    echo "###### iptables-persistent already installed" | tee -a $LOG_FILE
  else
    echo "####### Installing iptables-persistent" | tee -a $LOG_FILE
	sudo apt install -qq iptables-persistent netfilter-persistent | tee -a $LOG_FILE
  fi
  if [[ $(checkSuccess netfilter-persistent) == "Success!" ]]; then
    echo "###### netfilter-persistent already installed" | tee -a $LOG_FILE
  else
    echo "####### Installing netfilter-persistent" | tee -a $LOG_FILE
	sudo apt install -qq iptables-persistent netfilter-persistent | tee -a $LOG_FILE
  fi
  sudo iptables -t nat -D POSTROUTING -s 192.168.100.0/24 ! -d 192.168.100.0/24 -j MASQUERADE >> $LOG_FILE
  sudo iptables -t nat -A POSTROUTING -s 192.168.100.0/24 ! -d 192.168.100.0/24 -j MASQUERADE >> $LOG_FILE
  sudo netfilter-persistent save >> $LOG_FILE
  sudo netfilter-persistent reload >> $LOG_FILE
  sleep 7
}

##########################################
# Run the functions 
##########################################

checkRoot
checkUbuntu
updatePackages
installSSH
installWGET
installScreen
installunzip
enableForwarding
installLXC
# installLXCwebportal
createLXCtemplate
configLXCnet
updateIPtables
SetupRootContainer
SetupGtldContainer
# createAPTContainer
# updateDNSresolver
# copyScripts
displayMessage

