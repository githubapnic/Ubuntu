# Netplan configuration
## Requirements
This script is designed to work on Ubuntu Desktop 18.04 LTS. It should be run under root (not suitable for a production environment).

## Overview
This script was created as a way to set a static IP and other networking details

## Actions Performed
* Get current settings
* Confirm new settings
* Back up netplan file
* Set new settings
* Test new settings
* Apply new settings

## Installation
To use the script open a new terminal window (Use Ctrl+alt+T to open terminal) and type the following commands:

```bash
cd Ubuntu/staticIP/18.04/
chmod 744 SetStaticIP.sh
sudo ./SetStaticIP.sh
```
## Troubleshooting
There is a packagelist_removal.log file. To view the file when running the script, open another terminal window and type:
```
tail -f set_ip.log
