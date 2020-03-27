#!/bin/bash

# Purpose: USe this to clone and update the template file
# Usage: ./CloneLXC.sh group01.apnictraining.net 192.168.30.1
# Credit: based on the script by fakrul[at]apnic.net

# Check if 2 parameters entered into the command line
if test "$#" -ne 2; then
	echo "Not enough values typed for the command."
	echo "Usage: $0 HOSTNAME IP"
	exit
fi

HOSTNAME="$1"
IP="$2"
VETH_NAME=$(echo $HOSTNAME | awk -F . '{print $1}')

# First clone the container template.apnictraining.net
echo "Copying template.apnictraining.net to $HOSTNAME or $VETH_NAME"
lxc-copy -n template.apnictraining.net -N $HOSTNAME

echo "Update IP and Host details to:"

# Update the IP address
sed -i 's/192.168.30.100/'"$IP"'/' /var/lib/lxc/$HOSTNAME/rootfs/etc/netplan/10-lxc.yaml
more /var/lib/lxc/$HOSTNAME/rootfs/etc/netplan/10-lxc.yaml | grep address

# Update host file
sed -i 's/template.apnictraining.net/'"$HOSTNAME"'/' /var/lib/lxc/$HOSTNAME/rootfs/etc/hosts
sed -i 's/template.apnictraining.net/'"$HOSTNAME"'/' /var/lib/lxc/$HOSTNAME/rootfs/etc/hostname
more /var/lib/lxc/$HOSTNAME/rootfs/etc/hosts | grep 127.0.1.1

# Update LXC config file
sudo sed -i 's/lxc.net.0.veth.pair \= template/lxc.net.0.veth.pair \= '"$VETH_NAME"'/' /var/lib/lxc/$HOSTNAME/config
more /var/lib/lxc/$HOSTNAME/config | grep veth.pair 

# Copy scripts to the scripts folder
function copyScripts()
{
	# Add script to help with installation of routinator
	mkdir -p /var/lib/lxc/$HOSTNAME/rootfs/home/apnic/scripts/
	sudo cp -p $(find /home/ -type f -name installRoutinator.sh | awk 'NR==1{print $1}') /var/lib/lxc/$HOSTNAME/rootfs/home/apnic/scripts/installRoutinator.sh
	chmod 744 /var/lib/lxc/$HOSTNAME/rootfs/home/apnic/scripts/installRoutinator.sh
}


# Run the functions 
#copyScripts