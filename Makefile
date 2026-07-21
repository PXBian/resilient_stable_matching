# Compiler settings
CXX = g++
CXXFLAGS = -O3 -std=c++17 -Wall

# Project directories
ROOT_DIR = $(CURDIR)
RUST_DIR = rotation_poset
RUST_LIB_DIR = $(RUST_DIR)/target/release
RUST_HEADER = $(RUST_DIR)/rotation_poset.h

LEMON_DIR = lemon-1.3.1
LEMON_BUILD_DIR = $(LEMON_DIR)/build
LEMON_LIB = $(LEMON_BUILD_DIR)/lemon/libemon.a

# Common compile and link options
COMMON_INCLUDES = -I.
RUST_LINK = -L$(RUST_LIB_DIR) -lrotation_poset \
	-Wl,-rpath,$(ROOT_DIR)/$(RUST_LIB_DIR)
LEMON_INCLUDES = -I$(LEMON_DIR) -I$(LEMON_BUILD_DIR)
LEMON_LINK = -L$(LEMON_BUILD_DIR)/lemon -lemon

TARGETS = ssp_dijkstra capacity_scaling network_simplex heuristic competitor

.PHONY: all rust-lib clean

# Build all implementations
all: $(TARGETS)

# Cargo handles incremental compilation, so this is inexpensive when unchanged.
rust-lib:
	cd $(RUST_DIR) && cargo build --release

# The order-only dependency "| rust-lib" builds Rust first without forcing
# an unchanged C++ target to be rebuilt every time.

# Self-implemented SSP solver
ssp_dijkstra: ssp_dijkstra.cpp $(RUST_HEADER) | rust-lib
	$(CXX) $(CXXFLAGS) $(COMMON_INCLUDES) ssp_dijkstra.cpp \
		$(RUST_LINK) -o ssp_dijkstra

# LEMON Capacity Scaling solver
capacity_scaling: capacity_scaling.cpp $(RUST_HEADER) $(LEMON_LIB) | rust-lib
	$(CXX) $(CXXFLAGS) $(COMMON_INCLUDES) $(LEMON_INCLUDES) capacity_scaling.cpp \
		$(LEMON_LINK) $(RUST_LINK) -o capacity_scaling

# LEMON Network Simplex solver
network_simplex: network_simplex.cpp $(RUST_HEADER) $(LEMON_LIB) | rust-lib
	$(CXX) $(CXXFLAGS) $(COMMON_INCLUDES) $(LEMON_INCLUDES) network_simplex.cpp \
		$(LEMON_LINK) $(RUST_LINK) -o network_simplex

# Heuristic
heuristic: heuristic.cpp $(RUST_HEADER) | rust-lib
	$(CXX) $(CXXFLAGS) $(COMMON_INCLUDES) heuristic.cpp \
		$(RUST_LINK) -o heuristic

# FFK competitor
competitor: competitor.cpp $(RUST_HEADER) | rust-lib
	$(CXX) $(CXXFLAGS) $(COMMON_INCLUDES) competitor.cpp \
		$(RUST_LINK) -o competitor

clean:
	rm -f $(TARGETS)
