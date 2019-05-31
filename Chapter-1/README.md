# Chapter 1: Build Cross Compiler

> 크로스 컴파일러(Cross Compiler)는 컴파일러가 실행되는 플랫폼이 아닌 다른 플랫폼에서 실행 가능한 코드를 생성할 수 있는 컴파일러이다. 크로스 컴파일러 툴은 임베디드 시스템 혹은 여러 플랫폼에서 실행파일을 생성하는데 사용된다. 이것은 운영 체제를 지원하지 않는 마이크로컨트롤러와 같이 컴파일이 실현 불가능한 플랫폼에 컴파일하는데 사용된다. 이것은 시스템이 사용하는데 하나 이상의 플랫폼을 쓰는 반가상화에 이 도구를 사용하는 것이 더 일반적이게 되었다.  
> [Wikipedia - 크로스 컴파일러](https://ko.wikipedia.org/wiki/크로스_컴파일러)

![GNU GCC Cross Compiler](./gcc-cross-compiler.png)  
Picture Source : *[Preshing on Programming - How to Build a GCC Cross-Compiler
](https://preshing.com/20141119/how-to-build-a-gcc-cross-compiler)*

## Step 1. Download Source code

```
$ wget https://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.xz
$ wget https://ftp.gnu.org/gnu/gcc/gcc-9.1.0/gcc-9.1.0.tar.xz
$ wget https://ftp.gnu.org/gnu/glibc/glibc-2.29.tar.xz
$ wget https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz
$ wget https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz
$ wget https://ftp.gnu.org/gnu/mpfr/mpfr-4.0.2.tar.xz
$ wget https://github.com/raspberrypi/linux/archive/raspberrypi-kernel_1.20190517-1.tar.gz
```

## Step 2. Setting Env

```
$ export CONFIG_HOST=`echo ${MACHTYPE} | sed -e 's/-[^-]*/-cross/'`
$ export CONFIG_TARGET=arm-linux-gnueabihf
$ export CONFIG_PREFIX=$HOME/tools
$ export CONFIG_SYSROOT=$CONFIG_PREFIX/$CONFIG_TARGET/sysroot
$ export PATH=$CONFIG_PREFIX/bin:$PATH
$ export PARALLEL_JOBS=$(cat /proc/cpuinfo | grep cores | wc -l)
$ mkdir -pv $CONFIG_SYSROOT
$ ln -svf . $CONFIG_SYSROOT/usr
```

## Step 3. Installation of Cross Binutils

> GNU 바이너리 유틸리티(GNU Binary Utilities) 또는 GNU Binutils는 여러 종류의 오브젝트 파일 형식들을 조작하기 위한 프로그래밍 도구 모음이다.  
> [Wikipedia - GNU 바이너리 유틸리티](https://ko.wikipedia.org/wiki/GNU_바이너리_유틸리티)

```
$ tar xvJf binutils-2.32.tar.xz
$ cd binutils-2.32
$ ./configure \
  --prefix=$CONFIG_PREFIX \
  --target=$CONFIG_TARGET \
  --disable-gdb \
  --disable-multilib \
  --disable-nls \
  --disable-shared \
  --disable-sim \
  --disable-werror \
  --enable-poison-system-directories \
  --enable-static \
  --with-sysroot=$CONFIG_SYSROOT
$ make configure-host
$ make
$ make install
$ $CONFIG_PREFIX/bin/arm-linux-gnueabihf-as -version
  GNU assembler (GNU Binutils) 2.32
  Copyright (C) 2019 Free Software Foundation, Inc.
  This program is free software; you may redistribute it under the terms of
  the GNU General Public License version 3 or later.
  This program has absolutely no warranty.
  This assembler was configured for a target of `arm-linux-gnueabihf'.
$ cd ..
$ rm -rf binutils-2.32
```

## Step 3. Installation of Linux Headers

```
$ tar xvzf raspberrypi-kernel_1.20190517-1.tar.gz
$ cd linux-raspberrypi-kernel_1.20190517-1
$ make ARCH=arm mrproper
$ make ARCH=arm headers_check
$ make ARCH=arm INSTALL_HDR_PATH=$CONFIG_SYSROOT headers_install
$ cd ..
$ rm -rf linux-raspberrypi-kernel_1.20190517-1
```

## Step 4. Installation of Cross GCC Compiler with Static libgcc and no Threads

```
$ tar xvJf gcc-9.1.0.tar.xz
$ tar xvJf mpfr-4.0.2.tar.xz
$ tar xvJf gmp-6.1.2.tar.xz
$ tar xvzf mpc-1.1.0.tar.gz
$ mv -v mpfr-4.0.2 gcc-9.1.0/mpfr
$ mv -v gmp-6.1.2 gcc-9.1.0/gmp
$ mv -v mpc-1.1.0 gcc-9.1.0/mpc
$ mkdir -pv gcc-9.1.0/gcc-build-initial
$ cd gcc-9.1.0/gcc-build-initial
$ ../configure \
  --prefix=$CONFIG_PREFIX \
  --target=$CONFIG_TARGET \
  --disable-decimal-float \
  --disable-largefile \
  --disable-libmudflap \
  --disable-libquadmath \
  --disable-libssp \
  --disable-multilib \
  --disable-nls \
  --disable-shared \
  --disable-static \
  --disable-threads \
  --enable-__cxa_atexit \
  --enable-languages=c \
  --enable-tls \
  --with-abi="aapcs-linux" \
  --with-cpu=arm1176jzf-s \
  --with-float=hard \
  --with-fpu=vfp \
  --with-mode=arm \
  --with-gnu-ld \
  --with-newlib \
  --with-sysroot=$CONFIG_SYSROOT \
  --without-headers
$ make configure-host
$ make gcc_cv_libc_provides_ssp=yes all-gcc all-target-libgcc
$ make install-gcc install-target-libgcc
$ cd ../..
$ rm -rf gcc-9.1.0
```

- GCC를 빌드 할 때 GMP, MPC, MPFR이 필요하여 GCC 소스코드에 압축을 풀어주었습니다.

## Step 5. Installation of glibc

> GNU C 라이브러리는, 일반적으로 glibc로 알려진, GNU 프로젝트가 C 표준 라이브러리를 구현한 것이다.  
> [Wikipedia - GNU C 라이브러리](https://ko.wikipedia.org/wiki/GNU_C_라이브러리)

```
$ tar xvJf glibc-2.29.tar.xz
$ mkdir -pv glibc-2.29/glibc-build
$ cd glibc-2.29/glibc-build
$ AR="$CONFIG_PREFIX/bin/$CONFIG_TARGET-ar" \
  AS="$CONFIG_PREFIX/bin/$CONFIG_TARGET-as" \
  LD="$CONFIG_PREFIX/bin/$CONFIG_TARGET-ld" \
  CC="$CONFIG_PREFIX/bin/$CONFIG_TARGET-gcc" \
  CXX="$CONFIG_PREFIX/bin/$CONFIG_TARGET-g++" \
  RANLIB="$CONFIG_PREFIX/bin/$CONFIG_TARGET-ranlib" \
  READELF="$CONFIG_PREFIX/bin/$CONFIG_TARGET-readelf" \
  STRIP="$CONFIG_PREFIX/bin/$CONFIG_TARGET-strip" \
  OBJCOPY="$CONFIG_PREFIX/bin/$CONFIG_TARGET-objcopy" \
  OBJDUMP="$CONFIG_PREFIX/bin/$CONFIG_TARGET-objdump" \
  ac_cv_path_BASH_SHELL=/bin/bash \
  libc_cv_forced_unwind=yes \
  libc_cv_ssp=no \
  ../configure \
  --prefix=/usr \
  --target=$CONFIG_TARGET \
  --host=$CONFIG_TARGET \
  --build=$CONFIG_HOST \
  --disable-profile \
  --enable-kernel=4.19 \
  --enable-obsolete-rpc \
  --enable-shared \
  --with-headers=$CONFIG_SYSROOT/usr/include \
  --without-cvs \
  --without-gd
$ make
$ make install_root=$CONFIG_SYSROOT install
$ cd ../..
$ rm -rf glibc-2.29
```

## Step 6. Installation of GCC Cross Compiler

```
$ tar xvJf gcc-9.1.0.tar.xz
$ tar xvJf mpfr-4.0.2.tar.xz
$ tar xvJf gmp-6.1.2.tar.xz
$ tar xvzf mpc-1.1.0.tar.gz
$ mv -v mpfr-4.0.2 gcc-9.1.0/mpfr
$ mv -v gmp-6.1.2 gcc-9.1.0/gmp
$ mv -v mpc-1.1.0 gcc-9.1.0/mpc
$ mkdir -pv gcc-9.1.0/gcc-build-final
$ cd gcc-9.1.0/gcc-build-final
$ ../configure \
  --prefix=$CONFIG_PREFIX \
  --target=$CONFIG_TARGET \
  --disable-decimal-float \
  --disable-libgomp \
  --disable-libmudflap \
  --disable-libquadmath \
  --disable-libssp \
  --disable-multilib \
  --enable-__cxa_atexit \
  --enable-languages=c,c++ \
  --enable-shared \
  --enable-static \
  --enable-threads \
  --enable-tls \
  --with-abi="aapcs-linux" \
  --with-build-time-tools=$CONFIG_PREFIX/$CONFIG_TARGET/bin \
  --with-cpu=arm1176jzf-s \
  --with-float=hard \
  --with-fpu=vfp \
  --with-mode=arm \
  --with-gnu-ld \
  --with-sysroot=$CONFIG_SYSROOT
$ make -j$PARALLEL_JOBS configure-host -C gcc-9.1.0/gcc-build-final
$ make -j$PARALLEL_JOBS gcc_cv_libc_provides_ssp=yes -C gcc-9.1.0/gcc-build-final
$ make -j$PARALLEL_JOBS install -C gcc-9.1.0/gcc-build-final
$ $CONFIG_PREFIX/bin/arm-linux-gnueabihf-gcc -v
  내부 spec 사용.
  COLLECT_GCC=/home/leekyuhyuk/tools/bin/arm-linux-gnueabihf-gcc
  COLLECT_LTO_WRAPPER=/home/leekyuhyuk/tools/libexec/gcc/arm-linux-gnueabihf/9.1.0/lto-wrapper
  타겟: arm-linux-gnueabihf
  Configured with: ../configure --prefix=/home/leekyuhyuk/tools --target=arm-linux-gnueabihf --disable-decimal-float --disable-libgomp --disable-libmudflap --disable-libquadmath --disable-libssp --disable-multilib --enable-__cxa_atexit --enable-languages=c,c++ --enable-shared --enable-static --enable-threads --enable-tls --with-abi=aapcs-linux --with-build-time-tools=/home/leekyuhyuk/tools/arm-linux-gnueabihf/bin --with-cpu=arm1176jzf-s --with-float=hard --with-fpu=vfp --with-mode=arm --with-gnu-ld --with-sysroot=/home/leekyuhyuk/tools/arm-linux-gnueabihf/sysroot
  Thread model: posix
  gcc 버전 9.1.0 (GCC)
$ cd ../..
$ rm -rf gcc-9.1.0
```

## Build Cross Compiler Script

위의 내용을 Shell Script로 만들어 놓았습니다.  
타이핑하기 힘든 경우에는 아래의 스크립트를 사용하면 됩니다.

```bash
#!/bin/bash
set -o nounset
set -o errexit

export CONFIG_HOST=`echo ${MACHTYPE} | sed -e 's/-[^-]*/-cross/'`
export CONFIG_TARGET=arm-linux-gnueabihf
export CONFIG_PREFIX=$HOME/tools
export CONFIG_SYSROOT=$CONFIG_PREFIX/$CONFIG_TARGET/sysroot
export PATH=$CONFIG_PREFIX/bin:$PATH
export PARALLEL_JOBS=$(cat /proc/cpuinfo | grep cores | wc -l)

rm -rf $CONFIG_PREFIX
mkdir -pv $CONFIG_SYSROOT
ln -svf . $CONFIG_SYSROOT/usr

# Installation of Cross Binutils
wget -c https://ftp.gnu.org/gnu/binutils/binutils-2.32.tar.xz
tar xvJf binutils-2.32.tar.xz
( cd binutils-2.32 && \
./configure \
--prefix=$CONFIG_PREFIX \
--target=$CONFIG_TARGET \
--disable-gdb \
--disable-multilib \
--disable-nls \
--disable-shared \
--disable-sim \
--disable-werror \
--enable-poison-system-directories \
--enable-static \
--with-sysroot=$CONFIG_SYSROOT )
make -j$PARALLEL_JOBS configure-host -C binutils-2.32
make -j$PARALLEL_JOBS -C binutils-2.32
make -j$PARALLEL_JOBS install -C binutils-2.32
rm -rf binutils-2.32

# Installation of Linux Headers
wget -c https://github.com/raspberrypi/linux/archive/raspberrypi-kernel_1.20190517-1.tar.gz
tar xvzf raspberrypi-kernel_1.20190517-1.tar.gz
make -j$PARALLEL_JOBS ARCH=arm mrproper -C linux-raspberrypi-kernel_1.20190517-1
make -j$PARALLEL_JOBS ARCH=arm headers_check -C linux-raspberrypi-kernel_1.20190517-1
make -j$PARALLEL_JOBS ARCH=arm INSTALL_HDR_PATH=$CONFIG_SYSROOT headers_install -C linux-raspberrypi-kernel_1.20190517-1
rm -rf linux-raspberrypi-kernel_1.20190517-1

# Installation of Cross GCC Compiler with Static libgcc and no Threads
wget -c https://ftp.gnu.org/gnu/gcc/gcc-9.1.0/gcc-9.1.0.tar.xz
wget -c https://ftp.gnu.org/gnu/mpfr/mpfr-4.0.2.tar.xz
wget -c https://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz
wget -c https://ftp.gnu.org/gnu/mpc/mpc-1.1.0.tar.gz
tar xvJf gcc-9.1.0.tar.xz
tar xvJf mpfr-4.0.2.tar.xz
tar xvJf gmp-6.1.2.tar.xz
tar xvzf mpc-1.1.0.tar.gz
mv -v mpfr-4.0.2 gcc-9.1.0/mpfr
mv -v gmp-6.1.2 gcc-9.1.0/gmp
mv -v mpc-1.1.0 gcc-9.1.0/mpc
mkdir -pv gcc-9.1.0/gcc-build-initial
( cd gcc-9.1.0/gcc-build-initial && \
../configure \
--prefix=$CONFIG_PREFIX \
--target=$CONFIG_TARGET \
--disable-decimal-float \
--disable-largefile \
--disable-libmudflap \
--disable-libquadmath \
--disable-libssp \
--disable-multilib \
--disable-nls \
--disable-shared \
--disable-static \
--disable-threads \
--enable-__cxa_atexit \
--enable-languages=c \
--enable-tls \
--with-abi="aapcs-linux" \
--with-cpu=arm1176jzf-s \
--with-float=hard \
--with-fpu=vfp \
--with-mode=arm \
--with-gnu-ld \
--with-newlib \
--with-sysroot=$CONFIG_SYSROOT \
--without-headers )
make -j$PARALLEL_JOBS configure-host -C gcc-9.1.0/gcc-build-initial
make -j$PARALLEL_JOBS gcc_cv_libc_provides_ssp=yes all-gcc all-target-libgcc -C gcc-9.1.0/gcc-build-initial
make -j$PARALLEL_JOBS install-gcc install-target-libgcc -C gcc-9.1.0/gcc-build-initial
rm -rf gcc-9.1.0

# Installation of glibc
wget -c https://ftp.gnu.org/gnu/glibc/glibc-2.29.tar.xz
tar xvJf glibc-2.29.tar.xz
mkdir -pv glibc-2.29/glibc-build
( cd glibc-2.29/glibc-build && \
AR="$CONFIG_PREFIX/bin/$CONFIG_TARGET-ar" \
AS="$CONFIG_PREFIX/bin/$CONFIG_TARGET-as" \
LD="$CONFIG_PREFIX/bin/$CONFIG_TARGET-ld" \
CC="$CONFIG_PREFIX/bin/$CONFIG_TARGET-gcc" \
CXX="$CONFIG_PREFIX/bin/$CONFIG_TARGET-g++" \
RANLIB="$CONFIG_PREFIX/bin/$CONFIG_TARGET-ranlib" \
READELF="$CONFIG_PREFIX/bin/$CONFIG_TARGET-readelf" \
STRIP="$CONFIG_PREFIX/bin/$CONFIG_TARGET-strip" \
OBJCOPY="$CONFIG_PREFIX/bin/$CONFIG_TARGET-objcopy" \
OBJDUMP="$CONFIG_PREFIX/bin/$CONFIG_TARGET-objdump" \
ac_cv_path_BASH_SHELL=/bin/bash \
libc_cv_forced_unwind=yes \
libc_cv_ssp=no \
../configure \
--prefix=/usr \
--target=$CONFIG_TARGET \
--host=$CONFIG_TARGET \
--build=$CONFIG_HOST \
--disable-profile \
--enable-kernel=4.19 \
--enable-obsolete-rpc \
--enable-shared \
--with-headers=$CONFIG_SYSROOT/usr/include \
--without-cvs \
--without-gd )
make -j$PARALLEL_JOBS -C glibc-2.29/glibc-build
make -j$PARALLEL_JOBS install_root=$CONFIG_SYSROOT install -C glibc-2.29/glibc-build
rm -rf glibc-2.29

# Installation of GCC Cross Compiler
tar xvJf gcc-9.1.0.tar.xz
tar xvJf mpfr-4.0.2.tar.xz
tar xvJf gmp-6.1.2.tar.xz
tar xvzf mpc-1.1.0.tar.gz
mv -v mpfr-4.0.2 gcc-9.1.0/mpfr
mv -v gmp-6.1.2 gcc-9.1.0/gmp
mv -v mpc-1.1.0 gcc-9.1.0/mpc
mkdir -pv gcc-9.1.0/gcc-build-final
( cd gcc-9.1.0/gcc-build-final && \
../configure \
--prefix=$CONFIG_PREFIX \
--target=$CONFIG_TARGET \
--disable-decimal-float \
--disable-libgomp \
--disable-libmudflap \
--disable-libquadmath \
--disable-libssp \
--disable-multilib \
--enable-__cxa_atexit \
--enable-languages=c,c++ \
--enable-shared \
--enable-static \
--enable-threads \
--enable-tls \
--with-abi="aapcs-linux" \
--with-build-time-tools=$CONFIG_PREFIX/$CONFIG_TARGET/bin \
--with-cpu=arm1176jzf-s \
--with-float=hard \
--with-fpu=vfp \
--with-mode=arm \
--with-gnu-ld \
--with-sysroot=$CONFIG_SYSROOT )
make -j$PARALLEL_JOBS configure-host -C gcc-9.1.0/gcc-build-final
make -j$PARALLEL_JOBS gcc_cv_libc_provides_ssp=yes -C gcc-9.1.0/gcc-build-final
make -j$PARALLEL_JOBS install -C gcc-9.1.0/gcc-build-final
rm -rf gcc-9.1.0
```
