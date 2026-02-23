#!/bin/bash
#SBATCH --mem=350G

# 加载 Rust 环境（如果存在）
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

# 设置超时时间：任何任务运行超过2小时将被终止并跳过
TIMEOUT_DURATION="2h"

mkdir -p no_poset_output
mkdir -p poset_cache
gunzip data/*.gz 2>/dev/null

# 编译所有需要的程序
make save_poset
# make cost_scaling_no_poset
make capacity_scaling_no_poset
make network_simplex_no_poset
make ssp_dijkstra_no_poset
make heuristic_no_poset

# 定义数据集
declare -a datasets=(
#     "TAXI_new"
    # "ADM_new"
    "FOOD"
#     "RAP"
#     "BIKE"
)


# 定义测试用例
declare -a test_cases=(
    "10000 1"
    "10000 10000"
    "20000 1"
    "20000 10000"
    # "20000 15000"
    "20000 20000"
    "30000 1"
    "30000 10000"
    # "30000 15000"
    "30000 20000"
    # "30000 25000"
    "30000 30000"
    "40000 1"
    "40000 10000"
    # "40000 15000"
    "40000 20000"
    # "40000 25000"
    "40000 30000"
    # "40000 35000"
    "40000 40000"
    "50000 1"
    "50000 10000"
    # "50000 15000"
    "50000 20000"
    # "50000 25000"
    "50000 30000"
    # "50000 35000"
    "50000 40000"
    # "50000 45000"
    "50000 50000"
    "60000 1"
    "60000 10000"
    "60000 20000"
    "60000 30000"
    "60000 40000"
    "60000 50000"
    "60000 60000"
)

# 定义方法数组
declare -a methods=(
    "capacity_scaling"
    "heuristic"
    "network_simplex"
    "ssp_dijkstra"
    # "cost_scaling"
)

# 对每个数据集
for dataset in "${datasets[@]}"; do
    echo "Processing dataset: $dataset"
    
    # 根据数据集名称生成前缀
    if [ "$dataset" = "TAXI_new" ]; then
        dataset_prefix="taxi_new"
    elif [ "$dataset" = "ADM_new" ]; then
        dataset_prefix="adm_new"
    else
        dataset_prefix=$(echo "$dataset" | tr '[:upper:]' '[:lower:]')
    fi
    
    # 第一步：先生成所有需要的 poset 文件
    # 由于 poset 只依赖于 dataset 和 n，不依赖于 flowAmount，
    # 我们只需要为每个唯一的 n 值生成一次 poset 文件
    echo "Generating poset files for dataset: $dataset"
    
    for test_case in "${test_cases[@]}"; do
        read -r n flowAmount <<< "$test_case"
        
        # 根据数据集名称生成文件名
        if [ "$dataset" = "TAXI_new" ]; then
            input_file="data/TAXI_new_${n}_instance.txt"
        elif [ "$dataset" = "ADM_new" ]; then
            input_file="data/ADM_new_${n}_instance.txt"
        else
            input_file="data/${dataset}_${n}_instance.txt"
        fi
        
        # Poset 只依赖于 dataset 和 n，不依赖于 flowAmount
        poset_file="poset_cache/poset_${dataset_prefix}_${n}.txt"
        
        # 检查输入文件是否存在
        if [ ! -f "$input_file" ]; then
            echo "Input file not found: $input_file, skipping..."
            continue
        fi
        
        # 如果poset文件不存在，先运行save_poset生成
        # 文件存在性检查会自动避免重复生成
        if [ ! -f "$poset_file" ]; then
            echo "Generating poset file: $poset_file"
            timeout $TIMEOUT_DURATION ./save_poset "$input_file" "$n" "$flowAmount" "$poset_file"
            if [ $? -ne 0 ]; then
                echo "Failed to generate poset file for dataset=$dataset, n=$n, skipping..."
                continue
            fi
        fi
    done
    
    # 第二步：对每种方法，运行所有测试用例
    for method in "${methods[@]}"; do
        echo "Running method: $method for dataset=$dataset"
        
        for test_case in "${test_cases[@]}"; do
            read -r n flowAmount <<< "$test_case"
            
            # Poset 文件路径
            poset_file="poset_cache/poset_${dataset_prefix}_${n}.txt"
            
            # 检查 poset 文件是否存在
            if [ ! -f "$poset_file" ]; then
                echo "Poset file not found: $poset_file, skipping..."
                continue
            fi
            
            echo "Running $method for dataset=$dataset, n=$n, flowAmount=$flowAmount"
            
            # 根据方法名称执行相应的命令
            # if [ "$method" = "cost_scaling" ]; then
            #     # CostScaling 使用 timeout
            #     (timeout $TIMEOUT_DURATION /usr/bin/time -v ./cost_scaling_no_poset "$poset_file") &> output/no_poset_cost_scaling_${dataset_prefix}_${n}_${flowAmount}.txt
            # else
                # 其他方法不使用 timeout
                /usr/bin/time -v ./${method}_no_poset "$poset_file" &> no_poset_output/no_poset_${method}_${dataset_prefix}_${n}_${flowAmount}.txt
            # fi
        done
        
        echo "Completed all test cases for method: $method"
    done
done

echo "All no-poset performance tests completed!"


