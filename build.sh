#! /bin/sh

apt update
apt install -y cmake gcc-arm-none-eabi git

git clean -dfx
git reset --hard HEAD

mkdir build
cd build

cmake .. -DCMAKE_TOOLCHAIN_FILE=../toolchain/gcc.cmake

make -j8

truncate -s 512 *.bin
