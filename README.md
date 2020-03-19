# Ubuntu
Repo of Ubuntu scripts

## Installation
Download the repo and change the permissions on all the shell scripts to allow it to be run. eg:
``` bash
find Ubuntu/ -type f -iname "*.sh" -exec chmod u+x {} \;
```
## Troubleshooting
If an error about "/bin/bash^M: bad interpeter" replace suspicious characters using the following command:
```bash
sed -i -e 's/\r$//' <filename>
```
