#!/bin/bash

# Created: 20th March 2020
# Purpose: After starting the workshop dynamips lab, bring the TAP interfaces up
# Usage: ./start_rpki_tap.sh 

BRIDGENAME="br0"

for i in {13..20}
do 
  sudo ifconfig tap$i up
  sudo brctl addif $BRIDGENAME tap$i
  sleep 1
done
ifconfig | grep tap
brctl show
