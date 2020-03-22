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

# First clone the container template.apnictraining.net
echo "Copying template.apnictraining.net to $HOSTNAME ...."
lxc-copy -n template.apnictraining.net -N $HOSTNAME

echo "Update IP and Host details to:"

# Update the IP address
sed -i 's/192.168.30.100/'"$IP"'/' /var/lib/lxc/$HOSTNAME/rootfs/etc/netplan/10-lxc.yaml
more /var/lib/lxc/$HOSTNAME/rootfs/etc/netplan/10-lxc.yaml | grep address

# Update host file
sed -i 's/template.apnictraining.net/'"$HOSTNAME"'/' /var/lib/lxc/$HOSTNAME/rootfs/etc/hosts
more /var/lib/lxc/$HOSTNAME/rootfs/etc/hosts | grep 127.0.1.1
