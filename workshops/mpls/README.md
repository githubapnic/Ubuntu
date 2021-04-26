# Install Packages for MPLS Fundamentals workshop
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
* Copy Scripts to Documents folder
* Copy dynamips MPLS toplogy files to virtual_labs folder
* Create an APT cache server [optional]

## Installation
Change to root user (if necessary) and clone Git repository:
```
cd ~
git clone https://github.com/githubapnic/Ubuntu.git
```
Enter the new directory, change variables , update permissions, and run setup_rpki_workshop.sh, answer the questions:
```
cd ~/Ubuntu/workshops/mpls
vi setup_mpls_workshop.sh
chmod 744 setup_mpls_workshop.sh
sudo ./setup_mpls_workshop.sh
```

## Troubleshooting
There is an install.log file. To view the file when running the script
```
tail -f install.log
```
# To start the mpls workshop lab
```
cd ~/Documents/scripts
screen

# detach from the dynagen screen
press ctrl+a d 

```

