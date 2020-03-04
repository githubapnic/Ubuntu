# Uninstall Bloatware from Ubuntu
## Requirements
This script is designed to work on Ubuntu Desktop 18.04 LTS. It should be run under root (not suitable for a production environment).

## Overview
This script was created as a way to standardise the removal of unwanted packages that are included with a default installation of Ubuntu Desktop. There are 2 files included:

1. remove_package.sh - this is the script to uninstall the packages
2. packagelist - This is a list of packages to remove

## Actions Performed
* Add Terminal shortcut to launcher
* Uninstall packages
* Disable Auto Updates [optional]

## Installation
To use the script open a new terminal window (Use Ctrl+alt+T to open terminal) and type the following commands:

```bash
sudo apt-get install -y git
git clone https://github.com/githubapnic/Ubuntu.git
cd Ubuntu/removepackages/
chmod 744 remove_packages.sh
sudo ./removepackages.sh
```
To see the output from the removal of the packages

`cat packagelist_removal.log`

To check if packages are installed

`dpkg -l $(cat packagelist)`

## Troubleshooting
There is a packagelist_removal.log file. To view the file when running the script, open another terminal window and type:
```
tail -f packagelist_removal.log
