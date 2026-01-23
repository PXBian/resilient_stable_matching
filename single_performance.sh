#!/bin/bash

# 加载 Rust 环境（如果存在）
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

mkdir peak_ram
gunzip data/*.gz

make total


# (/usr/bin/time -v ./total data/max_rot_5000.txt  5000  1000 ) &> peak_ram/total_rot_5000_1000.txt
# (/usr/bin/time -v ./total data/max_rot_5000.txt  5000  2000 ) &> peak_ram/total_rot_5000_2000.txt
# (/usr/bin/time -v ./total data/max_rot_5000.txt  5000  3000 ) &> peak_ram/total_rot_5000_3000.txt
# (/usr/bin/time -v ./total data/max_rot_5000.txt  5000  4000 ) &> peak_ram/total_rot_5000_4000.txt
# (/usr/bin/time -v ./total data/max_rot_5000.txt  5000  5000 ) &> peak_ram/total_rot_5000_5000.txt

# (/usr/bin/time -v ./total data/max_rot_10000.txt  10000  1000 ) &> peak_ram/total_rot_10000_1000.txt
# (/usr/bin/time -v ./total data/max_rot_10000.txt  10000  2000 ) &> peak_ram/total_rot_10000_2000.txt
# (/usr/bin/time -v ./total data/max_rot_10000.txt  10000  3000 ) &> peak_ram/total_rot_10000_3000.txt
# (/usr/bin/time -v ./total data/max_rot_10000.txt  10000  4000 ) &> peak_ram/total_rot_10000_4000.txt
# (/usr/bin/time -v ./total data/max_rot_10000.txt  10000  5000 ) &> peak_ram/total_rot_10000_5000.txt
# (/usr/bin/time -v ./total data/max_rot_10000.txt  10000  6000 ) &> peak_ram/total_rot_10000_6000.txt
# (/usr/bin/time -v ./total data/max_rot_10000.txt  10000  7000 ) &> peak_ram/total_rot_10000_7000.txt
# (/usr/bin/time -v ./total data/max_rot_10000.txt  10000  8000 ) &> peak_ram/total_rot_10000_8000.txt
# (/usr/bin/time -v ./total data/max_rot_10000.txt  10000  9000 ) &> peak_ram/total_rot_10000_9000.txt
# (/usr/bin/time -v ./total data/max_rot_10000.txt  10000  10000) &> peak_ram/total_rot_10000_10000.txt

# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  1000 ) &> peak_ram/total_rot_15000_1000.txt
# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  2000 ) &> peak_ram/total_rot_15000_2000.txt
# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  3000 ) &> peak_ram/total_rot_15000_3000.txt
# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  4000 ) &> peak_ram/total_rot_15000_4000.txt
# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  5000 ) &> peak_ram/total_rot_15000_5000.txt
# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  6000 ) &> peak_ram/total_rot_15000_6000.txt
# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  7000 ) &> peak_ram/total_rot_15000_7000.txt
# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  8000 ) &> peak_ram/total_rot_15000_8000.txt
# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  9000 ) &> peak_ram/total_rot_15000_9000.txt
# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  10000) &> peak_ram/total_rot_15000_10000.txt
# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  11000) &> peak_ram/total_rot_15000_11000.txt
# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  12000) &> peak_ram/total_rot_15000_12000.txt
# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  13000) &> peak_ram/total_rot_15000_13000.txt
# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  14000) &> peak_ram/total_rot_15000_14000.txt
# (/usr/bin/time -v ./total data/max_rot_15000.txt  15000  15000) &> peak_ram/total_rot_15000_15000.txt

# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  1000 ) &> peak_ram/total_rot_20000_1000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  2000 ) &> peak_ram/total_rot_20000_2000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  3000 ) &> peak_ram/total_rot_20000_3000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  4000 ) &> peak_ram/total_rot_20000_4000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  5000 ) &> peak_ram/total_rot_20000_5000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  6000 ) &> peak_ram/total_rot_20000_6000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  7000 ) &> peak_ram/total_rot_20000_7000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  8000 ) &> peak_ram/total_rot_20000_8000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  9000 ) &> peak_ram/total_rot_20000_9000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  10000) &> peak_ram/total_rot_20000_10000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  11000) &> peak_ram/total_rot_20000_11000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  12000) &> peak_ram/total_rot_20000_12000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  13000) &> peak_ram/total_rot_20000_13000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  14000) &> peak_ram/total_rot_20000_14000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  15000) &> peak_ram/total_rot_20000_15000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  16000) &> peak_ram/total_rot_20000_16000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  17000) &> peak_ram/total_rot_20000_17000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  18000) &> peak_ram/total_rot_20000_18000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  19000) &> peak_ram/total_rot_20000_19000.txt
# (/usr/bin/time -v ./total data/max_rot_20000.txt  20000  20000) &> peak_ram/total_rot_20000_20000.txt

# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  1000 ) &> peak_ram/total_rot_25000_1000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  2000 ) &> peak_ram/total_rot_25000_2000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  3000 ) &> peak_ram/total_rot_25000_3000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  4000 ) &> peak_ram/total_rot_25000_4000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  5000 ) &> peak_ram/total_rot_25000_5000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  6000 ) &> peak_ram/total_rot_25000_6000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  7000 ) &> peak_ram/total_rot_25000_7000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  8000 ) &> peak_ram/total_rot_25000_8000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  9000 ) &> peak_ram/total_rot_25000_9000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  10000) &> peak_ram/total_rot_25000_10000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  11000) &> peak_ram/total_rot_25000_11000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  12000) &> peak_ram/total_rot_25000_12000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  13000) &> peak_ram/total_rot_25000_13000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  14000) &> peak_ram/total_rot_25000_14000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  15000) &> peak_ram/total_rot_25000_15000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  16000) &> peak_ram/total_rot_25000_16000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  17000) &> peak_ram/total_rot_25000_17000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  18000) &> peak_ram/total_rot_25000_18000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  19000) &> peak_ram/total_rot_25000_19000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  20000) &> peak_ram/total_rot_25000_20000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  21000) &> peak_ram/total_rot_25000_21000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  22000) &> peak_ram/total_rot_25000_22000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  23000) &> peak_ram/total_rot_25000_23000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  24000) &> peak_ram/total_rot_25000_24000.txt
# (/usr/bin/time -v ./total data/max_rot_25000.txt  25000  25000) &> peak_ram/total_rot_25000_25000.txt

# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  1000 ) &> peak_ram/total_rot_30000_1000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  2000 ) &> peak_ram/total_rot_30000_2000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  3000 ) &> peak_ram/total_rot_30000_3000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  4000 ) &> peak_ram/total_rot_30000_4000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  5000 ) &> peak_ram/total_rot_30000_5000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  6000 ) &> peak_ram/total_rot_30000_6000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  7000 ) &> peak_ram/total_rot_30000_7000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  8000 ) &> peak_ram/total_rot_30000_8000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  9000 ) &> peak_ram/total_rot_30000_9000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  10000) &> peak_ram/total_rot_30000_10000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  11000) &> peak_ram/total_rot_30000_11000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  12000) &> peak_ram/total_rot_30000_12000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  13000) &> peak_ram/total_rot_30000_13000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  14000) &> peak_ram/total_rot_30000_14000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  15000) &> peak_ram/total_rot_30000_15000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  16000) &> peak_ram/total_rot_30000_16000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  17000) &> peak_ram/total_rot_30000_17000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  18000) &> peak_ram/total_rot_30000_18000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  19000) &> peak_ram/total_rot_30000_19000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  20000) &> peak_ram/total_rot_30000_20000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  21000) &> peak_ram/total_rot_30000_21000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  22000) &> peak_ram/total_rot_30000_22000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  23000) &> peak_ram/total_rot_30000_23000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  24000) &> peak_ram/total_rot_30000_24000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  25000) &> peak_ram/total_rot_30000_25000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  26000) &> peak_ram/total_rot_30000_26000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  27000) &> peak_ram/total_rot_30000_27000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  28000) &> peak_ram/total_rot_30000_28000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  29000) &> peak_ram/total_rot_30000_29000.txt
# (/usr/bin/time -v ./total data/max_rot_30000.txt  30000  30000) &> peak_ram/total_rot_30000_30000.txt

# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  1000 ) &> peak_ram/total_rot_35000_1000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  2000 ) &> peak_ram/total_rot_35000_2000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  3000 ) &> peak_ram/total_rot_35000_3000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  4000 ) &> peak_ram/total_rot_35000_4000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  5000 ) &> peak_ram/total_rot_35000_5000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  6000 ) &> peak_ram/total_rot_35000_6000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  7000 ) &> peak_ram/total_rot_35000_7000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  8000 ) &> peak_ram/total_rot_35000_8000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  9000 ) &> peak_ram/total_rot_35000_9000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  10000) &> peak_ram/total_rot_35000_10000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  11000) &> peak_ram/total_rot_35000_11000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  12000) &> peak_ram/total_rot_35000_12000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  13000) &> peak_ram/total_rot_35000_13000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  14000) &> peak_ram/total_rot_35000_14000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  15000) &> peak_ram/total_rot_35000_15000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  16000) &> peak_ram/total_rot_35000_16000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  17000) &> peak_ram/total_rot_35000_17000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  18000) &> peak_ram/total_rot_35000_18000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  19000) &> peak_ram/total_rot_35000_19000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  20000) &> peak_ram/total_rot_35000_20000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  21000) &> peak_ram/total_rot_35000_21000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  22000) &> peak_ram/total_rot_35000_22000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  23000) &> peak_ram/total_rot_35000_23000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  24000) &> peak_ram/total_rot_35000_24000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  25000) &> peak_ram/total_rot_35000_25000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  26000) &> peak_ram/total_rot_35000_26000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  27000) &> peak_ram/total_rot_35000_27000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  28000) &> peak_ram/total_rot_35000_28000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  29000) &> peak_ram/total_rot_35000_29000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  30000) &> peak_ram/total_rot_35000_30000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  31000) &> peak_ram/total_rot_35000_31000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  32000) &> peak_ram/total_rot_35000_32000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  33000) &> peak_ram/total_rot_35000_33000.txt
# (/usr/bin/time -v ./total data/max_rot_35000.txt  35000  34000) &> peak_ram/total_rot_35000_34000.txt
(/usr/bin/time -v ./total data/max_rot_35000.txt  35000  35000) &> peak_ram/total_rot_35000_35000.txt

# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  1000 ) &> peak_ram/total_rot_40000_1000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  2000 ) &> peak_ram/total_rot_40000_2000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  3000 ) &> peak_ram/total_rot_40000_3000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  4000 ) &> peak_ram/total_rot_40000_4000.txt
(/usr/bin/time -v ./total data/max_rot_40000.txt  40000  5000 ) &> peak_ram/total_rot_40000_5000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  6000 ) &> peak_ram/total_rot_40000_6000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  7000 ) &> peak_ram/total_rot_40000_7000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  8000 ) &> peak_ram/total_rot_40000_8000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  9000 ) &> peak_ram/total_rot_40000_9000.txt
(/usr/bin/time -v ./total data/max_rot_40000.txt  40000  10000) &> peak_ram/total_rot_40000_10000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  11000) &> peak_ram/total_rot_40000_11000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  12000) &> peak_ram/total_rot_40000_12000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  13000) &> peak_ram/total_rot_40000_13000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  14000) &> peak_ram/total_rot_40000_14000.txt
(/usr/bin/time -v ./total data/max_rot_40000.txt  40000  15000) &> peak_ram/total_rot_40000_15000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  16000) &> peak_ram/total_rot_40000_16000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  17000) &> peak_ram/total_rot_40000_17000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  18000) &> peak_ram/total_rot_40000_18000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  19000) &> peak_ram/total_rot_40000_19000.txt
(/usr/bin/time -v ./total data/max_rot_40000.txt  40000  20000) &> peak_ram/total_rot_40000_20000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  21000) &> peak_ram/total_rot_40000_21000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  22000) &> peak_ram/total_rot_40000_22000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  23000) &> peak_ram/total_rot_40000_23000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  24000) &> peak_ram/total_rot_40000_24000.txt
(/usr/bin/time -v ./total data/max_rot_40000.txt  40000  25000) &> peak_ram/total_rot_40000_25000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  26000) &> peak_ram/total_rot_40000_26000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  27000) &> peak_ram/total_rot_40000_27000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  28000) &> peak_ram/total_rot_40000_28000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  29000) &> peak_ram/total_rot_40000_29000.txt
(/usr/bin/time -v ./total data/max_rot_40000.txt  40000  30000) &> peak_ram/total_rot_40000_30000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  31000) &> peak_ram/total_rot_40000_31000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  32000) &> peak_ram/total_rot_40000_32000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  33000) &> peak_ram/total_rot_40000_33000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  34000) &> peak_ram/total_rot_40000_34000.txt
(/usr/bin/time -v ./total data/max_rot_40000.txt  40000  35000) &> peak_ram/total_rot_40000_35000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  36000) &> peak_ram/total_rot_40000_36000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  37000) &> peak_ram/total_rot_40000_37000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  38000) &> peak_ram/total_rot_40000_38000.txt
# (/usr/bin/time -v ./total data/max_rot_40000.txt  40000  39000) &> peak_ram/total_rot_40000_39000.txt
(/usr/bin/time -v ./total data/max_rot_40000.txt  40000  40000) &> peak_ram/total_rot_40000_40000.txt

# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  1000 ) &> peak_ram/total_rot_45000_1000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  2000 ) &> peak_ram/total_rot_45000_2000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  3000 ) &> peak_ram/total_rot_45000_3000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  4000 ) &> peak_ram/total_rot_45000_4000.txt
(/usr/bin/time -v ./total data/max_rot_45000.txt  45000  5000 ) &> peak_ram/total_rot_45000_5000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  6000 ) &> peak_ram/total_rot_45000_6000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  7000 ) &> peak_ram/total_rot_45000_7000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  8000 ) &> peak_ram/total_rot_45000_8000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  9000 ) &> peak_ram/total_rot_45000_9000.txt
(/usr/bin/time -v ./total data/max_rot_45000.txt  45000  10000) &> peak_ram/total_rot_45000_10000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  11000) &> peak_ram/total_rot_45000_11000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  12000) &> peak_ram/total_rot_45000_12000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  13000) &> peak_ram/total_rot_45000_13000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  14000) &> peak_ram/total_rot_45000_14000.txt
(/usr/bin/time -v ./total data/max_rot_45000.txt  45000  15000) &> peak_ram/total_rot_45000_15000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  16000) &> peak_ram/total_rot_45000_16000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  17000) &> peak_ram/total_rot_45000_17000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  18000) &> peak_ram/total_rot_45000_18000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  19000) &> peak_ram/total_rot_45000_19000.txt
(/usr/bin/time -v ./total data/max_rot_45000.txt  45000  20000) &> peak_ram/total_rot_45000_20000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  21000) &> peak_ram/total_rot_45000_21000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  22000) &> peak_ram/total_rot_45000_22000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  23000) &> peak_ram/total_rot_45000_23000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  24000) &> peak_ram/total_rot_45000_24000.txt
(/usr/bin/time -v ./total data/max_rot_45000.txt  45000  25000) &> peak_ram/total_rot_45000_25000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  26000) &> peak_ram/total_rot_45000_26000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  27000) &> peak_ram/total_rot_45000_27000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  28000) &> peak_ram/total_rot_45000_28000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  29000) &> peak_ram/total_rot_45000_29000.txt
(/usr/bin/time -v ./total data/max_rot_45000.txt  45000  30000) &> peak_ram/total_rot_45000_30000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  31000) &> peak_ram/total_rot_45000_31000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  32000) &> peak_ram/total_rot_45000_32000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  33000) &> peak_ram/total_rot_45000_33000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  34000) &> peak_ram/total_rot_45000_34000.txt
(/usr/bin/time -v ./total data/max_rot_45000.txt  45000  35000) &> peak_ram/total_rot_45000_35000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  36000) &> peak_ram/total_rot_45000_36000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  37000) &> peak_ram/total_rot_45000_37000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  38000) &> peak_ram/total_rot_45000_38000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  39000) &> peak_ram/total_rot_45000_39000.txt
(/usr/bin/time -v ./total data/max_rot_45000.txt  45000  40000) &> peak_ram/total_rot_45000_40000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  41000) &> peak_ram/total_rot_45000_41000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  42000) &> peak_ram/total_rot_45000_42000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  43000) &> peak_ram/total_rot_45000_43000.txt
# (/usr/bin/time -v ./total data/max_rot_45000.txt  45000  44000) &> peak_ram/total_rot_45000_44000.txt
(/usr/bin/time -v ./total data/max_rot_45000.txt  45000  45000) &> peak_ram/total_rot_45000_45000.txt

