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





# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_5000_instance.txt   5000  1000 )  &> peak_ram/heuristic_food_rand_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_5000_instance.txt   5000  5000 )  &> peak_ram/heuristic_food_rand_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_10000_instance.txt  10000  1000 ) &> peak_ram/heuristic_food_rand_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_10000_instance.txt  10000  5000 ) &> peak_ram/heuristic_food_rand_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_10000_instance.txt  10000  10000) &> peak_ram/heuristic_food_rand_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_15000_instance.txt  15000  1000 ) &> peak_ram/heuristic_food_rand_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_15000_instance.txt  15000  5000 ) &> peak_ram/heuristic_food_rand_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_15000_instance.txt  15000  10000) &> peak_ram/heuristic_food_rand_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_15000_instance.txt  15000  15000) &> peak_ram/heuristic_food_rand_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_20000_instance.txt  20000  1000 ) &> peak_ram/heuristic_food_rand_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_20000_instance.txt  20000  5000 ) &> peak_ram/heuristic_food_rand_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_20000_instance.txt  20000  10000) &> peak_ram/heuristic_food_rand_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_20000_instance.txt  20000  15000) &> peak_ram/heuristic_food_rand_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_20000_instance.txt  20000  20000) &> peak_ram/heuristic_food_rand_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_25000_instance.txt  25000  1000 ) &> peak_ram/heuristic_food_rand_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_25000_instance.txt  25000  5000 ) &> peak_ram/heuristic_food_rand_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_25000_instance.txt  25000  10000) &> peak_ram/heuristic_food_rand_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_25000_instance.txt  25000  15000) &> peak_ram/heuristic_food_rand_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_25000_instance.txt  25000  20000) &> peak_ram/heuristic_food_rand_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/FOOD_25000_instance.txt  25000  25000) &> peak_ram/heuristic_food_rand_25000_25000.txt


# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_5000_instance.txt   5000  1000 )  &> peak_ram/capacity_scaling_food_rand_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_5000_instance.txt   5000  5000 )  &> peak_ram/capacity_scaling_food_rand_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_10000_instance.txt  10000  1000 ) &> peak_ram/capacity_scaling_food_rand_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_10000_instance.txt  10000  5000 ) &> peak_ram/capacity_scaling_food_rand_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_10000_instance.txt  10000  10000) &> peak_ram/capacity_scaling_food_rand_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_15000_instance.txt  15000  1000 ) &> peak_ram/capacity_scaling_food_rand_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_15000_instance.txt  15000  5000 ) &> peak_ram/capacity_scaling_food_rand_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_15000_instance.txt  15000  10000) &> peak_ram/capacity_scaling_food_rand_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_15000_instance.txt  15000  15000) &> peak_ram/capacity_scaling_food_rand_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_20000_instance.txt  20000  1000 ) &> peak_ram/capacity_scaling_food_rand_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_20000_instance.txt  20000  5000 ) &> peak_ram/capacity_scaling_food_rand_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_20000_instance.txt  20000  10000) &> peak_ram/capacity_scaling_food_rand_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_20000_instance.txt  20000  15000) &> peak_ram/capacity_scaling_food_rand_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_20000_instance.txt  20000  20000) &> peak_ram/capacity_scaling_food_rand_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_25000_instance.txt  25000  1000 ) &> peak_ram/capacity_scaling_food_rand_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_25000_instance.txt  25000  5000 ) &> peak_ram/capacity_scaling_food_rand_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_25000_instance.txt  25000  10000) &> peak_ram/capacity_scaling_food_rand_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_25000_instance.txt  25000  15000) &> peak_ram/capacity_scaling_food_rand_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_25000_instance.txt  25000  20000) &> peak_ram/capacity_scaling_food_rand_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/FOOD_25000_instance.txt  25000  25000) &> peak_ram/capacity_scaling_food_rand_25000_25000.txt


# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_5000_instance.txt   5000  1000 )  &> peak_ram/network_simplex_food_rand_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_5000_instance.txt   5000  5000 )  &> peak_ram/network_simplex_food_rand_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_10000_instance.txt  10000  1000 ) &> peak_ram/network_simplex_food_rand_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_10000_instance.txt  10000  5000 ) &> peak_ram/network_simplex_food_rand_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_10000_instance.txt  10000  10000) &> peak_ram/network_simplex_food_rand_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_15000_instance.txt  15000  1000 ) &> peak_ram/network_simplex_food_rand_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_15000_instance.txt  15000  5000 ) &> peak_ram/network_simplex_food_rand_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_15000_instance.txt  15000  10000) &> peak_ram/network_simplex_food_rand_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_15000_instance.txt  15000  15000) &> peak_ram/network_simplex_food_rand_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_20000_instance.txt  20000  1000 ) &> peak_ram/network_simplex_food_rand_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_20000_instance.txt  20000  5000 ) &> peak_ram/network_simplex_food_rand_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_20000_instance.txt  20000  10000) &> peak_ram/network_simplex_food_rand_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_20000_instance.txt  20000  15000) &> peak_ram/network_simplex_food_rand_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_20000_instance.txt  20000  20000) &> peak_ram/network_simplex_food_rand_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_25000_instance.txt  25000  1000 ) &> peak_ram/network_simplex_food_rand_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_25000_instance.txt  25000  5000 ) &> peak_ram/network_simplex_food_rand_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_25000_instance.txt  25000  10000) &> peak_ram/network_simplex_food_rand_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_25000_instance.txt  25000  15000) &> peak_ram/network_simplex_food_rand_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_25000_instance.txt  25000  20000) &> peak_ram/network_simplex_food_rand_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/FOOD_25000_instance.txt  25000  25000) &> peak_ram/network_simplex_food_rand_25000_25000.txt



# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_5000_instance.txt   5000  1000 )  &> peak_ram/ssp_dijkstra_food_rand_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_5000_instance.txt   5000  5000 )  &> peak_ram/ssp_dijkstra_food_rand_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_10000_instance.txt  10000  1000 ) &> peak_ram/ssp_dijkstra_food_rand_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_10000_instance.txt  10000  5000 ) &> peak_ram/ssp_dijkstra_food_rand_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_10000_instance.txt  10000  10000) &> peak_ram/ssp_dijkstra_food_rand_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_15000_instance.txt  15000  1000 ) &> peak_ram/ssp_dijkstra_food_rand_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_15000_instance.txt  15000  5000 ) &> peak_ram/ssp_dijkstra_food_rand_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_15000_instance.txt  15000  10000) &> peak_ram/ssp_dijkstra_food_rand_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_15000_instance.txt  15000  15000) &> peak_ram/ssp_dijkstra_food_rand_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_20000_instance.txt  20000  1000 ) &> peak_ram/ssp_dijkstra_food_rand_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_20000_instance.txt  20000  5000 ) &> peak_ram/ssp_dijkstra_food_rand_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_20000_instance.txt  20000  10000) &> peak_ram/ssp_dijkstra_food_rand_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_20000_instance.txt  20000  15000) &> peak_ram/ssp_dijkstra_food_rand_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_20000_instance.txt  20000  20000) &> peak_ram/ssp_dijkstra_food_rand_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_25000_instance.txt  25000  1000 ) &> peak_ram/ssp_dijkstra_food_rand_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_25000_instance.txt  25000  5000 ) &> peak_ram/ssp_dijkstra_food_rand_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_25000_instance.txt  25000  10000) &> peak_ram/ssp_dijkstra_food_rand_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_25000_instance.txt  25000  15000) &> peak_ram/ssp_dijkstra_food_rand_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_25000_instance.txt  25000  20000) &> peak_ram/ssp_dijkstra_food_rand_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/FOOD_25000_instance.txt  25000  25000) &> peak_ram/ssp_dijkstra_food_rand_25000_25000.txt


# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_5000_instance.txt   5000  1000 )  &> peak_ram/cost_scaling_food_rand_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_5000_instance.txt   5000  5000 )  &> peak_ram/cost_scaling_food_rand_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_10000_instance.txt  10000  1000 ) &> peak_ram/cost_scaling_food_rand_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_10000_instance.txt  10000  5000 ) &> peak_ram/cost_scaling_food_rand_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_10000_instance.txt  10000  10000) &> peak_ram/cost_scaling_food_rand_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_15000_instance.txt  15000  1000 ) &> peak_ram/cost_scaling_food_rand_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_15000_instance.txt  15000  5000 ) &> peak_ram/cost_scaling_food_rand_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_15000_instance.txt  15000  10000) &> peak_ram/cost_scaling_food_rand_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_15000_instance.txt  15000  15000) &> peak_ram/cost_scaling_food_rand_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_20000_instance.txt  20000  1000 ) &> peak_ram/cost_scaling_food_rand_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_20000_instance.txt  20000  5000 ) &> peak_ram/cost_scaling_food_rand_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_20000_instance.txt  20000  10000) &> peak_ram/cost_scaling_food_rand_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_20000_instance.txt  20000  15000) &> peak_ram/cost_scaling_food_rand_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_20000_instance.txt  20000  20000) &> peak_ram/cost_scaling_food_rand_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_25000_instance.txt  25000  1000 ) &> peak_ram/cost_scaling_food_rand_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_25000_instance.txt  25000  5000 ) &> peak_ram/cost_scaling_food_rand_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_25000_instance.txt  25000  10000) &> peak_ram/cost_scaling_food_rand_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_25000_instance.txt  25000  15000) &> peak_ram/cost_scaling_food_rand_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_25000_instance.txt  25000  20000) &> peak_ram/cost_scaling_food_rand_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/FOOD_25000_instance.txt  25000  25000) &> peak_ram/cost_scaling_food_rand_25000_25000.txt







# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_5000_instance.txt   5000  1000 )  &> peak_ram/heuristic_bike_rand_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_5000_instance.txt   5000  5000 )  &> peak_ram/heuristic_bike_rand_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_10000_instance.txt  10000  1000 ) &> peak_ram/heuristic_bike_rand_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_10000_instance.txt  10000  5000 ) &> peak_ram/heuristic_bike_rand_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_10000_instance.txt  10000  10000) &> peak_ram/heuristic_bike_rand_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_15000_instance.txt  15000  1000 ) &> peak_ram/heuristic_bike_rand_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_15000_instance.txt  15000  5000 ) &> peak_ram/heuristic_bike_rand_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_15000_instance.txt  15000  10000) &> peak_ram/heuristic_bike_rand_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_15000_instance.txt  15000  15000) &> peak_ram/heuristic_bike_rand_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_20000_instance.txt  20000  1000 ) &> peak_ram/heuristic_bike_rand_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_20000_instance.txt  20000  5000 ) &> peak_ram/heuristic_bike_rand_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_20000_instance.txt  20000  10000) &> peak_ram/heuristic_bike_rand_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_20000_instance.txt  20000  15000) &> peak_ram/heuristic_bike_rand_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_20000_instance.txt  20000  20000) &> peak_ram/heuristic_bike_rand_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_25000_instance.txt  25000  1000 ) &> peak_ram/heuristic_bike_rand_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_25000_instance.txt  25000  5000 ) &> peak_ram/heuristic_bike_rand_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_25000_instance.txt  25000  10000) &> peak_ram/heuristic_bike_rand_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_25000_instance.txt  25000  15000) &> peak_ram/heuristic_bike_rand_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_25000_instance.txt  25000  20000) &> peak_ram/heuristic_bike_rand_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/BIKE_25000_instance.txt  25000  25000) &> peak_ram/heuristic_bike_rand_25000_25000.txt


# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_5000_instance.txt   5000  1000 )  &> peak_ram/capacity_scaling_bike_rand_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_5000_instance.txt   5000  5000 )  &> peak_ram/capacity_scaling_bike_rand_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_10000_instance.txt  10000  1000 ) &> peak_ram/capacity_scaling_bike_rand_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_10000_instance.txt  10000  5000 ) &> peak_ram/capacity_scaling_bike_rand_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_10000_instance.txt  10000  10000) &> peak_ram/capacity_scaling_bike_rand_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_15000_instance.txt  15000  1000 ) &> peak_ram/capacity_scaling_bike_rand_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_15000_instance.txt  15000  5000 ) &> peak_ram/capacity_scaling_bike_rand_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_15000_instance.txt  15000  10000) &> peak_ram/capacity_scaling_bike_rand_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_15000_instance.txt  15000  15000) &> peak_ram/capacity_scaling_bike_rand_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_20000_instance.txt  20000  1000 ) &> peak_ram/capacity_scaling_bike_rand_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_20000_instance.txt  20000  5000 ) &> peak_ram/capacity_scaling_bike_rand_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_20000_instance.txt  20000  10000) &> peak_ram/capacity_scaling_bike_rand_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_20000_instance.txt  20000  15000) &> peak_ram/capacity_scaling_bike_rand_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_20000_instance.txt  20000  20000) &> peak_ram/capacity_scaling_bike_rand_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_25000_instance.txt  25000  1000 ) &> peak_ram/capacity_scaling_bike_rand_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_25000_instance.txt  25000  5000 ) &> peak_ram/capacity_scaling_bike_rand_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_25000_instance.txt  25000  10000) &> peak_ram/capacity_scaling_bike_rand_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_25000_instance.txt  25000  15000) &> peak_ram/capacity_scaling_bike_rand_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_25000_instance.txt  25000  20000) &> peak_ram/capacity_scaling_bike_rand_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/BIKE_25000_instance.txt  25000  25000) &> peak_ram/capacity_scaling_bike_rand_25000_25000.txt

# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_5000_instance.txt   5000  1000 )  &> peak_ram/network_simplex_bike_rand_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_5000_instance.txt   5000  5000 )  &> peak_ram/network_simplex_bike_rand_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_10000_instance.txt  10000  1000 ) &> peak_ram/network_simplex_bike_rand_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_10000_instance.txt  10000  5000 ) &> peak_ram/network_simplex_bike_rand_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_10000_instance.txt  10000  10000) &> peak_ram/network_simplex_bike_rand_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_15000_instance.txt  15000  1000 ) &> peak_ram/network_simplex_bike_rand_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_15000_instance.txt  15000  5000 ) &> peak_ram/network_simplex_bike_rand_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_15000_instance.txt  15000  10000) &> peak_ram/network_simplex_bike_rand_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_15000_instance.txt  15000  15000) &> peak_ram/network_simplex_bike_rand_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_20000_instance.txt  20000  1000 ) &> peak_ram/network_simplex_bike_rand_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_20000_instance.txt  20000  5000 ) &> peak_ram/network_simplex_bike_rand_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_20000_instance.txt  20000  10000) &> peak_ram/network_simplex_bike_rand_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_20000_instance.txt  20000  15000) &> peak_ram/network_simplex_bike_rand_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_20000_instance.txt  20000  20000) &> peak_ram/network_simplex_bike_rand_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_25000_instance.txt  25000  1000 ) &> peak_ram/network_simplex_bike_rand_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_25000_instance.txt  25000  5000 ) &> peak_ram/network_simplex_bike_rand_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_25000_instance.txt  25000  10000) &> peak_ram/network_simplex_bike_rand_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_25000_instance.txt  25000  15000) &> peak_ram/network_simplex_bike_rand_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_25000_instance.txt  25000  20000) &> peak_ram/network_simplex_bike_rand_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/BIKE_25000_instance.txt  25000  25000) &> peak_ram/network_simplex_bike_rand_25000_25000.txt

# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_5000_instance.txt   5000  1000 )  &> peak_ram/ssp_dijkstra_bike_rand_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_5000_instance.txt   5000  5000 )  &> peak_ram/ssp_dijkstra_bike_rand_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_10000_instance.txt  10000  1000 ) &> peak_ram/ssp_dijkstra_bike_rand_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_10000_instance.txt  10000  5000 ) &> peak_ram/ssp_dijkstra_bike_rand_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_10000_instance.txt  10000  10000) &> peak_ram/ssp_dijkstra_bike_rand_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_15000_instance.txt  15000  1000 ) &> peak_ram/ssp_dijkstra_bike_rand_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_15000_instance.txt  15000  5000 ) &> peak_ram/ssp_dijkstra_bike_rand_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_15000_instance.txt  15000  10000) &> peak_ram/ssp_dijkstra_bike_rand_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_15000_instance.txt  15000  15000) &> peak_ram/ssp_dijkstra_bike_rand_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_20000_instance.txt  20000  1000 ) &> peak_ram/ssp_dijkstra_bike_rand_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_20000_instance.txt  20000  5000 ) &> peak_ram/ssp_dijkstra_bike_rand_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_20000_instance.txt  20000  10000) &> peak_ram/ssp_dijkstra_bike_rand_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_20000_instance.txt  20000  15000) &> peak_ram/ssp_dijkstra_bike_rand_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_20000_instance.txt  20000  20000) &> peak_ram/ssp_dijkstra_bike_rand_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_25000_instance.txt  25000  1000 ) &> peak_ram/ssp_dijkstra_bike_rand_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_25000_instance.txt  25000  5000 ) &> peak_ram/ssp_dijkstra_bike_rand_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_25000_instance.txt  25000  10000) &> peak_ram/ssp_dijkstra_bike_rand_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_25000_instance.txt  25000  15000) &> peak_ram/ssp_dijkstra_bike_rand_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_25000_instance.txt  25000  20000) &> peak_ram/ssp_dijkstra_bike_rand_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/BIKE_25000_instance.txt  25000  25000) &> peak_ram/ssp_dijkstra_bike_rand_25000_25000.txt


# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_5000_instance.txt   5000  1000 )  &> peak_ram/cost_scaling_bike_rand_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_5000_instance.txt   5000  5000 )  &> peak_ram/cost_scaling_bike_rand_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_10000_instance.txt  10000  1000 ) &> peak_ram/cost_scaling_bike_rand_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_10000_instance.txt  10000  5000 ) &> peak_ram/cost_scaling_bike_rand_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_10000_instance.txt  10000  10000) &> peak_ram/cost_scaling_bike_rand_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_15000_instance.txt  15000  1000 ) &> peak_ram/cost_scaling_bike_rand_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_15000_instance.txt  15000  5000 ) &> peak_ram/cost_scaling_bike_rand_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_15000_instance.txt  15000  10000) &> peak_ram/cost_scaling_bike_rand_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_15000_instance.txt  15000  15000) &> peak_ram/cost_scaling_bike_rand_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_20000_instance.txt  20000  1000 ) &> peak_ram/cost_scaling_bike_rand_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_20000_instance.txt  20000  5000 ) &> peak_ram/cost_scaling_bike_rand_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_20000_instance.txt  20000  10000) &> peak_ram/cost_scaling_bike_rand_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_20000_instance.txt  20000  15000) &> peak_ram/cost_scaling_bike_rand_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_20000_instance.txt  20000  20000) &> peak_ram/cost_scaling_bike_rand_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_25000_instance.txt  25000  1000 ) &> peak_ram/cost_scaling_bike_rand_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_25000_instance.txt  25000  5000 ) &> peak_ram/cost_scaling_bike_rand_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_25000_instance.txt  25000  10000) &> peak_ram/cost_scaling_bike_rand_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_25000_instance.txt  25000  15000) &> peak_ram/cost_scaling_bike_rand_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_25000_instance.txt  25000  20000) &> peak_ram/cost_scaling_bike_rand_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/BIKE_25000_instance.txt  25000  25000) &> peak_ram/cost_scaling_bike_rand_25000_25000.txt







# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_5000_instance.txt   5000  1000 )  &> peak_ram/cost_scaling_rap_rand_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_5000_instance.txt   5000  5000 )  &> peak_ram/cost_scaling_rap_rand_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_10000_instance.txt  10000  1000 ) &> peak_ram/cost_scaling_rap_rand_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_10000_instance.txt  10000  5000 ) &> peak_ram/cost_scaling_rap_rand_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_10000_instance.txt  10000  10000) &> peak_ram/cost_scaling_rap_rand_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_15000_instance.txt  15000  1000 ) &> peak_ram/cost_scaling_rap_rand_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_15000_instance.txt  15000  5000 ) &> peak_ram/cost_scaling_rap_rand_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_15000_instance.txt  15000  10000) &> peak_ram/cost_scaling_rap_rand_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_15000_instance.txt  15000  15000) &> peak_ram/cost_scaling_rap_rand_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_20000_instance.txt  20000  1000 ) &> peak_ram/cost_scaling_rap_rand_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_20000_instance.txt  20000  5000 ) &> peak_ram/cost_scaling_rap_rand_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_20000_instance.txt  20000  10000) &> peak_ram/cost_scaling_rap_rand_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_20000_instance.txt  20000  15000) &> peak_ram/cost_scaling_rap_rand_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_20000_instance.txt  20000  20000) &> peak_ram/cost_scaling_rap_rand_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_25000_instance.txt  25000  1000 ) &> peak_ram/cost_scaling_rap_rand_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_25000_instance.txt  25000  5000 ) &> peak_ram/cost_scaling_rap_rand_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_25000_instance.txt  25000  10000) &> peak_ram/cost_scaling_rap_rand_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_25000_instance.txt  25000  15000) &> peak_ram/cost_scaling_rap_rand_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_25000_instance.txt  25000  20000) &> peak_ram/cost_scaling_rap_rand_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/RAP_25000_instance.txt  25000  25000) &> peak_ram/cost_scaling_rap_rand_25000_25000.txt





# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_5000_instance.txt   5000  1000 )  &> peak_ram/heuristic_taxi_new_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_5000_instance.txt   5000  5000 )  &> peak_ram/heuristic_taxi_new_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_10000_instance.txt  10000  1000 ) &> peak_ram/heuristic_taxi_new_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_10000_instance.txt  10000  5000 ) &> peak_ram/heuristic_taxi_new_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_10000_instance.txt  10000  10000) &> peak_ram/heuristic_taxi_new_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_15000_instance.txt  15000  1000 ) &> peak_ram/heuristic_taxi_new_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_15000_instance.txt  15000  5000 ) &> peak_ram/heuristic_taxi_new_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_15000_instance.txt  15000  10000) &> peak_ram/heuristic_taxi_new_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_15000_instance.txt  15000  15000) &> peak_ram/heuristic_taxi_new_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_20000_instance.txt  20000  1000 ) &> peak_ram/heuristic_taxi_new_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_20000_instance.txt  20000  5000 ) &> peak_ram/heuristic_taxi_new_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_20000_instance.txt  20000  10000) &> peak_ram/heuristic_taxi_new_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_20000_instance.txt  20000  15000) &> peak_ram/heuristic_taxi_new_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_20000_instance.txt  20000  20000) &> peak_ram/heuristic_taxi_new_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_25000_instance.txt  25000  1000 ) &> peak_ram/heuristic_taxi_new_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_25000_instance.txt  25000  5000 ) &> peak_ram/heuristic_taxi_new_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_25000_instance.txt  25000  10000) &> peak_ram/heuristic_taxi_new_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_25000_instance.txt  25000  15000) &> peak_ram/heuristic_taxi_new_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_25000_instance.txt  25000  20000) &> peak_ram/heuristic_taxi_new_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./heuristic data/TAXI_new_25000_instance.txt  25000  25000) &> peak_ram/heuristic_taxi_new_25000_25000.txt


# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_5000_instance.txt   5000  1000 )  &> peak_ram/capacity_scaling_taxi_new_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_5000_instance.txt   5000  5000 )  &> peak_ram/capacity_scaling_taxi_new_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_10000_instance.txt  10000  1000 ) &> peak_ram/capacity_scaling_taxi_new_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_10000_instance.txt  10000  5000 ) &> peak_ram/capacity_scaling_taxi_new_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_10000_instance.txt  10000  10000) &> peak_ram/capacity_scaling_taxi_new_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_15000_instance.txt  15000  1000 ) &> peak_ram/capacity_scaling_taxi_new_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_15000_instance.txt  15000  5000 ) &> peak_ram/capacity_scaling_taxi_new_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_15000_instance.txt  15000  10000) &> peak_ram/capacity_scaling_taxi_new_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_15000_instance.txt  15000  15000) &> peak_ram/capacity_scaling_taxi_new_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_20000_instance.txt  20000  1000 ) &> peak_ram/capacity_scaling_taxi_new_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_20000_instance.txt  20000  5000 ) &> peak_ram/capacity_scaling_taxi_new_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_20000_instance.txt  20000  10000) &> peak_ram/capacity_scaling_taxi_new_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_20000_instance.txt  20000  15000) &> peak_ram/capacity_scaling_taxi_new_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_20000_instance.txt  20000  20000) &> peak_ram/capacity_scaling_taxi_new_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_25000_instance.txt  25000  1000 ) &> peak_ram/capacity_scaling_taxi_new_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_25000_instance.txt  25000  5000 ) &> peak_ram/capacity_scaling_taxi_new_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_25000_instance.txt  25000  10000) &> peak_ram/capacity_scaling_taxi_new_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_25000_instance.txt  25000  15000) &> peak_ram/capacity_scaling_taxi_new_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_25000_instance.txt  25000  20000) &> peak_ram/capacity_scaling_taxi_new_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./capacity_scaling data/TAXI_new_25000_instance.txt  25000  25000) &> peak_ram/capacity_scaling_taxi_new_25000_25000.txt

# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_5000_instance.txt   5000  1000 )  &> peak_ram/network_simplex_taxi_new_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_5000_instance.txt   5000  5000 )  &> peak_ram/network_simplex_taxi_new_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_10000_instance.txt  10000  1000 ) &> peak_ram/network_simplex_taxi_new_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_10000_instance.txt  10000  5000 ) &> peak_ram/network_simplex_taxi_new_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_10000_instance.txt  10000  10000) &> peak_ram/network_simplex_taxi_new_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_15000_instance.txt  15000  1000 ) &> peak_ram/network_simplex_taxi_new_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_15000_instance.txt  15000  5000 ) &> peak_ram/network_simplex_taxi_new_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_15000_instance.txt  15000  10000) &> peak_ram/network_simplex_taxi_new_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_15000_instance.txt  15000  15000) &> peak_ram/network_simplex_taxi_new_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_20000_instance.txt  20000  1000 ) &> peak_ram/network_simplex_taxi_new_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_20000_instance.txt  20000  5000 ) &> peak_ram/network_simplex_taxi_new_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_20000_instance.txt  20000  10000) &> peak_ram/network_simplex_taxi_new_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_20000_instance.txt  20000  15000) &> peak_ram/network_simplex_taxi_new_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_20000_instance.txt  20000  20000) &> peak_ram/network_simplex_taxi_new_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_25000_instance.txt  25000  1000 ) &> peak_ram/network_simplex_taxi_new_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_25000_instance.txt  25000  5000 ) &> peak_ram/network_simplex_taxi_new_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_25000_instance.txt  25000  10000) &> peak_ram/network_simplex_taxi_new_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_25000_instance.txt  25000  15000) &> peak_ram/network_simplex_taxi_new_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_25000_instance.txt  25000  20000) &> peak_ram/network_simplex_taxi_new_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./network_simplex data/TAXI_new_25000_instance.txt  25000  25000) &> peak_ram/network_simplex_taxi_new_25000_25000.txt

# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_5000_instance.txt   5000  1000 )  &> peak_ram/ssp_dijkstra_taxi_new_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_5000_instance.txt   5000  5000 )  &> peak_ram/ssp_dijkstra_taxi_new_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_10000_instance.txt  10000  1000 ) &> peak_ram/ssp_dijkstra_taxi_new_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_10000_instance.txt  10000  5000 ) &> peak_ram/ssp_dijkstra_taxi_new_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_10000_instance.txt  10000  10000) &> peak_ram/ssp_dijkstra_taxi_new_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_15000_instance.txt  15000  1000 ) &> peak_ram/ssp_dijkstra_taxi_new_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_15000_instance.txt  15000  5000 ) &> peak_ram/ssp_dijkstra_taxi_new_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_15000_instance.txt  15000  10000) &> peak_ram/ssp_dijkstra_taxi_new_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_15000_instance.txt  15000  15000) &> peak_ram/ssp_dijkstra_taxi_new_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_20000_instance.txt  20000  1000 ) &> peak_ram/ssp_dijkstra_taxi_new_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_20000_instance.txt  20000  5000 ) &> peak_ram/ssp_dijkstra_taxi_new_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_20000_instance.txt  20000  10000) &> peak_ram/ssp_dijkstra_taxi_new_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_20000_instance.txt  20000  15000) &> peak_ram/ssp_dijkstra_taxi_new_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_20000_instance.txt  20000  20000) &> peak_ram/ssp_dijkstra_taxi_new_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_25000_instance.txt  25000  1000 ) &> peak_ram/ssp_dijkstra_taxi_new_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_25000_instance.txt  25000  5000 ) &> peak_ram/ssp_dijkstra_taxi_new_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_25000_instance.txt  25000  10000) &> peak_ram/ssp_dijkstra_taxi_new_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_25000_instance.txt  25000  15000) &> peak_ram/ssp_dijkstra_taxi_new_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_25000_instance.txt  25000  20000) &> peak_ram/ssp_dijkstra_taxi_new_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./ssp_dijkstra data/TAXI_new_25000_instance.txt  25000  25000) &> peak_ram/ssp_dijkstra_taxi_new_25000_25000.txt


# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_5000_instance.txt   5000  1000 )  &> peak_ram/cost_scaling_taxi_new_5000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_5000_instance.txt   5000  5000 )  &> peak_ram/cost_scaling_taxi_new_5000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_10000_instance.txt  10000  1000 ) &> peak_ram/cost_scaling_taxi_new_10000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_10000_instance.txt  10000  5000 ) &> peak_ram/cost_scaling_taxi_new_10000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_10000_instance.txt  10000  10000) &> peak_ram/cost_scaling_taxi_new_10000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_15000_instance.txt  15000  1000 ) &> peak_ram/cost_scaling_taxi_new_15000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_15000_instance.txt  15000  5000 ) &> peak_ram/cost_scaling_taxi_new_15000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_15000_instance.txt  15000  10000) &> peak_ram/cost_scaling_taxi_new_15000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_15000_instance.txt  15000  15000) &> peak_ram/cost_scaling_taxi_new_15000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_20000_instance.txt  20000  1000 ) &> peak_ram/cost_scaling_taxi_new_20000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_20000_instance.txt  20000  5000 ) &> peak_ram/cost_scaling_taxi_new_20000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_20000_instance.txt  20000  10000) &> peak_ram/cost_scaling_taxi_new_20000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_20000_instance.txt  20000  15000) &> peak_ram/cost_scaling_taxi_new_20000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_20000_instance.txt  20000  20000) &> peak_ram/cost_scaling_taxi_new_20000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_25000_instance.txt  25000  1000 ) &> peak_ram/cost_scaling_taxi_new_25000_1000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_25000_instance.txt  25000  5000 ) &> peak_ram/cost_scaling_taxi_new_25000_5000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_25000_instance.txt  25000  10000) &> peak_ram/cost_scaling_taxi_new_25000_10000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_25000_instance.txt  25000  15000) &> peak_ram/cost_scaling_taxi_new_25000_15000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_25000_instance.txt  25000  20000) &> peak_ram/cost_scaling_taxi_new_25000_20000.txt
# (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling data/TAXI_new_25000_instance.txt  25000  25000) &> peak_ram/cost_scaling_taxi_new_25000_25000.txt



