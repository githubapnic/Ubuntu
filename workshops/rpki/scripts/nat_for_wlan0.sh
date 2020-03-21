#!/bin/bash

# Created: 14th July 2019
# Purpose: Add nat to iptables for wlan0 interface
# Usage: ./nat_for_wlan0.sh 

# https://www.revsys.com/writings/quicktips/nat.html
echo "Current NAT details"
sudo iptables -t nat -L -n -v

echo #####################################

sudo /sbin/iptables -t nat -A POSTROUTING -o wlan0 -j MASQUERADE
sudo /sbin/iptables -A FORWARD -i eth0 -o wlan0 -m state --state RELATED,ESTABLISHED -j ACCEPT

echo #####################################

echo "Update NAT details"
sudo iptables -t nat -L -n -v
