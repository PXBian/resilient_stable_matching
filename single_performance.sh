#!/bin/bash
#SBATCH --mem=200G

# 加载 Rust 环境（如果存在）
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# 设置超时时间：任何任务运行超过1小时将被终止并跳过
TIMEOUT_DURATION="1h"

mkdir -p peak_ram
gunzip data/*.gz 2>/dev/null

make capacity_scaling
make network_simplex
make cost_scaling
make ssp_dijkstra
make heuristic

# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/ADM_new_10000_instance.txt  10000  1000 ) &> peak_ram/capacity_scaling_adm_10000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/ADM_new_20000_instance.txt  20000  1000 ) &> peak_ram/network_simplex_adm_20000_1000.txt

