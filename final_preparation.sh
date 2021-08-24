#!/bin/bash
# final preparation


LC_ALL=POSIX
LFS=/mnt/lfs
HOME=/home/lfs
TERM=xterm-256color
LFS_TGT=x86_64-lfs-linux-gnu
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
LOG=/mnt/lfs/sources/log.txt
export LFS LC_ALL LFS_TGT PATH CONFIG_SITE
export MAKEFLAGS='-j4'

GREEN='\e[32m'
RED='\e[31m'
WHITE='\e[0m'

#### disk verification ####
if [[ $(mount | grep -c "/mnt/lfs") == 0 ]]
then
	echo -e "${RED}Error ${WHITE}: The lfs Root directory is not mounted on any partition"
	exit 1
fi
echo -e "Disk partitions and filesystem [${GREEN}OK${WHITE}]"

### source directory creation and Download ###
mkdir  $LFS/sources
chmod  a+wt $LFS/sources

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

### checksum sources validation ###
pushd $LFS/sources
	echo -e "checksum validation..."
	md5sum --quiet -c md5sums 2> checksum.txt
popd > /dev/null

if [[ $(grep -c ^ $LFS/sources/checksum.txt) > 0 ]]
then
	echo -e "${RED}Error ${WHITE}: checksum incorrect"
	exit 3
else
	echo -e "cheksum [${GREEN}OK${WHITE}]"
fi


### Limited directory Layout ###
mkdir -p $LFS/{bin,etc,lib,lib64,sbin,usr,var}
mkdir -p $LFS/tools  # cross compiler directory

### create unprivileged user ####
groupadd lfs
useradd -s /bin/bash -g lfs -m -k /dev/null lfs
chown lfs $LFS/{usr,lib,lib64,var,etc,bin,sources,sbin,tools}

################ Building the Cross Compiler #################

sudo -u lfs bash << EOZ 

### Binutils-2.36.1 package ###

echo -e "Installing Binutils-2.36.1 package..."
tar xf $LFS/sources/binutils-2.36.1.tar.xz -C $LFS/sources/
mkdir $LFS/sources/binutils-2.36.1/build
cd $LFS/sources/binutils-2.36.1/build
../configure --prefix=$LFS/tools \
--with-sysroot=$LFS \
--target=$LFS_TGT \
--disable-nls \
--disable-werror \
--silent > $LOG 2>&1
make --silent >> $LOG 2>&1
make --silent install >> $LOG 2>&1
cd $LFS/sources
rm -rf $LFS/sources/binutils-2.36.1
echo -e "Binutils-2.36.1 installed [${GREEN}OK${WHITE}]"

### GCC-10.2.0 package ###

echo -e "Installing GCC-10.2.0 package..."
tar xf $LFS/sources/gcc-10.2.0.tar.xz -C $LFS/sources/
cd $LFS/sources/gcc-10.2.0
tar -xf ../mpfr-4.1.0.tar.xz
mv mpfr-4.1.0 mpfr
tar -xf ../gmp-6.2.1.tar.xz
mv gmp-6.2.1 gmp
tar -xf ../mpc-1.2.1.tar.gz
mv mpc-1.2.1 mpc
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
      -i.orig gcc/config/i386/t-linux64
  ;;
esac
mkdir build
cd build
../configure \
--target=$LFS_TGT \
--prefix=$LFS/tools \
--with-glibc-version=2.11 \
--with-sysroot=$LFS \
--with-newlib \
--without-headers \
--enable-initfini-array \
--disable-nls \
--disable-shared \
--disable-multilib \
--disable-decimal-float \
--disable-threads \
--disable-libatomic \
--disable-libgomp \
--disable-libquadmath \
--disable-libssp \
--disable-libvtv \
--disable-libstdcxx \
--enable-languages=c,c++ \
--silent >> $LOG 2>&1
make --silent >>  $LOG 2>&1
make --silent install >> $LOG 2>&1
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
`dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
cd $LFS/sources
rm -rf gcc-10.2.0
echo -e "gcc-10.2.0 installed [${GREEN}OK${WHITE}]"

### Linux-5.10.17 API Headers ###

echo -e "Installing Linux-5.10.17 Headers package..."
tar xf $LFS/sources/linux-5.10.17.tar.xz -C $LFS/sources/
cd $LFS/sources/linux-5.10.17
make --silent mrproper >> log.txt 2>&1
make --silent headers >> log.txt 2>&1
find usr/include -name '.*' -delete
rm usr/include/Makefile
cp -r usr/include $LFS/usr
cd $LFS/sources
rm -rf linux-5.10.17
echo -e "Linux-5.10.17 Headers installed [${GREEN}OK${WHITE}]"

#### Glibc-2.33 ###
echo -e "Installing Glibc-2.33 package..."
tar xf $LFS/sources/glibc-2.33.tar.xz -C $LFS/sources/
cd $LFS/sources/glibc-2.33
case $(uname -m) in
  i?86)
    ln -sfv ld-linux.so.2 $LFS/lib/ld-lsb.so.3
  ;;
  x86_64) ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64
          ln -sfv ../lib/ld-linux-x86-64.so.2 $LFS/lib64/ld-lsb-x86-64.so.3
  ;;
esac
patch -Np1 -i ../glibc-2.33-fhs-1.patch
mkdir build
cd build
../configure \
--prefix=/usr \
--host=$LFS_TGT \
--build=$(../scripts/config.guess) \
--enable-kernel=3.2 \
--with-headers=$LFS/usr/include \
--silent \
libc_cv_slibdir=/lib >> $LOG 2>&1
make >> $LOG 2>&1
make DESTDIR=$LFS install >> $LOG 2>&1
cd $LFS/sources
rm -rf glibc-2.33
echo -e "Glibc-2.33 installed [${GREEN}OK${WHITE}]"

$LFS/tools/libexec/gcc/$LFS_TGT/10.2.0/install-tools/mkheaders


#### Libstdc++ from GCC-10.2.0 ####

echo -e "Installing Libstdc++ from GCC-10.2.0..."
tar xf $LFS/sources/gcc-10.2.0.tar.xz -C $LFS/sources/
cd $LFS/sources/gcc-10.2.0
mkdir -v build
cd build
../libstdc++-v3/configure \
--host=$LFS_TGT \
--build=$(../config.guess) \
--prefix=/usr \
--disable-multilib \
--disable-nls \
--disable-libstdcxx-pch \
--with-gxx-include-dir=/tools/$LFS_TGT/include/c++/10.2.0 >> $LOG 2>&1
make >> $LOG 2>&1
make DESTDIR=$LFS install >> $LOG 2>&1
cd $LFS/sources
rm -rf gcc-10.2.0
echo -e "Libstdc++ installed [${GREEN}OK${WHITE}]"


########################### Cross Compiling Temporary Tools ##############################


#### M4-1.4.18 ####

echo -e "Installing M4..."
tar xf $LFS/sources/m4-1.4.18.tar.xz -C $LFS/sources/
cd $LFS/sources/m4-1.4.18
sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c
echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(build-aux/config.guess) >> $LOG 2>&1
make >> $LOG 2>&1
make DESTDIR=$LFS install >> $LOG 2>&1
cd $LFS/sources
rm -rf gcc-10.2.0
echo -e "M4 installed [${GREEN}OK${WHITE}]"

#### Ncurses-6.2 ####

echo -e "Installing M4..."
tar xf $LFS/sources/ncurses-6.2.tar.gz -C $LFS/sources/
cd $LFS/sources/ncurses-6.2
sed -i s/mawk// configure >> $LOG 2>&1
mkdir build
pushd build
  ../configure
  make -C include >> log.txt 2>&1
  make -C progs tic >> log.txt 2>&1
popd
./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(./config.guess) \
--mandir=/usr/share/man \
--with-manpage-format=normal \
--with-shared \
--without-debug \
--without-ada \
--without-normal \
--enable-widec >> $LOG 2>&1
make >> $LOG 2>&1
make DESTDIR=$LFS TIC_PATH=$(pwd)/build/progs/tic install >> $LOG 2>&1
echo "INPUT(-lncursesw)" > $LFS/usr/lib/libncurses.so
mv $LFS/usr/lib/libncursesw.so.6* $LFS/lib
ln -sf ../../lib/$(readlink $LFS/usr/lib/libncursesw.so) $LFS/usr/lib/libncursesw
cd $LFS/sources
rm -rf $LFS/sources/ncurses-6.2
echo -e "ncursed installed [${GREEN}OK${WHITE}]"

#### bash-5.1 ####

echo -e "Installing bash-5.1..."
tar xf $LFS/sources/bash-5.1.tar.gz -C $LFS/sources/
cd $LFS/sources/bash-5.1
./configure --prefix=/usr \
--build=$(support/config.guess) \
--host=$LFS_TGT \
--without-bash-malloc >> $LOG 2>&1
make >> $LOG 2>&1
make DESTDIR=$LFS install >> $LOG 2>&1
mv $LFS/usr/bin/bash $LFS/bin/bash
ln -sv bash $LFS/bin/sh
cd $LFS/sources
rm -rf $LFS/sources/bash-5.1
echo -e "bash installed [${GREEN}OK${WHITE}]"

#### Coreutils-8.32 ####

echo -e "Installing Coreutils..."
tar xf $LFS/sources/coreutils-8.32.tar.xz -C $LFS/sources/
cd $LFS/sources/coreutils-8.32
./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(build-aux/config.guess) \
--enable-install-program=hostname \
--enable-no-install-program=kill,uptime >> $LOG 2>&1
make >> $LOG 2>&1
make DESTDIR=$LFS install >> $LOG 2>&1
mv $LFS/usr/bin/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} $LFS/bin
mv $LFS/usr/bin/{false,ln,ls,mkdir,mknod,mv,pwd,rm} $LFS/bin
mv $LFS/usr/bin/{rmdir,stty,sync,true,uname} $LFS/bin
mv $LFS/usr/bin/{head,nice,sleep,touch} $LFS/bin
mv $LFS/usr/bin/chroot $LFS/usr/sbin
mkdir -p $LFS/usr/share/man/man8 
mv $LFS/usr/share/man/man1/chroot.1 $LFS/usr/share/man/man8/chroot.8
sed -i 's/"1"/"8"/' $LFS/usr/share/man/man8/chroot.8
cd $LFS/sources
rm -rf $LFS/sources/coreutils-8.32
echo -e "coreutils installed [${GREEN}OK${WHITE}]"

#### Diffutils-3.7 ####

echo -e "Installing Coreutils..."
tar xf $LFS/sources/diffutils-3.7.tar.xz -C $LFS/sources/
cd $LFS/sources/diffutils-3.7
./configure --prefix=/usr --host=$LFS_TGT >> $LOG 2>&1
make >> $LOG 2>&1
make DESTDIR=$LFS install >> $LOG 2>&1
cd $LFS/sources
rm -rf $LFS/sources/diffutils-3.7
echo -e "diffutils installed [${GREEN}OK${WHITE}]"

#### File-5.39 ####

echo -e "Installing File..."
tar xf $LFS/sources/file-5.39.tar.gz -C $LFS/sources/
cd $LFS/sources/file-5.39
mkdir build
pushd build
../configure --disable-bzlib \
--disable-libseccomp \
--disable-xzlib \
--disable-zlib >> log.txt 2>&1
make >> log.txt 2>&1
popd
./configure --prefix=/usr --host=$LFS_TGT --build=$(./config.guess) >> $LOG 2>&1
make FILE_COMPILE=$(pwd)/build/src/file >> $LOG 2>&1
make DESTDIR=$LFS install >> $LOG 2>&1
cd $LFS/sources
rm -rf $LFS/sources/file-5.39
echo -e "file installed [${GREEN}OK${WHITE}]"

#### Findutils-4.8.0 ####

echo -e "Installing File..."
tar xf $LFS/sources/findutils-4.8.0.tar.xz -C $LFS/sources/
cd $LFS/sources/findutils-4.8.0
./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(build-aux/config.guess) >> $LOG 2>&1
make >> $LOG 2>&1
make DESTDIR=$LFS install >> $LOG 2>&1
mv $LFS/usr/bin/find $LFS/bin
sed -i 's|find:=${BINDIR}|find:=/bin|' $LFS/usr/bin/updatedb
cd $LFS/sources
rm -rf $LFS/sources/findutils-4.8.0
echo -e "findutils installed [${GREEN}OK${WHITE}]"

#### Gawk-5.1.0 ####

echo -e "Installing Gawk..."
tar xf $LFS/sources/gawk-5.1.0.tar.xz -C $LFS/sources/
cd $LFS/sources/gawk-5.1.0
./configure --prefix=/usr \
--host=$LFS_TGT \
--build=$(./config.guess) >> $LOG 2>&1
make >> $LOG 2>&1
make DESTDIR=$LFS install >> $LOG 2>&1
cd $LFS/sources
rm -rf $LFS/sources/gawk-5.1.0
echo -e "gawk installled [${GREEN}OK${WHITE}]"

#### Grep-3.6 ####

echo -e "Installing Grep..."
tar xf $LFS/sources/grep-3.6.tar.xz -C $LFS/sources/
cd $LFS/sources/grep-3.6
./configure --prefix=/usr \
--host=$LFS_TGT \
--bindir=/bin >> $LOG 2>&1
make >> $LOG 2>&1
make DESTDIR=$LFS install >> $LOG 2>&1
cd $LFS/sources
rm -rf $LFS/sources/grep-3.6
echo -e "Grep installled [${GREEN}OK${WHITE}]"

#### Gzip-1.10 ####

echo -e "Installing Gzip..."
tar xf $LFS/sources/gzip-1.10.tar.xz -C $LFS/sources/
cd $LFS/sources/gzip-1.10
./configure --prefix=/usr --host=$LFS_TGT >> $LOG 2>&1
make >> $LOG 2>&1
make DESTDIR=$LFS install >> $LOG 2>&1
mv -v $LFS/usr/bin/gzip $LFS/bin
cd $LFS/sources
rm -rf $LFS/sources/gzip-1.10
echo -e "Gzip installed [${GREEN}OK${WHITE}]"

#### Make-4.3 ####

echo -e "Installing make..."
tar xf $LFS/sources/make-4.3.tar.gz -C $LFS/sources/
cd $LFS/sources/make-4.3
./configure --prefix=/usr \
--without-guile \
--host=$LFS_TGT \
--build=$(build-aux/config.guess) >> $LOG 2>&1
make >> $LOG 2>&1
make DESTDIR=$LFS install >> $LOG 2>&1
cd $LFS/sources
rm -rf $LFS/sources/make-4.3
echo -e "Make installed [${GREEN}OK${WHITE}]"

#### Patch-2.7.6 ####


