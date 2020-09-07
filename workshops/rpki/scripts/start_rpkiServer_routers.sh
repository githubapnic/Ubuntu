#!/bin/bash

# Created: 20th March 2020
# Purpose: start the rpki  workshop dynamips lab, bring the rpki server up
# Usage: ./start_rpkiServer_routers.sh

sudo lxc-start -d -n rpki.apnictraining.net
sleep 2
cd $HOME/virtual_labs/rpki/
sudo ./run-dynamips
sleep 1
screen -dmS dynagenSession
screen -S dynagenSession -p 0 -X stuff 'dynagen /home/apnic/virtual_labs/rpki/topology.net\r'
sleep 1
cd $HOME/Documents/scripts
sudo ./start_rpki_tap.sh
