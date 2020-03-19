#!/bin/bash

# Purpose: Use this to clone and update the template file for all the containers
# Usage: ./CreateGroupContainers.sh 30


# Check if 1 parameter is entered into the command line
if test "$#" -ne 1; then
	echo "Not enough values typed for the command."
	echo "Usage: $0 HowManyContainers"
	exit
fi

COUNTER=1
while [  $COUNTER -lt $(($1+1)) ]; do
	if test $COUNTER -lt 10; then
		sudo ./CopyLXC.sh group0$COUNTER.apnictraining.net 192.168.30.$COUNTER
	else
		sudo ./CopyLXC.sh group$COUNTER.apnictraining.net 192.168.30.$COUNTER
	fi
	let COUNTER=COUNTER+1 
done

sudo lxc-ls -f
