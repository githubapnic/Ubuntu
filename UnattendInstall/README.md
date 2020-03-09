# Create an unattended installation ISO image for Ubuntu
## Requirements
This script is designed to work on Ubuntu 16.04 LTS. It should be run under root (not suitable for a production environment).
## Actions Performed
* Extract ISO image
* Gather details
* Update preseed.cfg file
* Create ISO image

## Installation
Change to root user (if necessary) and clone Git repository:
```
git clone https://github.com/githubapnic/Ubuntu.git
```
Enter the new directory, update permissions, and run script_ubuntu.sh, answer the questions:
```
cd Ubuntu/UnattendInstall
chmod 764 script_ubuntu.sh
sudo ./script_ubuntu.sh
```
After starting the script you will be asked for the full path to the ISO file eg
```
/home/user01/Downloads/ubuntu-16.04.5-desktop-amd64.iso
```
## Pre-requisites
There ISO image needs to be stored locally. Please download the Ubuntu ISO from
* http://releases.ubuntu.com/16.04/
* http://releases.ubuntu.com

### Credits:
Based on the script created by Aditya Nehra & Anoop Chaudhary https://github.com/asniii/Automating-ubuntu-preseed 
