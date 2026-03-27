# Makefile for resilient_stable_matching project

# 编译器设置
CXX = g++
CXXFLAGS = -O3 -std=c++17 -Wall

# 目录设置
ROOT_DIR = $(shell pwd)
RUST_LIB_DIR = rotation_poset/target/release
LEMON_DIR = lemon-1.3.1
LEMON_BUILD_DIR = $(LEMON_DIR)/build/lemon

# 包含路径
# 需要包含 LEMON 源码目录和构建目录（config.h 在构建目录中）
INCLUDES = -I. -I$(LEMON_DIR) -I$(LEMON_DIR)/build

# 库路径
LIBDIRS = -L$(RUST_LIB_DIR) -L$(LEMON_BUILD_DIR)

# 库文件
LIBS = -lemon -lrotation_poset

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

# Poset-only target (only need rotations_poset library, not LEMON)
# All 5 implementations use the same poset construction code, so we only need one executable
POSET_ONLY_SOURCE = poset_only.cpp
POSET_ONLY_TARGET = poset_only

# Save poset tool
SAVE_POSET_SOURCE = save_poset.cpp
SAVE_POSET_TARGET = save_poset

# No-poset targets (skip poset construction, load from file)
COST_SCALING_NO_POSET_SOURCE = cost_scaling_no_poset.cpp
COST_SCALING_NO_POSET_TARGET = cost_scaling_no_poset
CAPACITY_SCALING_NO_POSET_SOURCE = capacity_scaling_no_poset.cpp
CAPACITY_SCALING_NO_POSET_TARGET = capacity_scaling_no_poset
NETWORK_SIMPLEX_NO_POSET_SOURCE = network_simplex_no_poset.cpp
NETWORK_SIMPLEX_NO_POSET_TARGET = network_simplex_no_poset
SSP_DIJKSTRA_NO_POSET_SOURCE = ssp_dijkstra_no_poset.cpp
SSP_DIJKSTRA_NO_POSET_TARGET = ssp_dijkstra_no_poset
HEURISTIC_NO_POSET_SOURCE = heuristic_no_poset.cpp
HEURISTIC_NO_POSET_TARGET = heuristic_no_poset
SAVE_POSET_SHARED_SOURCE = save_poset_shared.cpp
SAVE_POSET_SHARED_TARGET = save_poset_shared
SOLVER_NO_POSET_SHARED_SOURCE = solver_no_poset_shared.cpp
SOLVER_NO_POSET_SHARED_TARGET = solver_no_poset_shared

# 检查 cargo 是否可用
CARGO = $(shell command -v cargo 2>/dev/null || echo "$(HOME)/.cargo/bin/cargo")
ifeq ($(CARGO),)
    CARGO = $(shell test -f "$(HOME)/.cargo/bin/cargo" && echo "$(HOME)/.cargo/bin/cargo" || echo "")
endif

.PHONY: all rust-lib total heuristic capacity_scaling network_simplex cost_scaling ssp_dijkstra \
        poset_only save_poset cost_scaling_no_poset capacity_scaling_no_poset \
        network_simplex_no_poset ssp_dijkstra_no_poset heuristic_no_poset \
        save_poset_shared solver_no_poset_shared clean

# 默认目标
all: total

# 库文件（不含 LEMON，用于只依赖 rotation_poset 的目标）
POSET_LIBS = -lrotation_poset

# 构建 Rust 库（cargo 是增量的，源码不变时瞬间完成）
rust-lib:
	cd rotation_poset && cargo build --release

# 带 LEMON 的目标
total: rust-lib
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(TARGET)

heuristic: rust-lib
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(HEURISTIC_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(HEURISTIC_TARGET)

capacity_scaling: rust-lib
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(CAPACITY_SCALING_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(CAPACITY_SCALING_TARGET)

network_simplex: rust-lib
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(NETWORK_SIMPLEX_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(NETWORK_SIMPLEX_TARGET)

cost_scaling: rust-lib
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(COST_SCALING_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(COST_SCALING_TARGET)

ssp_dijkstra: rust-lib
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(SSP_DIJKSTRA_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(SSP_DIJKSTRA_TARGET)

cost_scaling_no_poset: rust-lib
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(COST_SCALING_NO_POSET_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(COST_SCALING_NO_POSET_TARGET)

capacity_scaling_no_poset: rust-lib
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(CAPACITY_SCALING_NO_POSET_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(CAPACITY_SCALING_NO_POSET_TARGET)

network_simplex_no_poset: rust-lib
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(NETWORK_SIMPLEX_NO_POSET_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(NETWORK_SIMPLEX_NO_POSET_TARGET)

ssp_dijkstra_no_poset: rust-lib
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(SSP_DIJKSTRA_NO_POSET_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(SSP_DIJKSTRA_NO_POSET_TARGET)

solver_no_poset_shared: rust-lib
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(SOLVER_NO_POSET_SHARED_SOURCE) $(LIBDIRS) $(LIBS) $(RUST_LIB_RPATH) -o $(SOLVER_NO_POSET_SHARED_TARGET)

# 不需要 LEMON 的目标
poset_only: rust-lib
	$(CXX) $(CXXFLAGS) -I. $(POSET_ONLY_SOURCE) -L$(RUST_LIB_DIR) $(POSET_LIBS) $(RUST_LIB_RPATH) -o $(POSET_ONLY_TARGET)

save_poset: rust-lib
	$(CXX) $(CXXFLAGS) -I. $(SAVE_POSET_SOURCE) -L$(RUST_LIB_DIR) $(POSET_LIBS) $(RUST_LIB_RPATH) -o $(SAVE_POSET_TARGET)

save_poset_shared: rust-lib
	$(CXX) $(CXXFLAGS) -I. $(SAVE_POSET_SHARED_SOURCE) -L$(RUST_LIB_DIR) $(POSET_LIBS) $(RUST_LIB_RPATH) -o $(SAVE_POSET_SHARED_TARGET)

heuristic_no_poset: rust-lib
	$(CXX) $(CXXFLAGS) -I. $(HEURISTIC_NO_POSET_SOURCE) -L$(RUST_LIB_DIR) $(POSET_LIBS) $(RUST_LIB_RPATH) -o $(HEURISTIC_NO_POSET_TARGET)

# 清理
clean:
	rm -f $(TARGET) $(HEURISTIC_TARGET) $(CAPACITY_SCALING_TARGET) $(NETWORK_SIMPLEX_TARGET) $(COST_SCALING_TARGET) $(SSP_DIJKSTRA_TARGET) \
	      $(POSET_ONLY_TARGET) $(SAVE_POSET_TARGET) \
	      $(SAVE_POSET_SHARED_TARGET) $(SOLVER_NO_POSET_SHARED_TARGET) \
	      $(COST_SCALING_NO_POSET_TARGET) $(CAPACITY_SCALING_NO_POSET_TARGET) \
	      $(NETWORK_SIMPLEX_NO_POSET_TARGET) $(SSP_DIJKSTRA_NO_POSET_TARGET) $(HEURISTIC_NO_POSET_TARGET)
	@echo "Cleaned all binaries"
