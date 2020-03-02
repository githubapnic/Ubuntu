<H1> Script to uninstall Bloatware from Ubuntu</H1>
This repo was created as a way to standardise the removal of unwanted packages that are included with a default installation of Ubuntu Desktop. There are 2 files included:

1. remove_package.sh - this is the script to uninstall the packages
2. packagelist - This is a list of packages to remove

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

