#!/bin/bash

# 加载 Rust 环境（如果存在）
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

mkdir -p peak_ram
gunzip data/*.gz 2>/dev/null

make capacity_scaling
make network_simplex
make cost_scaling
make ssp_dijkstra
make heuristic

(/usr/bin/time -v ./capacity_scaling data/ADM_rand_1000_instance.txt  1000  1000 ) &> peak_ram/capacity_scaling_adm_rand_1000_1000.txt

(/usr/bin/time -v ./capacity_scaling data/ADM_rand_2000_instance.txt  2000  1000 ) &> peak_ram/capacity_scaling_adm_rand_2000_1000.txt
(/usr/bin/time -v ./capacity_scaling data/ADM_rand_2000_instance.txt  2000  2000 ) &> peak_ram/capacity_scaling_adm_rand_2000_2000.txt

(/usr/bin/time -v ./capacity_scaling data/ADM_rand_3000_instance.txt  3000  1000 ) &> peak_ram/capacity_scaling_adm_rand_3000_1000.txt
(/usr/bin/time -v ./capacity_scaling data/ADM_rand_3000_instance.txt  3000  2000 ) &> peak_ram/capacity_scaling_adm_rand_3000_2000.txt
(/usr/bin/time -v ./capacity_scaling data/ADM_rand_3000_instance.txt  3000  3000 ) &> peak_ram/capacity_scaling_adm_rand_3000_3000.txt

(/usr/bin/time -v ./capacity_scaling data/ADM_rand_4000_instance.txt  4000  1000 ) &> peak_ram/capacity_scaling_adm_rand_4000_1000.txt
(/usr/bin/time -v ./capacity_scaling data/ADM_rand_4000_instance.txt  4000  2000 ) &> peak_ram/capacity_scaling_adm_rand_4000_2000.txt
(/usr/bin/time -v ./capacity_scaling data/ADM_rand_4000_instance.txt  4000  3000 ) &> peak_ram/capacity_scaling_adm_rand_4000_3000.txt
(/usr/bin/time -v ./capacity_scaling data/ADM_rand_4000_instance.txt  4000  4000 ) &> peak_ram/capacity_scaling_adm_rand_4000_4000.txt

(/usr/bin/time -v ./capacity_scaling data/ADM_rand_5000_instance.txt  5000  1000 ) &> peak_ram/capacity_scaling_adm_rand_5000_1000.txt
(/usr/bin/time -v ./capacity_scaling data/ADM_rand_5000_instance.txt  5000  2000 ) &> peak_ram/capacity_scaling_adm_rand_5000_2000.txt
(/usr/bin/time -v ./capacity_scaling data/ADM_rand_5000_instance.txt  5000  3000 ) &> peak_ram/capacity_scaling_adm_rand_5000_3000.txt
(/usr/bin/time -v ./capacity_scaling data/ADM_rand_5000_instance.txt  5000  4000 ) &> peak_ram/capacity_scaling_adm_rand_5000_4000.txt
(/usr/bin/time -v ./capacity_scaling data/ADM_rand_5000_instance.txt  5000  5000 ) &> peak_ram/capacity_scaling_adm_rand_5000_5000.txt

(/usr/bin/time -v ./network_simplex data/ADM_rand_1000_instance.txt  1000  1000 ) &> peak_ram/network_simplex_adm_rand_1000_1000.txt

(/usr/bin/time -v ./network_simplex data/ADM_rand_2000_instance.txt  2000  1000 ) &> peak_ram/network_simplex_adm_rand_2000_1000.txt
(/usr/bin/time -v ./network_simplex data/ADM_rand_2000_instance.txt  2000  2000 ) &> peak_ram/network_simplex_adm_rand_2000_2000.txt

(/usr/bin/time -v ./network_simplex data/ADM_rand_3000_instance.txt  3000  1000 ) &> peak_ram/network_simplex_adm_rand_3000_1000.txt
(/usr/bin/time -v ./network_simplex data/ADM_rand_3000_instance.txt  3000  2000 ) &> peak_ram/network_simplex_adm_rand_3000_2000.txt
(/usr/bin/time -v ./network_simplex data/ADM_rand_3000_instance.txt  3000  3000 ) &> peak_ram/network_simplex_adm_rand_3000_3000.txt

(/usr/bin/time -v ./network_simplex data/ADM_rand_4000_instance.txt  4000  1000 ) &> peak_ram/network_simplex_adm_rand_4000_1000.txt
(/usr/bin/time -v ./network_simplex data/ADM_rand_4000_instance.txt  4000  2000 ) &> peak_ram/network_simplex_adm_rand_4000_2000.txt
(/usr/bin/time -v ./network_simplex data/ADM_rand_4000_instance.txt  4000  3000 ) &> peak_ram/network_simplex_adm_rand_4000_3000.txt
(/usr/bin/time -v ./network_simplex data/ADM_rand_4000_instance.txt  4000  4000 ) &> peak_ram/network_simplex_adm_rand_4000_4000.txt

(/usr/bin/time -v ./network_simplex data/ADM_rand_5000_instance.txt  5000  1000 ) &> peak_ram/network_simplex_adm_rand_5000_1000.txt
(/usr/bin/time -v ./network_simplex data/ADM_rand_5000_instance.txt  5000  2000 ) &> peak_ram/network_simplex_adm_rand_5000_2000.txt
(/usr/bin/time -v ./network_simplex data/ADM_rand_5000_instance.txt  5000  3000 ) &> peak_ram/network_simplex_adm_rand_5000_3000.txt
(/usr/bin/time -v ./network_simplex data/ADM_rand_5000_instance.txt  5000  4000 ) &> peak_ram/network_simplex_adm_rand_5000_4000.txt
(/usr/bin/time -v ./network_simplex data/ADM_rand_5000_instance.txt  5000  5000 ) &> peak_ram/network_simplex_adm_rand_5000_5000.txt

(/usr/bin/time -v ./cost_scaling data/ADM_rand_1000_instance.txt  1000  1000 ) &> peak_ram/cost_scaling_adm_rand_1000_1000.txt

(/usr/bin/time -v ./cost_scaling data/ADM_rand_2000_instance.txt  2000  1000 ) &> peak_ram/cost_scaling_adm_rand_2000_1000.txt
(/usr/bin/time -v ./cost_scaling data/ADM_rand_2000_instance.txt  2000  2000 ) &> peak_ram/cost_scaling_adm_rand_2000_2000.txt

(/usr/bin/time -v ./cost_scaling data/ADM_rand_3000_instance.txt  3000  1000 ) &> peak_ram/cost_scaling_adm_rand_3000_1000.txt
(/usr/bin/time -v ./cost_scaling data/ADM_rand_3000_instance.txt  3000  2000 ) &> peak_ram/cost_scaling_adm_rand_3000_2000.txt
(/usr/bin/time -v ./cost_scaling data/ADM_rand_3000_instance.txt  3000  3000 ) &> peak_ram/cost_scaling_adm_rand_3000_3000.txt

(/usr/bin/time -v ./cost_scaling data/ADM_rand_4000_instance.txt  4000  1000 ) &> peak_ram/cost_scaling_adm_rand_4000_1000.txt
(/usr/bin/time -v ./cost_scaling data/ADM_rand_4000_instance.txt  4000  2000 ) &> peak_ram/cost_scaling_adm_rand_4000_2000.txt
(/usr/bin/time -v ./cost_scaling data/ADM_rand_4000_instance.txt  4000  3000 ) &> peak_ram/cost_scaling_adm_rand_4000_3000.txt
(/usr/bin/time -v ./cost_scaling data/ADM_rand_4000_instance.txt  4000  4000 ) &> peak_ram/cost_scaling_adm_rand_4000_4000.txt

(/usr/bin/time -v ./cost_scaling data/ADM_rand_5000_instance.txt  5000  1000 ) &> peak_ram/cost_scaling_adm_rand_5000_1000.txt
(/usr/bin/time -v ./cost_scaling data/ADM_rand_5000_instance.txt  5000  2000 ) &> peak_ram/cost_scaling_adm_rand_5000_2000.txt
(/usr/bin/time -v ./cost_scaling data/ADM_rand_5000_instance.txt  5000  3000 ) &> peak_ram/cost_scaling_adm_rand_5000_3000.txt
(/usr/bin/time -v ./cost_scaling data/ADM_rand_5000_instance.txt  5000  4000 ) &> peak_ram/cost_scaling_adm_rand_5000_4000.txt
(/usr/bin/time -v ./cost_scaling data/ADM_rand_5000_instance.txt  5000  5000 ) &> peak_ram/cost_scaling_adm_rand_5000_5000.txt

(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_1000_instance.txt  1000  1000 ) &> peak_ram/ssp_dijkstra_adm_rand_1000_1000.txt

(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_2000_instance.txt  2000  1000 ) &> peak_ram/ssp_dijkstra_adm_rand_2000_1000.txt
(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_2000_instance.txt  2000  2000 ) &> peak_ram/ssp_dijkstra_adm_rand_2000_2000.txt

(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_3000_instance.txt  3000  1000 ) &> peak_ram/ssp_dijkstra_adm_rand_3000_1000.txt
(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_3000_instance.txt  3000  2000 ) &> peak_ram/ssp_dijkstra_adm_rand_3000_2000.txt
(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_3000_instance.txt  3000  3000 ) &> peak_ram/ssp_dijkstra_adm_rand_3000_3000.txt

(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_4000_instance.txt  4000  1000 ) &> peak_ram/ssp_dijkstra_adm_rand_4000_1000.txt
(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_4000_instance.txt  4000  2000 ) &> peak_ram/ssp_dijkstra_adm_rand_4000_2000.txt
(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_4000_instance.txt  4000  3000 ) &> peak_ram/ssp_dijkstra_adm_rand_4000_3000.txt
(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_4000_instance.txt  4000  4000 ) &> peak_ram/ssp_dijkstra_adm_rand_4000_4000.txt

(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_5000_instance.txt  5000  1000 ) &> peak_ram/ssp_dijkstra_adm_rand_5000_1000.txt
(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_5000_instance.txt  5000  2000 ) &> peak_ram/ssp_dijkstra_adm_rand_5000_2000.txt
(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_5000_instance.txt  5000  3000 ) &> peak_ram/ssp_dijkstra_adm_rand_5000_3000.txt
(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_5000_instance.txt  5000  4000 ) &> peak_ram/ssp_dijkstra_adm_rand_5000_4000.txt
(/usr/bin/time -v ./ssp_dijkstra data/ADM_rand_5000_instance.txt  5000  5000 ) &> peak_ram/ssp_dijkstra_adm_rand_5000_5000.txt

(/usr/bin/time -v ./heuristic data/ADM_rand_1000_instance.txt  1000  1000 ) &> peak_ram/heuristic_adm_rand_1000_1000.txt

(/usr/bin/time -v ./heuristic data/ADM_rand_2000_instance.txt  2000  1000 ) &> peak_ram/heuristic_adm_rand_2000_1000.txt
(/usr/bin/time -v ./heuristic data/ADM_rand_2000_instance.txt  2000  2000 ) &> peak_ram/heuristic_adm_rand_2000_2000.txt

(/usr/bin/time -v ./heuristic data/ADM_rand_3000_instance.txt  3000  1000 ) &> peak_ram/heuristic_adm_rand_3000_1000.txt
(/usr/bin/time -v ./heuristic data/ADM_rand_3000_instance.txt  3000  2000 ) &> peak_ram/heuristic_adm_rand_3000_2000.txt
(/usr/bin/time -v ./heuristic data/ADM_rand_3000_instance.txt  3000  3000 ) &> peak_ram/heuristic_adm_rand_3000_3000.txt

(/usr/bin/time -v ./heuristic data/ADM_rand_4000_instance.txt  4000  1000 ) &> peak_ram/heuristic_adm_rand_4000_1000.txt
(/usr/bin/time -v ./heuristic data/ADM_rand_4000_instance.txt  4000  2000 ) &> peak_ram/heuristic_adm_rand_4000_2000.txt
(/usr/bin/time -v ./heuristic data/ADM_rand_4000_instance.txt  4000  3000 ) &> peak_ram/heuristic_adm_rand_4000_3000.txt
(/usr/bin/time -v ./heuristic data/ADM_rand_4000_instance.txt  4000  4000 ) &> peak_ram/heuristic_adm_rand_4000_4000.txt

(/usr/bin/time -v ./heuristic data/ADM_rand_5000_instance.txt  5000  1000 ) &> peak_ram/heuristic_adm_rand_5000_1000.txt
(/usr/bin/time -v ./heuristic data/ADM_rand_5000_instance.txt  5000  2000 ) &> peak_ram/heuristic_adm_rand_5000_2000.txt
(/usr/bin/time -v ./heuristic data/ADM_rand_5000_instance.txt  5000  3000 ) &> peak_ram/heuristic_adm_rand_5000_3000.txt
(/usr/bin/time -v ./heuristic data/ADM_rand_5000_instance.txt  5000  4000 ) &> peak_ram/heuristic_adm_rand_5000_4000.txt
(/usr/bin/time -v ./heuristic data/ADM_rand_5000_instance.txt  5000  5000 ) &> peak_ram/heuristic_adm_rand_5000_5000.txt

