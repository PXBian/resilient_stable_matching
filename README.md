# Preference Resilience in Stable Matching

This repository contains the implementations used in our experimental evaluation of RPP and $\tau$-RPP.

## Requirements

- GNU/Linux
- A C++17-compatible compiler
- GNU Make
- [Rust and Cargo](https://www.rust-lang.org/tools/install)
- [CMake](https://cmake.org/)

## Setup

Build LEMON 1.3.1 from the included archive:

```bash
sh pre-install.sh
```

The Rust library in `rotation_poset/` is built automatically by the Makefile.

## Implementations

| Algorithm | Source and binary | Build target | Arguments |
|---|---|---|---|
| RPP-SSP / $\tau$-RPP-SSP | `ssp_dijkstra.cpp` / `ssp_dijkstra` | `make ssp_dijkstra` | `<input_file> <n> <tau>` |
| RPP-LCS / $\tau$-RPP-LCS | `capacity_scaling.cpp` / `capacity_scaling` | `make capacity_scaling` | `<input_file> <n> <tau>` |
| RPP-LNS / $\tau$-RPP-LNS | `network_simplex.cpp` / `network_simplex` | `make network_simplex` | `<input_file> <n> <tau>` |
| $\tau$-RPP-H | `heuristic.cpp` / `heuristic` | `make heuristic` | `<input_file> <n> <tau>` |
| FFK | `competitor.cpp` / `competitor` | `make competitor` | `<input_file> <n>` |

Build every implementation with:

```bash
make
```

## Input Format

An instance with $n$ agents on each side contains $2n$ lines:

- The first $n$ lines contain the preference lists of the first side.
- The next $n$ lines contain the preference lists of the second side.
- Each line is a permutation of `0, 1, ..., n-1`, ordered from most preferred to least preferred.

The repository includes `data/test_case.txt`, for which $n=7$.

## Usage

Run an RPP or $\tau$-RPP implementation with:

```bash
./ssp_dijkstra <input_file> <n> <tau>
./capacity_scaling <input_file> <n> <tau>
./network_simplex <input_file> <n> <tau>
./heuristic <input_file> <n> <tau>
```

Parameters:

- `<input_file>`: path to the preference instance.
- `<n>`: number of agents on each side.
- `<tau>`: integer threshold with `1 <= tau <= n`; use `1` for RPP.

FFK only supports RPP:

```bash
./competitor <input_file> <n>
```

## Examples Using the Test Case

Build and run all implementations for RPP:

```bash
make
./ssp_dijkstra data/test_case.txt 7 1
./capacity_scaling data/test_case.txt 7 1
./network_simplex data/test_case.txt 7 1
./heuristic data/test_case.txt 7 1
./competitor data/test_case.txt 7
```


Run the four $\tau$-RPP implementations with $\tau=3$:

```bash
./ssp_dijkstra data/test_case.txt 7 3
./capacity_scaling data/test_case.txt 7 3
./network_simplex data/test_case.txt 7 3
./heuristic data/test_case.txt 7 3
```


Remove the compiled binaries with:

```bash
make clean
```
