#!/bin/bash
#SBATCH --mem=150G


# 加载 Rust 环境（如果存在）
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# 设置超时时间：任何任务运行超过1小时将被终止并跳过
TIMEOUT_DURATION="1h"

mkdir -p single_test
gunzip data/*.gz 2>/dev/null

make capacity_scaling
make network_simplex
# make cost_scaling
make ssp_dijkstra
# make heuristic

# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_60000_instance.txt  60000  10000) &> single_test/network_simplex_taxi_60000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_60000_instance.txt  60000  20000) &> single_test/network_simplex_taxi_60000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_60000_instance.txt  60000  30000) &> single_test/network_simplex_taxi_60000_30000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_60000_instance.txt  60000  40000) &> single_test/network_simplex_taxi_60000_40000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_60000_instance.txt  60000  50000) &> single_test/network_simplex_taxi_60000_50000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_60000_instance.txt  60000  60000) &> single_test/network_simplex_taxi_60000_60000.txt


# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_10000_instance.txt 10000  10000) &> single_test/ssp_dijkstra_taxi_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_20000_instance.txt 20000  10000) &> single_test/ssp_dijkstra_taxi_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_30000_instance.txt 30000  10000) &> single_test/ssp_dijkstra_taxi_30000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_40000_instance.txt 40000  10000) &> single_test/ssp_dijkstra_taxi_40000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_50000_instance.txt 50000  10000) &> single_test/ssp_dijkstra_taxi_50000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_60000_instance.txt 60000  10000) &> single_test/ssp_dijkstra_taxi_60000_10000.txt

# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_60000_instance.txt 60000  10000) &> single_test/ssp_dijkstra_taxi_60000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_60000_instance.txt 60000  20000) &> single_test/ssp_dijkstra_taxi_60000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_60000_instance.txt 60000  30000) &> single_test/ssp_dijkstra_taxi_60000_30000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_60000_instance.txt 60000  40000) &> single_test/ssp_dijkstra_taxi_60000_40000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_60000_instance.txt 60000  50000) &> single_test/ssp_dijkstra_taxi_60000_50000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_60000_instance.txt 60000  60000) &> single_test/ssp_dijkstra_taxi_60000_60000.txt



# (/usr/bin/time -v ./network_simplex data/random_new_hc_10000.txt  10000  1) &> single_test/network_simplex_random_new_10000_1.txt
# (/usr/bin/time -v ./network_simplex data/random_new_hc_20000.txt  20000  1) &> single_test/network_simplex_random_new_20000_1.txt
# (/usr/bin/time -v ./network_simplex data/random_new_hc_30000.txt  30000  1) &> single_test/network_simplex_random_new_30000_1.txt
# (/usr/bin/time -v ./network_simplex data/random_new_hc_40000.txt  40000  1) &> single_test/network_simplex_random_new_40000_1.txt
# (/usr/bin/time -v ./network_simplex data/random_new_hc_50000.txt  50000  1) &> single_test/network_simplex_random_new_50000_1.txt

# (/usr/bin/time -v ./network_simplex data/random_new_hc_10000.txt  10000  10000) &> single_test/network_simplex_random_new_10000_10000.txt
# (/usr/bin/time -v ./network_simplex data/random_new_hc_20000.txt  20000  20000) &> single_test/network_simplex_random_new_20000_20000.txt
# (/usr/bin/time -v ./network_simplex data/random_new_hc_30000.txt  30000  30000) &> single_test/network_simplex_random_new_30000_30000.txt
# (/usr/bin/time -v ./network_simplex data/random_new_hc_40000.txt  40000  40000) &> single_test/network_simplex_random_new_40000_40000.txt
# (/usr/bin/time -v ./network_simplex data/random_new_hc_50000.txt  50000  50000) &> single_test/network_simplex_random_new_50000_50000.txt

# (/usr/bin/time -v ./capacity_scaling data/random_new_hc_10000.txt  10000  10000) &> single_test/capacity_scaling_random_new_10000_10000.txt
# (/usr/bin/time -v ./capacity_scaling data/random_new_hc_20000.txt  20000  20000) &> single_test/capacity_scaling_random_new_20000_20000.txt
# (/usr/bin/time -v ./capacity_scaling data/random_new_hc_30000.txt  30000  30000) &> single_test/capacity_scaling_random_new_30000_30000.txt
# (/usr/bin/time -v ./capacity_scaling data/random_new_hc_40000.txt  40000  40000) &> single_test/capacity_scaling_random_new_40000_40000.txt
# (/usr/bin/time -v ./capacity_scaling data/random_new_hc_50000.txt  50000  50000) &> single_test/capacity_scaling_random_new_50000_50000.txt

# (/usr/bin/time -v ./ssp_dijkstra data/random_new_hc_10000.txt  10000  10000) &> single_test/ssp_dijkstra_random_new_10000_10000.txt
# (/usr/bin/time -v ./ssp_dijkstra data/random_new_hc_20000.txt  20000  20000) &> single_test/ssp_dijkstra_random_new_20000_20000.txt
# (/usr/bin/time -v ./ssp_dijkstra data/random_new_hc_30000.txt  30000  30000) &> single_test/ssp_dijkstra_random_new_30000_30000.txt
# (/usr/bin/time -v ./ssp_dijkstra data/random_new_hc_40000.txt  40000  40000) &> single_test/ssp_dijkstra_random_new_40000_40000.txt
# (/usr/bin/time -v ./ssp_dijkstra data/random_new_hc_50000.txt  50000  50000) &> single_test/ssp_dijkstra_random_new_50000_50000.txt

# (/usr/bin/time -v ./network_simplex     data/random_new_hc_60000.txt  60000  1)     &> single_test/network_simplex_random_new_60000_1.txt
# (/usr/bin/time -v ./network_simplex     data/random_new_hc_60000.txt  60000  60000) &> single_test/network_simplex_random_new_60000_60000.txt
(/usr/bin/time -v ./capacity_scaling    data/random_new_hc_60000.txt  60000  60000) &> single_test/capacity_scaling_random_new_60000_60000.txt
(/usr/bin/time -v ./ssp_dijkstra        data/random_new_hc_60000.txt  60000  60000) &> single_test/ssp_dijkstra_random_new_60000_60000.txt


