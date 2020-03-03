#!/bin/bash
# This script automates the installation of a applications on Ubuntu 18.04 LTS.
# Ensure the directories, credentials and ports specified in the variables below are 
# what you want.

# Credit: Script based on GNS3 installation script
# https://github.com/rhelshane/Install-GNS3-Server


# Declare variables
CURRENT_DIR=$(pwd)
GNS_DIR="$HOME/GNS3"
IMAGE_DIR="$HOME/GNS3/Images"
APPLIANCE_DIR="$HOME/GNS3/Appliances"
PROJECT_DIR="$HOME/GNS3/Project"
CONFIG_DIR="$HOME/.config"
LOG_FILE="install.log"
VPCS_URL="http://sourceforge.net/projects/vpcs/files/0.8/vpcs_0.8b_Linux64/download"


GNS_PORT="3080"
#GNS_VERS="2.1.8"
GNS_VERS="2.2.5"
SSH_PORT="22"


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


function updatePackages()
{
  echo "###### Updating Packages" | tee -a $LOG_FILE
  apt-get update -qq >> $LOG_FILE
  apt-get upgrade -qq >> $LOG_FILE
  echo "###### Installing New Packages" 
  apt-get install -qq $(cat packagelist) >> $LOG_FILE
  dpkg -l $(cat packagelist) &> /dev/null && echo "Success!" 
}

# Update packages via apt and install gns3-server via pip3
function installGNS3()
{
  echo "####### Installing GNS3" | tee -a $LOG_FILE
  pip3 install -qq gns3-server==$GNS_VERS >> $LOG_FILE
  checkSuccess gns3server
}

function installGNS3-GUI()
{
  echo "####### Installing GNS3 GUI" | tee -a $LOG_FILE
  pip3 install -q gns3-gui==$GNS_VERS >> $LOG_FILE
  gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'org.gnome.Terminal.desktop']"
  # sudo cp /usr/local/share/applications/gns3.desktop ~/Desktop/.
  # sudo chmod +x ~/Desktop/gns3.desktop
  # sudo chown ${USER} ~/Desktop/gns3.desktop
  checkSuccess gns3
}

#Install GNS3-IOU
function installGNS3-IOU()
{
  echo "####### Installing GNS3 IOU" | tee -a $LOG_FILE
  dpkg --add-architecture i386 >> $LOG_FILE
  apt-get update -qq >> $LOG_FILE
  apt-get install gns3-iou >> $LOG_FILE
  checkSuccess gns3-iou
}


#Install docker
function installDocker()
{
  echo "###### Installing Docker" | tee -a $LOG_FILE
  apt-get install -qq docker.io >> $LOG_FILE
  echo "###### Enabling Docker" | tee -a $LOG_FILE
  systemctl start docker >> $LOG_FILE
  systemctl enable docker >> $LOG_FILE
  checkSuccess docker
}


# Install the 32-bit version of dynamips (more stable)
function installDynamips()
{
  echo "###### Installing dynamips" | tee -a $LOG_FILE
  dpkg --add-architecture i386 >> $LOG_FILE
  apt-get update -qq >> $LOG_FILE
  apt-get install -qq dynamips:i386 >> $LOG_FILE
  checkSuccess dynamips
}


# Install dynagen
function installDynagen()
{
  echo "###### Installing dynagen" | tee -a $LOG_FILE
  apt-get update -qq >> $LOG_FILE
  apt-get install -qq dynagen >> $LOG_FILE
  checkSuccess dynagen
}

# Clone, build and install ubridge
function installUbridge()
{
  echo "###### Installing ubridge" | tee -a $LOG_FILE
  git clone -q https://github.com/GNS3/ubridge.git || echo "Error cloning ubridge."
  cd ubridge
  make >> $LOG_FILE
  make install >> $LOG_FILE
  cd $CURRENT_DIR
  checkSuccess ubridge
}


# Install VPCS
function installVPCS()
{
  echo "###### Installing VPCS" | tee -a $LOG_FILE
  wget -q $VPCS_URL >> $LOG_FILE || echo "Error downloading VPCS."
  mv download vpcs >> $LOG_FILE
  chmod +x vpcs >> $LOG_FILE
  mv vpcs /usr/local/bin/ 
  checkSuccess vpcs
} 


# Open ports in UFW
function configUFW()
{
  echo "###### Configuring UFW" | tee -a $LOG_FILE
  ufw allow $SSH_PORT >> $LOG_FILE
  ufw allow $GNS_PORT >> $LOG_FILE
  ufw allow 2000:2050/tcp >> $LOG_FILE
  ufw allow 2000:2050/udp >> $LOG_FILE
  ufw allow 3000:3050/tcp >> $LOG_FILE
  ufw allow 3000:3050/udp >> $LOG_FILE
  ufw allow 5000:6000/tcp >> $LOG_FILE
  ufw allow 5000:6000/udp >> $LOG_FILE
  ufw allow 10000:11000/tcp >> $LOG_FILE
  ufw allow 10000:11000/udp >> $LOG_FILE
  systemctl enable ufw >> $LOG_FILE
  ufw --force enable >> $LOG_FILE
}


# Update the GNS3 config file
function configureGNS3()
{
  echo "###### Configuring GNS3" | tee -a $LOG_FILE
  printf "Enter GNS3 username: "
  read user
  printf "Enter GNS3 password: "
  read password
  clear
  echo "###### Configuring GNS3 config file" 
  GNS_USER=$user
  GNS_PASS=$password
  mkdir -p $GNS_DIR $CONFIG_DIR $IMAGE_DIR $APPLIANCE_DIR $PROJECT_DIR || echo "Error making folders"
  sed -i "s/___USER___/$GNS_USER/" GNS3.conf
  sed -i "s/___PASS___/$GNS_PASS/" GNS3.conf	
  sed -i "s/___PORT___/$GNS_PORT/" GNS3.conf
  sed -i "s@___IMAGE_DIR___@$IMAGE_DIR@" GNS3.conf
  sed -i "s@___APPLIANCE_DIR___@$APPLIANCE_DIR@" GNS3.conf
  sed -i "s@___PROJECT_DIR___@$PROJECT_DIR@" GNS3.conf
  sed -i "s/^enable_kvm.*$/enable_kvm = False/" GNS3.conf
  cp GNS3.conf $CONFIG_DIR || echo "Error copying GNS3.conf"
}


# Run the functions 
checkRoot
updatePackages
installGNS3
installGNS3-GUI
#installGNS3-IOU
installDocker
installDynamips
installDynagen
installUbridge
installVPCS
#configUFW
#configureGNS3
