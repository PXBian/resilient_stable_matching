#! /bin/sh

# 1. 解压 LEMON
tar -xvf lemon-1.3.1.tar.gz

# 2. 进入目录
cd lemon-1.3.1

# 3. 为本地安装创建 build 目录
mkdir build
cd build

# 4. 运行配置（指定前缀为当前路径下的 liblemon）
cmake -DCMAKE_INSTALL_PREFIX="$(pwd)"/liblemon ..

# 5. 编译 & 安装
make -j 4
make install

# 6. 把 liblemon 移动回项目根目录
mv liblemon/ ../..
