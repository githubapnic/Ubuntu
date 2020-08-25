#!/bin/bash

# Created: 25th Aug 2020
# Purpose: After starting the workshop dynamips lab, bring the TAP interfaces up
# Usage: ./start_tap_for_TR1_TR2.sh [bridgename]
#			./start_tap_for_TR1_TR2.sh LAN

BRIDGENAME=%1

if [[ BRIDGENAME =="" ]]; then
  BRIDGENAME="LAN"
fi

for i in {1..2}
do 
  sudo ifconfig TR$i up
  sudo brctl addif $BRIDGENAME TR$i
  sleep 1
done
ifconfig | grep TR
brctl show
