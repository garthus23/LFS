# Linux From Scratch

**Shell Scripts to install Linux From Scratch From Ubuntu18(liveCD) to an x86_64 target**

## Install developpement tools on ubuntu ##
```
sudo ./install_host_env.sh
```
## check the host environnement ##
```
sudo ./check_host_env.sh
```
## Install sources and temporary tools ##

!! partition ~20go need to be mounted on /mnt/lfs !!
```
sudo ./final_preparation.sh
```
## Install the basic system ##
```
sudo ./install_lfs_system.sh
```

!! compilation Problems : remove/ajust the MAKEFLAGS to your processor capabilities !!
