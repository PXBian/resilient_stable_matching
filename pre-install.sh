#! /bin/sh
set -e

# 1. 解压源码
tar -xzf lemon-1.3.1.tar.gz
cd lemon-1.3.1

# 2. 建 build 目录
mkdir -p build
cd build

# 注意：这里需要 cmake，可先在 HPC 上 module load cmake
# 3. 配置安装前缀到当前 build 目录下的 liblemon
cmake -DCMAKE_BUILD_TYPE=Release \
      -DCMAKE_INSTALL_PREFIX="$(pwd)"/liblemon ..

# 4. 编译和安装到 liblemon/
make -j4
make install

# 5. 把 liblemon 挪到项目根目录，和 libsdsl 一样
cd ..
mv build/liblemon ../..

# 6. 回到项目根目录
cd ..
echo "LEMON has been installed to $(pwd)/liblemon"
