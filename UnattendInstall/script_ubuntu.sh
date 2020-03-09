#!/bin/bash
# This script automates the creation of an unattended installation ISO for Ubuntu

# Credit: Script based on ubuntu Automatic installer script
# https://github.com/asniii/Automating-ubuntu-preseed 


# Declare variables
CURRENT_DIR=$(pwd)
LOCAL_UBUNTU_VERSION=$(lsb_release -rs)
LOG_FILE="install.log"
ISO_LOCATION=""
UBUNTU_VERSION=""
## Set language to use
LANGUAGE="en_US.UTF-8"
## Initialise user details
FULLNAME="apnic"
USERNAME="apnic"
PASSWORD1=""
PASSWORD2=""
HOSTNAME="apnic-vm"

# Ensure script is run as root user (not a super secure script)
function checkRoot()
{
  if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
  fi
}

# Get which version of Ubuntu to create ISO for
function whichUbuntu()
{
  echo "Please choose ubuntu version-- "
  echo " press 1 for ubuntu 16.04 Desktop"
  echo " press 2 for ubuntu 16.04 Server"
  echo " press 3 for ubuntu 18.04 Desktop"
  echo " press 4 for ubuntu 18.04 Server"
  read -p "Enter your choice: " choice
  case $choice in
    1)
       $UBUNTU_VERSION="16.04 Desktop";;
    2)
       $UBUNTU_VERSION="16.04 Server";;  
    3)
       $UBUNTU_VERSION="18.04 Desktop";;
    4)
       $UBUNTU_VERSION="18.04 Server";;
    * )
       echo "not a valid option "
       exit 1
	   ;;
  esac
}

# Get the ISO image and extract
function extractISO()
{
  echo "###############################################################"
  echo "###############################################################"
  echo "#############   Preparing Ubuntu $UBUNTU_VERSION ##############"
  echo "###############################################################"
  echo "###############################################################"
  read -p  "Where is the downloaded iso location" loc	
  if [ -f "$loc" && $(echo "$loc" | grep ".iso" ) ]
  then
    echo "Loading ISO"
	cp $(echo $loc) ./ubuntu${UBUNTU_VERSION:0:2}.iso
	mkdir iso
	sudo mount -o loop ubuntu${UBUNTU_VERSION:0:2}.iso ./iso
	rsync -avr ./iso/ ./extract/
	sudo chmod 777 -R extract
	sudo umount ./iso
	sudo rm -R ./iso
	sudo rm ubuntu${UBUNTU_VERSION:0:2}.iso
	rm ./extract/isolinux/isolinux.cfg				
	rm ./extract/isolinux/txt.cfg
	rm ./extract/isolinux/langlist
	if [ echo $UBUNTU_VERSION | grep Desktop ] 
	then 
	  rm ./extract/preseed/ubuntu.seed
	  cp ./files/${UBUNTU_VERSION:0:2}/isolinux.cfg ./extract/isolinux/isolinux.cfg
	  cp ./files/${UBUNTU_VERSION:0:2}/txt.cfg ./extract/isolinux/txt.cfg
	else
	  rm ./extract/preseed/ubuntu-server.seed
	  cp ./files/${UBUNTU_VERSION:0:2}ser/isolinux.cfg ./extract/isolinux/isolinux.cfg
	  cp ./files/${UBUNTU_VERSION:0:2}ser/txt.cfg ./extract/isolinux/txt.cfg
	fi
  else 
    echo "not a valid iso file "
	exit 1
  fi
}

# Select a Language for installation
function whichLanguage()
{
  echo "###############################################################"
  echo "###############################################################"
  echo "########## Choose a language for installation purpose #########"
  echo "###############################################################"
  echo "###############################################################"
  echo "press 1 for arabic"
  echo "press 2 for belarusia"
  echo "press 3 for bosnian"
  echo "press 4 for chinese"
  echo "press 5 for czech"
  echo "press 6 for danish"
  echo "press 7 for english_us"
  echo "press 8 for english"
  echo "press 9 for french"
  echo "press 10 for german"
  echo "press 11 for hebrew"
  echo "press 12 for hindi"
  echo "press 13 for japanese"
  echo "press 14 for kannada"
  echo "press 15 for malayalam"
  echo "press 16 for portugese"
  echo "press 17 for russian"
  echo "press 18 for tamil"
  read lang
  case $lang in 
		1 )
			LANGUAGE="af_ZA.UTF-8";;
		2 )
			LANGUAGE="be_BY.UTF-8";;
		3 )
			LANGUAGE="bs_BA.UTF-8";;
		4 )
			LANGUAGE="zh_CN.UTF-8";; 
		5 )
			LANGUAGE="cs_CZ.UTF-8";;
		6 )
			LANGUAGE="da_DK.UTF-8";;
		7 )
			LANGUAGE="en_US.UTF-8";;
		8 )
			LANGUAGE="en.UTF-8";;
		9 )
			LANGUAGE="fr_FR.UTF-8";;
		10 )
			LANGUAGE="de_DE.UTF-8";;
		11 )
			LANGUAGE="he_IL.UTF-8";;
		12 )
			LANGUAGE="hi_IN.UTF-8";;
		13 )
			LANGUAGE="ja_JP.UTF-8";;
		14 )
			LANGUAGE="kn_IN.UTF-8";;
		15 )
			LANGUAGE="ml_IN.UTF-8";;
		16 )
			LANGUAGE="pt_PT.UTF-8";;
		17 )
			LANGUAGE="ru_RU.UTF-8";;
		18 )
			LANGUAGE="ta_IN.UTF-8";;
		* )
			;;
	esac
	echo $LANGUAGE >> ./extract/isolinux/langlist
}

# Get details for installation
function getUserDetails ()
{
  echo "#########################################################"
  echo "#########################################################"
  read -p " Enter the user-fullname: " FULLNAME
  read -p "\n Enter the username: " USERNAME
  read -s -p "\n Enter the password: " PASSWORD1
  read -s -p "\n Enter the password again: " PASSWORD2
  read -p "\n Enter the hostname: " HOSTNAME
}

# Update the preseed file with details
function updateSeedFile()
{
  echo "#############   Updating preSeed file ##############"
  if [ echo $UBUNTU_VERSION | grep Desktop ] 
  then 
    cp ./files/${UBUNTU_VERSION:0:2}/u_preseed ./extract/preseed/ubuntu.seed
	filename="ubuntu.seed"
  else
    cp ./files/${UBUNTU_VERSION:0:2}/u_preseed ./extract/preseed/ubuntu-server.seed
	filename="ubuntu-server.seed"
  fi
  sed -i "s/___LANGUAGE___/$LANGUAGE/" ./extract/preseed/$filename
  sed -i "s/___FULLNAME___/$FULLNAME/" ./extract/preseed/$filename
  sed -i "s/___USERNAME___/$USERNAME/" ./extract/preseed/$filename
  sed -i "s/___PASSWORD1___/$PASSWORD1/" ./extract/preseed/$filename
  sed -i "s/___PASSWORD2___/$PASSWORD2/" ./extract/preseed/$filename
}

# Run the functions 
checkRoot
whichUbuntu
extractISO
#whichLanguage
getUserDetails
updateSeedFile