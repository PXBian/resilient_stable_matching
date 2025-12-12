#! /bin/sh
set -e

# 0. 检查并安装 Rust 和 cargo（如果需要）
echo "Checking for Rust and cargo..."
if ! command -v cargo >/dev/null 2>&1; then
    echo "Rust/cargo not found. Installing Rust..."
    RUST_INSTALLED=0
    
    # 尝试使用 rustup 安装（推荐方式）
    if command -v curl >/dev/null 2>&1; then
        echo "Installing Rust using rustup..."
        if curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y; then
            # 将 cargo 添加到 PATH（当前会话）
            export PATH="$HOME/.cargo/bin:$PATH"
            # 也尝试 source 一下（如果可能）
            if [ -f "$HOME/.cargo/env" ]; then
                . "$HOME/.cargo/env"
            fi
            RUST_INSTALLED=1
        fi
    # 如果 curl 不可用，尝试使用系统包管理器
    elif command -v apt-get >/dev/null 2>&1; then
        echo "Installing Rust using apt-get..."
        if sudo apt-get update && sudo apt-get install -y cargo rustc; then
            RUST_INSTALLED=1
        fi
    elif command -v yum >/dev/null 2>&1; then
        echo "Installing Rust using yum..."
        if sudo yum install -y cargo rustc; then
            RUST_INSTALLED=1
        fi
    fi
    
    # 验证安装
    if command -v cargo >/dev/null 2>&1; then
        echo "Rust and cargo installed successfully!"
        cargo --version
    elif [ "$RUST_INSTALLED" -eq 1 ]; then
        echo "WARNING: Rust installation completed, but cargo is not in PATH."
        echo "Please run: source \$HOME/.cargo/env"
        echo "Or restart your terminal and run the script again."
        echo "Continuing with LEMON installation..."
    else
        echo "WARNING: Failed to install Rust automatically."
        echo "Please install Rust manually from https://www.rust-lang.org/tools/install"
        echo "Continuing with LEMON installation..."
    fi
else
    echo "Rust/cargo already installed: $(cargo --version)"
fi

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

# 7. 构建 Rust 库（rotations_poset）
echo ""
echo "Building Rust library (rotations_poset)..."
if command -v cargo >/dev/null 2>&1; then
    cd rotations_poset
    cargo build --release
    cd ..
    echo "Rust library built successfully!"
else
    echo "WARNING: cargo not found. Please install Rust first, then run:"
    echo "  cd rotations_poset && cargo build --release"
fi

echo ""
echo "Installation complete!"
