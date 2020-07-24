# Install Packages for RPKI workshop
## Requirements
This script is designed to work on Ubuntu 18.04 LTS. It should be run under root (not suitable for a production environment).

### Cisco IOS image file
The dynamips for this workshop requires a cisco 7200 IOS image file to be located in an images folder.

```
cd ~/virtual_labs/images
ls -lash
```
If there is no file, please download from cisco before trying to start the dynamips lab
https://www.cisco.com/c/en/us/support/routers/7200-series-routers/tsd-products-support-series-home.html

## Actions Performed
* Update Packages
* Install SSH
* Install Screen
* Install Dynamips
* Install Dynagen
* Enable IPv6 and IPv4 Forwarding
* Install LXC, LXCTL and LXC Templates
* Create a template container
* Setup a RPKI container
* Copy Scripts to Documents folder
* Copy dynamips rpki toplogy files to virtual_labs folder
* Install LXC web portal [optional]
* Create an APT cache server [optional]

## Installation
Change to root user (if necessary) and clone Git repository:
```
cd ~
git clone https://github.com/githubapnic/Ubuntu.git
```
Enter the new directory, change variables , update permissions, and run setup_rpki_workshop.sh, answer the questions:
```
cd ~/Ubuntu/workshops/rpki
vi setup_rpki_workshop.sh
chmod 744 setup_rpki_workshop.sh
sudo ./setup_rpki_workshop.sh
```

## Troubleshooting
There is an install.log file. To view the file when running the script
```
tail -f install.log
```
# To start the rpki workshop lab
```
cd ~/Documents/scripts
screen
sudo ./start_rpkiServer_routers.sh

# detach from the dynagen screen
press ctrl+a d 

# Start the tap interfaces
sudo ./start_rpki_tap.sh

# confirm containers are running
sudo lxc-ls -f | grep run

# confirm tap interfaces are connected to bridge
brctl show
```

