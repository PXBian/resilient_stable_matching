# Makefile for total_test.cpp

# 编译器设置
CXX = g++
CXXFLAGS = -O3 -std=c++17 -Wall

# 目标文件
TARGET = total_test
SOURCE = total_test.cpp

# Rust 库路径
RUST_LIB_DIR = rotations_poset/target/release
RUST_LIB_NAME = rotations_poset

# LEMON 库设置
# 优先使用 pkg-config，如果不可用则使用默认路径
LEMON_CFLAGS = $(shell pkg-config --cflags lemon 2>/dev/null || echo "-I/usr/local/include")
LEMON_LDFLAGS = $(shell pkg-config --libs lemon 2>/dev/null || echo "-L/usr/local/lib -llemon")

# 如果 pkg-config 不可用，尝试使用本地构建的 LEMON
ifeq ($(LEMON_CFLAGS),-I/usr/local/include)
    ifneq ($(wildcard lemon-1.3.1/build/liblemon/include),)
        LEMON_CFLAGS = -Ilemon-1.3.1/build/liblemon/include
        LEMON_LDFLAGS = -Llemon-1.3.1/build/liblemon/lib -llemon
    endif
endif

# 包含路径
INCLUDES = -I. $(LEMON_CFLAGS)

# 库路径和链接库
# 使用 rpath 在运行时自动找到库，避免每次设置 LD_LIBRARY_PATH
RUST_LIB_RPATH = -Wl,-rpath,$(shell pwd)/$(RUST_LIB_DIR)
LIBDIRS = -L$(RUST_LIB_DIR) $(LEMON_LDFLAGS) $(RUST_LIB_RPATH)
LIBS = -l$(RUST_LIB_NAME)

# 检查 Rust 库是否存在（支持 Linux .so 和 macOS .dylib）
RUST_LIB_SO = $(RUST_LIB_DIR)/lib$(RUST_LIB_NAME).so
RUST_LIB_DYLIB = $(RUST_LIB_DIR)/lib$(RUST_LIB_NAME).dylib

# 检查 cargo 是否可用（尝试多个位置）
CARGO = $(shell which cargo 2>/dev/null || echo "$(HOME)/.cargo/bin/cargo" 2>/dev/null)
# 如果找到 cargo 路径，检查它是否可执行
ifneq ($(CARGO),)
    CARGO_EXISTS = $(shell test -x "$(CARGO)" && echo "yes" || echo "no")
    ifeq ($(CARGO_EXISTS),no)
        CARGO = 
    endif
endif

.PHONY: all total clean rust-lib check-rust-lib help

# 默认目标
all: total

# 检查 Rust 库是否存在
check-rust-lib:
	@if [ ! -f "$(RUST_LIB_SO)" ] && [ ! -f "$(RUST_LIB_DYLIB)" ]; then \
		CARGO_CMD=""; \
		if command -v cargo >/dev/null 2>&1; then \
			CARGO_CMD="cargo"; \
		elif [ -x "$(HOME)/.cargo/bin/cargo" ]; then \
			CARGO_CMD="$(HOME)/.cargo/bin/cargo"; \
		fi; \
		if [ -z "$$CARGO_CMD" ]; then \
			echo "ERROR: Rust library not found and cargo is not installed."; \
			echo ""; \
			echo "Please install Rust and cargo first:"; \
			echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"; \
			echo "  or: sudo apt install cargo"; \
			echo ""; \
			echo "Then run: make rust-lib"; \
			echo "Or if you have a pre-built library, place it at:"; \
			echo "  $(RUST_LIB_SO)"; \
			echo "  or: $(RUST_LIB_DYLIB)"; \
			exit 1; \
		else \
			echo "Rust library not found, building..."; \
			CARGO=$$CARGO_CMD $(MAKE) rust-lib; \
		fi; \
	fi

# 编译 total_test
total: check-rust-lib $(TARGET)

$(TARGET): $(SOURCE)
	@echo "Compiling $(SOURCE)..."
	$(CXX) $(CXXFLAGS) $(INCLUDES) $(SOURCE) $(LIBDIRS) $(LIBS) -o $(TARGET)
	@echo "Build complete: $(TARGET)"

# 构建 Rust 库
rust-lib:
	@CARGO_CMD=""; \
	if command -v cargo >/dev/null 2>&1; then \
		CARGO_CMD="cargo"; \
	elif [ -x "$(HOME)/.cargo/bin/cargo" ]; then \
		CARGO_CMD="$(HOME)/.cargo/bin/cargo"; \
	fi; \
	if [ -z "$$CARGO_CMD" ]; then \
		echo "ERROR: cargo is not installed."; \
		echo "Please install Rust and cargo first:"; \
		echo "  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"; \
		echo "  or: sudo apt install cargo"; \
		exit 1; \
	fi; \
	echo "Building Rust library..."; \
	cd rotations_poset && $$CARGO_CMD build --release; \
	echo "Rust library built successfully"

# 清理
clean:
	rm -f $(TARGET)
	@echo "Cleaned $(TARGET)"

# 深度清理（包括 Rust 库）
clean-all: clean
	@cd rotations_poset && cargo clean 2>/dev/null || true
	@echo "Cleaned all build artifacts"

# 帮助信息
help:
	@echo "Available targets:"
	@echo "  make total      - Build total_test (default)"
	@echo "  make rust-lib   - Build Rust library only"
	@echo "  make clean      - Remove compiled binary"
	@echo "  make clean-all  - Remove all build artifacts including Rust library"
	@echo "  make help       - Show this help message"





