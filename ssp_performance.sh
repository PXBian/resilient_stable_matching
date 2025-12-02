#!/bin/bash

mkdir peak_ram
g++ -O3 -std=c++17 capacity_scaling_lemon_test.cpp -o cs_lemon_test
g++ -O3 -std=c++17 ssp_dij_test.cpp -o ssp_dij_test
gunzip *.gz


# parameter: n max_deg flow_amount
./cs_lemon_test 1000 5 200
./cs_lemon_test 2000 5 400
./cs_lemon_test 3000 5 600
./cs_lemon_test 4000 5 800
./cs_lemon_test 5000 5 1000

./ssp_dij_test 1000 5 200
./ssp_dij_test 2000 5 400
./ssp_dij_test 3000 5 600
./ssp_dij_test 4000 5 800
./ssp_dij_test 5000 5 1000
