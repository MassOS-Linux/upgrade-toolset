#!/bin/bash

# This script (NOT the binaries produced from it) is under the MIT license and
# copyright (c) 2022 MassOS Developers.

# Please read the 'LICENSE' document in this project's source tree for the full
# license text and information about distribution of the produced binaries.

set -e

if [ "$(uname -m)" != "x86_64" ]; then
  echo "Error: Currently only x86_64 is supported." >&2
  exit 1
fi

. versions.conf

savedir="$(pwd)"
workdir="$(mktemp -d)"
cd "${workdir}"

CC=x86_64-linux-musl-gcc
CXX=x86_64-linux-musl-g++
CFLAGS="-Os"
CPPFLAGS="-Os"
CXXFLAGS="-Os"
LDFLAGS="-static --static -s"
MAKEFLAGS="-j$(nproc)"
export CC CXX CFLAGS CPPFLAGS CXXFLAGS LDFLAGS MAKEFLAGS

echo "Downloading toolchain..."
curl -LO https://github.com/DanielMYT/musl-cross-make/releases/download/20220901/x86_64-linux-musl-toolchain.tar.xz

echo "Downloading sources..."
curl -LO https://ftpmirror.gnu.org/gnu/bash/bash-"${BASH_VER}".tar.gz
curl -LO https://ftpmirror.gnu.org/gnu/coreutils/coreutils-"${COREUTILS_VER}".tar.xz
curl -LO https://ftpmirror.gnu.org/gnu/diffutils/diffutils-"${DIFFUTILS_VER}".tar.xz
curl -LO https://astron.com/pub/file/file-"${FILE_VER}".tar.gz
curl -LO https://ftpmirror.gnu.org/gnu/findutils/findutils-"${FINDUTILS_VER}".tar.xz
curl -LO https://ftpmirror.gnu.org/gnu/gawk/gawk-"${GAWK_VER}".tar.xz
curl -LO https://ftpmirror.gnu.org/gnu/gettext/gettext-"${GETTEXT_VER}".tar.xz
curl -LO https://ftpmirror.gnu.org/gnu/grep/grep-"${GREP_VER}".tar.xz
curl -LO https://ftpmirror.gnu.org/gnu/gzip/gzip-"${GZIP_VER}".tar.xz
curl -LO https://ftpmirror.gnu.org/gnu/m4/m4-"${M4_VER}".tar.xz
curl -LO https://ftpmirror.gnu.org/gnu/make/make-"${MAKE_VER}".tar.gz
curl -LO https://ftpmirror.gnu.org/gnu/patch/patch-"${PATCH_VER}".tar.xz
curl -LO https://ftpmirror.gnu.org/gnu/sed/sed-"${SED_VER}".tar.gz
curl -LO https://ftpmirror.gnu.org/gnu/tar/tar-"${TAR_VER}".tar.xz
curl -LO https://freefr.dl.sourceforge.net/project/lzmautils/xz-"${XZ_VER}".tar.xz

echo "Extracting toolchain..."
tar -xf x86_64-linux-musl-toolchain.tar.xz
export PATH="$PATH:${workdir}/bin"

echo "Building Bash..."
tar -xf bash-"${BASH_VER}".tar.gz
cd bash-"${BASH_VER}"
./configure --prefix=/usr --without-bash-malloc
make
install -Dm755 bash "${workdir}"/stage/bash
ln -sf bash "${workdir}"/stage/sh
install -Dm644 COPYING "${workdir}"/stage/LICENSE.bash
cd ..

echo "Building Coreutils..."
tar -xf coreutils-"${COREUTILS_VER}".tar.xz
cd coreutils-"${COREUTILS_VER}"
./configure --prefix=/usr
make
make DESTDIR="$PWD" install
install -Dm755 usr/bin/* "${workdir}"/stage/
install -Dm644 COPYING "${workdir}"/stage/LICENSE.coreutils
cd ..

echo "Building Diffutils..."
tar -xf diffutils-"${DIFFUTILS_VER}".tar.xz
cd diffutils-"${DIFFUTILS_VER}"
./configure --prefix=/usr
make
install -Dm755 src/{cmp,diff,diff3,sdiff} "${workdir}"/stage/
install -Dm644 COPYING "${workdir}"/stage/LICENSE.diffutils
cd ..

echo "Building File..."
tar -xf file-"${FILE_VER}".tar.gz
cd file-"${FILE_VER}"
mkdir build; cd build
../configure --prefix=/usr --enable-static --disable-shared --disable-bzlib --disable-libseccomp --disable-xzlib --disable-zlib
make
cd ..
./configure --prefix=/usr --enable-static --disable-shared --disable-bzlib --disable-libseccomp --disable-xzlib --disable-zlib
make FILE_COMPILE="$PWD"/build/src/file
install -Dm755 src/file "${workdir}"/stage/
install -Dm644 COPYING "${workdir}"/stage/LICENSE.file
cd ..

echo "Building Findutils..."
tar -xf findutils-"${FINDUTILS_VER}".tar.xz
cd findutils-"${FINDUTILS_VER}"
./configure --prefix=/usr
make
install -Dm755 {find/find,locate/{locate,updatedb},xargs/xargs} "${workdir}"/stage/
install -Dm644 COPYING "${workdir}"/stage/LICENSE.findutils
cd ..

echo "Building Gawk..."
tar -xf gawk-"${GAWK_VER}".tar.xz
cd gawk-"${GAWK_VER}"
./configure --prefix=/usr
make
install -Dm755 gawk "${workdir}"/stage/
ln -sf gawk "${workdir}"/stage/awk
install -Dm644 COPYING "${workdir}"/stage/LICENSE.gawk
cd ..

echo "Building Gettext-Tools..."
tar -xf gettext-"${GETTEXT_VER}".tar.xz
cd gettext-"${GETTEXT_VER}"
./configure --prefix=/usr --disable-shared
make
install -Dm755 gettext-tools/src/{msgfmt,msgmerge,xgettext} "${workdir}"/stage/
install -Dm644 COPYING "${workdir}"/stage/LICENSE.gettext-tools
cd ..

echo "Building Grep..."
tar -xf grep-"${GREP_VER}".tar.xz
cd grep-"${GREP_VER}"
./configure --prefix=/usr --disable-perl-regexp
make
install -Dm755 src/{,e,f}grep "${workdir}"/stage/
install -Dm644 COPYING "${workdir}"/stage/LICENSE.grep
cd ..

echo "Building Gzip..."
tar -xf gzip-"${GZIP_VER}".tar.xz
cd gzip-"${GZIP_VER}"
./configure --prefix=/usr
make
install -Dm755 {g{unzip,zexe,zip},z{cat,cmp,diff,egrep,fgrep,force,grep,less,more,new}} "${workdir}"/stage/
ln -sf gunzip "${workdir}"/stage/uncompress
install -Dm644 COPYING "${workdir}"/stage/LICENSE.gzip
cd ..

echo "Building M4..."
tar -xf m4-"${M4_VER}".tar.xz
cd m4-"${M4_VER}"
./configure --prefix=/usr
make
install -Dm755 src/m4 "${workdir}"/stage/
install -Dm644 COPYING "${workdir}"/stage/LICENSE.m4
cd ..

echo "Building Make..."
tar -xf make-"${MAKE_VER}".tar.gz
cd make-"${MAKE_VER}"
./configure --prefix=/usr --without-guile
make
install -Dm755 make "${workdir}"/stage/
ln -sf make "${workdir}"/stage/gmake
install -Dm644 COPYING "${workdir}"/stage/LICENSE.make
cd ..

echo "Building Patch..."
tar -xf patch-"${PATCH_VER}".tar.xz
cd patch-"${PATCH_VER}"
./configure --prefix=/usr
make
install -Dm755 src/patch "${workdir}"/stage/
install -Dm644 COPYING "${workdir}"/stage/LICENSE.patch
cd ..

echo "Building Sed..."
tar -xf sed-"${SED_VER}".tar.gz
cd sed-"${SED_VER}"
./configure --prefix=/usr
make
install -Dm755 sed/sed "${workdir}"/stage
install -Dm644 COPYING "${workdir}"/stage/LICENSE.sed
cd ..

echo "Building Tar..."
tar -xf tar-"${TAR_VER}".tar.xz
cd tar-"${TAR_VER}"
./configure --prefix=/usr
make
install -Dm755 src/tar "${workdir}"/stage/
install -Dm644 COPYING "${workdir}"/stage/LICENSE.tar
cd ..

echo "Building Xz..."
tar -xf xz-"${XZ_VER}".tar.xz
cd xz-"${XZ_VER}"
./configure --prefix=/usr --enable-static --disable-shared
make
install -Dm755 src/{xz{/xz,dec/{lzma,xz}dec},lzmainfo/lzmainfo,scripts/xz{diff,grep,less,more}} "${workdir}"/stage/
for link in lzcat lzma unlzma unxz xzcat; do
  ln -sf xz "${workdir}"/stage/"${link}"
done
for link in lzcmp lzdiff xzcmp; do
  ln -sf xzdiff "${workdir}"/stage/"${link}"
done
for link in lzegrep lzfgrep lzgrep xzegrep xzfgrep; do
  ln -sf xzgrep "${workdir}"/stage/"${link}"
done
ln -sf xzless "${workdir}"/stage/lzless
ln -sf xzmore "${workdir}"/stage/lzmore
install -Dm644 COPYING "${workdir}"/stage/LICENSE.xz
cd ..

echo "Creating package tarball..."
mv stage upgrade-toolset-"$(date "+%Y%m%d")"-x86_64
tar -cJf upgrade-toolset-"$(date "+%Y%m%d")"-x86_64.tar.xz upgrade-toolset-"$(date "+%Y%m%d")"-x86_64
mv upgrade-toolset-"$(date "+%Y%m%d")"-x86_64.tar.xz "${savedir}"

echo "Cleaning up..."
rm -rf "${workdir}"

echo "Success!"
