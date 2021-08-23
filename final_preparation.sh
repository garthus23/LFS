#!/bin/bash
# final preparation


LC_ALL=POSIX
LFS=/mnt/lfs
LFS_TGT=$(uname -m)-lfs-linux-gnu
HOME=/home/lfs
TERM=xterm-256color
PATH=$LFS/tools/bin:$PATH
CONFIG_SITE=$LFS/usr/share/config.site
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
mkdir -v $LFS/sources
chmod -v a+wt $LFS/sources

#wget https://ftp.wrz.de/pub/LFS/lfs-packages/lfs-packages-10.1.tar --directory-prefix=$LFS/sources -q --show-progress
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

### Building the Cross Compiler ###

sudo -u lfs bash << EOZ

### Binutils-2.36.1 package ###

tar xf $LFS/sources/binutils-2.36.1.tar.xz -C $LFS/sources/
mkdir -v $LFS/sources/binutils-2.36.1/build
cd $LFS/sources/binutils-2.36.1/build
../configure --prefix=$LFS/tools \
--with-sysroot=$LFS \
--target=$LFS_TGT \
--disable-nls \
--disable-werror
make
make install
cd $LFS/sources
rm -rf $LFS/sources/binutils-2.36.1

### GCC-10.2.0 package ###

tar xf $LFS/sources/gcc-10.2.0.tar.xz -C $LFS/sources/
cd $LFS/sources/gcc-10.2.0
tar -xf ../mpfr-4.1.0.tar.xz
mv -v mpfr-4.1.0 mpfr
tar -xf ../gmp-6.2.1.tar.xz
mv -v gmp-6.2.1 gmp
tar -xf ../mpc-1.2.1.tar.gz
mv -v mpc-1.2.1 mpc
case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
      -i.orig gcc/config/i386/t-linux64
  ;;
esac
mkdir -v build
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
--enable-languages=c,c++
make
make install
cd ..
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > \
`dirname $($LFS_TGT-gcc -print-libgcc-file-name)`/install-tools/include/limits.h
cd $LFS/sources
rm -rf gcc-10.2.0

### Linux-5.10.17 API Headers ###
tar xf $LFS/sources/linux-5.10.17.tar.xz -C $LFS/sources/
cd $LFS/sources/linux-5.10.17
make mrproper
make headers
find usr/include -name '.*' -delete
rm usr/include/Makefile
cp -rv usr/include $LFS/usr
cd $LFS/sources
rm -rf linux-5.10.17

#### Glibc-2.33 ###
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
libc_cv_slibdir=/lib
make
make DESTDIR=$LFS install
cd $LFS/sources
rm -rf glibc-2.33

$LFS/tools/libexec/gcc/$LFS_TGT/10.2.0/install-tools/mkheaders

EOZ
