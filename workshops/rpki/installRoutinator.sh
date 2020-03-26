#!/bin/bash

# Purpose: Use this to update and install routinator
# Usage: ./installRoutinator.sh

apt-get update && sudo apt-get dist-upgrade
apt-get install -y curl gcc build-essential openssh-server rsync
apt-get update && sudo apt-get dist-upgrade
curl https://sh.rustup.rs -sSf | sh
source $HOME/.cargo/env
cargo install routinator 
routinator init --accept-arin-rpa
routinator -v vrps 