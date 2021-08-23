#!/bin/bash
# install host requirement for ubuntu 20

### install building tools ##
apt -y install build-essential bison gawk texinfo

### symbolic link sh to bash ###
rm /bin/sh
ln -s /bin/bash /bin/sh
