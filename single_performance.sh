#!/bin/bash
#SBATCH --mem=200G

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
make cost_scaling
make ssp_dijkstra
make heuristic

(timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/ADM_new_10000_instance_test.txt  10000  1000 ) &> single_test/network_simplex_adm_10000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/ADM_new_20000_instance_test.txt  20000  1000 ) &> single_test/network_simplex_adm_20000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/ADM_new_30000_instance_test.txt  30000  1000 ) &> single_test/network_simplex_adm_30000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/ADM_new_40000_instance_test.txt  40000  1000 ) &> single_test/network_simplex_adm_40000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/ADM_new_50000_instance_test.txt  50000  1000 ) &> single_test/network_simplex_adm_50000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/ADM_new_60000_instance_test.txt  60000  1000 ) &> single_test/network_simplex_adm_60000_1000.txt


(timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_10000_instance_test.txt 10000  1000 ) &> single_test/network_simplex_taxi_10000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_20000_instance_test.txt 20000  1000 ) &> single_test/network_simplex_taxi_20000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_30000_instance_test.txt 30000  1000 ) &> single_test/network_simplex_taxi_30000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_40000_instance_test.txt 40000  1000 ) &> single_test/network_simplex_taxi_40000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_50000_instance_test.txt 50000  1000 ) &> single_test/network_simplex_taxi_50000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_60000_instance_test.txt 60000  1000 ) &> single_test/network_simplex_taxi_60000_1000.txt




