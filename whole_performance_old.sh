#!/bin/bash
#SBATCH --mem=350G
#SBATCH --time=2-00:00:00

# 加载 Rust 环境（如果存在）
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# 设置超时时间：任何任务运行超过1小时将被终止并跳过
TIMEOUT_DURATION="1h"

mkdir -p output
gunzip data/*.gz 2>/dev/null

# 编译所有需要的程序
make capacity_scaling
make network_simplex
make cost_scaling
make ssp_dijkstra
make heuristic

定义数据集
declare -a datasets=(
    # "TAXI_new"
    # "ADM_new"
    "FOOD"
    "RAP"
    # "BIKE"
)


# 定义测试用例
declare -a test_cases=(
    # "10000 5000"
    # "10000 10000"
    # "20000 5000"
    # "20000 10000"
    # # "20000 15000"
    # "20000 20000"
    # "30000 5000"
    # "30000 10000"
    # # "30000 15000"
    # "30000 20000"
    # # "30000 25000"
    # "30000 30000"
    # "40000 5000"
    # "40000 10000"
    # # "40000 15000"
    # "40000 20000"
    # # "40000 25000"
    # "40000 30000"
    # # "40000 35000"
    # "40000 40000"
    # "50000 5000"
    # "50000 10000"
    # # "50000 15000"
    # "50000 20000"
    # # "50000 25000"
    # "50000 30000"
    # # "50000 35000"
    # "50000 40000"
    # # "50000 45000"
    # "50000 50000"
    # "60000 5000"
    # "60000 10000"
    "60000 15000"
    # "60000 20000"
    "60000 25000"
    # "60000 30000"
    "60000 35000"
    # "60000 40000"
    "60000 45000"
    # "60000 50000"
    "60000 55000"
    # "60000 60000"
)

# 定义方法数组
declare -a methods=(
    "capacity_scaling"
    "heuristic"
    "network_simplex"
    "ssp_dijkstra"
    "cost_scaling"
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
            
            # 根据数据集名称生成文件名
            input_file="data/${dataset}_${n}_instance.txt"
            
            # 检查输入文件是否存在
            if [ ! -f "$input_file" ]; then
                echo "Input file not found: $input_file, skipping..."
                continue
            fi
            
            echo "Running $method for dataset=$dataset, n=$n, flowAmount=$flowAmount"
            
            # 根据方法名称执行相应的命令
            if [ "$method" = "cost_scaling" ]; then
                # CostScaling 使用 timeout
                (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling "$input_file" "$n" "$flowAmount") &> output/cost_scaling_${dataset_lower}_rand_${n}_${flowAmount}.txt
            else
                # 其他方法不使用 timeout
                /usr/bin/time -v ./${method} "$input_file" "$n" "$flowAmount" &> output/${method}_${dataset_lower}_rand_${n}_${flowAmount}.txt
            fi
        done
        
        echo "Completed all test cases for method: $method"
    done
done

echo "All performance tests completed!"



