#!/bin/bash

# Created: 25th Aug 2020
# Purpose: After starting the workshop dynamips lab, bring the TAP interfaces up
# Usage: ./start_tap_for_TR1_TR2.sh [bridgename]
#			./start_tap_for_TR1_TR2.sh LAN

BRIDGENAME=$1

# https://www.cyberciti.biz/faq/unix-linux-bash-script-check-if-variable-is-empty
# Check if Bridgename exists
if [[ -z $BRIDGENAME ]]; then
  BRIDGENAME="LAN"
fi

for i in {1..2}
do 
  sudo ifconfig tap-lan$i up
  sudo brctl addif $BRIDGENAME tap-lan$i
  sleep 1
done
ifconfig | grep tap
brctl show
