#!/bin/bash


# 加载 Rust 环境（如果存在）
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# 设置超时时间：任何任务运行超过1小时将被终止并跳过
TIMEOUT_DURATION="1h"

mkdir -p output_competitor
gunzip data/*.gz 2>/dev/null

# 编译所有需要的程序
make capacity_scaling
make network_simplex
make ssp_dijkstra
make heuristic
make competitor

# 定义数据集
declare -a datasets=(
    "TAXI_new"
    "FOOD"
    "RAP"
    "BIKE"
    "ADM_new"
)

# 只测试 flowAmount=1
declare -a test_cases=(
    "10000 1"
    "20000 1"
    "30000 1"
    "40000 1"
    "50000 1"
    "60000 1"
)

# 定义方法数组（包含 competitor）
declare -a methods=(
    "heuristic"
    "capacity_scaling"
    "network_simplex"
    "ssp_dijkstra"
    "competitor"
)

# 对每个数据集
for dataset in "${datasets[@]}"; do
    echo "Processing dataset: $dataset"
    dataset_lower=$(echo "$dataset" | tr '[:upper:]' '[:lower:]')

    # 对每种方法
    for method in "${methods[@]}"; do
        echo "Running method: $method for dataset=$dataset"

        # 对每个测试用例
        for test_case in "${test_cases[@]}"; do
            read -r n flowAmount <<< "$test_case"

            input_file="data/${dataset}_${n}_instance.txt"

            if [ ! -f "$input_file" ]; then
                echo "Input file not found: $input_file, skipping..."
                continue
            fi

            echo "Running $method for dataset=$dataset, n=$n, flowAmount=$flowAmount"
            if [ "$method" = "competitor" ]; then
                /usr/bin/time -v ./competitor "$input_file" "$n" &> output_competitor/${method}_${dataset_lower}_rand_${n}_${flowAmount}.txt
            else
                /usr/bin/time -v ./${method} "$input_file" "$n" "$flowAmount" &> output_competitor/${method}_${dataset_lower}_rand_${n}_${flowAmount}.txt
            fi
        done

        echo "Completed all test cases for method: $method"
    done
done

echo "All performance tests completed!"
