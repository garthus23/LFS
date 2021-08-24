#!/bin/bash
# install host requirement for ubuntu 20

### install building tools ##
apt -y install build-essential bison gawk texinfo

### symbolic link sh to bash ###
rm /bin/sh
ln -s /bin/bash /bin/sh

### create the root directory ###
mkdir -pv /mnt/lfs
#mount /dev/sda3 /mnt/lfs

echo "Now you can create partitions and filesystem on your lfs disk"

#mkdir -pv /mnt/lfs/home
#mkdir -pv /mnt/lfs/boot
#mount /dev/sda4 /mnt/lfs/home
#mount /dev/sda2 /mnt/lfs/boot
