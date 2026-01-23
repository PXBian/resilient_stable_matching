# Makefile for resilient_stable_matching project

# 编译器设置
CXX = g++
CXXFLAGS = -O3 -std=c++17 -Wall

# 目录设置
ROOT_DIR = $(shell pwd)
RUST_LIB_DIR = rotations_poset/target/release
LEMON_DIR = lemon-1.3.1
LEMON_BUILD_DIR = $(LEMON_DIR)/build/lemon

# 包含路径
# 需要包含 LEMON 源码目录和构建目录（config.h 在构建目录中）
INCLUDES = -I. -I$(LEMON_DIR) -I$(LEMON_DIR)/build

# 库路径
LIBDIRS = -L$(RUST_LIB_DIR) -L$(LEMON_BUILD_DIR)

# 库文件
LIBS = -lemon -lrotations_poset

# rpath 设置，避免需要设置 LD_LIBRARY_PATH
RUST_LIB_RPATH = -Wl,-rpath,$(ROOT_DIR)/$(RUST_LIB_DIR)

# 目标文件
TARGET = total
SOURCE = total_test.cpp
HEURISTIC_TARGET = heuristic
HEURISTIC_SOURCE = heuristic.cpp
CAPACITY_SCALING_TARGET = capacity_scaling
CAPACITY_SCALING_SOURCE = capacity_scaling.cpp
NETWORK_SIMPLEX_TARGET = network_simplex
NETWORK_SIMPLEX_SOURCE = network_simplex.cpp
COST_SCALING_TARGET = cost_scaling
COST_SCALING_SOURCE = cost_scaling.cpp
SSP_DIJKSTRA_TARGET = ssp_dijkstra
SSP_DIJKSTRA_SOURCE = ssp_dijkstra.cpp

# 检查 cargo 是否可用
CARGO = $(shell command -v cargo 2>/dev/null || echo "$(HOME)/.cargo/bin/cargo")
ifeq ($(CARGO),)
    CARGO = $(shell test -f "$(HOME)/.cargo/bin/cargo" && echo "$(HOME)/.cargo/bin/cargo" || echo "")
endif

.PHONY: all total heuristic capacity_scaling network_simplex cost_scaling ssp_dijkstra clean rust-lib check-rust-lib help

# 默认目标
all: total

help:
	@echo "Available targets:"
	@echo "  make total            - Compile total_test.cpp to 'total'"
	@echo "  make heuristic        - Compile heuristic.cpp to 'heuristic'"
	@echo "  make capacity_scaling - Compile capacity_scaling.cpp to 'capacity_scaling'"
	@echo "  make network_simplex  - Compile network_simplex.cpp to 'network_simplex'"
	@echo "  make cost_scaling     - Compile cost_scaling.cpp to 'cost_scaling'"
	@echo "  make ssp_dijkstra     - Compile ssp_dijkstra.cpp to 'ssp_dijkstra'"
	@echo "  make clean            - Remove compiled binaries"
	@echo "  make rust-lib         - Build Rust library"

# 检查 Rust 库是否存在
check-rust-lib:
	@if [ ! -f "$(RUST_LIB_DIR)/librotations_poset.so" ] && [ ! -f "$(RUST_LIB_DIR)/librotations_poset.a" ]; then \
		echo "Rust library not found. Building..."; \
		$(MAKE) rust-lib; \
	fi

# 构建 Rust 库
rust-lib:
	@echo "Building Rust library..."
	@if [ -z "$(CARGO)" ] || [ ! -f "$(CARGO)" ]; then \
		echo "Error: cargo not found. Please install Rust and Cargo."; \
		echo "Run: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"; \
		exit 1; \
	fi
	@cd rotations_poset && $(CARGO) build --release
	@if [ ! -f "$(RUST_LIB_DIR)/librotations_poset.so" ] && [ ! -f "$(RUST_LIB_DIR)/librotations_poset.a" ]; then \
		echo "Error: Failed to build Rust library"; \
		exit 1; \
	fi
	@echo "Rust library built successfully"

# 编译 total
total: check-rust-lib $(SOURCE)
	@echo "Compiling $(SOURCE)..."
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(TARGET)
	@echo "Build complete: $(TARGET)"

# 编译 heuristic
heuristic: check-rust-lib $(HEURISTIC_SOURCE)
	@echo "Compiling $(HEURISTIC_SOURCE)..."
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(HEURISTIC_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(HEURISTIC_TARGET)
	@echo "Build complete: $(HEURISTIC_TARGET)"

# 编译 capacity_scaling
capacity_scaling: check-rust-lib $(CAPACITY_SCALING_SOURCE)
	@echo "Compiling $(CAPACITY_SCALING_SOURCE)..."
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(CAPACITY_SCALING_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(CAPACITY_SCALING_TARGET)
	@echo "Build complete: $(CAPACITY_SCALING_TARGET)"

# 编译 network_simplex
network_simplex: check-rust-lib $(NETWORK_SIMPLEX_SOURCE)
	@echo "Compiling $(NETWORK_SIMPLEX_SOURCE)..."
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(NETWORK_SIMPLEX_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(NETWORK_SIMPLEX_TARGET)
	@echo "Build complete: $(NETWORK_SIMPLEX_TARGET)"

# 编译 cost_scaling
cost_scaling: check-rust-lib $(COST_SCALING_SOURCE)
	@echo "Compiling $(COST_SCALING_SOURCE)..."
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(COST_SCALING_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(COST_SCALING_TARGET)
	@echo "Build complete: $(COST_SCALING_TARGET)"

# 编译 ssp_dijkstra
ssp_dijkstra: check-rust-lib $(SSP_DIJKSTRA_SOURCE)
	@echo "Compiling $(SSP_DIJKSTRA_SOURCE)..."
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(SSP_DIJKSTRA_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(SSP_DIJKSTRA_TARGET)
	@echo "Build complete: $(SSP_DIJKSTRA_TARGET)"

# 清理
clean:
	rm -f $(TARGET) $(HEURISTIC_TARGET) $(CAPACITY_SCALING_TARGET) $(NETWORK_SIMPLEX_TARGET) $(COST_SCALING_TARGET) $(SSP_DIJKSTRA_TARGET)
	@echo "Cleaned all binaries"

