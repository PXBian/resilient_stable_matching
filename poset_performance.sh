#!/bin/bash
#SBATCH --mem=100G

# 加载 Rust 环境（如果存在）
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# 设置超时时间：任何任务运行超过1小时将被终止并跳过
TIMEOUT_DURATION="1h"

mkdir -p peak_ram
gunzip data/*.gz 2>/dev/null

# 编译poset-only程序（所有5种实现使用同一个可执行文件）
make poset_only


# TAXI_new 测试用例
# 所有5种实现使用同一个poset_only可执行文件，但输出文件名保持区分以便后续分析
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_5000_instance.txt   5000  1000 )  &> peak_ram/poset_taxi_new_5000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_5000_instance.txt   5000  5000 )  &> peak_ram/poset_taxi_new_5000_5000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_10000_instance.txt  10000  1000 ) &> peak_ram/poset_taxi_new_10000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_10000_instance.txt  10000  5000 ) &> peak_ram/poset_taxi_new_10000_5000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_10000_instance.txt  10000  10000) &> peak_ram/poset_taxi_new_10000_10000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_15000_instance.txt  15000  1000 ) &> peak_ram/poset_taxi_new_15000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_15000_instance.txt  15000  5000 ) &> peak_ram/poset_taxi_new_15000_5000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_15000_instance.txt  15000  10000) &> peak_ram/poset_taxi_new_15000_10000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_15000_instance.txt  15000  15000) &> peak_ram/poset_taxi_new_15000_15000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_20000_instance.txt  20000  1000 ) &> peak_ram/poset_taxi_new_20000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_20000_instance.txt  20000  5000 ) &> peak_ram/poset_taxi_new_20000_5000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_20000_instance.txt  20000  10000) &> peak_ram/poset_taxi_new_20000_10000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_20000_instance.txt  20000  15000) &> peak_ram/poset_taxi_new_20000_15000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_20000_instance.txt  20000  20000) &> peak_ram/poset_taxi_new_20000_20000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_25000_instance.txt  25000  1000 ) &> peak_ram/poset_taxi_new_25000_1000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_25000_instance.txt  25000  5000 ) &> peak_ram/poset_taxi_new_25000_5000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_25000_instance.txt  25000  10000) &> peak_ram/poset_taxi_new_25000_10000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_25000_instance.txt  25000  15000) &> peak_ram/poset_taxi_new_25000_15000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_25000_instance.txt  25000  20000) &> peak_ram/poset_taxi_new_25000_20000.txt
(timeout $TIMEOUT_DURATION /usr/bin/time -v ./poset_only data/TAXI_new_25000_instance.txt  25000  25000) &> peak_ram/poset_taxi_new_25000_25000.txt


