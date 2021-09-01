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

chroot "$LFS" /usr/bin/env -i \
	HOME=/root \
	TERM="$TERM" \
	ERROR="/error" \
	PS1='(lfs chroot) \u:\w\$ ' \
	GREEN='\e[32m' \
	RED='\e[31m' \
	WHITE='\e[0m' \
	PATH=/bin:/usr/bin:/sbin:/usr/sbin \
	/bin/bash --login +h << "EOT"
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
#make check > /dev/null 2>> $ERROR
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
#make check > /dev/null 2>> $ERROR
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
#make check > /dev/null 2>> $ERROR
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
#make check > /dev/null 2>> $ERROR
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
#make check > /dev/null 2>> $ERROR
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
#make test > /dev/null 2>> $ERROR
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
#make check > /dev/null 2>> $ERROR
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
#make test > /dev/null 2>> $ERROR
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
#make test > /dev/null 2>> $ERROR
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
#make check > /dev/null 2>> $ERROR
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
#make -k check > /dev/null 2>> $ERROR
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
#make check 2>&1 | tee gmp-check-log > /dev/null 2>> $ERROR
#if [[ $(awk '/# PASS:/{total+=$3} ; END{print total}' gmp-check-log) == '197' ]]
#then
#	echo -e "make test [${GREEN}OK${WHITE}]"
#else
#	echo -e "make test  [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#make install > /dev/null 2>> $ERROR
#make install-html > /dev/null 2>> $ERROR
#if [[ -f $LFS/usr/lib/libgmp.so ]]
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
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#make install-html > /dev/null 2>> $ERROR
#if [[ -f $LFS/usr/lib/libmpfr.so ]]
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
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#make install-html > /dev/null 2>> $ERROR
#if [[ -f $LFS/usr/lib/libmpc.so ]]
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
#make > /dev/null 2>> $ERROR
#make check > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#mv /usr/lib/libattr.so.* /lib
#ln -sf ../../lib/$(readlink /usr/lib/libattr.so) /usr/lib/libattr.so
#if [[ -f $LFS/usr/bin/attr ]]
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
#if [[ -f $LFS/usr/bin/chacl ]]
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
#make test > /dev/null 2>> $ERROR
#make prefix=/usr lib=lib install > /dev/null 2>> $ERROR
#for libname in cap psx; do
#	mv /usr/lib/lib${libname}.so.* /lib
#	ln -sf ../../lib/lib${libname}.so.2 /usr/lib/lib${libname}.so
#	chmod 755 /lib/lib${libname}.so.2.48
#done
#if [[ -f $LFS/usr/sbin/getcap ]]
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
#if [[ -f $LFS/usr/bin/chage ]]
#then
#	echo -e "Shadow-4.8.1 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Shadow-4.8.1 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi

EOT

if [[ $? -eq 2 ]]
then
	exit 2
fi
