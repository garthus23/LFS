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

echo -e "#### Install basic System ####"

#chroot "$LFS" /usr/bin/env -i \
#	HOME=/root \
#	TERM="$TERM" \
#	ERROR="/error" \
#	CHECK="/make_check" \
#	PS1='(lfs chroot) \u:\w\$ ' \
#	GREEN='\e[32m' \
#	RED='\e[31m' \
#	WHITE='\e[0m' \
#	PATH=/bin:/usr/bin:/sbin:/usr/sbin \
#	/bin/bash --login +h << "EOT"
#
#
##### Man-pages-5.10 ####
#
#echo -e "#### Man-pages-5.10 ####" >> $ERROR
#echo -e "Installing Man-pages-5.10..."
#cd /sources
#tar xf man-pages-5.10.tar.xz -C /sources
#cd man-pages-5.10
#make install > /dev/null 2>> $ERROR
#if [[ -d /usr/share/man/man1 ]]
#then
#	echo -e "Manpages installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Manpages not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf man-pages-5.10
#
##### Iana-Etc-20210202 ####
#
#echo -e "#### Iana-Etc-20210202 ####" >> $ERROR
#echo -e "Installing Iana-etc..."
#tar xf iana-etc-20210202.tar.gz -C /sources
#cd iana-etc-20210202
#cp services protocols /etc
#if [[ -f /etc/services ]]
#then
#	echo -e "Iana-etc installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Manpages not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf iana-etc-20210202
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
#mkdir build
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
#cp ../nscd/nscd.conf /etc/nscd.conf
#mkdir -p /var/cache/nscd
#install -Dm644 ../nscd/nscd.tmpfiles /usr/lib/tmpfiles.d/nscd.conf
#install -Dm644 ../nscd/nscd.service /lib/systemd/system/nscd.service
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
#  zic -L leapseconds -d $ZONEINFO/right ${tz} 2>> $ERROR
#done
#cp zone.tab zone1970.tab iso3166.tab $ZONEINFO
#zic -d $ZONEINFO -p Europe/Paris
#unset ZONEINFO
#ln -sfv /usr/share/zoneinfo/Europe/Paris /etc/localtime
#cat > /etc/ld.so.conf << "EOF"
## Begin /etc/ld.so.conf
#/usr/local/lib
#/opt/lib
#EOF
#if [[ -f /usr/bin/tzselect ]]
#then
#	echo -e "Glibc-2.33 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Glibc-2.33 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf glibc-2.33
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
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv /usr/lib/libz.so.* /lib
#ln -sfv ../../lib/$(readlink /usr/lib/libz.so) /usr/lib/libz.so
#rm -fv /usr/lib/libz.a
#if [[ -f /usr/lib/libz.so ]]
#then
#	echo -e "Zlib-1.2.11 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Zlib-1.2.11 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf zlib-1.2.11
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
#cp bzip2-shared /bin/bzip2
#cp -a libbz2.so* /lib
#ln -s ../../lib/libbz2.so.1.0 /usr/lib/libbz2.so
#rm /usr/bin/{bunzip2,bzcat,bzip2}
#ln -s bzip2 /bin/bunzip2
#ln -s bzip2 /bin/bzcat
#rm -f /usr/lib/libbz2.a
#if [[ -f /bin/bzip2 ]]
#then
#	echo -e "Bzip2-1.0.8 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Bzip2-1.0.8 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf bzip2-1.0.8
#
##### Xz-5.2.5 ####
#
#echo -e "#### Xz-5.2.5 ####" >> $ERROR
#echo -e "Installing Xz-5.2.5..."
#tar -xf /sources/xz-5.2.5.tar.xz -C /sources
#cd /sources/xz-5.2.5
#./configure --prefix=/usr \
#	--disable-static \
#	--docdir=/usr/share/doc/xz-5.2.5 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv /usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} /bin
#mv /usr/lib/liblzma.so.* /lib
#ln -sf ../../lib/$(readlink /usr/lib/liblzma.so) /usr/lib/liblzma.so
#if [[ -f /bin/lzcat ]]
#then
#	echo -e "Xz-5.2.5 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Xz-5.2.5 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf xz-5.2.5
#
##### Zstd-1.4.8 ####
#
#echo -e "#### Zstd-1.4.8 ####" >> $ERROR 
#echo -e "Installing Zstd-1.4.8..."
#tar -xf /sources/zstd-1.4.8.tar.gz -C /sources
#cd /sources/zstd-1.4.8
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make prefix=/usr install > /dev/null 2>> $ERROR
#rm /usr/lib/libzstd.a
#mv /usr/lib/libzstd.so.* /lib
#ln -sf ../../lib/$(readlink /usr/lib/libzstd.so) /usr/lib/libzstd.so
#if [[ -f /usr/bin/zstd ]]
#then
#	echo -e "Zstd-1.4.8 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Zstd-1.4.8 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf zstd-1.4.8
#
##### File-5.39 ####
#
#echo -e "#### File-5.39 ####" >> $ERROR 
#echo -e "Installing File-5.39..."
#tar -xf /sources/file-5.39.tar.gz -C /sources
#cd /sources/file-5.39
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/file ]]
#then
#	echo -e "file-5.39 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "file-5.39 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf file-5.39
#
#
#### Readline-8.1 ####
#
#echo -e "#### Readline-8.1 ####" >> $ERROR
#echo -e "Installing Readline-8.1..."
#tar -xf /sources/readline-8.1.tar.gz -C /sources
#cd /sources/readline-8.1
#sed -i '/MV.*old/d' Makefile.in
#sed -i '/{OLDSUFF}/c:' support/shlib-install
#./configure --prefix=/usr \
#	--disable-static \
#	--with-curses \
#	--docdir=/usr/share/doc/readline-8.1 > /dev/null 2>> $ERROR
#make SHLIB_LIBS="-lncursesw" > /dev/null 2>> $ERROR
#make SHLIB_LIBS="-lncursesw" install > /dev/null 2>> $ERROR
#mv /usr/lib/lib{readline,history}.so.* /lib
#ln -sf ../../lib/$(readlink /usr/lib/libreadline.so) /usr/lib/libreadline.so
#ln -sf ../../lib/$(readlink /usr/lib/libhistory.so ) /usr/lib/libhistory.so
#install -m644 doc/*.{ps,pdf,html,dvi} /usr/share/doc/readline-8.1
#if [[ -f /usr/lib/libreadline.so ]]
#then
#	echo -e "Readline-8.1 installed [${GREEN}OK${WHITE}]" 
#else
#	echo -e "Readline-8.1 not installed [${RED}FAILED${WHITE}]" 
#	exit 2
#fi
#cd /sources
#rm -rf readline-8.1
#
#### M4-1.4.18 ####
#
#echo -e "#### M4-1.4.18 ####" >> $ERROR
#echo -e "Installing M4-1.4.18..." 
#tar -xf /sources/m4-1.4.18.tar.xz -C /sources
#cd /sources/m4-1.4.18
#sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
#echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/m4 ]]
#then
#	echo -e "M4-1.4.18 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "M4-1.4.18 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf m4-1.4.18
#
#### Bc-3.3.0 ####
#
#echo -e "#### Bc-3.3.0 ####" >> $ERROR
#echo -e "Installing Bc-3.3.0"
#tar -xf /sources/bc-3.3.0.tar.xz -C /sources
#cd /sources/bc-3.3.0
#PREFIX=/usr CC=gcc ./configure.sh -G -O3 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make test >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/bc ]]
#then
#	echo -e "Bc-3.3.0 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Bc-3.3.0 not installed [${RED}FAILED${WHITE}]"
#fi
#cd /sources
#rm -rf bc-3.3.0
#
#### Flex-2.6.4 ####
#
#echo -e "#### Flex-2.6.4 ####" >> $ERROR
#echo -e "Installing Flex-2.6.4"
#tar -xf /sources/flex-2.6.4.tar.gz -C /sources
#cd /sources/flex-2.6.4
#./configure --prefix=/usr \
#	--docdir=/usr/share/doc/flex-2.6.4 \
#	--disable-static > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#ln -sv flex /usr/bin/lex > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/flex ]]
#then
#	echo -e "Flex-2.6.4 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Flex-2.6.4 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf flex-2.6.4
#
#### Tcl-8.6.11 ####
#
#echo -e "#### Tcl-8.6.11 ####" >> $ERROR
#echo -e "Installing Tcl-8.6.11" 
#tar -xf /sources/tcl8.6.11-src.tar.gz -C /sources
#cd /sources/tcl8.6.11
#tar -xf ../tcl8.6.11-html.tar.gz --strip-components=1
#SRCDIR=$(pwd)
#cd unix
#./configure --prefix=/usr \
#	--mandir=/usr/share/man \
#	$([ "$(uname -m)" = x86_64 ] && echo --enable-64bit) > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#sed -e "s|$SRCDIR/unix|/usr/lib|" \
#    -e "s|$SRCDIR|/usr/include|" \
#    -i tclConfig.sh
#
#sed -e "s|$SRCDIR/unix/pkgs/tdbc1.1.2|/usr/lib/tdbc1.1.2|" \
#    -e "s|$SRCDIR/pkgs/tdbc1.1.2/generic|/usr/include|" \
#    -e "s|$SRCDIR/pkgs/tdbc1.1.2/library|/usr/lib/tcl8.6|" \
#    -e "s|$SRCDIR/pkgs/tdbc1.1.2|/usr/include|" \
#    -i pkgs/tdbc1.1.2/tdbcConfig.sh
#
#sed -e "s|$SRCDIR/unix/pkgs/itcl4.2.1|/usr/lib/itcl4.2.1|" \
#    -e "s|$SRCDIR/pkgs/itcl4.2.1/generic|/usr/include|" \
#    -e "s|$SRCDIR/pkgs/itcl4.2.1|/usr/include|" \
#    -i pkgs/itcl4.2.1/itclConfig.sh
#
#unset SRCDIR
#make test >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#chmod u+w /usr/lib/libtcl8.6.so
#make install-private-headers > /dev/null 2>> $ERROR
#ln -sf tclsh8.6 /usr/bin/tclsh
#mv /usr/share/man/man3/{Thread,Tcl_Thread}.3
#if [[ -f /usr/bin/tclsh ]]
#then
#	echo -e "Tcl-8.6.11 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Tcl-8.6.11 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf tcl8.6.11
#
#### Expect-5.45.4 ####
#
#echo -e "#### Expect-5.45.4 ####" >> $ERROR
#echo -e "Installing Expect-5.45.4"
#tar -xf /sources/expect5.45.4.tar.gz -C /sources
#cd /sources/expect5.45.4
#./configure --prefix=/usr \
#	--with-tcl=/usr/lib \
#	--enable-shared \
#	--mandir=/usr/share/man \
#	--with-tclinclude=/usr/include > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make test >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#ln -sf expect5.45.4/libexpect5.45.4.so /usr/lib
#if [[ -f /usr/bin/expect ]]
#then
#	echo -e "Expect-5.45.4 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Expect-5.45.4 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf expect5.45.4
#
#### DejaGNU-1.6.2 ####
#
#echo -e "#### DejaGNU-1.6.2 ####" >> $ERROR
#echo -e "Installing DejaGNU-1.6.2"
#tar -xf /sources/dejagnu-1.6.2.tar.gz -C /sources
#cd /sources/dejagnu-1.6.2
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#makeinfo --html --no-split -o doc/dejagnu.html doc/dejagnu.texi > /dev/null 2>> $ERROR
#makeinfo --plaintext -o doc/dejagnu.txt doc/dejagnu.texi > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#install -v -dm755 /usr/share/doc/dejagnu-1.6.2
#install -v -m644 doc/dejagnu.{html,txt} /usr/share/doc/dejagnu-1.6.2
#make check >> $CHECK 2>> $ERROR
#if [[ -f /usr/bin/runtest ]]
#then
#	echo -e "DejaGNU-1.6.2 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "DejaGNU-1.6.2 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf /sources/dejagnu-1.6.2
#
#### Binutils-2.36.1 ####
#
#echo -e "#### Binutils-2.36.1 ####" >> $ERROR
#echo -e "Installing Binutils-2.36.1"
#tar -xf /sources/binutils-2.36.1.tar.xz -C /sources
#cd /sources/binutils-2.36.1
#if [[ $(expect -c "spawn ls" | wc -w) == 2 ]]
#then
#	echo -e "PTY's [${GREEN}OK${WHITE}]"
#else
#	echo -e "PTYs are not working properly [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#sed -i '/@\tincremental_copy/d' gold/testsuite/Makefile.in
#mkdir -v build
#cd build
#../configure --prefix=/usr \
#	--enable-gold \
#	--enable-ld=default \
#	--enable-plugins \
#	--enable-shared \
#	--disable-werror \
#	--enable-64-bit-bfd \
#	--with-system-zlib > /dev/null 2>> $ERROR
#make tooldir=/usr > /dev/null 2>> $ERROR
#make -k check >> $CHECK 2>> $ERROR
#make tooldir=/usr install > /dev/null 2>> $ERROR
#rm -f /usr/lib/lib{bfd,ctf,ctf-nobfd,opcodes}.a
#if [[ -f /usr/bin/dwp ]]
#then
#	echo -e "Binutils-2.36.1 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Binutils-2.36.1 not installed [${RED}FAILED${WHITE}]"
#fi
#cd /sources
#rm -rf binutils-2.36.1
#
#### GMP-6.2.1 ####
#
#echo -e "#### GMP-6.2.1 ####" >> $ERROR
#echo -e "Installing GMP-6.2.1"
#tar xf /sources/gmp-6.2.1.tar.xz -C /sources
#cd /sources/gmp-6.2.1
#cp -v configfsf.guess config.guess
#cp -v configfsf.sub config.sub
#./configure --prefix=/usr \
#	--enable-cxx \
#	--disable-static \
#	--docdir=/usr/share/doc/gmp-6.2.1 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make html > /dev/null 2>> $ERROR
#make check 2>&1 | tee gmp-check-log >> $CHECK 2>> $ERROR
#if [[ $(awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log) == '197' ]]
#then
#	echo -e "make test [${GREEN}OK${WHITE}]"
#else
#	echo -e "make test  [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#make install > /dev/null 2>> $ERROR
#make install-html > /dev/null 2>> $ERROR
#if [[ -f /usr/lib/libgmp.so ]]
#then
#	echo -e "GMP-6.2.1 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "GMP-6.2.1 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf gmp-6.2.1
#
#### MPFR-4.1.0 ####
#
#echo -e "#### MPFR-4.1.0 ####" >> $ERROR
#echo -e "Installing MPFR-4.1.0..."
#tar xf /sources/mpfr-4.1.0.tar.xz -C /sources
#cd /sources/mpfr-4.1.0
#./configure --prefix=/usr \
#	--disable-static \
#	--enable-thread-safe \
#	--docdir=/usr/share/doc/mpfr-4.1.0 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make html > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#make install-html > /dev/null 2>> $ERROR
#if [[ -f /usr/lib/libmpfr.so ]]
#then
#	echo -e "MPFR-4.1.0 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "MPFR-4.1.0 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf mpfr-4.1.0
#
#### MPC-1.2.1 ####
#
#echo -e "#### MPC-1.2.1 ####" >> $ERROR
#echo -e "Installing MPC-1.2.1"
#tar xf /sources/mpc-1.2.1.tar.gz -C /sources
#cd /sources/mpc-1.2.1
#./configure --prefix=/usr \
#	--disable-static \
#	--docdir=/usr/share/doc/mpc-1.2.1 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make html > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#make install-html > /dev/null 2>> $ERROR
#if [[ -f /usr/lib/libmpc.so ]]
#then
#	echo -e "MPC-1.2.1 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "MPC-1.2.1 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf mpc-1.2.1
#
#### Attr-2.4.48 ####
#
#echo -e "#### Attr-2.4.48 ####" >> $ERROR
#echo -e "Installing Attr-2.4.48..."
#tar xf /sources/attr-2.4.48.tar.gz -C /sources
#cd /sources/attr-2.4.48
#./configure --prefix=/usr \
#	--disable-static \
#	--sysconfdir=/etc \
#	--docdir=/usr/share/doc/attr-2.4.48 > /dev/null 2>> $ERROR
#make >> $CHECK 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv /usr/lib/libattr.so.* /lib
#ln -sf ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so
#if [[ -f /usr/bin/attr ]]
#then
#	echo -e "Attr-2.4.48 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Attr-2.4.48 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf attr-2.4.48
#
##### Acl-2.2.53 ####
#
#echo -e "#### Acl-2.2.53 ####" >> $ERROR
#echo -e "Installing Acl-2.2.53..."
#tar xf /sources/acl-2.2.53.tar.gz -C /sources
#cd /sources/acl-2.2.53
#./configure --prefix=/usr \
#	--disable-static \
#	--libexecdir=/usr/lib \
#	--docdir=/usr/share/doc/acl-2.2.53 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv /usr/lib/libacl.so.* /lib
#ln -sf ../../lib/$(readlink /usr/lib/libacl.so) /usr/lib/libacl.so
#if [[ -f /usr/bin/chacl ]]
#then
#	echo -e "Acl-2.2.53 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Acl-2.2.53 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf acl-2.2.53

#### Libcap-2.48 ####

#echo -e "#### Libcap-2.48 ####" >> $ERROR
#echo -e "Installing Libcap-2.48..."
#tar xf /sources/libcap-2.48.tar.xz -C /sources
#cd /sources/libcap-2.48
#sed -i '/install -m.*STA/d' libcap/Makefile
#make prefix=/usr lib=lib > /dev/null 2>> $ERROR
#make test >> $CHECK 2>> $ERROR
#make prefix=/usr lib=lib install > /dev/null 2>> $ERROR
#for libname in cap psx; do
#	mv /usr/lib/lib${libname}.so.* /lib
#	ln -sf ../../lib/lib${libname}.so.2 /usr/lib/lib${libname}.so
#	chmod 755 /lib/lib${libname}.so.2.48
#done
#if [[ -f /usr/sbin/getcap ]]
#then
#	echo -e "Libcap-2.48 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Libcap-2.48 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf libcap-2.48

#### Shadow-4.8.1 ####

#echo -e "#### Shadow-4.8.1 ####" >> $ERROR
#echo -e "Installing Shadow-4.8.1"
#tar xf /sources/shadow-4.8.1.tar.xz -C /sources
#cd /sources/shadow-4.8.1
#sed -i 's/groups$(EXEEXT) //' src/Makefile.in
#find man -name Makefile.in -exec sed -i 's/groups\.1 / /' {} \;
#find man -name Makefile.in -exec sed -i 's/getspnam\.3 / /' {} \;
#find man -name Makefile.in -exec sed -i 's/passwd\.5 / /' {} \;
#sed -e 's:#ENCRYPT_METHOD DES:ENCRYPT_METHOD SHA512:' \
#    -e 's:/var/spool/mail:/var/mail:' \
#    -i etc/login.defs
#sed -i 's:DICTPATH.*:DICTPATH\t/lib/cracklib/pw_dict:' etc/login.defs
#sed -i 's/1000/999/' etc/useradd
#touch /usr/bin/passwd
#./configure --sysconfdir=/etc \
#	--with-group-name-max-length=32 \
#	--with-libcrack > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#pwconv
#grpconv
######passwd root ### if want to define the root password in interactive
#echo "root:rootpassword" | chpasswd
#if [[ -f /usr/bin/chage ]]
#then
#	echo -e "Shadow-4.8.1 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Shadow-4.8.1 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf shadow-4.8.1
#
#
###### GCC-10.2.0 ####
#
#echo -e "#### GCC-10.2.0 ####" >> $ERROR
#echo -e "Installing GCC-10.2.0"
#tar xf /sources/gcc-10.2.0.tar.xz -C /sources
#cd /sources/gcc-10.2.0
#case $(uname -m) in
#  x86_64)
#    sed -e '/m64=/s/lib64/lib/' \
#        -i.orig gcc/config/i386/t-linux64
#;;
#esac
#mkdir build
#cd build
#../configure --prefix=/usr \
#	LD=ld \
#	--enable-languages=c,c++ \
#	--disable-multilib \
#	--disable-bootstrap \
#	--with-system-zlib > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#ulimit -s 32768
#chown -Rv tester .
#su tester -c "PATH=$PATH make -k check" >> $CHECK 2>> $ERROR
#for i in $(../contrib/test_summary | grep "unexpected failure" | grep -o '[0-9].*')
#do
#	if [[ $i -gt 100 ]]
#	then
#		echo -e "too many errors on tests [${RED}FAILED${WHITE}]"
#		exit 2
#	fi
#done
#make install > /dev/null 2>> $ERROR
#rm -rf /usr/lib/gcc/$(gcc -dumpmachine)/10.2.0/include-fixed/bits/
#chown -R root:root \
#	/usr/lib/gcc/*linux-gnu/10.2.0/include{,-fixed}
#ln -s ../usr/bin/cpp /lib
#ln -sf ../../libexec/gcc/$(gcc -dumpmachine)/10.2.0/liblto_plugin.so \
#	/usr/lib/bfd-plugins/
#echo 'int main(){}' > dummy.c
#cc dummy.c -v -Wl,--verbose &> dummy.log
#if [[ $? -ne 0 ]]
#then
#	echo -e "Compiler Doesn't work [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#readelf -l a.out | grep ': /lib'
#grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log
#grep -B4 '^ /usr/include' dummy.log
#grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g'
#grep "/lib.*/libc.so.6 " dummy.log
#grep found dummy.log
#rm dummy.c a.out dummy.log
#mkdir -p /usr/share/gdb/auto-load/usr/lib
#mv /usr/lib/*gdb.py /usr/share/gdb/auto-load/usr/lib
#if [[ -f /usr/bin/gcc ]]
#then
#	echo -e "GCC-10.2.0 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "GCC-10.2.0 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf gcc-10.2.0

##### Pkg-config-0.29.2 ####

#echo -e "#### Pkg-config-0.29.2 ####" >> $ERROR
#echo -e "Installing Pkg-config-0.29.2"
#tar xf /sources/pkg-config-0.29.2.tar.gz -C /sources
#cd /sources/pkg-config-0.29.2
#./configure --prefix=/usr \
#	--with-internal-glib \
#	--disable-host-tool \
#	--docdir=/usr/share/doc/pkg-config-0.29.2 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/pkg-config ]]
#then
#	echo -e "Pkg-config-0.29.2 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Pkg-config-0.29.2 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf pkg-config-0.29.2

#### Ncurses-6.2 ####

#echo -e "#### Ncurses-6.2 ####" >> $ERROR
#echo -e "Installing Ncurses-6.2"
#tar xf /sources/ncurses-6.2.tar.gz -C /sources
#cd /sources/ncurses-6.2
#./configure --prefix=/usr \
#	--mandir=/usr/share/man \
#	--with-shared \
#	--without-debug \
#	--without-normal \
#	--enable-pc-files \
#	--enable-widec > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv /usr/lib/libncursesw.so.6* /lib
#ln -sf ../../lib/$(readlink /usr/lib/libncursesw.so) /usr/lib/libncursesw.so
#for lib in ncurses form panel menu ; do
#	rm -f /usr/lib/lib${lib}.so
#	echo "INPUT(-l${lib}w)" > /usr/lib/lib${lib}.so
#	ln -sf ${lib}w.pc /usr/lib/pkgconfig/${lib}.pc
#done
#rm -f /usr/lib/libcursesw.so
#echo "INPUT(-lncursesw)" > /usr/lib/libcursesw.so
#ln -sf libncurses.so /usr/lib/libcurses.so
#rm -f /usr/lib/libncurses++w.a
#mkdir /usr/share/doc/ncurses-6.2
#cp -R doc/* /usr/share/doc/ncurses-6.2
#if [[ -f /usr/bin/clear ]]
#then
#	echo -e "Ncurses-6.2 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Ncurses-6.2 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf ncurses-6.2

#### Sed-4.8 ####

#echo -e "#### Sed-4.8 ####" >> $ERROR
#echo -e "Installing Sed-4.8"
#tar xf /sources/sed-4.8.tar.xz -C /sources
#cd /sources/sed-4.8
#./configure --prefix=/usr --bindir=/bin > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make html > /dev/null 2>> $ERROR
#chown -R tester .
#su tester -c "PATH=$PATH make check" >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#install -d -m755 /usr/share/doc/sed-4.8
#install -m644 doc/sed.html /usr/share/doc/sed-4.8
#if [[ -f /bin/sed ]]
#then
#	echo -e "Sed-4.8 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Sed-4.8 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf sed-4.8

#### Psmisc-23.4 ####

#echo -e "#### Psmisc-23.4 ####" >> $ERROR
#echo -e "Installing Psmisc-23.4"
#tar xf /sources/psmisc-23.4.tar.xz -C /sources
#cd /sources/psmisc-23.4
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv /usr/bin/fuser /bin
#mv /usr/bin/killall /bin
#if [[ -f /bin/fuser ]]
#then
#	echo -e "Psmisc-23.4 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Psmisc-23.4 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf psmisc-23.4

#### Gettext-0.21 ####

#echo -e "#### Gettext-0.21 ####" >> $ERROR
#echo -e "Installing Gettext-0.21"
#tar xf /sources/gettext-0.21.tar.xz -C /sources
#cd /sources/gettext-0.21
#./configure --prefix=/usr \
#	--disable-static \
#	--docdir=/usr/share/doc/gettext-0.21 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#chmod 0755 /usr/lib/preloadable_libintl.so
#if [[ -f /usr/bin/gettext ]]
#then
#	echo -e "Gettext-0.21 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Gettext-0.21 not installed [${RED}FAILED${WHITE}]"
#fi
#cd /sources
#rm -rf gettext-0.21

#### Bison-3.7.5 ####

#echo -e "#### Bison-3.7.5 ####" >> $ERROR
#echo -e "Installing Bison-3.7.5"
#tar xf /sources/bison-3.7.5.tar.xz -C /sources
#cd /sources/bison-3.7.5
#./configure --prefix=/usr --docdir=/usr/share/doc/bison-3.7.5 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/bison ]]
#then
#	echo -e "Bison-3.7.5 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Bison-3.7.5 not installed [${RED}FAILED${WHITE}]"
#fi
#cd /sources
#rm -rf bison-3.7.5

#### Grep-3.6 ####

#echo -e "#### Grep-3.6 ####" >> $ERROR
#echo -e "Installing Grep-3.6"
#tar xf /sources/grep-3.6.tar.xz -C /sources
#cd /sources/grep-3.6
#./configure --prefix=/usr --bindir=/bin > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /bin/grep ]]
#then
#	 echo -e "Grep-3.6 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Grep-3.6 not installed [${RED}FAILED${WHITE}]"
#fi
#cd /sources
#rm -rf grep-3.6
#
##### Bash-5.1 ####
#
#echo -e "#### Bash-5.1 ####" >> $ERROR
#echo -e "Installing Bash-5.1"
#tar xf /sources/bash-5.1.tar.gz -C /sources
#cd /sources/bash-5.1
#sed -i '/^bashline.o:.*shmbchar.h/a bashline.o: ${DEFDIR}/builtext.h' Makefile.in
#./configure --prefix=/usr \
#	--docdir=/usr/share/doc/bash-5.1 \
#	--without-bash-malloc \
#	--with-installed-readline > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#chown -v tester .
#su tester << EOF >> $CHECK 2>> $ERROR
#PATH=$PATH make tests < $(tty)
#EOF
#make install > /dev/null 2>> $ERROR
#mv -f /usr/bin/bash /bin
#exec /bin/bash --login +h
#if [[ $? -eq 0 ]]
#then
#	echo -e "Bash-5.1 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Bash-5.1 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf bash-5.1
#
##### Libtool-2.4.6 ####
#
#echo -e "#### Libtool-2.4.6 ####" >> $ERROR
#echo -e "Installing Libtool-2.4.6"
#tar xf /sources/libtool-2.4.6.tar.xz -C /sources
#cd /sources/libtool-2.4.6
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#rm -f /usr/lib/libltdl.a
#if [[ -f /usr/bin/libtool ]]
#then
#	echo -e "Libtool-2.4.6 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Libtool-2.4.6 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf libtool-2.4.6
#
##### GDBM-1.19 ####
#
#echo -e "#### GDBM-1.19 ####" >> $ERROR
#echo -e "Installing GDBM-1.19"
#tar xf /sources/gdbm-1.19.tar.gz -C /sources
#cd /sources/gdbm-1.19
#./configure --prefix=/usr \
#	--disable-static \
#	--enable-libgdbm-compat > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/gdbm_dump ]]
#then
#	echo -e "GDBM-1.19 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "GDBM-1.19 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf gdbm-1.19
#
##### Gperf-3.1 ####
#
#echo -e "#### Gperf-3.1 ####" >> $ERROR
#echo -e "Installing Gperf-3.1"
#tar xf /sources/gperf-3.1.tar.gz -C /sources
#cd /sources/gperf-3.1
#./configure --prefix=/usr --docdir=/usr/share/doc/gperf-3.1 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make -j1 check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/gperf ]]
#then
#	echo -e "Gperf-3.1 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Gperf-3.1 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf gperf-3.1
#

#### Expat-2.2.10 ####

#echo -e "#### Expat-2.2.10 ####" >> $ERROR
#echo -e "Installing Expat-2.2.10..."
#tar xf /sources/expat-2.2.10.tar.xz -C /sources
#cd /sources/expat-2.2.10
#./configure --prefix=/usr \
#	--disable-static \
#	--docdir=/usr/share/doc/expat-2.2.10 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#install -m644 doc/*.{html,png,css} /usr/share/doc/expat-2.2.10
#if [[ -f /usr/bin/xmlwf ]]
#then
#	echo -e "Expat-2.2.10 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Expat-2.2.10 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf expat-2.2.10

#### Inetutils-2.0 ####
#
#echo -e "#### Inetutils-2.0 ####" >> $ERROR
#echo -e "Installing Inetutils-2.0..."
#tar xf /sources/inetutils-2.0.tar.xz -C /sources
#cd /sources/inetutils-2.0
#./configure --prefix=/usr \
#	--localstatedir=/var \
#	--disable-logger \
#	--disable-whois \
#	--disable-rcp \
#	--disable-rexec \
#	--disable-rlogin \
#	--disable-rsh \
#	--disable-servers > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv /usr/bin/{hostname,ping,ping6,traceroute} /bin
#mv /usr/bin/ifconfig /sbin
#if [[ -f /bin/ping ]]
#then
#	echo -e "Inetutils-2.0 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Inetutils-2.0 not installed [${RED}FAILED${WHITE}]"
#fi
#cd /sources
#rm -rf inetutils-2.0

#### Perl-5.32.1 ####
#
#echo -e "#### Perl-5.32.1 ####" >> $ERROR
#echo -e "Installing Perl-5.32.1..."
#tar xf /sources/perl-5.32.1.tar.xz -C /sources
#cd /sources/perl-5.32.1
#export BUILD_ZLIB=False
#export BUILD_BZIP2=0
#sh Configure -des \
#	-Dprefix=/usr \
#	-Dvendorprefix=/usr \
#	-Dprivlib=/usr/lib/perl5/5.32/core_perl \
#	-Darchlib=/usr/lib/perl5/5.32/core_perl \
#	-Dsitelib=/usr/lib/perl5/5.32/site_perl \
#	-Dsitearch=/usr/lib/perl5/5.32/site_perl \
#	-Dvendorlib=/usr/lib/perl5/5.32/vendor_perl \
#	-Dvendorarch=/usr/lib/perl5/5.32/vendor_perl \
#	-Dman1dir=/usr/share/man/man1 \
#	-Dman3dir=/usr/share/man/man3 \
#	-Dpager="/usr/bin/less -isR" \
#	-Duseshrplib \
#	-Dusethreads > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make test >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#unset BUILD_ZLIB BUILD_BZIP2
#if [[ -f /usr/bin/perl ]]
#then
#	echo -e "Perl-5.32.1 installed [${GREEN}OK${WHITE}]"
#else
#	 echo -e "Perl-5.32.1 not installed [${RED}FAILED${WHITE}]"
#fi
#cd /sources
#rm -rf perl-5.32.1
#

#### XML::Parser-2.46 ####
#
#echo -e "#### XML::Parser-2.46 #####" >> $ERROR
#echo -e "Installing XML::Parser-2.46..."
#tar xf /sources/XML-Parser-2.46.tar.gz -C /sources
#cd /sources/XML-Parser-2.46
#perl Makefile.PL > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make test >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/lib/perl5/5.32/site_perl/auto/XML/Parser/Expat/Expat.so ]]
#then
#	echo -e "XML-Parser-2.46 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "XML-Parser-2.46 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf XML-Parser-2.46
#

#### Intltool-0.51.0 ####

#echo -e "#### Intltool-0.51.0 ####" >> $ERROR
#echo -e "Installing Intltool-0.51.0..."
#tar xf /sources/intltool-0.51.0.tar.gz -C /sources
#cd /sources/intltool-0.51.0
#sed -i 's:\\\${:\\\$\\{:' intltool-update.in
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#install -Dm644 doc/I18N-HOWTO /usr/share/doc/intltool-0.51.0/I18N-HOWTO
#if [[ -f /usr/bin/intltool-extract ]]
#then
#	echo -e "Intltool-0.51.0 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Intltool-0.51.0 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf intltool-0.51.0


#### Autoconf-2.71 ####

#echo -e "#### Autoconf-2.71 ####" >> $ERROR
#echo -e "Installing Autoconf-2.71..."
#tar xf /sources/autoconf-2.71.tar.xz -C /sources
#cd /sources/autoconf-2.71
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/autoconf ]]
#then
#	echo -e "Autoconf-2.71 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Autoconf-2.71 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf autoconf-2.71

#### Automake-1.16.3 ####

#echo -e "#### Automake-1.16.3 ####" >> $ERROR
#echo -e "Installing Automake-1.16.3..."
#tar xf /sources/automake-1.16.3.tar.xz -C /sources
#cd /sources/automake-1.16.3
#sed -i "s/''/etags/" t/tags-lisp-space.sh
#./configure --prefix=/usr --docdir=/usr/share/doc/automake-1.16.3 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make -j4 check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/automake ]]
#then
#	echo -e "Automake-1.16.3 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Automake-1.16.3 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf automake-1.16.3

#### Kmod-28 ####
#
#echo -e "#### Kmod-28 ####" >> $ERROR
#echo -e "Installing Kmod-28..."
#tar xf /sources/kmod-28.tar.xz -C /sources
#cd /sources/kmod-28
#./configure --prefix=/usr \
#	--bindir=/bin \
#	--sysconfdir=/etc \
#	--with-rootlibdir=/lib \
#	--with-xz \
#	--with-zstd \
#	--with-zlib > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#for target in depmod insmod lsmod modinfo modprobe rmmod; do
#	ln -sf ../bin/kmod /sbin/$target
#done
#ln -sf kmod /bin/lsmod
#if [[ -f /bin/kmod ]]
#then
#	echo -e "Kmod-28 installed [${GREEN}OK${WHITE}]"
#else
#	 echo -e "Kmod-28 not installed [${RED}FAILED${WHITE}]"
#	 exit 2
#fi
#cd /sources
#rm -rf kmod-28
#

#### Libelf ####

#echo -e "#### Libelf ####" >> $ERROR
#echo -e "Installing Libelf..."
#tar xf /sources/elfutils-0.183.tar.bz2 -C /sources
#cd /sources/elfutils-0.183
#./configure --prefix=/usr \
#	--disable-debuginfod \
#	--enable-libdebuginfod=dummy \
#	--libdir=/lib > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make -C libelf install > /dev/null 2>> $ERROR
#install -m644 config/libelf.pc /usr/lib/pkgconfig
#rm /lib/libelf.a
#if [[ -f /lib/libelf.so ]]
#then
#	echo -e "Libelf installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Libelf not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf elfutils-0.183

#### Libffi-3.3 ####

#echo -e "#### Libffi-3.3 ####" >> $ERROR
#echo -e "Installing Libffi-3.3..."
#tar xf /sources/libffi-3.3.tar.gz -C /sources
#cd /sources/libffi-3.3
#./configure --prefix=/usr --disable-static --with-gcc-arch=native > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/lib/libffi.so ]]
#then
#	 echo -e "Libffi-3.3 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Libffi-3.3 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf libffi-3.3

#### OpenSSL-1.1.1j ####

#echo -e "#### OpenSSL-1.1.1j ####" >> $ERROR
#echo -e "Installing OpenSSL-1.1.1j..."
#tar xf /sources/openssl-1.1.1j.tar.gz -C /sources
#cd /sources/openssl-1.1.1j
#./config --prefix=/usr \
#	--openssldir=/etc/ssl \
#	--libdir=lib \
#	shared \
#	zlib-dynamic > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make test >> $CHECK 2>> $ERROR
#sed -i '/INSTALL_LIBS/s/libcrypto.a libssl.a//' Makefile
#make MANSUFFIX=ssl install > /dev/null 2>> $ERROR
#mv /usr/share/doc/openssl /usr/share/doc/openssl-1.1.1j
#cp -fr doc/* /usr/share/doc/openssl-1.1.1j
#if [[ -f /usr/lib/libcrypto.so ]]
#then
#	echo -e "OpenSSL-1.1.1j installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "OpenSSL-1.1.1j not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf openssl-1.1.1j

#### Python-3.9.2 ####

#echo -e "#### Python-3.9.2 ####" >> $ERROR
#echo -e "Installing Python-3.9.2..."
#tar xf /sources/Python-3.9.2.tar.xz -C /sources
#cd /sources/Python-3.9.2
#./configure --prefix=/usr \
#	--enable-shared \
#	--with-system-expat \
#	--with-system-ffi \
#	--with-ensurepip=yes > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make test >> $CHECK 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#install -dm755 /usr/share/doc/python-3.9.2/html
#tar --strip-components=1 \
#	--no-same-owner \
#	--no-same-permissions \
#	-C /usr/share/doc/python-3.9.2/html \
#	-xvf ../python-3.9.2-docs-html.tar.bz2
#if [[ -f /usr/bin/python3 ]]
#then
#	echo -e "Python-3.9.2 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Python-3.9.2 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf Python-3.9.2

#### Ninja-1.10.2 ####

#echo -e "#### Ninja-1.10.2 ####" >> $ERROR
#echo -e "Installing Ninja-1.10.2..."
#tar xf /sources/ninja-1.10.2.tar.gz -C /sources
#cd /sources/ninja-1.10.2
#sed -i '/int Guess/a \
#  int j = 0;\
#  char* jobs = getenv( "NINJAJOBS" );\
#  if ( jobs != NULL ) j = atoi( jobs );\
#  if ( j > 0 ) return j;\
#' src/ninja.cc
#python3 configure.py --bootstrap > /dev/null 2>> $ERROR
#./ninja ninja_test > /dev/null 2>> $ERROR
#./ninja_test --gtest_filter=-SubprocessTest.SetWithLots > /dev/null 2>> $ERROR
#install -m755 ninja /usr/bin/
#install -Dm644 misc/bash-completion /usr/share/bash-completion/completions/ninja
#install -Dm644 misc/zsh-completion /usr/share/zsh/site-functions/_ninja
#if [[ -f /usr/bin/ninja ]]
#then 
#	echo -e "Ninja-1.10.2 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Ninja-1.10.2 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf ninja-1.10.2

#### Meson-0.57.1 ####

#echo -e "#### Meson-0.57.1 ####" >> $ERROR
#echo -e "Installing Meson-0.57.1..."
#tar xf /sources/meson-0.57.1.tar.gz -C /sources
#cd /sources/meson-0.57.1
#python3 setup.py build > /dev/null 2>> $ERROR
#python3 setup.py install --root=dest > /dev/null 2>> $ERROR
#cp -r dest/* /
#if [[ -f /usr/bin/meson ]]
#then
#	echo -e "Meson-0.57.1  installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Meson-0.57.1 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf meson-0.57.1

#### Coreutils-8.32 ####

#echo -e "#### Coreutils-8.32 ####" >> $ERROR
#echo -e "Installing Coreutils-8.32..."
#tar xf /sources/coreutils-8.32.tar.xz -C /sources
#cd /sources/coreutils-8.32
#patch -Np1 -i ../coreutils-8.32-i18n-1.patch > /dev/null 2>> $ERROR
#sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk
#autoreconf -fiv
#FORCE_UNSAFE_CONFIGURE=1 ./configure \
#	--prefix=/usr \
#	--enable-no-install-program=kill,uptime > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make NON_ROOT_USERNAME=tester check-root > /dev/null 2>> $ERROR
#echo "dummy:x:102:tester" >> /etc/group
#chown -R tester .
#su tester -c "PATH=$PATH make RUN_EXPENSIVE_TESTS=yes check" >> $CHECK 2>> $ERROR
#sed -i '/dummy/d' /etc/group
#make install > /dev/null 2>> $ERROR
#mv /usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} /bin
#mv /usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} /bin
#mv /usr/bin/{rmdir,stty,sync,true,uname} /bin
#mv /usr/bin/chroot /usr/sbin
#mv /usr/share/man/man1/chroot.1 /usr/share/man/man8/chroot.8
#sed -i 's/"1"/"8"/' /usr/share/man/man8/chroot.8
#mv /usr/bin/{head,nice,sleep,touch} /bin
#if [[ -f /bin/cat ]]
#then
#	echo -e "Coreutils-8.32 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Coreutils-8.32 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf coreutils-8.32

#### Check-0.15.2 ####

#echo -e "#### Check-0.15.2 ####" >> $ERROR
#echo -e "Installing Check-0.15.2..."
#tar xf /sources/check-0.15.2.tar.gz -C /sources
#cd /sources/check-0.15.2
#./configure --prefix=/usr --disable-static > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make docdir=/usr/share/doc/check-0.15.2 install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/diff ]]
#then
#	echo -e "Check-0.15.2 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Check-0.15.2 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf check-0.15.2

#### Gawk-5.1.0 ####

#echo -e "#### Gawk-5.1.0 ####" >> $ERROR
#echo -e "Installing Gawk-5.1.0..."
#tar xf /sources/gawk-5.1.0.tar.xz -C /sources
#cd /sources/gawk-5.1.0
#sed -i 's/extras//' Makefile.in
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mkdir /usr/share/doc/gawk-5.1.0
#cp doc/{awkforai.txt,*.{eps,pdf,jpg}} /usr/share/doc/gawk-5.1.0
#if [[ -f /usr/bin/awk ]]
#then
#	echo -e "Gawk-5.1.0 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Gawk-5.1.0 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf gawk-5.1.0

#### Findutils-4.8.0 ####

#echo -e "#### Findutils-4.8.0 ####" >> $ERROR
#echo -e "Installing Findutils-4.8.0"
#tar xf /sources/findutils-4.8.0.tar.xz -C /sources
#cd /sources/findutils-4.8.0
#./configure --prefix=/usr --localstatedir=/var/lib/locate > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#chown -R tester .
#su tester -c "PATH=$PATH make check" > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv /usr/bin/find /bin
#sed -i 's|find:=${BINDIR}|find:=/bin|' /usr/bin/updatedb
#if [[ -f /bin/find ]]
#then
#	echo -e "Findutils-4.8.0 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Findutils-4.8.0 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf findutils-4.8.0

#### Groff-1.22.4 ####

#echo -e "#### Groff-1.22.4 ####" >> $ERROR
#echo -e "Installing Groff-1.22.4..."
#tar xf /sources/groff-1.22.4.tar.gz -C /sources
#cd /sources/groff-1.22.4
#PAGE=A4 ./configure --prefix=/usr > /dev/null 2>> $ERROR
#make -j1 > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/groff ]]
#then
#	echo -e "Groff-1.22.4 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Groff-1.22.4 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf groff-1.22.4

#### GRUB-2.04 ####

#echo -e "#### GRUB-2.04 ####" >> $ERROR
#echo -e "Installing GRUB-2.04..."
#tar xf /sources/grub-2.04.tar.xz -C /sources
#cd /sources/grub-2.04
#sed "s/gold-version/& -R .note.gnu.property/" \
#	-i Makefile.in grub-core/Makefile.in
#./configure --prefix=/usr \
#	--sbindir=/sbin \
#	--sysconfdir=/etc \
#	--disable-efiemu \
#	--disable-werror > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv /etc/bash_completion.d/grub /usr/share/bash-completion/completions
#if [[ -f /sbin/grub-install ]]
#then
#	echo -e "GRUB-2.04 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "GRUB-2.04 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf grub-2.04

#### Less-563 ####

#echo -e "#### Less-563 ####" >> $ERROR
#echo -e "Installing Less-563..."
#tar xf /sources/less-563.tar.gz -C /sources
#cd /sources/less-563
#./configure --prefix=/usr --sysconfdir=/etc > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/less ]]
#then
#	echo -e "Less-563 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Less-563 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf less-563

#### Gzip-1.10 ####

#echo -e "#### Gzip-1.10 ####" >> $ERROR
#echo -e "Installing Gzip-1.10..."
#tar xf /sources/gzip-1.10.tar.xz -C /sources
#cd /sources/gzip-1.10
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv /usr/bin/gzip /bin
#if [[ -f /bin/gzip ]]
#then
#	echo -e "Gzip-1.10 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Gzip-1.10 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf /sources/gzip-1.10

#### IPRoute2-5.10.0 ####

#echo -e "#### IPRoute2-5.10.0 ####" >> $ERROR
#echo -e "Installing IPRoute2-5.10.0..."
#tar xf /sources/iproute2-5.10.0.tar.xz -C /sources
#cd /sources/iproute2-5.10.0
#sed -i /ARPD/d Makefile
#rm -f man/man8/arpd.8
#sed -i 's/.m_ipt.o//' tc/Makefile
#make > /dev/null 2>> $ERROR
#make DOCDIR=/usr/share/doc/iproute2-5.10.0 install > /dev/null 2>> $ERROR
#if [[ -f /sbin/ip ]]
#then
#	echo -e "IPRoute2-5.10.0 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "IPRoute2-5.10.0 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf iproute2-5.10.0

#### Kbd-2.4.0 ####

#echo -e "#### Kbd-2.4.0 ####" >> $ERROR
#echo -e "Installing Kbd-2.4.0..."
#tar xf /sources/kbd-2.4.0.tar.xz -C /sources
#cd /sources/kbd-2.4.0
#patch -Np1 -i ../kbd-2.4.0-backspace-1.patch > /dev/null 2>> $ERROR
#sed -i '/RESIZECONS_PROGS=/s/yes/no/' configure
#sed -i 's/resizecons.8 //' docs/man/man8/Makefile.in
#./configure --prefix=/usr --disable-vlock > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mkdir /usr/share/doc/kbd-2.4.0
#cp -R docs/doc/* /usr/share/doc/kbd-2.4.0
#if [[ -f /usr/bin/loadkeys ]]
#then
#	echo -e "Kbd-2.4.0 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Kbd-2.4.0 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf kbd-2.4.0


#### Libpipeline-1.5.3 ####

#echo -e "#### Libpipeline-1.5.3 ####" >> $ERROR
#echo -e "Installing Libpipeline-1.5.3..."
#tar xf /sources/libpipeline-1.5.3.tar.gz -C /sources
#cd /sources/libpipeline-1.5.3
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/lib/libpipeline.so ]]
#then
#	echo -e "Libpipeline-1.5.3 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Libpipeline-1.5.3 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf libpipeline-1.5.3

#### Make-4.3 ####

#echo -e "#### Make-4.3 ####" >> $ERROR
#echo -e "Installing Make-4.3..."
#tar xf /sources/make-4.3.tar.gz -C /sources
#cd /sources/make-4.3
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/make ]]
#then
#	echo -e "Make-4.3 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Make-4.3 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf make-4.3

#### Patch-2.7.6 ####

#echo -e "#### Patch-2.7.6 ####" >> $ERROR
#echo -e "Installing Patch-2.7.6..."
#tar xf /sources/patch-2.7.6.tar.xz -C /sources
#cd /sources/patch-2.7.6
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/patch ]]
#then
#	echo -e "Patch-2.7.6 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Patch-2.7.6 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf patch-2.7.6

#### Man-DB-2.9.4 ####

#echo -e "#### Man-DB-2.9.4 ####" >> $ERROR
#echo -e "Installing Man-DB-2.9.4..."
#tar xf /sources/man-db-2.9.4.tar.xz -C /sources
#cd /sources/man-db-2.9.4
#sed -i '/find/s@/usr@@' init/systemd/man-db.service.in
#./configure --prefix=/usr \
#	--docdir=/usr/share/doc/man-db-2.9.4 \
#	--sysconfdir=/etc \
#	--disable-setuid \
#	--enable-cache-owner=bin \
#	--with-browser=/usr/bin/lynx \
#	--with-vgrind=/usr/bin/vgrind \
#	--with-grap=/usr/bin/grap > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /usr/bin/man ]]
#then
#	echo -e "Man-DB-2.9.4 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Man-DB-2.9.4 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf man-db-2.9.4

#### Tar-1.34 ####

#echo -e "#### Tar-1.34 ####" >> $ERROR
#echo -e "Installing Tar-1.34..."
#tar xf /sources/tar-1.34.tar.xz -C /sources
#cd /sources/tar-1.34
#FORCE_UNSAFE_CONFIGURE=1 \
#	./configure --prefix=/usr \
#		--bindir=/bin > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#make -C doc install-html docdir=/usr/share/doc/tar-1.34 > /dev/null 2>> $ERROR
#if [[ -f /bin/tar ]]
#then
#	echo -e "Tar-1.34 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Tar-1.34 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf tar-1.34

#### Texinfo-6.7 ####

#echo -e "#### Texinfo-6.7 ####" >> $ERROR
#echo -e "Installing Texinfo-6.7..."
#tar xf /sources/texinfo-6.7.tar.xz -C /sources
#cd /sources/texinfo-6.7
#./configure --prefix=/usr > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#pushd /usr/share/info
#	rm dir
#	for f in *
#		do install-info $f dir 2>/dev/null
#	done
#popd
#if [[ -f /usr/bin/info ]]
#then
#	echo -e "Texinfo-6.7 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Texinfo-6.7 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf texinfo-6.7

#### Systemd-247 ####
#echo -e "#### Systemd-247 ####" >> $ERROR
#echo -e "Installing Systemd-247.."
#tar xf /sources/systemd-247.tar.gz -C /sources
#cd /sources/systemd-247
#patch -Np1 -i ../systemd-247-upstream_fixes-1.patch > /dev/null 2>> $ERROR
#ln -sf /bin/true /usr/bin/xsltproc
#tar -xf ../systemd-man-pages-247.tar.xz
#sed '181,$ d' -i src/resolve/meson.build
#sed -i 's/GROUP="render"/GROUP="video"/' rules.d/50-udev-default.rules.in
#mkdir -p build
#cd build
#LANG=en_US.UTF-8 \
#meson --prefix=/usr \
#	--sysconfdir=/etc \
#	--localstatedir=/var \
#	-Dblkid=true \
#	-Dbuildtype=release \
#	-Ddefault-dnssec=no \
#	-Dfirstboot=false \
#	-Dinstall-tests=false \
#	-Dkmod-path=/bin/kmod \
#	-Dldconfig=false \
#	-Dmount-path=/bin/mount \
#	-Drootprefix= \
#	-Drootlibdir=/lib \
#	-Dsplit-usr=true \
#	-Dsulogin-path=/sbin/sulogin \
#	-Dsysusers=false \
#	-Dumount-path=/bin/umount \
#	-Db_lto=false \
#	-Drpmmacrosdir=no \
#	-Dhomed=false \
#	-Duserdb=false \
#	-Dman=true \
#	-Dmode=release \
#	-Ddocdir=/usr/share/doc/systemd-247 \
#	.. > /dev/null 2>> $ERROR
#LANG=en_US.UTF-8 ninja
#LANG=en_US.UTF-8 ninja install
#rm -f /usr/bin/xsltproc
#rm -rf /usr/lib/pam.d
#systemd-machine-id-setup
#systemctl preset-all
#systemctl disable systemd-time-wait-sync.service
#if [[ -f /bin/systemctl ]]
#then
#	echo -e "Systemd-247 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Systemd-247 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf systemd-247

#### D-Bus-1.12.20 ####

#echo -e "#### D-Bus-1.12.20 ####" >> $ERROR
#echo -e "Installing D-Bus-1.12.20..."
#tar xf /sources/dbus-1.12.20.tar.gz -C /sources
#cd /sources/dbus-1.12.20
#./configure --prefix=/usr \
#	--sysconfdir=/etc \
#	--localstatedir=/var \
#	--disable-static \
#	--disable-doxygen-docs \
#	--disable-xml-docs \
#	--docdir=/usr/share/doc/dbus-1.12.20 \
#	--with-console-auth-dir=/run/console \
#	--with-system-pid-file=/run/dbus/pid \
#	--with-system-socket=/run/dbus/system_bus_socket > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv /usr/lib/libdbus-1.so.* /lib
#ln -sf ../../lib/$(readlink /usr/lib/libdbus-1.so) /usr/lib/libdbus-1.so
#ln -sf /etc/machine-id /var/lib/dbus
#if [[ -f /usr/bin/dbus-daemon ]]
#then
#	echo -e "D-Bus-1.12.20 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "D-Bus-1.12.20 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf dbus-1.12.20

#### Procps-ng-3.3.17 ####

#echo -e "#### Procps-ng-3.3.17 ####" >> $ERROR
#echo -e "Installing Procps-ng-3.3.17"
#tar xf /sources/procps-ng-3.3.17.tar.xz -C /sources
#cd /sources/procps-3.3.17
#./configure --prefix=/usr \
#	--exec-prefix= \
#	--libdir=/usr/lib \
#	--docdir=/usr/share/doc/procps-ng-3.3.17 \
#	--disable-static \
#	--disable-kill \
#	--with-systemd > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv /usr/lib/libprocps.so.* /lib
#ln -sf ../../lib/$(readlink /usr/lib/libprocps.so) /usr/lib/libprocps.so
#if [[ -f /bin/ps ]]
#then
#	echo -e "Procps-ng-3.3.17 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Procps-ng-3.3.17 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf procps-3.3.17

#### Util-linux-2.36.2 ####

#echo -e "#### Util-linux-2.36.2 ####" >> $ERROR
#echo -e "Installing Util-linux-2.36.2"
#tar xf /sources/util-linux-2.36.2.tar.xz -C /sources
#cd /sources/util-linux-2.36.2
#./configure ADJTIME_PATH=/var/lib/hwclock/adjtime \
#	--docdir=/usr/share/doc/util-linux-2.36.2 \
#	--disable-chfn-chsh \
#	--disable-login \
#	--disable-nologin \
#	--disable-su \
#	--disable-setpriv \
#	--disable-runuser \
#	--disable-pylibmount \
#	--disable-static \
#	--without-python \
#	runstatedir=/run > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#chown -R tester .
#su tester -c "make -k check" > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f /bin/dmesg ]]
#then
#	echo -e "Util-linux-2.36.2 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Util-linux-2.36.2 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf util-linux-2.36.2

#### E2fsprogs-1.46.1 ####

#echo -e "#### E2fsprogs-1.46.1 ####" >> $ERROR
#echo -e "Installing E2fsprogs-1.46.1"
#tar xf /sources/e2fsprogs-1.46.1.tar.gz -C /sources
#cd /sources/e2fsprogs-1.46.1
#mkdir build
#cd build
#../configure --prefix=/usr \
#	--bindir=/bin \
#	--with-root-prefix="" \
#	--enable-elf-shlibs \
#	--disable-libblkid \
#	--disable-libuuid \
#	--disable-uuidd \
#	--disable-fsck > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#rm -f /usr/lib/{libcom_err,libe2p,libext2fs,libss}.a
#gunzip /usr/share/info/libext2fs.info.gz
#install-info --dir-file=/usr/share/info/dir /usr/share/info/libext2fs.info
#makeinfo -o doc/com_err.info ../lib/et/com_err.texinfo > /dev/null 2>> $ERROR
#install -m644 doc/com_err.info /usr/share/info
#install-info --dir-file=/usr/share/info/dir /usr/share/info/com_err.info
#if [[ -f /bin/chattr ]]
#then
#	echo -e "E2fsprogs-1.46.1 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "E2fsprogs-1.46.1 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd /sources
#rm -rf e2fsprogs-1.46.1

#save_lib="ld-2.33.so libc-2.33.so libpthread-2.33.so libthread_db-1.0.so"
#cd /lib
#for LIB in $save_lib; do
#	objcopy --only-keep-debug $LIB $LIB.dbg
#	strip --strip-unneeded $LIB
#	objcopy --add-gnu-debuglink=$LIB.dbg $LIB
#done

#save_usrlib="libquadmath.so.0.0.0 libstdc++.so.6.0.28
#	libitm.so.1.0.0 libatomic.so.1.2.0"

#cd /usr/lib

#for LIB in $save_usrlib; do
#	objcopy --only-keep-debug $LIB $LIB.dbg
#	strip --strip-unneeded $LIB
#	objcopy --add-gnu-debuglink=$LIB.dbg $LIB
#done
#unset LIB save_lib save_usrlib
#
#find /usr/lib -type f -name \*.a \
#	-exec strip --strip-debug {} ';' > /dev/null 2>> $ERROR
#find /lib /usr/lib -type f -name \*.so* ! -name \*dbg \
#	-exec strip --strip-unneeded {} ';' > /dev/null 2>> $ERROR
#find /{bin,sbin} /usr/{bin,sbin,libexec} -type f \
#	-exec strip --strip-all {} ';' > /dev/null 2>> $ERROR

#rm -rf /tmp/*

#EOT

#### copy the kernel conf to the kernel sources ###

## kernel conf generated with defconfig, removed kvm and ipv6
## activation of the book recommendation features

#tar xf /mnt/lfs/sources/linux-5.10.17.tar.xz -C /mnt/lfs/sources
#cp .config /mnt/lfs/sources/linux-5.10.17
#chown -R root:root /mnt/lfs/sources/linux-5.10.17
#mount /dev/sda2 /mnt/lfs/boot

chroot "$LFS" /usr/bin/env -i \
	HOME=/root \
	TERM="$TERM" \
	ERROR="/error" \
	CHECK="/make_check" \
	PS1='(lfs chroot) \u:\w\$ ' \
	GREEN='\e[32m' \
	RED='\e[31m' \
	WHITE='\e[0m' \
	PATH=/bin:/usr/bin:/sbin:/usr/sbin \
	/bin/bash --login << "EOT"

#find /usr/lib /usr/libexec -name \*.la -delete
#find /usr -depth -name $(uname -m)-lfs-linux-gnu\* | xargs rm -rf
#rm -rf /tools
#userdel -r tester
#
#ln -s /dev/null /etc/systemd/network/99-default.link

### set name/mac address of ether ###

#cat > /etc/systemd/network/10-lan0.link << "EOF"
#[Match]
## Change the MAC address as appropriate for your network device
#MACAddress=30:9c:23:94:13:82
#[Link]
#Name=lan0
#EOF

### configure ethernet int ####

#cat > /etc/systemd/network/10-eth-static.network << "EOF"
#[Match]
#Name=lan0
#[Network]
#Address=192.168.1.50/24
#Gateway=192.168.1.1
#DNS=1.1.1.1
#Domains=nodomain.no
#EOF

### set /etc/resolv.conf dns server file ###

##ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf

##cat > /etc/resolv.conf << "EOF"
### Begin /etc/resolv.conf
### End /etc/resolv.conf
##EOF

### set hosts/hostname ####

#echo "gregopc" > /etc/hostname

#cat > /etc/hosts << "EOF"
## Begin /etc/hosts
#127.0.0.1 localhost.nodomain.no localhost
## End /etc/hosts
#EOF

##### disable sntp ###
#
#systemctl disable systemd-timesyncd
#
#### set keyboard layout ###
#
#cat > /etc/vconsole.conf << "EOF"
#KEYMAP=fr-fr
#EOF
#
##### configuration for readline library ####
#
#cat > /etc/inputrc << "EOF"
## Begin /etc/inputrc
## Modified by Chris Lynn <roryo@roryo.dynup.net>
#
## Allow the command prompt to wrap to the next line
#set horizontal-scroll-mode Off
#
## Enable 8bit input
#set meta-flag On
#set input-meta On
#
## Turns off 8th bit stripping
#set convert-meta Off
#
## Keep the 8th bit for display
#set output-meta On
#
## none, visible or audible
#set bell-style none
#
## All of the following map the escape sequence of the value
## contained in the 1st argument to the readline specific functions
#"\eOd": backward-word
#"\eOc": forward-word
#
## for linux console
#"\e[1~": beginning-of-line
#"\e[4~": end-of-line
#"\e[5~": beginning-of-history
#"\e[6~": end-of-history
#"\e[3~": delete-char
#"\e[2~": quoted-insert
#
## for xterm
#"\eOH": beginning-of-line
#"\eOF": end-of-line
#
## for Konsole
#"\e[H": beginning-of-line
#"\e[F": end-of-line
#
## End /etc/inputrc
#EOF
#
#### list of loggin shell ###
#
#cat > /etc/shells << "EOF"
## Begin /etc/shells
#/bin/sh
#/bin/bash
## End /etc/shells
#EOF
#
#### Disabling Screen Clearing at Boot Time ####
#mkdir -pv /etc/systemd/system/getty@tty1.service.d
#
#cat > /etc/systemd/system/getty@tty1.service.d/noclear.conf << EOF
#[Service]
#TTYVTDisallocate=no
#EOF
#

#### Disabling tmpfs for /tmp ###
##ln -sfv /dev/null /etc/systemd/system/tmp.mount

#### core dump size limitation ####

#mkdir -pv /etc/systemd/coredump.conf.d
#cat > /etc/systemd/coredump.conf.d/maxuse.conf << EOF
#[Coredump]
#MaxUse=5G
#EOF

#### Making the LFS System Bootable ####


### creation of the mount file ###

#cat > /etc/fstab << "EOF"
## Begin /etc/fstab
## file system
## mount-point type options dump fsck
##				order

#/dev/sda3	/	ext4	defaults	1 1
#/dev/sda4	/home	ext4	defaults	1 1
## End /etc/fstab
#EOF

### Installation of the kernel ###

#cd /sources/linux-5.10.17
#make
#make modules_install
#cp -i arch/x86/boot/bzImage /boot/vmlinuz-5.10.17-lfs-10.1-systemd
#cp -i System.map /boot/System.map-5.10.17
#cp -i .config /boot/config-5.10.17
#install -d /usr/share/doc/linux-5.10.17
#cp -r Documentation/* /usr/share/doc/linux-5.10.17
#install -m755 -d /etc/modprobe.d

### load usb driver ###

#cat > /etc/modprobe.d/usb.conf << "EOF"
## Begin /etc/modprobe.d/usb.conf
#install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
#install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true
## End /etc/modprobe.d/usb.conf
#EOF

#if [[ -f /boot/vmlinuz-5.10.17-lfs-10.1-systemd ]]
#then
#	echo -e "Kernel installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Kernel not installed [${RED}FAILED${WHITE}]"
#fi

#grub-install /dev/sda

#cat > /boot/grub/grub.cfg << "EOF"
# Begin /boot/grub/grub.cfg
#set default=0
#set timeout=10
#insmod ext2
#set root=(hd0,2)
#menuentry "GNU/Linux, Linux 5.10.17-lfs-10.1-systemd" {
#	linux /vmlinuz-5.10.17-lfs-10.1-systemd root=/dev/sda3 ro
#}
#EOF

#echo 10.1-systemd > /etc/lfs-release

#cat > /etc/os-release << "EOF"
#NAME="Linux From Scratch"
#VERSION="10.1-systemd"
#ID=lfs
#PRETTY_NAME="Linux From Scratch 10.1-systemd"
#VERSION_CODENAME="<your name here>"
#EOF

EOT

if [[ $? -eq 2 ]]
then
	exit 2
fi


umount -Rv $LFS


