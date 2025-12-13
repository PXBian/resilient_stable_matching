#!/bin/bash

# 加载 Rust 环境（如果存在）
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

mkdir peak_ram
gunzip data/*.gz

make total


(/usr/bin/time -v ./total_test data/ADM_rand_1000_instance.txt 1000 500) &> peak_ram/total_test_adm_rand1000_1000_500.txt
(/usr/bin/time -v ./total_test data/ADM_rand_2000_instance.txt 2000 500) &> peak_ram/total_test_adm_rand2000_2000_500.txt
(/usr/bin/time -v ./total_test data/ADM_rand_3000_instance.txt 3000 500) &> peak_ram/total_test_adm_rand3000_3000_500.txt
(/usr/bin/time -v ./total_test data/ADM_rand_4000_instance.txt 4000 500) &> peak_ram/total_test_adm_rand4000_4000_500.txt
(/usr/bin/time -v ./total_test data/ADM_rand_5000_instance.txt 5000 500) &> peak_ram/total_test_adm_rand5000_5000_500.txt

(/usr/bin/time -v ./total_test data/ADM_rand_1000_instance.txt 1000 1000) &> peak_ram/total_test_adm_rand1000_1000_1000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_2000_instance.txt 2000 1000) &> peak_ram/total_test_adm_rand2000_2000_1000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_3000_instance.txt 3000 1000) &> peak_ram/total_test_adm_rand3000_3000_1000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_4000_instance.txt 4000 1000) &> peak_ram/total_test_adm_rand4000_4000_1000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_5000_instance.txt 5000 1000) &> peak_ram/total_test_adm_rand5000_5000_1000.txt

(/usr/bin/time -v ./total_test data/ADM_rand_1000_instance.txt 1000 2000) &> peak_ram/total_test_adm_rand1000_1000_2000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_2000_instance.txt 2000 2000) &> peak_ram/total_test_adm_rand2000_2000_2000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_3000_instance.txt 3000 2000) &> peak_ram/total_test_adm_rand3000_3000_2000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_4000_instance.txt 4000 2000) &> peak_ram/total_test_adm_rand4000_4000_2000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_5000_instance.txt 5000 2000) &> peak_ram/total_test_adm_rand5000_5000_2000.txt

(/usr/bin/time -v ./total_test data/ADM_rand_1000_instance.txt 1000 3000) &> peak_ram/total_test_adm_rand1000_1000_3000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_2000_instance.txt 2000 3000) &> peak_ram/total_test_adm_rand2000_2000_3000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_3000_instance.txt 3000 3000) &> peak_ram/total_test_adm_rand3000_3000_3000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_4000_instance.txt 4000 3000) &> peak_ram/total_test_adm_rand4000_4000_3000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_5000_instance.txt 5000 3000) &> peak_ram/total_test_adm_rand5000_5000_3000.txt

(/usr/bin/time -v ./total_test data/ADM_rand_1000_instance.txt 1000 4000) &> peak_ram/total_test_adm_rand1000_1000_4000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_2000_instance.txt 2000 4000) &> peak_ram/total_test_adm_rand2000_2000_4000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_3000_instance.txt 3000 4000) &> peak_ram/total_test_adm_rand3000_3000_4000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_4000_instance.txt 4000 4000) &> peak_ram/total_test_adm_rand4000_4000_4000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_5000_instance.txt 5000 4000) &> peak_ram/total_test_adm_rand5000_5000_4000.txt

(/usr/bin/time -v ./total_test data/ADM_rand_1000_instance.txt 1000 5000) &> peak_ram/total_test_adm_rand1000_1000_5000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_2000_instance.txt 2000 5000) &> peak_ram/total_test_adm_rand2000_2000_5000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_3000_instance.txt 3000 5000) &> peak_ram/total_test_adm_rand3000_3000_5000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_4000_instance.txt 4000 5000) &> peak_ram/total_test_adm_rand4000_4000_5000.txt
(/usr/bin/time -v ./total_test data/ADM_rand_5000_instance.txt 5000 5000) &> peak_ram/total_test_adm_rand5000_5000_5000.txt