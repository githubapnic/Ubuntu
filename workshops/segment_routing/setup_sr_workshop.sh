#!/bin/bash
# This script automates the installation of a applications on Ubuntu 18.04 LTS.
# For the segment routing workshop
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
SR1_URL="https://github.com/githubapnic/Ubuntu/raw/master/workshops/segment_routing/SR1-2020.zip"


GNS_PORT="3080"
#GNS_VERS="2.1.8"
GNS_VERS="2.2.5"
SSH_PORT="22"
RDP_PORT="3389"

USERNAME=$1
PASSWORD=$2

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

# Update packages via apt
function updatePackages()
{
  echo "###### Updating Packages" | tee -a $LOG_FILE
  apt-get update -qq >> $LOG_FILE
  apt-get upgrade -qq >> $LOG_FILE
}

# Install packages via apt
function installPackages()
{
  echo "###### Installing New Packages" | tee -a $LOG_FILE
  apt-get install -qq $(cat packagelist) >> $LOG_FILE
  dpkg -l $(cat packagelist) &> /dev/null && echo "Success!" 
}

# Install a GUI
function installxfce4()
{
  echo "###### Installing xfce4 Packages" | tee -a $LOG_FILE
  apt-get install -qq xfce4 >> $LOG_FILE
  dpkg -l xfce4 &> /dev/null && echo "Success!" 
}

# Install and enable xrdp
function installxrdp()
{
  # https://docs.microsoft.com/en-us/azure/virtual-machines/linux/use-remote-desktop
  echo "###### Installing xrdp Packages" | tee -a $LOG_FILE
  apt-get install -qq xrdp >> $LOG_FILE
  dpkg -l xrdp &> /dev/null && echo "Success!" 
  systemctl enable xrdp | tee -a $LOG_FILE
  echo xfce4-session >~/.xsession | tee -a $LOG_FILE
  systemctl restart xrdp | tee -a $LOG_FILE
}

function installSSH()
{
  echo "####### Installing SSH server" | tee -a $LOG_FILE
  apt-get install -qq openssh-server >> $LOG_FILE
  checkSuccess ssh
}

# Install gns3-server and GUI via pip3
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
  gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'gns3.desktop']"
  # sudo cp /usr/local/share/applications/gns3.desktop ~/Desktop/.
  # sudo chmod +x ~/Desktop/gns3.desktop
  # sudo chown ${USER}:${USER} ~/Desktop/gns3.desktop
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

# Install VirtualBox
function InstallVirtualBox()
{
  echo "###### Installing VirtualBox" | tee -a $LOG_FILE
  apt-get install -qq virtualbox >> $LOG_FILE
  dpkg -l virtualbox &> /dev/null && echo "Success!" 
} 

# Open ports in UFW
function configUFW()
{
  echo "###### Configuring UFW" | tee -a $LOG_FILE
  ufw allow $SSH_PORT >> $LOG_FILE
  ufw allow $GNS_PORT >> $LOG_FILE
  ufw allow $RDP_PORT >> $LOG_FILE
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
  read -s -p password
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

#Install Wireshark
function installwireshark()
{
  echo "####### Installing wireshark" | tee -a $LOG_FILE
  add-apt-repository -y ppa:wireshark-dev/stable >> $LOG_FILE
  apt-get update -qq >> $LOG_FILE
  # Fix to bypass the interactive prompt
  # https://unix.stackexchange.com/questions/367866/how-to-choose-a-response-for-interactive-prompt-during-installation-from-a-shell
  echo "wireshark-common wireshark-common/install-setuid boolean true" | sudo debconf-set-selections
  sudo DEBIAN_FRONTEND=noninteractive apt-get -y -qq install wireshark | tee -a $LOG_FILE
  #apt-get install -y -qq wireshark | tee -a $LOG_FILE
  addgroup -system wireshark >> $LOG_FILE
  #echo "adding $USER to wireshark group"  | tee -a $LOG_FILE
  echo "adding ${SUDO_USER} to wireshark group"  | tee -a $LOG_FILE
  #usermod -a -G wireshark $USER >> $LOG_FILE
  usermod -a -G wireshark $SUDO_USER >> $LOG_FILE
  chgrp wireshark /usr/bin/dumpcap >> $LOG_FILE
  chmod 750 /usr/bin/dumpcap >> $LOG_FILE
  setcap cap_net_raw,cap_net_admin=eip /usr/bin/dumpcap >> $LOG_FILE
  gsettings set org.gnome.shell favorite-apps "$(gsettings get org.gnome.shell favorite-apps | sed s/.$//), 'wireshark.desktop']"
  checkSuccess wireshark
}

function removePackages()
{
  echo "###### Deleting Packages" | tee -a $LOG_FILE
  apt-get update -qq >> $LOG_FILE
  #apt-get upgrade -qq >> $LOG_FILE
  apt-get remove --purge -qq $(cat packagelist_removal) >> $LOG_FILE
  dpkg -l $(cat packagelist_removal) &> /dev/null && echo "Not removed!" 
  apt-get clean -qq >> $LOG_FILE
  apt-get autoremove -qq >> $LOG_FILE
  apt-get update -qq >> $LOG_FILE
  cat $LOG_FILE
}

function disableAutoUpdates()
{
  echo "###### Updating Packages" | tee -a $LOG_FILE
  apt-get update -qq >> $LOG_FILE
  apt-get upgrade -qq >> $LOG_FILE
  echo "###### Disable Auto Updates" | tee -a $LOG_FILE
  sed -i "s/Upgrade \"1/Upgrade \"0/" /etc/apt/apt.conf.d/20auto-upgrades
  echo "cat /etc/apt/apt.conf.d/20auto-upgrades" >> $LOG_FILE
  cat /etc/apt/apt.conf.d/20auto-upgrades | tee -a $LOG_FILE
}

function createRestrictedUser()
{
  echo "###### Create Restricted User" | tee -a $LOG_FILE
  if [[ -z $USERNAME ]]; then
    read -p 'Enter Restricted username for SSH access: ' user >> $LOG_FILE
    read -sp 'Enter password: ' password
    echo
  else
    user=$USERNAME
    password=$PASSWORD
  fi
  useradd -m $user -s /bin/rbash | tee -a $LOG_FILE
  echo "$user:$password" | chpasswd 
  mkdir -p /home/$user/bin | tee -a $LOG_FILE
  ln -s /usr/bin/telnet /home/$user/bin | tee -a $LOG_FILE
  ln -s /bin/ping /home/$user/bin | tee -a $LOG_FILE
  ln -s /usr/bin/ssh /home/$user/bin | tee -a $LOG_FILE
  chown root. /home/$user/.profile | tee -a $LOG_FILE
  chmod 755 /home/$user/.profile | tee -a $LOG_FILE
}

SetupGNSProject()
{

  echo "###### Downloading GNS3 Segment Routing project SR-1" | tee -a $LOG_FILE
  wget -q $SR1_URL >> $LOG_FILE || echo "Error downloading SR-1." | tee -a $LOG_FILE
  mkdir -p $PROJECT_DIR | tee -a $LOG_FILE
  unzip SR1-2020.zip -d $PROJECT_DIR | tee -a $LOG_FILE
  chown -R $SUDO_USER:$SUDO_USER $GNS_DIR
  mkdir -p $HOME/iso
  chown -R $SUDO_USER:$SUDO_USER $HOME/iso
}

# Run the functions 
checkRoot
checkUbuntu
updatePackages
installxfce4
removePackages
disableAutoUpdates
updatePackages
installPackages
installxrdp
installSSH
installGNS3
installGNS3-GUI
#installGNS3-IOU
#installDocker
installDynamips
installDynagen
installUbridge
#installVPCS
#configUFW
#configureGNS3
#installwireshark
updatePackages
#createRestrictedUser
SetupGNSProject
InstallVirtualBox

echo "####### Installation Finished." | tee -a $LOG_FILE
echo " Make sure to import the OVA into virtualbox" | tee -a $LOG_FILE
echo " before starting the GNS3 project" | tee -a $LOG_FILE
echo " Please restart to complete the installation." | tee -a $LOG_FILE