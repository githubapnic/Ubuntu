#!/bin/bash

# Purpose: Use this to update and install routinator
# Usage: ./installRoutinator.sh

sudo apt-get update && sudo apt-get dist-upgrade
sudo apt-get install -y curl gcc build-essential openssh-server rsync
sudo apt-get update && sudo apt-get dist-upgrade
# The below commands need to be run as apnic
# su - apnic
curl https://sh.rustup.rs -sSf | sh
source $HOME/.cargo/env
cargo install routinator -f --version 0.7.1-rc2 routinator
routinator init --accept-arin-rpa
routinator -v vrps 
