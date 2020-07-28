# Install Packages for APNIC Segment Routing workshops
## Requirements
This script is designed to work on Ubuntu 18.04 LTS. It should be run under root (not suitable for a production environment).
## Actions Performed
* Install xfce4 basic desktop
* Remove some default packages
* Disable auto update
* Update system packages
* Install required packages
* Install XRDP for remote desktop access
* Install GNS3-Server
* Install GNS3-GUI
* Install Docker (optional)
* Install Dynamips
* Install Dynagen
* Install uBridge
* Install VPCS
* Configure UFW [optional]
* Configure GNS3 [optional]
* Install Wireshark
* Create a restricted user
* Setup GNS3 project for Segment Routing
* Install Virtualbox

## Installation
Change to root user (if necessary) and clone Git repository:
```
sudo su - 
git clone https://github.com/githubapnic/Ubuntu.git
```
Enter the new directory, change variables , update permissions, and run install_packages.sh, answer the questions:
```
cd Ubuntu/workshops/segment_routing
vi setup_sr_workshop.sh
chmod 744 setup_sr_workshop.sh
sudo ./setup_sr_workshop.sh
```

