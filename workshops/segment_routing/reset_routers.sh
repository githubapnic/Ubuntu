#!/bin/bash

# Purpose: Log into XR routers and reset to base SR config
# Usage: ./reset_routers.sh ipaddress startingPort

# Check if 2 parameter is entered into the command line
if test "$#" -ne 2; then
	echo "Not enough values typed for the command."
	echo "Usage: $0 IPaddress StartingPort"
	exit
fi

COUNTER=$2
FINISHPORT=$COUNTER+6
while [  $COUNTER -lt $(($FINISHPORT)) ]; do
	echo "Telnet to $1 $COUNTER"
	./telnet_to_router.sh $1 $COUNTER
	let COUNTER=COUNTER+1 
	echo "##################################################"
done

