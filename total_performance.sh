#!/bin/bash

# 加载 Rust 环境（如果存在）
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

mkdir peak_ram
gunzip data/*.gz

make total

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  500) &> peak_ram/total_test_adm_rand1000_1000_500.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  500) &> peak_ram/total_test_adm_rand2000_2000_500.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  500) &> peak_ram/total_test_adm_rand3000_3000_500.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  500) &> peak_ram/total_test_adm_rand4000_4000_500.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  500) &> peak_ram/total_test_adm_rand5000_5000_500.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  500) &> peak_ram/total_test_adm_rand6000_6000_500.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  500) &> peak_ram/total_test_adm_rand8000_8000_500.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 500) &> peak_ram/total_test_adm_rand10000_10000_500.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  1000) &> peak_ram/total_test_adm_rand1000_1000_1000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  1000) &> peak_ram/total_test_adm_rand2000_2000_1000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  1000) &> peak_ram/total_test_adm_rand3000_3000_1000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  1000) &> peak_ram/total_test_adm_rand4000_4000_1000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  1000) &> peak_ram/total_test_adm_rand5000_5000_1000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  1000) &> peak_ram/total_test_adm_rand6000_6000_1000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  1000) &> peak_ram/total_test_adm_rand8000_8000_1000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 1000) &> peak_ram/total_test_adm_rand10000_10000_1000.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  2000) &> peak_ram/total_test_adm_rand1000_1000_2000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  2000) &> peak_ram/total_test_adm_rand2000_2000_2000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  2000) &> peak_ram/total_test_adm_rand3000_3000_2000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  2000) &> peak_ram/total_test_adm_rand4000_4000_2000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  2000) &> peak_ram/total_test_adm_rand5000_5000_2000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  2000) &> peak_ram/total_test_adm_rand6000_6000_2000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  2000) &> peak_ram/total_test_adm_rand8000_8000_2000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 2000) &> peak_ram/total_test_adm_rand10000_10000_2000.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  3000) &> peak_ram/total_test_adm_rand1000_1000_3000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  3000) &> peak_ram/total_test_adm_rand2000_2000_3000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  3000) &> peak_ram/total_test_adm_rand3000_3000_3000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  3000) &> peak_ram/total_test_adm_rand4000_4000_3000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  3000) &> peak_ram/total_test_adm_rand5000_5000_3000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  3000) &> peak_ram/total_test_adm_rand6000_6000_3000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  3000) &> peak_ram/total_test_adm_rand8000_8000_3000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 3000) &> peak_ram/total_test_adm_rand10000_10000_3000.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  4000) &> peak_ram/total_test_adm_rand1000_1000_4000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  4000) &> peak_ram/total_test_adm_rand2000_2000_4000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  4000) &> peak_ram/total_test_adm_rand3000_3000_4000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  4000) &> peak_ram/total_test_adm_rand4000_4000_4000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  4000) &> peak_ram/total_test_adm_rand5000_5000_4000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  4000) &> peak_ram/total_test_adm_rand6000_6000_4000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  4000) &> peak_ram/total_test_adm_rand8000_8000_4000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 4000) &> peak_ram/total_test_adm_rand10000_10000_4000.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  5000) &> peak_ram/total_test_adm_rand1000_1000_5000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  5000) &> peak_ram/total_test_adm_rand2000_2000_5000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  5000) &> peak_ram/total_test_adm_rand3000_3000_5000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  5000) &> peak_ram/total_test_adm_rand4000_4000_5000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  5000) &> peak_ram/total_test_adm_rand5000_5000_5000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  5000) &> peak_ram/total_test_adm_rand6000_6000_5000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  5000) &> peak_ram/total_test_adm_rand8000_8000_5000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 5000) &> peak_ram/total_test_adm_rand10000_10000_5000.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  6000) &> peak_ram/total_test_adm_rand1000_1000_6000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  6000) &> peak_ram/total_test_adm_rand2000_2000_6000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  6000) &> peak_ram/total_test_adm_rand3000_3000_6000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  6000) &> peak_ram/total_test_adm_rand4000_4000_6000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  6000) &> peak_ram/total_test_adm_rand5000_5000_6000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  6000) &> peak_ram/total_test_adm_rand6000_6000_6000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  6000) &> peak_ram/total_test_adm_rand8000_8000_6000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 6000) &> peak_ram/total_test_adm_rand10000_10000_6000.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  7000) &> peak_ram/total_test_adm_rand1000_1000_7000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  7000) &> peak_ram/total_test_adm_rand2000_2000_7000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  7000) &> peak_ram/total_test_adm_rand3000_3000_7000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  7000) &> peak_ram/total_test_adm_rand4000_4000_7000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  7000) &> peak_ram/total_test_adm_rand5000_5000_7000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  7000) &> peak_ram/total_test_adm_rand6000_6000_7000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  7000) &> peak_ram/total_test_adm_rand8000_8000_7000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 7000) &> peak_ram/total_test_adm_rand10000_10000_7000.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  8000) &> peak_ram/total_test_adm_rand1000_1000_8000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  8000) &> peak_ram/total_test_adm_rand2000_2000_8000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  8000) &> peak_ram/total_test_adm_rand3000_3000_8000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  8000) &> peak_ram/total_test_adm_rand4000_4000_8000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  8000) &> peak_ram/total_test_adm_rand5000_5000_8000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  8000) &> peak_ram/total_test_adm_rand6000_6000_8000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  8000) &> peak_ram/total_test_adm_rand8000_8000_8000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 8000) &> peak_ram/total_test_adm_rand10000_10000_8000.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  9000) &> peak_ram/total_test_adm_rand1000_1000_9000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  9000) &> peak_ram/total_test_adm_rand2000_2000_9000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  9000) &> peak_ram/total_test_adm_rand3000_3000_9000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  9000) &> peak_ram/total_test_adm_rand4000_4000_9000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  9000) &> peak_ram/total_test_adm_rand5000_5000_9000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  9000) &> peak_ram/total_test_adm_rand6000_6000_9000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  9000) &> peak_ram/total_test_adm_rand8000_8000_9000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 9000) &> peak_ram/total_test_adm_rand10000_10000_9000.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  10000) &> peak_ram/total_test_adm_rand1000_1000_10000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  10000) &> peak_ram/total_test_adm_rand2000_2000_10000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  10000) &> peak_ram/total_test_adm_rand3000_3000_10000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  10000) &> peak_ram/total_test_adm_rand4000_4000_10000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  10000) &> peak_ram/total_test_adm_rand5000_5000_10000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  10000) &> peak_ram/total_test_adm_rand6000_6000_10000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  10000) &> peak_ram/total_test_adm_rand8000_8000_10000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 10000) &> peak_ram/total_test_adm_rand10000_10000_10000.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  15000) &> peak_ram/total_test_adm_rand1000_1000_15000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  15000) &> peak_ram/total_test_adm_rand2000_2000_15000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  15000) &> peak_ram/total_test_adm_rand3000_3000_15000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  15000) &> peak_ram/total_test_adm_rand4000_4000_15000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  15000) &> peak_ram/total_test_adm_rand5000_5000_15000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  15000) &> peak_ram/total_test_adm_rand6000_6000_15000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  15000) &> peak_ram/total_test_adm_rand8000_8000_15000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 15000) &> peak_ram/total_test_adm_rand10000_10000_15000.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  20000) &> peak_ram/total_test_adm_rand1000_1000_20000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  20000) &> peak_ram/total_test_adm_rand2000_2000_20000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  20000) &> peak_ram/total_test_adm_rand3000_3000_20000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  20000) &> peak_ram/total_test_adm_rand4000_4000_20000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  20000) &> peak_ram/total_test_adm_rand5000_5000_20000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  20000) &> peak_ram/total_test_adm_rand6000_6000_20000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  20000) &> peak_ram/total_test_adm_rand8000_8000_20000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 20000) &> peak_ram/total_test_adm_rand10000_10000_20000.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  30000) &> peak_ram/total_test_adm_rand1000_1000_30000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  30000) &> peak_ram/total_test_adm_rand2000_2000_30000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  30000) &> peak_ram/total_test_adm_rand3000_3000_30000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  30000) &> peak_ram/total_test_adm_rand4000_4000_30000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  30000) &> peak_ram/total_test_adm_rand5000_5000_30000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  30000) &> peak_ram/total_test_adm_rand6000_6000_30000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  30000) &> peak_ram/total_test_adm_rand8000_8000_30000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 30000) &> peak_ram/total_test_adm_rand10000_10000_30000.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  40000) &> peak_ram/total_test_adm_rand1000_1000_40000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  40000) &> peak_ram/total_test_adm_rand2000_2000_40000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  40000) &> peak_ram/total_test_adm_rand3000_3000_40000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  40000) &> peak_ram/total_test_adm_rand4000_4000_40000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  40000) &> peak_ram/total_test_adm_rand5000_5000_40000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  40000) &> peak_ram/total_test_adm_rand6000_6000_40000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  40000) &> peak_ram/total_test_adm_rand8000_8000_40000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 40000) &> peak_ram/total_test_adm_rand10000_10000_40000.txt

(/usr/bin/time -v ./total data/ADM_rand_1000_instance.txt  1000  50000) &> peak_ram/total_test_adm_rand1000_1000_50000.txt
(/usr/bin/time -v ./total data/ADM_rand_2000_instance.txt  2000  50000) &> peak_ram/total_test_adm_rand2000_2000_50000.txt
(/usr/bin/time -v ./total data/ADM_rand_3000_instance.txt  3000  50000) &> peak_ram/total_test_adm_rand3000_3000_50000.txt
(/usr/bin/time -v ./total data/ADM_rand_4000_instance.txt  4000  50000) &> peak_ram/total_test_adm_rand4000_4000_50000.txt
(/usr/bin/time -v ./total data/ADM_rand_5000_instance.txt  5000  50000) &> peak_ram/total_test_adm_rand5000_5000_50000.txt
(/usr/bin/time -v ./total data/ADM_rand_6000_instance.txt  6000  50000) &> peak_ram/total_test_adm_rand6000_6000_50000.txt
(/usr/bin/time -v ./total data/ADM_rand_8000_instance.txt  8000  50000) &> peak_ram/total_test_adm_rand8000_8000_50000.txt
(/usr/bin/time -v ./total data/ADM_rand_10000_instance.txt 10000 50000) &> peak_ram/total_test_adm_rand10000_10000_50000.txt


