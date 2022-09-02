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
curl -LO https://ftpmirror.gnu.org/gnu/findutils/findutils-"${FINDUTILS_VER}".tar.xz
curl -LO https://ftpmirror.gnu.org/gnu/grep/grep-"${GREP_VER}".tar.xz
curl -LO https://ftpmirror.gnu.org/gnu/sed/sed-"${SED_VER}".tar.gz

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

echo "Building Findutils..."
tar -xf findutils-"${FINDUTILS_VER}".tar.xz
cd findutils-"${FINDUTILS_VER}"
./configure --prefix=/usr
make
install -Dm755 {find/find,locate/{locate,updatedb},xargs/xargs} "${workdir}"/stage
install -Dm644 COPYING "${workdir}"/stage/LICENSE.findutils
cd ..

echo "Building Grep..."
tar -xf grep-"${GREP_VER}".tar.xz
cd grep-"${GREP_VER}"
./configure --prefix=/usr --disable-perl-regexp
make
install -Dm755 src/{,e,f}grep "${workdir}"/stage
install -Dm644 COPYING "${workdir}"/stage/LICENSE.grep
cd ..

echo "Building Sed..."
tar -xf sed-"${SED_VER}".tar.gz
cd sed-"${SED_VER}"
./configure --prefix=/usr
make
install -Dm755 sed/sed "${workdir}"/stage
install -Dm644 COPYING "${workdir}"/stage/LICENSE.sed
cd ..

echo "Creating package tarball..."
mv stage upgrade-toolset-"$(date "+%Y%m%d")"-x86_64
tar -cJf upgrade-toolset-"$(date "+%Y%m%d")"-x86_64.tar.xz upgrade-toolset-"$(date "+%Y%m%d")"-x86_64
mv upgrade-toolset-"$(date "+%Y%m%d")"-x86_64.tar.xz "${savedir}"

echo "Cleaning up..."
rm -rf "${workdir}"

echo "Success!"
