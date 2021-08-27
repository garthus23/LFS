#!/bin/bash
# final preparation

LFS=/mnt/lfs
TERM=xterm-256color

GREEN='\e[32m'
RED='\e[31m'
WHITE='\e[0m'

### disk verification ####
#if [[ $(mount | grep -c "/mnt/lfs") == 0 ]]
#then
#	echo -e "${RED}Error ${WHITE}: The lfs Root partition is not mounted on any directory"
#	exit 1
#fi
#echo -e "Disk partitions and filesystem [${GREEN}OK${WHITE}]"
#
### source directory creation and Download ###
#mkdir  $LFS/sources
#chmod  a+wt $LFS/sources
#
#wget https://ftp.wrz.de/pub/LFS/lfs-packages/lfs-packages-10.1.tar --directory-prefix=$LFS/sources -q --show-progress
#if [[ -f "$LFS/sources/lfs-packages-10.1.tar" ]]
#then
#	tar xfs $LFS/sources/lfs-packages-10.1.tar -C $LFS/sources/
#	mv $LFS/sources/10.1/* $LFS/sources/
#	rmdir $LFS/sources/10.1	
#else
#	echo -e "${RED}Error ${WHITE}: Problem extracting sources"
#	exit 2
#fi
#
### checksum sources validation ###
#pushd $LFS/sources
#	echo -e "checksum validation..."
#	md5sum --quiet -c md5sums 2> checksum.txt
#popd > /dev/null
#
#if [[ $(grep -c ^ $LFS/sources/checksum.txt) > 0 ]]
#then
#	echo -e "${RED}Error ${WHITE}: checksum incorrect"
#	exit 3
#else
#	echo -e "cheksum [${GREEN}OK${WHITE}]"
#fi
#
#
### Limited directory Layout ###
#mkdir -p $LFS/{bin,etc,lib,lib64,sbin,usr,var}
#mkdir -p $LFS/tools  # cross compiler directory
#
##### create unprivileged user ####
#groupadd lfs
#useradd -s /bin/bash -g lfs -m -k /dev/null lfs
#chown lfs $LFS/{usr,lib,lib64,var,etc,bin,sources,sbin,tools}

############## Building the Cross Compiler #################

sudo -u lfs bash << "EOZ" 

LC_ALL=POSIX
LFS=/mnt/lfs
HOME=/home/lfs
TERM=xterm-256color
LFS_TGT=x86_64-lfs-linux-gnu
PATH=$LFS/tools/bin:/bin:/usr/bin
CONFIG_SITE=$LFS/usr/share/config.site
ERROR=/mnt/lfs/sources/error
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS='-j4'

GREEN='\e[32m'
RED='\e[31m'
WHITE='\e[0m'

cat > ~/.bash_profile << "EOF"
exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash
EOF

cat > ~/.bashrc << "EOF"
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/usr/bin
if [ ! -L /bin ]; then PATH=/bin:$PATH; fi
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
EOF

#
#### Binutils-2.36.1 package ####
#echo "#### Binutils-2.36.1 package ####" >> $ERROR
#echo -e "Installing Binutils-2.36.1 package..."
#tar xf $LFS/sources/binutils-2.36.1.tar.xz -C $LFS/sources/
#mkdir $LFS/sources/binutils-2.36.1/build
#cd $LFS/sources/binutils-2.36.1/build
#../configure --prefix=$LFS/tools \
#	--with-sysroot=$LFS \
#	--target=$LFS_TGT \
#	--disable-nls \
#	--disable-werror > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#if [[ -f $LFS/tools/x86_64-lfs-linux-gnu/bin/as ]]
#then
#	echo -e "Binutils-2.36.1 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Binutils-2.36.1 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi	
#cd $LFS/sources
#rm -rf $LFS/sources/binutils-2.36.1
#
#### GCC-10.2.0 package ###
#echo -e "#### GCC-10.2.0 package ####" >> $ERROR
#echo -e "Installing GCC-10.2.0 package..."
#tar xf $LFS/sources/gcc-10.2.0.tar.xz -C $LFS/sources/
#cd $LFS/sources/gcc-10.2.0
#tar -xf ../mpfr-4.1.0.tar.xz
#mv mpfr-4.1.0 mpfr
#tar -xf ../gmp-6.2.1.tar.xz
#mv gmp-6.2.1 gmp
#tar -xf ../mpc-1.2.1.tar.gz
#mv mpc-1.2.1 mpc
#sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
#mkdir build
#cd build
#../configure \
#	--target=$LFS_TGT \
#	--prefix=$LFS/tools \
#	--with-glibc-version=2.11 \
#	--with-sysroot=$LFS \
#	--with-newlib \
#	--without-headers \
#	--enable-initfini-array \
#	--disable-nls \
#	--disable-shared \
#	--disable-multilib \
#	--disable-decimal-float \
#	--disable-threads \
#	--disable-libatomic \
#	--disable-libgomp \
#	--disable-libquadmath \
#	--disable-libssp \
#	--disable-libvtv \
#	--disable-libstdcxx \
#	--enable-languages=c,c++ > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#cd ..
#cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
#$LFS/tools/lib/gcc/x86_64-lfs-linux-gnu/10.2.0/install-tools/include/limits.h
#if [[ -d $LFS/tools/lib/gcc ]]
#then
#	echo -e "gcc-10.2.0 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "gcc-10.2.0 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf gcc-10.2.0
#
#### Linux-5.10.17 API Headers ###
#echo -e "#### Linux-5.10.17 package ####" >> $ERROR
#echo -e "Installing Linux-5.10.17 Headers package..."
#tar xf $LFS/sources/linux-5.10.17.tar.xz -C $LFS/sources/
#cd $LFS/sources/linux-5.10.17
#make mrproper > /dev/null 2>> $ERROR
#make headers > /dev/null 2>> $ERROR
#find usr/include -name '.*' -delete
#rm usr/include/Makefile
#cp -r usr/include $LFS/usr
#if [[ -d $LFS/usr/include ]]
#then
#	echo -e "Linux-5.10.17 Headers installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Linux-5.10.17 Headers not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf linux-5.10.17
#
#
##### Glibc-2.33 ####
#echo -e "##### Glibc-2.33 ####" >> $ERROR
#echo -e "Installing Glibc-2.33 package..."
#tar xf $LFS/sources/glibc-2.33.tar.xz -C $LFS/sources/
#cd $LFS/sources/glibc-2.33
#ln -sf ../lib/ld-linux-x86-64.so.2 $LFS/lib64
#ln -sf ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
#patch -Np1 -i ../glibc-2.33-fhs-1.patch > /dev/null 2>> $ERROR
#mkdir build
#cd build
#../configure \
#	--prefix=/usr \
#	--host=$LFS_TGT \
#	--build=$(../scripts/config.guess) \
#	--enable-kernel=3.2 \
#	--with-headers=$LFS/usr/include \
#	libc_cv_slibdir=/lib > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#if [[ -f $LFS/usr/bin/ldd ]]
#then
#	echo -e "Glibc-2.33 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Glibc-2.33 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#
#$LFS/tools/libexec/gcc/$LFS_TGT/10.2.0/install-tools/mkheaders
#cd $LFS/sources
#rm -rf glibc-2.33
#
#
#
#
##### Libstdc++ from GCC-10.2.0 ####
#echo -e "##### Libstdc++ from GCC-10.2.0 ####" >> $ERROR
#echo -e "Installing Libstdc++ from GCC-10.2.0..."
#tar xf $LFS/sources/gcc-10.2.0.tar.xz -C $LFS/sources/
#cd $LFS/sources/gcc-10.2.0
#mkdir build
#cd build
#../libstdc++-v3/configure \
#	--host=$LFS_TGT \
#	--build=$(../config.guess) \
#	--prefix=/usr \
#	--disable-multilib \
#	--disable-nls \
#	--disable-libstdcxx-pch \
#	--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/10.2.0 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#if [[ -d /mnt/lfs/tools/x86_64-lfs-linux-gnu/include/c++ ]]
#then
#	echo -e "Libstdc++ installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Libstdc++ not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf gcc-10.2.0
#
#
############################ Cross Compiling Temporary Tools ##############################
#
#
##### M4-1.4.18 ####
#echo -e "##### M4-1.4.18 ####" >> $ERROR
#echo -e "Installing M4..."
#tar xf $LFS/sources/m4-1.4.18.tar.xz -C $LFS/sources/
#cd $LFS/sources/m4-1.4.18
#sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
#echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
#./configure --prefix=/usr \
#	--host=$LFS_TGT \
#	--build=$(build-aux/config.guess) > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#cd $LFS/sources
#rm -rf m4-1.4.18
#if [[ -f $LFS/usr/bin/m4 ]]
#then
#	echo -e "M4 installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "M4 not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#
##### Ncurses-6.2 ####
#
#echo -e "##### Ncurses-6.2 ####" >> $ERROR
#echo -e "Installing Ncurses..."
#tar xf $LFS/sources/ncurses-6.2.tar.gz -C $LFS/sources/
#cd $LFS/sources/ncurses-6.2
#sed -i s/mawk// configure
#mkdir build
#pushd build
#  ../configure > /dev/null 2>> $ERROR
#  make -C include > /dev/null 2>> $ERROR
#  make -C progs tic > /dev/null 2>> $ERROR
#popd
#./configure --prefix=/usr \
#	--host=$LFS_TGT \
#	--build=$(./config.guess) \
#	--mandir=/usr/share/man \
#	--with-manpage-format=normal \
#	--with-shared \
#	--without-debug \
#	--without-ada \
#	--without-normal \
#	--enable-widec > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install > /dev/null 2>> $ERROR
#echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
#mv $LFS/usr/lib/libncursesw.so.6* $LFS/lib
#ln -sf ../../lib/$(readlink $LFS/usr/lib/libncursesw.so) $LFS/usr/lib/libncursesw.so
#if [[ -f $LFS/usr/bin/tic ]]
#then
#	echo -e "ncurses installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "ncurses not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/ncurses-6.2"

##### bash-5.1 ####

#echo -e "##### bash-5.1 ####" >> $ERROR
#echo -e "Installing bash-5.1..."
#tar xf $LFS/sources/bash-5.1.tar.gz -C $LFS/sources/
#cd $LFS/sources/bash-5.1
#./configure --prefix=/usr \
#	--build=$(support/config.guess) \
#	--host=$LFS_TGT \
#	--without-bash-malloc > /dev/null 2>> $ERROR
#make > /dev/null 2> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#mv -v $LFS/usr/bin/bash $LFS/bin/bash
#ln -sv bash $LFS/bin/sh
#if [[ -f $LFS/bin/bash ]]
#then
#	echo -e "bash installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "bash not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/bash-5.1"


#### Coreutils-8.32 ####
#
#echo -e "##### Coreutils-8.32 ####" >> $ERROR
#echo -e "Installing Coreutils..."
#tar xf $LFS/sources/coreutils-8.32.tar.xz -C $LFS/sources/
#cd $LFS/sources/coreutils-8.32
#./configure --prefix=/usr \
#	--host=$LFS_TGT \
#	--build=$(build-aux/config.guess) \
#	--enable-install-program=hostname \
#	--enable-no-install-program=kill,uptime > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#mv -v $LFS/usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} $LFS/bin
#mv -v $LFS/usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} $LFS/bin
#mv -v $LFS/usr/bin/{rmdir,stty,sync,true,uname} $LFS/bin
#mv -v $LFS/usr/bin/{head,nice,sleep,touch} $LFS/bin
#mv -v $LFS/usr/bin/chroot $LFS/usr/sbin
#mkdir -p $LFS/usr/share/man/man8 
#mv -v $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
#sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8
#if [[ -f $LFS/bin/cat ]]
#then
#	echo -e "coreutils installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "coreutils not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/coreutils-8.32"

##### Diffutils-3.7 ####
#echo -e "##### Diffutils-3.7 ####" >> $ERROR
#echo -e "Installing diffutils..."
#tar xf $LFS/sources/diffutils-3.7.tar.xz -C $LFS/sources/
#cd $LFS/sources/diffutils-3.7
#./configure --prefix=/usr --host=$LFS_TGT > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#cd $LFS/sources
#rm -rf "$LFS/sources/diffutils-3.7"
#if [[ -f $LFS/usr/bin/diff ]]
#then
#	echo -e "diffutils installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "diffutils not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#
##### File-5.39 ####
#echo -e "##### File-5.39 ####" >> $ERROR
#echo -e "Installing File..."
#tar xf $LFS/sources/file-5.39.tar.gz -C $LFS/sources/
#cd $LFS/sources/file-5.39
#mkdir build
#pushd build
#   ../configure --disable-bzlib \
#		--disable-libseccomp \
#		--disable-xzlib \
#		--disable-zlib > /dev/null 2>> $ERROR
#   make > /dev/null 2>> $ERROR
#popd
#./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess) > /dev/null 2>> $ERROR
#make FILE_COMPILE=$(pwd)/build/src/file > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#if [[ -f $LFS/usr/bin/file ]]
#then
#	echo -e "file installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "file not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/file-5.39"
#
##### Findutils-4.8.0 ####
#echo -e "##### Findutils-4.8.0 ####" >> $ERROR
#echo -e "Installing Findutils..."
#tar xf $LFS/sources/findutils-4.8.0.tar.xz -C $LFS/sources/
#cd $LFS/sources/findutils-4.8.0
#./configure --prefix=/usr \
#    --host=$LFS_TGT \
#    --build=$(build-aux/config.guess) > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#mv $LFS/usr/bin/find $LFS/bin
#sed -i 's|find:=${BINDIR}|find:=/bin|' $LFS/usr/bin/updatedb
#if [[ -f $LFS/bin/find ]]
#then
#	echo -e "findutils installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "findutils not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/findutils-4.8.0"

#
##### Gawk-5.1.0 ####

#echo -e "##### Gawk-5.1.0 ####" >> $ERROR
#echo -e "Installing Gawk..."
#tar xf $LFS/sources/gawk-5.1.0.tar.xz -C $LFS/sources/
#cd $LFS/sources/gawk-5.1.0
#sed -i 's/extras//' Makefile.in
#./configure --prefix=/usr \
#	--host=$LFS_TGT \
#	--build=$(./config.guess) > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#if [[ -f $LFS/usr/bin/gawk ]]
#then
#	echo -e "gawk installled [${GREEN}OK${WHITE}]"
#else
#	echo -e "gawk not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/gawk-5.1.0"
#
##### Grep-3.6 ####
#
#echo -e "##### Grep-3.6 ####" >> $ERROR
#echo -e "Installing Grep..."
#tar xf $LFS/sources/grep-3.6.tar.xz -C $LFS/sources/
#cd $LFS/sources/grep-3.6
#./configure --prefix=/usr \
#	--host=$LFS_TGT \
#	--bindir=/bin > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#if [[ -f $LFS/bin/grep ]]
#then
#	echo -e "Grep installled [${GREEN}OK${WHITE}]"
#else
#	echo -e "Grep not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/grep-3.6"
#
##### Gzip-1.10 ####
#
#echo -e "##### Gzip-1.10 ####" >> $ERROR
#echo -e "Installing Gzip..."
#tar xf $LFS/sources/gzip-1.10.tar.xz -C $LFS/sources/
#cd $LFS/sources/gzip-1.10
#./configure --prefix=/usr --host=$LFS_TGT > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#mv $LFS/usr/bin/gzip $LFS/bin
#if [[ -f $LFS/bin/gzip ]]
#then
#	echo -e "Gzip installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Gzip not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/gzip-1.10"
#
##### Make-4.3 ####
#
#echo -e "##### Make-4.3 ####" >> $ERROR
#echo -e "Installing make..."
#tar xf $LFS/sources/make-4.3.tar.gz -C $LFS/sources/
#cd $LFS/sources/make-4.3
#./configure --prefix=/usr \
#	--without-guile \
#	--host=$LFS_TGT \
#	--build=$(build-aux/config.guess) > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#if [[ -f $LFS/usr/bin/make ]]
#then
#	echo -e "Make installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Make not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/make-4.3"
#
##### Patch-2.7.6 ####
#
#echo -e "##### Patch-2.7.6 ####" >> $ERROR
#echo -e "Installing patch..."
#tar xf $LFS/sources/patch-2.7.6.tar.xz -C $LFS/sources/
#cd $LFS/sources/patch-2.7.6
#./configure --prefix=/usr \
#	--host=$LFS_TGT \
#	--build=$(build-aux/config.guess) > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#if [[ -f $LFS/usr/bin/patch ]]
#then
#	echo -e "Patch installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Patch not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/patch-2.7.6"
#
##### Sed-4.8 ####
#
#echo -e "##### Sed-4.8 ####" >> $ERROR
#echo -e "Installing sed..."
#tar xf $LFS/sources/sed-4.8.tar.xz -C $LFS/sources/
#cd $LFS/sources/sed-4.8
#./configure --prefix=/usr \
#	--host=$LFS_TGT \
#	--bindir=/bin > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#if [[ -f $LFS/bin/sed ]]
#then
#	echo -e "Sed installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Sed not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/sed-4.8"
#
##### Tar-1.34 ####

#echo -e "##### Tar-1.34 ####" >> $ERROR
#echo -e "Installing Tar..."
#tar xf $LFS/sources/tar-1.34.tar.xz -C $LFS/sources/
#cd $LFS/sources/tar-1.34
#./configure --prefix=/usr \
#	--host=$LFS_TGT \
#	--build=$(build-aux/config.guess) \
#	--bindir=/bin > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#if [[ -f $LFS/bin/tar ]]
#then
#	echo -e "Tar installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Tar not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/tar-1.34"
#
##### Xz-5.2.5 ####

#echo -e "##### Xz-5.2.5 ####" >> $ERROR
#echo -e "Installing Xz..."
#tar xf $LFS/sources/xz-5.2.5.tar.xz -C $LFS/sources/
#cd $LFS/sources/xz-5.2.5
#./configure --prefix=/usr \
#	--host=$LFS_TGT \
#	--build=$(build-aux/config.guess) \
#	--disable-static \
#	--docdir=/usr/share/doc/xz-5.2.5 > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#mv $LFS/usr/bin/{lzma,unlzma,lzcat,xz,unxz,xzcat} $LFS/bin
#mv $LFS/usr/lib/liblzma.so.* $LFS/lib
#ln -sf ../../lib/$(readlink $LFS/usr/lib/liblzma.so) $LFS/usr/lib/liblzma.so
#if [[ -f $LFS/bin/xz ]]
#then
#	echo -e "Xz installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Xz not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/xz-5.2.5"
#
##### Binutils-2.36.1 ####
#
#echo -e "##### Binutils-2.36.1 ####" >> $ERROR
#echo -e "Installing Binutils..."
#tar xf $LFS/sources/binutils-2.36.1.tar.xz -C $LFS/sources/
#cd $LFS/sources/binutils-2.36.1
#mkdir build
#cd build
#../configure \
#	--prefix=/usr \
#	--build=$(../config.guess) \
#	--host=$LFS_TGT \
#	--disable-nls \
#	--enable-shared \
#	--disable-werror \
#	--enable-64-bit-bfd > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#install -vm755 libctf/.libs/libctf.so.0.0.0 $LFS/usr/lib
#if [[ -f $LFS/usr/bin/as ]]
#then
#	echo -e "Binutils installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Binutils not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/binutils-2.36.1"
#
#
##### GCC-10.2.0 ####
#
#echo -e "##### GCC-10.2.0 ####" >> $ERROR
#echo -e "Installing Gcc..."
#tar xf $LFS/sources/gcc-10.2.0.tar.xz -C $LFS/sources/
#cd $LFS/sources/gcc-10.2.0
#tar -xf ../mpfr-4.1.0.tar.xz
#mv mpfr-4.1.0 mpfr
#tar -xf ../gmp-6.2.1.tar.xz
#mv gmp-6.2.1 gmp
#tar -xf ../mpc-1.2.1.tar.gz
#mv mpc-1.2.1 mpc
#sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
#mkdir build
#cd build
#mkdir -p $LFS_TGT/libgcc
#ln -sv ../../../libgcc/gthr-posix.h $LFS_TGT/libgcc/gthr-default.h
#../configure \
#	--build=$(../config.guess) \
#	--host=$LFS_TGT \
#	--prefix=/usr \
#	CC_FOR_TARGET=$LFS_TGT-gcc \
#	--with-build-sysroot=$LFS \
#	--enable-initfini-array \
#	--disable-nls \
#	--disable-multilib \
#	--disable-decimal-float \
#	--disable-libatomic \
#	--disable-libgomp \
#	--disable-libquadmath \
#	--disable-libssp \
#	--disable-libvtv \
#	--disable-libstdcxx \
#	--enable-languages=c,c++ > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make DESTDIR=$LFS install > /dev/null 2>> $ERROR
#ln -sv gcc $LFS/usr/bin/cc
#if [[ -f $LFS/usr/bin/cc ]]
#then
#	echo -e "Gcc installed [${GREEN}OK${WHITE}]"
#else
#	echo -e "Gcc not installed [${RED}FAILED${WHITE}]"
#	exit 2
#fi
#cd $LFS/sources
#rm -rf "$LFS/sources/gcc-10.2.0"
#
EOZ
#
if [[ $? -eq 2 ]]
then
	exit 2
fi
#### Preparing the Virtual Kernel ####

#chown -R root:root $LFS/{usr,lib,lib64,var,etc,bin,sbin,tools}
#mkdir -p $LFS/{dev,proc,sys,run}
#
#mknod -m 600 $LFS/dev/console c 5 1
#mknod -m 666 $LFS/dev/null c 1 3
#
#mount --bind /dev $LFS/dev
#mount -t proc proc $LFS/proc
#mount -t sysfs sysfs $LFS/sys
#mount -t tmpfs tmpfs $LFS/run
#mount --bind /dev/pts $LFS/dev/pts
#
##### Entering In the environment ####
#
#chroot "$LFS" /usr/bin/env -i \
#HOME=/root \
#ERROR=/error \
#GREEN='\e[32m' \
#RED='\e[31m' \
#WHITE='\e[0m' \
#TERM="$TERM" \
#PS1='(lfs chroot) \u:\w\$ ' \
#PATH=/bin:/usr/bin:/sbin:/usr/sbin \
#/bin/bash --login +h << "EOZ"
#
#mkdir -p /{boot,home,mnt,opt,srv}
#mkdir -p /etc/{opt,sysconfig}
#mkdir -p /lib/firmware
#mkdir -p /media/{floppy,cdrom}
#mkdir -p /usr/{,local/}{bin,include,lib,sbin,src}
#mkdir -p /usr/{,local/}share/{color,dict,doc,info,locale,man}
#mkdir -p /usr/{,local/}share/{misc,terminfo,zoneinfo}
#mkdir -p /usr/{,local/}share/man/man{1..8}
#mkdir -p /var/{cache,local,log,mail,opt,spool}
#mkdir -p /var/lib/{color,misc,locate}
#ln -svf /run /var/run
#ln -svf /run/lock /var/lock
#install -d -m 0750 /root
#install -d -m 1777 /tmp /var/tmp
#
#ln -sv /proc/self/mounts /etc/mtab
#echo "127.0.0.1 localhost $(hostname)" > /etc/hosts
#
#cat > /etc/passwd << "EOF"
#root:x:0:0:root:/root:/bin/bash
#bin:x:1:1:bin:/dev/null:/bin/false
#daemon:x:6:6:Daemon User:/dev/null:/bin/false
#messagebus:x:18:18:D-Bus Message Daemon User:/run/dbus:/bin/false
#systemd-bus-proxy:x:72:72:systemd Bus Proxy:/:/bin/false
#systemd-journal-gateway:x:73:73:systemd Journal Gateway:/:/bin/false
#systemd-journal-remote:x:74:74:systemd Journal Remote:/:/bin/false
#systemd-journal-upload:x:75:75:systemd Journal Upload:/:/bin/false
#systemd-network:x:76:76:systemd Network Management:/:/bin/false
#systemd-resolve:x:77:77:systemd Resolver:/:/bin/false
#systemd-timesync:x:78:78:systemd Time Synchronization:/:/bin/false
#systemd-coredump:x:79:79:systemd Core Dumper:/:/bin/false
#uuidd:x:80:80:UUID Generation Daemon User:/dev/null:/bin/false
#nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
#EOF
#
#cat > /etc/group << "EOF"
#root:x:0:
#bin:x:1:daemon
#sys:x:2:
#kmem:x:3:
#tape:x:4:
#tty:x:5:
#daemon:x:6:
#floppy:x:7:
#disk:x:8:
#lp:x:9:
#dialout:x:10:
#audio:x:11:
#video:x:12:
#utmp:x:13:
#usb:x:14:
#cdrom:x:15:
#adm:x:16:
#messagebus:x:18:
#systemd-journal:x:23:
#input:x:24:
#mail:x:34:
#kvm:x:61:
#systemd-bus-proxy:x:72:
#systemd-journal-gateway:x:73:
#systemd-journal-remote:x:74:
#systemd-journal-upload:x:75:
#systemd-network:x:76:
#systemd-resolve:x:77:
#systemd-timesync:x:78:
#systemd-coredump:x:79:
#uuidd:x:80:
#wheel:x:97:
#nogroup:x:99:
#users:x:999:
#EOF
#
#echo "tester:x:101:101::/home/tester:/bin/bash" >> /etc/passwd
#echo "tester:x:101:" >> /etc/group
#install -o tester -d /home/tester
#exec /bin/bash --login +h
#touch /var/log/{btmp,lastlog,faillog,wtmp}
#chgrp -v utmp /var/log/lastlog
#chmod -v 664  /var/log/lastlog
#chmod -v 600  /var/log/btmp
#
##### Libstdc++ from GCC-10.2.0 ####
#
#echo -e "Installing Libstdc++ from GCC-10.2.0..."
#tar xf /sources/gcc-10.2.0.tar.xz -C /sources/
#cd /sources/gcc-10.2.0
#mkdir build
#cd build
#../libstdc++-v3/configure \
#CXXFLAGS="-g -O2 -D_GNU_SOURCE" \
#--prefix=/usr \
#--disable-multilib \
#--disable-nls \
#--host=$(uname -m)-lfs-linux-gnu \
#--disable-libstdcxx-pch > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#make install > /dev/null 2>> $ERROR
#cd /sources
#rm -rf gcc-10.2.0
#echo -e "Libstdc++ installed [${GREEN}OK${WHITE}]"
#
#### Gettext-0.21 ###
#
#echo -e "Installing Gettext..."
#tar xf /sources/gettext-0.21.tar.xz -C /sources/
#cd /sources/gettext-0.21
#./configure --disable-shared > /dev/null 2>> $ERROR
#make > /dev/null 2>> $ERROR
#cp -v gettext-tools/src/{msgfmt,msgmerge,xgettext} /usr/bin
#cd /sources
#rm -rf gettext-0.21
#echo -e "Gettext installed [${GREEN}OK${WHITE}]"
#
##### Bison-3.7.5 ###
#
#echo -e "Installing Bison..."
#tar xf /sources/bison-3.7.5.tar.xz -C /sources/
#cd /sources/bison-3.7.5
#./configure --prefix=/usr \
#--docdir=/usr/share/doc/bison-3.7.5 >> /log 2>&1
#make >> /log 2>&1
#make install >> /log 2>&1
#cd /sources
#rm -rf bison-3.7.5
#echo -e "Bison installed [${GREEN}OK${WHITE}]"
#
#### Perl-5.32.1 ###
#
#echo -e "Installing Perl..."
#tar xf /sources/perl-5.32.1.tar.xz -C /sources/
#cd /sources/perl-5.32.1
#sh Configure -des \
#-Dprefix=/usr \
#-Dvendorprefix=/usr \
#-Dprivlib=/usr/lib/perl5/5.32/core_perl \
#-Darchlib=/usr/lib/perl5/5.32/core_perl \
#-Dsitelib=/usr/lib/perl5/5.32/site_perl \
#-Dsitearch=/usr/lib/perl5/5.32/site_perl \
#-Dvendorlib=/usr/lib/perl5/5.32/vendor_perl \
#-Dvendorarch=/usr/lib/perl5/5.32/vendor_perl >> log 2>&1
#make >> /log 2>&1
#make install >> /log 2>&1
#cd /sources
#rm -rf perl-5.32.1
#echo -e "Perl installed [${GREEN}OK${WHITE}]"
#
#### Python-3.9.2 ###
#
#echo -e "Installing Python..."
#tar xf /sources/Python-3.9.2.tar.xz -C /sources/
#cd /sources/Python-3.9.2
#./configure --prefix=/usr \
#--enable-shared \
#--without-ensurepip >> /log 2>&1
#make >> /log 2>&1
#make install >> /log 2>&1
#cd /sources
#rm -rf Python-3.9.2
#echo -e "Python installed [${GREEN}OK${WHITE}]"
#
#### Texinfo-6.7 ###
#
#echo -e "Installing Texinfo..."
#tar xf /sources/texinfo-6.7.tar.xz -C /sources/
#cd /sources/texinfo-6.7
#./configure --prefix=/usr >> /log 2>&1
#make >> /log 2>&1
#make install >> /log 2>&1
#cd /sources
#rm -rf texinfo-6.7
#echo -e "Texinfo installed [${GREEN}OK${WHITE}]"
#
#
#### Util-linux-2.36.2 ###
#
#echo -e "Installing Util-Linux..."
#tar xf /sources/util-linux-2.36.2.tar.xz -C /sources/
#cd /sources/util-linux-2.36.2
#mkdir -pv /var/lib/hwclock
#./configure ADJTIME_PATH=/var/lib/hwclock/adjtime \
#--docdir=/usr/share/doc/util-linux-2.36.2 \
#--disable-chfn-chsh \
#--disable-login \
#--disable-nologin \
#--disable-su \
#--disable-setpriv \
#--disable-runuser \
#--disable-pylibmount \
#--disable-static \
#--without-python \
#runstatedir=/run >> /log 2>&1
#make >> /log 2>&1
#make install >> /log 2>&1
#cd /sources
#rm -rf util-linux-2.36.2
#echo -e "Util-Linux installed [${GREEN}OK${WHITE}]"
#
#find /usr/{lib,libexec} -name \*.la -delete
#rm -rf /usr/share/{info,man,doc}/*
#
#EOZ
#
#
##### cleaning and backup CrossToolchain and Temporary Tools ####
#
#umount $LFS/run
#umount $LFS/proc
#umount $LFS/sys
#umount $LFS/dev/pts
#wait $!
#umount $LFS/dev
#
#strip --strip-debug $LFS/usr/lib/* >> $LOG 2>&1
#strip --strip-unneeded $LFS/usr/{,s}bin/* >> $LOG 2>&1
#strip --strip-unneeded $LFS/tools/bin/* >> $LOG 2>&1
#
#
# Backup
# cd $LFS && tar -cJpf $HOME/lfs-temp-tools-10.1-systemd.tar.xz .

# Restore
#
# cd $LFS &&
# rm -rf ./* && tar -xpf $HOME/lfs-temp-tools-10.1-systemd.tar.xz

