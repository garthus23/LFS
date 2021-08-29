#!/bin/bash
# Install the LFS system

LFS=/mnt/lfs
TERM=xterm-256color


### if backup|restore remount virt kernel ###

#mount --bind /dev $LFS/dev
#mount --bind /dev/pts $LFS/dev/pts
#mount -t proc proc $LFS/proc
#mount -t sysfs sysfs $LFS/sys
#mount -t tmpfs tmpfs $LFS/run


chroot "$LFS" /usr/bin/env -i \
HOME=/root \
TERM="$TERM" \
ERROR="/log" \
PS1='(lfs chroot) \u:\w\$ ' \
GREEN='\e[32m' \
RED='\e[31m' \
WHITE='\e[0m' \
PATH=/bin:/usr/bin:/sbin:/usr/sbin \
/bin/bash --login +h << "EOT"


#### Man-pages-5.10 ####

echo -e "#### Man-pages-5.10 ####" >> $ERROR
echo -e "Installing Man-pages-5.10..."
cd /sources
tar xf man-pages-5.10.tar.xz -C /sources
cd man-pages-5.10
make install > /dev/null 2>> $ERROR
cd /sources
rm -rf man-pages-5.10
echo -e "Manpages installed [${GREEN}OK${WHITE}]"

##### Iana-Etc-20210202 ####
#
#echo -e "#### Iana-Etc-20210202 ####" >> $ERROR
#echo -e "Installing Iana-etc..."
#tar xf iana-etc-20210202.tar.gz -C /sources
#cd iana-etc-20210202
#cp services protocols /etc
#cd /sources
#rm -rf iana-etc-20210202
#echo -e "Iana-etc installed [${GREEN}OK${WHITE}]"
#
##### Glibc-2.33 ####
#
#echo -e "#### Glibc-2.33 ####" >> $ERROR
#echo -e "Installing Glibc-2.33..."
#tar xf glibc-2.33.tar.xz -C /sources
#cd glibc-2.33
#patch -Np1 -i ../glibc-2.33-fhs-1.patch
#sed -e '402a\	*result = local->data.services[database_index];' \
#-i nss/nss_database.c
#mkdir -v build
#cd build
#../configure --prefix=/usr \
#	--disable-werror \
#	--enable-kernel=3.2 \
#	--enable-stack-protector=strong \
#	--with-headers=/usr/include \
#	libc_cv_slibdir=/lib > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#touch /etc/ld.so.conf
#sed '/test-installation/s@$(PERL)@echo not running@' -i ../Makefile
#make install > /dev/null 2>> $ERROR
#echo -e "Glibc installed [${GREEN}OK${WHITE}]"
#cp ../nscd/nscd.conf /etc/nscd.conf
#mkdir -p /var/cache/nscd
#install -v -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
#install -v -Dm644 ../nscd/nscd.service /lib/systemd/system/nscd.service
#mkdir -p /usr/lib/locale
#localedef -i POSIX -f UTF-8 C.UTF-8 2> /dev/null || true
#localedef -i cs_CZ -f UTF-8 cs_CZ.UTF-8
#localedef -i de_DE -f ISO-8859-1 de_DE
#localedef -i de_DE@euro -f ISO-8859-15 de_DE@euro
#localedef -i de_DE -f UTF-8 de_DE.UTF-8
#localedef -i el_GR -f ISO-8859-7 el_GR
#localedef -i en_GB -f UTF-8 en_GB.UTF-8
#localedef -i en_HK -f ISO-8859-1 en_HK
#localedef -i en_PH -f ISO-8859-1 en_PH
#localedef -i en_US -f ISO-8859-1 en_US
#localedef -i en_US -f UTF-8 en_US.UTF-8
#localedef -i es_MX -f ISO-8859-1 es_MX
#localedef -i fa_IR -f UTF-8 fa_IR
#localedef -i fr_FR -f ISO-8859-1 fr_FR
#localedef -i fr_FR@euro -f ISO-8859-15 fr_FR@euro
#localedef -i fr_FR -f UTF-8 fr_FR.UTF-8
#localedef -i it_IT -f ISO-8859-1 it_IT
#localedef -i it_IT -f UTF-8 it_IT.UTF-8
#localedef -i ja_JP -f EUC-JP ja_JP
#localedef -i ja_JP -f SHIFT_JIS ja_JP.SIJS 2> /dev/null || true
#localedef -i ja_JP -f UTF-8 ja_JP.UTF-8
#localedef -i ru_RU -f KOI8-R ru_RU.KOI8-R
#localedef -i ru_RU -f UTF-8 ru_RU.UTF-8
#localedef -i tr_TR -f UTF-8 tr_TR.UTF-8
#localedef -i zh_CN -f GB18030 zh_CN.GB18030
#localedef -i zh_HK -f BIG5-HKSCS zh_HK.BIG5-HKSCS
#make localedata/install-locales > /dev/null 2>> $ERROR
#cat > /etc/nsswitch.conf << "EOF"
## Begin /etc/nsswitch.conf
#passwd: files
#group: files
#shadow: files
#hosts: files dns
#networks: files
#protocols: files
#services: files
#ethers: files
#rpc: files
## End /etc/nsswitch.conf
#EOF
#tar -xf ../../tzdata2021a.tar.gz
#ZONEINFO=/usr/share/zoneinfo
#mkdir -pv $ZONEINFO/{posix,right}
#for tz in etcetera southamerica northamerica europe africa antarctica \
#	asia australasia backward; do
#  zic -L /dev/null -d $ZONEINFO ${tz}
#  zic -L /dev/null -d $ZONEINFO/posix ${tz}
#  zic -L leapseconds -d $ZONEINFO/right ${tz}
#done
#cp -v zone.tab zone1970.tab iso3166.tab $ZONEINFO
#zic -d $ZONEINFO -p Europe/Paris
#unset ZONEINFO
#ln -sfv /usr/share/zoneinfo/Europe/Paris /etc/localtime
#cat > /etc/ld.so.conf << "EOF"
## Begin /etc/ld.so.conf
#/usr/local/lib
#/opt/lib
#EOF
#cd /sources
#rm -rf glibc-2.33
#echo -e "Glibc-2.33 installed [${GREEN}OK${WHITE}]"
#
#
##### Zlib-1.2.11 ####
#
#echo -e "#### Zlib-1.2.11 ####" >> $ERROR
#echo -e "Installing Zlib-1.2.11..."
#tar -xf /sources/zlib-1.2.11.tar.xz -C /sources
#cd /sources/zlib-1.2.11
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv -v /usr/lib/libz.so.* /lib
#ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so
#rm -fv /usr/lib/libz.a
#cd /sources
#rm -rf zlib-1.2.11
#echo -e "Zlib-1.2.11 installed [${GREEN}OK${WHITE}]"
#
##### Bzip2-1.0.8 ####
#
#echo -e "#### Bzip2-1.0.8 ####" >> $ERROR
#echo -e "Installing Bzip2-1.0.8..."
#tar -xf /sources/bzip2-1.0.8.tar.gz -C /sources
#cd /sources/bzip2-1.0.8
#patch -Np1 -i ../bzip2-1.0.8-install_docs-1.patch
#sed -i 's@\(ln -s -f \)$(PREFIX)/bin/@\1@' Makefile
#sed -i "s@(PREFIX)/man@(PREFIX)/share/man@g" Makefile
#make -f Makefile-libbz2_so > /dev/null 2> $ERROR
#make clean  > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make PREFIX=/usr install > /dev/null 2>> $ERROR
#cp -v bzip2-shared /bin/bzip2
#cp -av libbz2.so* /lib
#ln -sv ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
#rm -v /usr/bin/{bunzip2,bzcat,bzip2}
#ln -sv bzip2 /bin/bunzip2
#ln -sv bzip2 /bin/bzcat
#rm -fv /usr/lib/libbz2.a
#cd /sources
#rm -rf bzip2-1.0.8
#echo -e "Bzip2-1.0.8 installed [${GREEN}OK${WHITE}]"
#
##### Xz-5.2.5 ####
#
#echo -e "#### Xz-5.2.5 ####" >> $ERROR
#echo -e "Installing Xz-5.2.5..."
#tar -xf /sources/xz-5.2.5.tar.xz -C /sources
#cd /sources/xz-5.2.5
#./configure --prefix=/usr \
#--disable-static \
#--docdir=/usr/share/doc/xz-5.2.5 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv -v /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
#mv -v /usr/lib/liblzma.so.* /lib
#ln -svf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so
#cd /sources
#rm -rf xz-5.2.5
#echo -e "Xz-5.2.5 installed [${GREEN}OK${WHITE}]"
#
##### Zstd-1.4.8 ####
#
#echo -e "#### Zstd-1.4.8 ####" >> $ERROR
#echo -e "Installing Zstd-1.4.8..."
#tar -xf /sources/zstd-1.4.8.tar.gz -C /sources
#cd /sources/zstd-1.4.8
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make prefix=/usr install > /dev/null 2>> $ERROR
#rm -v /usr/lib/libzstd.a
#mv -v /usr/lib/libzstd.so.* /lib
#ln -sfv ../../lib/$(readlink /usr/lib/libzstd.so) /usr/lib/libzstd.so
#cd /sources
#rm -rf zstd-1.4.8
#echo -e "Zstd-1.4.8 installed [${GREEN}OK${WHITE}]"
#
#### File-5.39 ###
#
#echo -e "#### File-5.39 ####" >> $ERROR
#echo -e "Installing File-5.39..."
#tar -xf /sources/file-5.39.tar.gz -C /sources
#cd /sources/file-5.39
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#cd /sources
#rm -rf file-5.39
#echo -e "file-5.39 installed [${GREEN}OK${WHITE}]"
#



EOT
