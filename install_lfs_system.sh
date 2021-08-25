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
GREEN='\e[32m' \
RED='\e[31m' \
WHITE='\e[0m' \
PATH=/bin:/usr/bin:/sbin:/usr/sbin \
/bin/bash --login +h << "EOT"


### Man-pages-5.10 ###

echo -e "Installing Man-pages-5.10..."
cd /sources
tar xf man-pages-5.10.tar.xz -C /sources
cd man-pages-5.10
make install >> /log 2>&1
cd /sources
rm -rf man-pages-5.10

### Iana-Etc-20210202 ###

echo -e "Installing Iana-etc..."
tar xf iana-etc-20210202.tar.gz -C /sources
cd iana-etc-20210202
cp services protocols /etc
cd /sources
rm -rf iana-etc-20210202

### Glibc-2.33 ####

echo -e "Installing Glibc-2.33..."
tar xf glibc-2.33.tar.xz -C /sources
cd glibc-2.33
patch -Np1 -i ../glibc-2.33-fhs-1.patch
sed -e '402a\*result = local->data.services[database_index];' \
-i nss/nss_database.c
mkdir -v build
cd build
../configure --prefix=/usr \
--disable-werror \
--enable-kernel=3.2 \
--enable-stack-protector=strong \
--with-headers=/usr/include \
libc_cv_slibdir=/lib >> /log 2>&1
make >> /log 2>&1
make check >> /log 2>&1
touch /etc/ld.so.conf
sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
make install >> /log 2>&1
cp ../nscd/nscd.conf /etc/nscd.conf
mkdir -p /var/cache/nscd
install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
install -v -Dm644 ../nscd/nscd.service /lib/systemd/system/nscd.service

mkdir -p /usr/lib/locale
localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
localedef -i de_DE -f ISO-8859-1 de_DE
localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
localedef -i de_DE -f UTF-8 de_DE.UTF-8
localedef -i el_GR -f ISO-8859-7 el_GR
localedef -i en_GB -f UTF-8 en_GB.UTF-8
localedef -i en_HK -f ISO-8859-1 en_HK
localedef -i en_PH -f ISO-8859-1 en_PH
localedef -i en_US -f ISO-8859-1 en_US
localedef -i en_US -f UTF-8 en_US.UTF-8
localedef -i es_MX -f ISO-8859-1 es_MX
localedef -i fa_IR -f UTF-8 fa_IR
localedef -i fr_FR -f ISO-8859-1 fr_FR
localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
localedef -i it_IT -f ISO-8859-1 it_IT
localedef -i it_IT -f UTF-8 it_IT.UTF-8
localedef -i ja_JP -f EUC-JP ja_JP
localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS 2> /dev/null || true
localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
localedef -i zh_CN -f GB18030 zh_CN.GB18030
localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS

make localedata/install-locales >> /log 2>&1

cat > /etc/nsswitch.conf << "EOF"
# Begin /etc/nsswitch.conf
passwd: files
group: files
shadow: files
hosts: files dns
networks: files
protocols: files
services: files
ethers: files
rpc: files
# End /etc/nsswitch.conf
EOF

tar -xf ../../tzdata2021a.tar.gz
ZONEINFO=/usr/share/zoneinfo
mkdir -pv $ZONEINFO/{posix,right}
for tz in etcetera southamerica northamerica europe africa antarctica \
	asia australasia backward; do
  zic -L /dev/null -d $ZONEINFO ${tz}
  zic -L /dev/null -d $ZONEINFO/posix ${tz}
  zic -L leapseconds -d $ZONEINFO/right ${tz}
done
cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
zic -d $ZONEINFO -p Europe/Paris
unset ZONEINFO

ln -sfv /usr/share/zoneinfo/Europe/Paris /etc/localtime


cat > /etc/ld.so.conf << "EOF"
# Begin /etc/ld.so.conf
/usr/local/lib
/opt/lib
EOF


EOT
