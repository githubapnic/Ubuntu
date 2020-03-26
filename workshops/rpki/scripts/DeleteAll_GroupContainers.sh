#!/bin/bash

# Purpose: Use this to stop all the groupXX containers
# Usage: ./Group_Stop.sh 

for i in {13..20}
do 
	if test $i -lt 10; then
		echo STOP and DESTROY container group0$i.apnictraining.net 
		sudo lxc-stop -n group0$i.apnictraining.net 
		sudo lxc-destroy -n group0$i.apnictraining.net 
	else
		echo STOP and DESTROY group$i.apnictraining.net 
		sudo lxc-stop -n group$i.apnictraining.net 
		sudo lxc-destroy -n group$i.apnictraining.net 
	fi
	sleep 2
	echo ""
done
echo ""
sudo lxc-ls --fancy 
