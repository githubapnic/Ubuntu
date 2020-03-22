# Purpose
These scripts are useful to setup and config dynamips and lxc containers for the workshop.

# Installation
Change to root user (if necessary) and clone Git repository:
```
cd ~
git clone https://github.com/githubapnic/Ubuntu.git
cd ~/Ubuntu/workshops
```

# CheatSheet for LXC
* Containers are created in `/var/lib/lxc/$name`, see the file `config` and the directory `rootfs`
* List all containers, with running state and IP address: `lxc-ls -f`
* Start a container without console: `lxc-start -d --name $name`
* Start a container: `lxc-start --name $name`
* Stop a container: `lxc-stop -n $name`
* Destroy a container: `lxc-destroy --name $name`

## Snapshots:
* are stored in `/var/lib/lxcsnaps/`
* first stop the container: `lxc-stop -n $name`
* then create the snapshot: `lxc-snapshot -n $name`
 * create with comment: `echo "mycomment" > /tmp/comment && lxc-snapshot -n $name -c /tmp/comment && rm -f /tmp/comment`
* list all snapshots: `lxc-snapshot -LC -n $name`
* restore a snapshot: `lxc-snapshot -n $name -r snap@`
* create a new container from snapshot: `lxc-snapshot -n $name -r snap@ new$name`
* delete a snapshot: `lxc-snapshot -n $name -d snap@`