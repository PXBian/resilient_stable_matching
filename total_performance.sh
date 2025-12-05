#!/bin/bash

mkdir peak_ram
gunzip *.gz

g++ -O3 -std=c++17 total_test.cpp \
    -Ilemon-1.3.1/build/liblemon/include \
    -Llemon-1.3.1/build/liblemon/lib \
    -o total_test


# (/usr/bin/time -v ./total_test 10000 1000 200 ) &> peak_ram/total_test_10000_1000_200.txt
# (/usr/bin/time -v ./total_test 20000 1000 200 ) &> peak_ram/total_test_20000_1000_200.txt
# (/usr/bin/time -v ./total_test 30000 1000 200 ) &> peak_ram/total_test_30000_1000_200.txt
# (/usr/bin/time -v ./total_test 40000 1000 200 ) &> peak_ram/total_test_40000_1000_200.txt
# (/usr/bin/time -v ./total_test 50000 1000 200 ) &> peak_ram/total_test_50000_1000_200.txt

# (/usr/bin/time -v ./total_test 10000 1000 400 ) &> peak_ram/total_test_10000_1000_400.txt
# (/usr/bin/time -v ./total_test 20000 1000 400 ) &> peak_ram/total_test_20000_1000_400.txt
# (/usr/bin/time -v ./total_test 30000 1000 400 ) &> peak_ram/total_test_30000_1000_400.txt
# (/usr/bin/time -v ./total_test 40000 1000 400 ) &> peak_ram/total_test_40000_1000_400.txt
# (/usr/bin/time -v ./total_test 50000 1000 400 ) &> peak_ram/total_test_50000_1000_400.txt

# (/usr/bin/time -v ./total_test 10000 1000 600 ) &> peak_ram/total_test_10000_1000_600.txt
# (/usr/bin/time -v ./total_test 20000 1000 600 ) &> peak_ram/total_test_20000_1000_600.txt
# (/usr/bin/time -v ./total_test 30000 1000 600 ) &> peak_ram/total_test_30000_1000_600.txt
# (/usr/bin/time -v ./total_test 40000 1000 600 ) &> peak_ram/total_test_40000_1000_600.txt
# (/usr/bin/time -v ./total_test 50000 1000 600 ) &> peak_ram/total_test_50000_1000_600.txt

# (/usr/bin/time -v ./total_test 10000 1000 800 ) &> peak_ram/total_test_10000_1000_800.txt
# (/usr/bin/time -v ./total_test 20000 1000 800 ) &> peak_ram/total_test_20000_1000_800.txt
# (/usr/bin/time -v ./total_test 30000 1000 800 ) &> peak_ram/total_test_30000_1000_800.txt
# (/usr/bin/time -v ./total_test 40000 1000 800 ) &> peak_ram/total_test_40000_1000_800.txt
# (/usr/bin/time -v ./total_test 50000 1000 800 ) &> peak_ram/total_test_50000_1000_800.txt

# (/usr/bin/time -v ./total_test 10000 1000 1000 ) &> peak_ram/total_test_10000_1000_1000.txt
# (/usr/bin/time -v ./total_test 20000 1000 1000 ) &> peak_ram/total_test_20000_1000_1000.txt
# (/usr/bin/time -v ./total_test 30000 1000 1000 ) &> peak_ram/total_test_30000_1000_1000.txt
# (/usr/bin/time -v ./total_test 40000 1000 1000 ) &> peak_ram/total_test_40000_1000_1000.txt
# (/usr/bin/time -v ./total_test 50000 1000 1000 ) &> peak_ram/total_test_50000_1000_1000.txt

(/usr/bin/time -v ./total_test 100000 1000 200 ) &> peak_ram/total_test_100000_1000_200.txt
(/usr/bin/time -v ./total_test 100000 1000 400 ) &> peak_ram/total_test_100000_1000_400.txt
(/usr/bin/time -v ./total_test 100000 1000 600 ) &> peak_ram/total_test_100000_1000_600.txt
(/usr/bin/time -v ./total_test 100000 1000 800 ) &> peak_ram/total_test_100000_1000_800.txt
(/usr/bin/time -v ./total_test 100000 1000 1000) &> peak_ram/total_test_100000_1000_1000.txt

(/usr/bin/time -v ./total_test 200000 1000 200 ) &> peak_ram/total_test_200000_1000_200.txt
(/usr/bin/time -v ./total_test 200000 1000 400 ) &> peak_ram/total_test_200000_1000_400.txt
(/usr/bin/time -v ./total_test 200000 1000 600 ) &> peak_ram/total_test_200000_1000_600.txt
(/usr/bin/time -v ./total_test 200000 1000 800 ) &> peak_ram/total_test_200000_1000_800.txt
(/usr/bin/time -v ./total_test 200000 1000 1000) &> peak_ram/total_test_200000_1000_1000.txt

(/usr/bin/time -v ./total_test 300000 1000 200 ) &> peak_ram/total_test_300000_1000_200.txt
(/usr/bin/time -v ./total_test 300000 1000 400 ) &> peak_ram/total_test_300000_1000_400.txt
(/usr/bin/time -v ./total_test 300000 1000 600 ) &> peak_ram/total_test_300000_1000_600.txt
(/usr/bin/time -v ./total_test 300000 1000 800 ) &> peak_ram/total_test_300000_1000_800.txt
(/usr/bin/time -v ./total_test 300000 1000 1000) &> peak_ram/total_test_300000_1000_1000.txt

(/usr/bin/time -v ./total_test 400000 1000 200 ) &> peak_ram/total_test_400000_1000_200.txt
(/usr/bin/time -v ./total_test 400000 1000 400 ) &> peak_ram/total_test_400000_1000_400.txt
(/usr/bin/time -v ./total_test 400000 1000 600 ) &> peak_ram/total_test_400000_1000_600.txt
(/usr/bin/time -v ./total_test 400000 1000 800 ) &> peak_ram/total_test_400000_1000_800.txt
(/usr/bin/time -v ./total_test 400000 1000 1000) &> peak_ram/total_test_400000_1000_1000.txt

(/usr/bin/time -v ./total_test 500000 1000 200 ) &> peak_ram/total_test_500000_1000_200.txt
(/usr/bin/time -v ./total_test 500000 1000 400 ) &> peak_ram/total_test_500000_1000_400.txt
(/usr/bin/time -v ./total_test 500000 1000 600 ) &> peak_ram/total_test_500000_1000_600.txt
(/usr/bin/time -v ./total_test 500000 1000 800 ) &> peak_ram/total_test_500000_1000_800.txt
(/usr/bin/time -v ./total_test 500000 1000 1000) &> peak_ram/total_test_500000_1000_1000.txt
