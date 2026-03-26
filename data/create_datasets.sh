#!/usr/bin/env bash
#SBATCH --mem=200G

set -eu

# python3 gen_instance_TAXI.py --csv raw/TAXI_raw.csv -n 5000  --sample-rows --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_5000_instance.txt
# python3 gen_instance_TAXI.py --csv raw/TAXI_raw.csv -n 10000 --sample-rows --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_10000_instance.txt
# python3 gen_instance_TAXI.py --csv raw/TAXI_raw.csv -n 15000 --sample-rows --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_15000_instance.txt
# python3 gen_instance_TAXI.py --csv raw/TAXI_raw.csv -n 20000 --sample-rows --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_20000_instance.txt
# python3 gen_instance_TAXI.py --csv raw/TAXI_raw.csv -n 25000 --sample-rows --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_25000_instance.txt

# New TAXI generator (drivers ↔ orders, rotation-friendly)
# # python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 5000  --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_5000_instance.txt
# python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 10000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_10000_instance.txt
# # python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 15000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_15000_instance.txt
# python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 20000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_20000_instance.txt
# # python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 25000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_25000_instance.txt
# python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 30000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_30000_instance.txt


# python3 gen_instance_FOOD_augmented.py --ratings raw/FOOD_rating_final.csv --users raw/FOOD_userprofile.csv --places raw/FOOD_geoplaces2.csv -n 5000  --seed 42 --temp-x 0.9 --temp-y 0.9 --unrated-baseline 0.0 --strategy top --out-txt FOOD_5000_instance.txt  --augment true
# python3 gen_instance_FOOD_augmented.py --ratings raw/FOOD_rating_final.csv --users raw/FOOD_userprofile.csv --places raw/FOOD_geoplaces2.csv -n 10000 --seed 42 --temp-x 0.9 --temp-y 0.9 --unrated-baseline 0.0 --strategy top --out-txt FOOD_10000_instance.txt --augment true
# python3 gen_instance_FOOD_augmented.py --ratings raw/FOOD_rating_final.csv --users raw/FOOD_userprofile.csv --places raw/FOOD_geoplaces2.csv -n 15000 --seed 42 --temp-x 0.9 --temp-y 0.9 --unrated-baseline 0.0 --strategy top --out-txt FOOD_15000_instance.txt --augment true
# python3 gen_instance_FOOD_augmented.py --ratings raw/FOOD_rating_final.csv --users raw/FOOD_userprofile.csv --places raw/FOOD_geoplaces2.csv -n 20000 --seed 42 --temp-x 0.9 --temp-y 0.9 --unrated-baseline 0.0 --strategy top --out-txt FOOD_20000_instance.txt --augment true
# python3 gen_instance_FOOD_augmented.py --ratings raw/FOOD_rating_final.csv --users raw/FOOD_userprofile.csv --places raw/FOOD_geoplaces2.csv -n 25000 --seed 42 --temp-x 0.9 --temp-y 0.9 --unrated-baseline 0.0 --strategy top --out-txt FOOD_25000_instance.txt --augment true
# python3 gen_instance_FOOD_augmented.py --ratings raw/FOOD_rating_final.csv --users raw/FOOD_userprofile.csv --places raw/FOOD_geoplaces2.csv -n 30000 --seed 42 --temp-x 0.9 --temp-y 0.9 --unrated-baseline 0.0 --strategy top --out-txt FOOD_30000_instance.txt --augment true


# python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 5000  --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_5000_instance.txt --augment true
python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 10000 --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_10000_instance.txt --augment true
# python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 15000 --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_15000_instance.txt --augment true
python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 20000 --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_20000_instance.txt --augment true
# python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 25000 --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_25000_instance.txt --augment true
python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 30000 --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_30000_instance.txt --augment true

# # python3 gen_instance_BIKE_augmented.py --csv raw/metro-trips-2025-q4.csv -n 5000  --seed 42 --temp-x 0.9 --temp-y 0.9 --individual-noise 0.4 --sample-bikes --augment true --out-txt BIKE_5000_instance.txt
# python3 gen_instance_BIKE_augmented.py --csv raw/metro-trips-2025-q4.csv -n 10000 --seed 42 --temp-x 0.9 --temp-y 0.9 --individual-noise 0.4 --sample-bikes --augment true --out-txt BIKE_10000_instance.txt
# # python3 gen_instance_BIKE_augmented.py --csv raw/metro-trips-2025-q4.csv -n 15000 --seed 42 --temp-x 0.9 --temp-y 0.9 --individual-noise 0.4 --sample-bikes --augment true --out-txt BIKE_15000_instance.txt
# python3 gen_instance_BIKE_augmented.py --csv raw/metro-trips-2025-q4.csv -n 20000 --seed 42 --temp-x 0.9 --temp-y 0.9 --individual-noise 0.4 --sample-bikes --augment true --out-txt BIKE_20000_instance.txt
# # python3 gen_instance_BIKE_augmented.py --csv raw/metro-trips-2025-q4.csv -n 25000 --seed 42 --temp-x 0.9 --temp-y 0.9 --individual-noise 0.4 --sample-bikes --augment true --out-txt BIKE_25000_instance.txt
# python3 gen_instance_BIKE_augmented.py --csv raw/metro-trips-2025-q4.csv -n 30000 --seed 42 --temp-x 0.9 --temp-y 0.9 --individual-noise 0.4 --sample-bikes --augment true --out-txt BIKE_30000_instance.txt

# python3 gen_instance_ADM_augmented_new.py --csv raw/ADM_Norway_raw.csv -n 10000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_new_10000_instance.txt
# python3 gen_instance_ADM_augmented_new.py --csv raw/ADM_Norway_raw.csv -n 20000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_new_20000_instance.txt
# python3 gen_instance_ADM_augmented_new.py --csv raw/ADM_Norway_raw.csv -n 30000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_new_30000_instance.txt
# # python3 gen_instance_ADM_augmented_new.py --csv raw/ADM_Norway_raw.csv -n 40000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_new_40000_instance.txt
# # python3 gen_instance_ADM_augmented_new.py --csv raw/ADM_Norway_raw.csv -n 50000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_new_50000_instance.txt


# python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 40000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_40000_instance.txt
# python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 50000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_50000_instance.txt

# python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 40000 --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_40000_instance.txt --augment true
# python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 50000 --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_50000_instance.txt --augment true

# # Output directory: keep artifacts under submit dir, not /tmp.
# BASE_DIR="${SLURM_SUBMIT_DIR:-$(pwd)}"
# RUN_ID="${SLURM_JOB_ID:-$(date +%Y%m%d_%H%M%S)}"
# OUT_DIR="${BASE_DIR}/results/${RUN_ID}"
# mkdir -p "${OUT_DIR}"
# LOG_FILE="${OUT_DIR}/benchmark.log"
# exec > >(tee -a "${LOG_FILE}") 2>&1
# echo "Run started: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
# echo "Host: $(hostname)"
# echo "Output dir: ${OUT_DIR}"

# WORKERS_N="${WORKERS_N:-8}"

# # # 1) TAXI
# # /usr/bin/time -f "taxi_w1 %E %MKB" python3 gen_instance_TAXI_new.py \
# #   --csv raw/TAXI_raw.csv -n 10000 --sample --seed 42 \
# #   --temp-x 0.9 --temp-y 0.9 --workers 1 \
# #   --out-txt "${OUT_DIR}/taxi_w1.txt"

# # /usr/bin/time -f "taxi_wN %E %MKB" python3 gen_instance_TAXI_new.py \
# #   --csv raw/TAXI_raw.csv -n 10000 --sample --seed 42 \
# #   --temp-x 0.9 --temp-y 0.9 --workers "${WORKERS_N}" \
# #   --out-txt "${OUT_DIR}/taxi_wN.txt"

# # cmp -s "${OUT_DIR}/taxi_w1.txt" "${OUT_DIR}/taxi_wN.txt" && echo "TAXI: IDENTICAL" || echo "TAXI: DIFFERENT"
# # sha256sum "${OUT_DIR}/taxi_w1.txt" "${OUT_DIR}/taxi_wN.txt"

# # # 2) BIKE
# # /usr/bin/time -f "bike_w1 %E %MKB" python3 gen_instance_BIKE_augmented.py \
# #   --csv raw/metro-trips-2025-q4.csv -n 10000 --seed 42 \
# #   --temp-x 0.9 --temp-y 0.9 --individual-noise 0.4 \
# #   --sample-bikes --augment true --workers 1 \
# #   --out-txt "${OUT_DIR}/bike_w1.txt"

# # /usr/bin/time -f "bike_wN %E %MKB" python3 gen_instance_BIKE_augmented.py \
# #   --csv raw/metro-trips-2025-q4.csv -n 10000 --seed 42 \
# #   --temp-x 0.9 --temp-y 0.9 --individual-noise 0.4 \
# #   --sample-bikes --augment true --workers "${WORKERS_N}" \
# #   --out-txt "${OUT_DIR}/bike_wN.txt"

# # cmp -s "${OUT_DIR}/bike_w1.txt" "${OUT_DIR}/bike_wN.txt" && echo "BIKE: IDENTICAL" || echo "BIKE: DIFFERENT"
# # sha256sum "${OUT_DIR}/bike_w1.txt" "${OUT_DIR}/bike_wN.txt"

# # 3) ADM（需要 data/gen_instance_ADM.py 存在）
# /usr/bin/time -f "adm_w1 %E %MKB" python3 gen_instance_ADM_augmented_new.py \
#   --csv raw/ADM_Norway_raw.csv -n 10000 --seed 42 \
#   --temp-x 0.9 --temp-y 0.9 --workers 1 \
#   --out-txt "${OUT_DIR}/adm_w1.txt"

# /usr/bin/time -f "adm_wN %E %MKB" python3 gen_instance_ADM_augmented_new.py \
#   --csv raw/ADM_Norway_raw.csv -n 10000 --seed 42 \
#   --temp-x 0.9 --temp-y 0.9 --workers "${WORKERS_N}" \
#   --out-txt "${OUT_DIR}/adm_wN.txt"

# cmp -s "${OUT_DIR}/adm_w1.txt" "${OUT_DIR}/adm_wN.txt" && echo "ADM: IDENTICAL" || echo "ADM: DIFFERENT"
# sha256sum "${OUT_DIR}/adm_w1.txt" "${OUT_DIR}/adm_wN.txt"

# echo "Run finished: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
# echo "Artifacts: ${OUT_DIR}"
