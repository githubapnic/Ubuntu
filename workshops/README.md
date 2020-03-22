# Purpose
These scripts are useful to setup and config dynamips and lxc containers for the workshop.

## Installation
Change to root user (if necessary) and clone Git repository:
```
cd ~
git clone https://github.com/githubapnic/Ubuntu.git
cd ~/Ubuntu/workshops
```

## Commands for using LXC containers
* Containers are created in `/var/lib/lxc/$name`, see the file `config` and the directory `rootfs`
* List all containers, with running state and IP address: `sudo lxc-ls -f`
* Start a container without console: `sudo lxc-start -d --name $name`
* Start a container: `sudo lxc-start --name $name`
* Stop a container: `sudo lxc-stop -n $name`
* Destroy a container: `sudo lxc-destroy --name $name`

### Snapshots:
* are stored in `/var/lib/lxcsnaps/`
* first stop the container: `sudo lxc-stop -n $name`
* then create the snapshot: `sudo lxc-snapshot -n $name`
 * create with comment: `echo "mycomment" > /tmp/comment && lxc-snapshot -n $name -c /tmp/comment && rm -f /tmp/comment`
* list all snapshots: `sudo lxc-snapshot -LC -n $name`
* restore a snapshot: `sudo lxc-snapshot -n $name -r snap@`
* create a new container from snapshot: `sudo lxc-snapshot -n $name -r snap@ new$name`
* delete a snapshot: `sudo lxc-snapshot -n $name -d snap@`

## Commands for starting dynamips and topology files
* Check if dynamips is running: `ps-ef | grep dynamips`
* Kill all dynamips processes: `sudo killall dynamips`
* Script to remove files and start dynamips: `sudo ./run-dynamips` or `sudo ./run-dynamips.sh`
* To start dynagen with the topology file: `sudo dynagen topology.net`
* To confirm dynamips port is listening: `netstat -ltnp | grep 720`
* A nice tutorial about using dynamips is available from [NSRC](https://nsrc.org/workshops/2013/nsrc-ubuntunet-trainers/raw-attachment/wiki/Agenda/lab-dynamips.html "NSRC Dynamips Lab")
