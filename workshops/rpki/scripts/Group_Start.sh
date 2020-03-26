#!/bin/bash

# Purpose: Use this to start all the groupXX containers
# Usage: ./Group_Start.sh 

for i in {13..20}
do 
	if test $i -lt 10; then
		echo START container group0$i.apnictraining.net -d
		sudo lxc-start -n group0$i.apnictraining.net -d
	else
		echo START container group$i.apnictraining.net -d
		sudo lxc-start -n group$i.apnictraining.net -d
	fi
	sleep 2
done

sudo lxc-stop -n group01.apnictraining.net
sudo lxc-ls --fancy | grep RUNNING
