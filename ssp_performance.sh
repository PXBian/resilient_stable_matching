#!/bin/bash

mkdir peak_ram
gunzip *.gz

g++ -O3 -std=c++17 capacity_scaling_lemon_test.cpp \
    -Ilemon-1.3.1/build/liblemon/include \
    -Llemon-1.3.1/build/liblemon/lib \
    -o cs_lemon_test

g++ -O3 -std=c++17 network_simplex_lemon_test.cpp \
    -Ilemon-1.3.1/build/liblemon/include \
    -Llemon-1.3.1/build/liblemon/lib \
    -o ns_lemon_test

g++ -O3 -std=c++17 cost_scaling_lemon_test.cpp \
    -Ilemon-1.3.1/build/liblemon/include \
    -Llemon-1.3.1/build/liblemon/lib \
    -o cost_lemon_test

g++ -O3 -std=c++17 cycle_canceling_lemon_test.cpp \
    -Ilemon-1.3.1/build/liblemon/include \
    -Llemon-1.3.1/build/liblemon/lib \
    -o cc_lemon_test

g++ -O3 -std=c++17 ssp_dij_test.cpp -o ssp_dij_test




# parameter: n max_deg flow_amount


# ## LEMON: Cost Scaling
# (/usr/bin/time -v ./cost_lemon_test 10000 1000 200 ) &> peak_ram/lemon_cost_10000_1000_200.txt
# (/usr/bin/time -v ./cost_lemon_test 20000 1000 400 ) &> peak_ram/lemon_cost_20000_1000_400.txt
# (/usr/bin/time -v ./cost_lemon_test 30000 1000 600 ) &> peak_ram/lemon_cost_30000_1000_600.txt
# (/usr/bin/time -v ./cost_lemon_test 40000 1000 800 ) &> peak_ram/lemon_cost_40000_1000_800.txt
# (/usr/bin/time -v ./cost_lemon_test 50000 1000 1000) &> peak_ram/lemon_cost_50000_1000_1000.txt

# (/usr/bin/time -v ./cost_lemon_test 100000 1000 200 ) &> peak_ram/lemon_cost_100000_1000_200.txt
# (/usr/bin/time -v ./cost_lemon_test 200000 1000 400 ) &> peak_ram/lemon_cost_200000_1000_400.txt
# (/usr/bin/time -v ./cost_lemon_test 300000 1000 600 ) &> peak_ram/lemon_cost_300000_1000_600.txt
# (/usr/bin/time -v ./cost_lemon_test 400000 1000 800 ) &> peak_ram/lemon_cost_400000_1000_800.txt
# (/usr/bin/time -v ./cost_lemon_test 500000 1000 1000) &> peak_ram/lemon_cost_500000_1000_1000.txt


## LEMON: Cycle Canceling
# (/usr/bin/time -v ./cc_lemon_test 10000 1000 200 ) &> peak_ram/lemon_cc_10000_1000_200.txt
# (/usr/bin/time -v ./cc_lemon_test 20000 1000 400 ) &> peak_ram/lemon_cc_20000_1000_400.txt
# (/usr/bin/time -v ./cc_lemon_test 30000 1000 600 ) &> peak_ram/lemon_cc_30000_1000_600.txt
# (/usr/bin/time -v ./cc_lemon_test 40000 1000 800 ) &> peak_ram/lemon_cc_40000_1000_800.txt
# (/usr/bin/time -v ./cc_lemon_test 50000 1000 1000) &> peak_ram/lemon_cc_50000_1000_1000.txt

# (/usr/bin/time -v ./cc_lemon_test 100000 1000 200 ) &> peak_ram/lemon_cc_100000_1000_200.txt
# (/usr/bin/time -v ./cc_lemon_test 200000 1000 400 ) &> peak_ram/lemon_cc_200000_1000_400.txt
# (/usr/bin/time -v ./cc_lemon_test 300000 1000 600 ) &> peak_ram/lemon_cc_300000_1000_600.txt
# (/usr/bin/time -v ./cc_lemon_test 400000 1000 800 ) &> peak_ram/lemon_cc_400000_1000_800.txt
# (/usr/bin/time -v ./cc_lemon_test 500000 1000 1000) &> peak_ram/lemon_cc_500000_1000_1000.txt


## LEMON: Capacity Scaling
# (/usr/bin/time -v ./cs_lemon_test 10000 1000 200 ) &> peak_ram/lemon_cs_10000_1000_200.txt
# (/usr/bin/time -v ./cs_lemon_test 20000 1000 400 ) &> peak_ram/lemon_cs_20000_1000_400.txt
# (/usr/bin/time -v ./cs_lemon_test 30000 1000 600 ) &> peak_ram/lemon_cs_30000_1000_600.txt
# (/usr/bin/time -v ./cs_lemon_test 40000 1000 800 ) &> peak_ram/lemon_cs_40000_1000_800.txt
# (/usr/bin/time -v ./cs_lemon_test 50000 1000 1000) &> peak_ram/lemon_cs_50000_1000_1000.txt

# (/usr/bin/time -v ./cs_lemon_test 100000 1000 200 ) &> peak_ram/lemon_cs_100000_1000_200.txt
(/usr/bin/time -v ./cs_lemon_test 200000 1000 400 ) &> peak_ram/lemon_cs_200000_1000_400.txt
(/usr/bin/time -v ./cs_lemon_test 300000 1000 600 ) &> peak_ram/lemon_cs_300000_1000_600.txt
(/usr/bin/time -v ./cs_lemon_test 400000 1000 800 ) &> peak_ram/lemon_cs_400000_1000_800.txt
(/usr/bin/time -v ./cs_lemon_test 500000 1000 1000) &> peak_ram/lemon_cs_500000_1000_1000.txt


# ## LEMON: Network Simplex
# (/usr/bin/time -v ./ns_lemon_test 10000 1000 200 ) &> peak_ram/lemon_ns_10000_1000_200.txt
# (/usr/bin/time -v ./ns_lemon_test 20000 1000 400 ) &> peak_ram/lemon_ns_20000_1000_400.txt
# (/usr/bin/time -v ./ns_lemon_test 30000 1000 600 ) &> peak_ram/lemon_ns_30000_1000_600.txt
# (/usr/bin/time -v ./ns_lemon_test 40000 1000 800 ) &> peak_ram/lemon_ns_40000_1000_800.txt
# (/usr/bin/time -v ./ns_lemon_test 50000 1000 1000) &> peak_ram/lemon_ns_50000_1000_1000.txt

# (/usr/bin/time -v ./ns_lemon_test 100000 1000 200 ) &> peak_ram/lemon_ns_100000_1000_200.txt
# (/usr/bin/time -v ./ns_lemon_test 200000 1000 400 ) &> peak_ram/lemon_ns_200000_1000_400.txt
# (/usr/bin/time -v ./ns_lemon_test 300000 1000 600 ) &> peak_ram/lemon_ns_300000_1000_600.txt
# (/usr/bin/time -v ./ns_lemon_test 400000 1000 800 ) &> peak_ram/lemon_ns_400000_1000_800.txt
# (/usr/bin/time -v ./ns_lemon_test 500000 1000 1000) &> peak_ram/lemon_ns_500000_1000_1000.txt




## DIY
(/usr/bin/time -v ./ssp_dij_test 10000 1000 200 ) &> peak_ram/ssp_dij_10000_1000_200.txt
(/usr/bin/time -v ./ssp_dij_test 20000 1000 400 ) &> peak_ram/ssp_dij_20000_1000_400.txt
(/usr/bin/time -v ./ssp_dij_test 30000 1000 600 ) &> peak_ram/ssp_dij_30000_1000_600.txt
(/usr/bin/time -v ./ssp_dij_test 40000 1000 800 ) &> peak_ram/ssp_dij_40000_1000_800.txt
(/usr/bin/time -v ./ssp_dij_test 50000 1000 1000) &> peak_ram/ssp_dij_50000_1000_1000.txt

(/usr/bin/time -v ./ssp_dij_test 100000 1000 200 ) &> peak_ram/ssp_dij_100000_1000_200.txt
(/usr/bin/time -v ./ssp_dij_test 200000 1000 400 ) &> peak_ram/ssp_dij_200000_1000_400.txt
(/usr/bin/time -v ./ssp_dij_test 300000 1000 600 ) &> peak_ram/ssp_dij_300000_1000_600.txt
(/usr/bin/time -v ./ssp_dij_test 400000 1000 800 ) &> peak_ram/ssp_dij_400000_1000_800.txt
(/usr/bin/time -v ./ssp_dij_test 500000 1000 1000) &> peak_ram/ssp_dij_500000_1000_1000.txt
