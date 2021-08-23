#!/bin/bash
# final preparation

GREEN='\e[32m'
RED='\e[31m'
WHITE='\e[0m'

LFS=/mnt/lfs

#### disk verification ####
if [[ $(mount | grep -c "/mnt/lfs") == 0 ]]
then
	echo -e "${RED}Error ${WHITE}: The lfs Root directory is not mounted on any partition"
	exit 1
fi
echo -e "Disk partitions and filesystem [${GREEN}OK${WHITE}]"

### source directory creation and Download ###
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources

wget https://ftp.wrz.de/pub/LFS/lfs-packages/lfs-packages-10.1.tar --directory-prefix=$LFS/sources -q --show-progress
if [[ -f "$LFS/sources/lfs-packages-10.1.tar" ]]
then
	tar xfs $LFS/sources/lfs-packages-10.1.tar -C $LFS/sources/
	mv $LFS/sources/10.1/* $LFS/sources/
	rmdir $LFS/sources/10.1	
else
	echo -e "${RED}Error ${WHITE}: Problem extracting sources"
	exit 2
fi
pushd $LFS/sources
	echo -e "checksum validation..."
	md5sum --quiet -c md5sums 2> error.txt
popd > /dev/null

if [[ $(grep -c ^ $LFS/sources/error.txt) > 0 ]]
then
	echo -e "${RED}Error ${WHITE}: checksum incorrect"
	exit 3
else
	echo -e "cheksum [${GREEN}OK${WHITE}]"
fi
