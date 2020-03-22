# Install Packages for GNS3
## Requirements
This script is designed to work on Ubuntu 18.04 LTS. It should be run under root (not suitable for a production environment).
## Actions Performed
* Update system packages
* Install new packages
* Install SSH server
* Install GNS3-Server
* Install GNS3-GUI
* Install Docker
* Install Dynamips
* Install Dynagen
* Install uBridge
* Install VPCS
* Install Wireshark
* Configure UFW [optional]
* Configure GNS3 [optional]
## Installation
Change to root user (if necessary) and clone Git repository:
```
git clone https://github.com/githubapnic/Ubuntu.git
```
Enter the new directory, change variables , update permissions, and run install_packages.sh, answer the questions:
```
cd Ubuntu/installpackages
vi install_packages.sh
chmod 744 install_packages.sh
sudo ./install_packages.sh
```
## Troubleshooting
There is an install.log file. To view the file when running the script
```
tail -f install.log
```
