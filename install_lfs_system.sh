#!/bin/bash
# Install the LFS system

LFS=/mnt/lfs
TERM=xterm-256color


### Mount /dev and virtual kernel ###

mount --bind /dev $LFS/dev
mount --bind /dev/pts $LFS/dev/pts
mount -t proc proc $LFS/proc
mount -t sysfs sysfs $LFS/sys
mount -t tmpfs tmpfs $LFS/run

if [ -h $LFS/dev/shm ]; then
mkdir -p $LFS/$(readlink $LFS/dev/shm)
fi


chroot "$LFS" /usr/bin/env -i \
HOME=/root \
TERM="$TERM" \
PS1='(lfs chroot) \u:\w\$ ' \
PATH=/bin:/usr/bin:/sbin:/usr/sbin \
/bin/bash --login +h << "EOT"

### Man-pages-5.10 ###



