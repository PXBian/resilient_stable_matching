#! /bin/sh
#SBATCH --mem=150G

# python3 gen_instance_TAXI.py --csv raw/TAXI_raw.csv -n 5000  --sample-rows --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_5000_instance.txt
# python3 gen_instance_TAXI.py --csv raw/TAXI_raw.csv -n 10000 --sample-rows --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_10000_instance.txt
# python3 gen_instance_TAXI.py --csv raw/TAXI_raw.csv -n 15000 --sample-rows --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_15000_instance.txt
# python3 gen_instance_TAXI.py --csv raw/TAXI_raw.csv -n 20000 --sample-rows --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_20000_instance.txt
# python3 gen_instance_TAXI.py --csv raw/TAXI_raw.csv -n 25000 --sample-rows --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_25000_instance.txt

# New TAXI generator (drivers ↔ orders, rotation-friendly)
# python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 5000  --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_5000_instance.txt
# python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 10000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_10000_instance.txt
# python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 15000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_15000_instance.txt
# python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 20000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_20000_instance.txt
# python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 25000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_25000_instance.txt
# python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 30000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_30000_instance.txt






# python3 gen_instance_ADM.py --csv raw/ADM_Norway_raw.csv -n 21000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_rand_21000_instance.txt --output-format indices
# python3 gen_instance_ADM.py --csv raw/ADM_Norway_raw.csv -n 22000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_rand_22000_instance.txt --output-format indices
# python3 gen_instance_ADM.py --csv raw/ADM_Norway_raw.csv -n 23000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_rand_23000_instance.txt --output-format indices
# python3 gen_instance_ADM.py --csv raw/ADM_Norway_raw.csv -n 24000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_rand_24000_instance.txt --output-format indices
# python3 gen_instance_ADM.py --csv raw/ADM_Norway_raw.csv -n 24000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_rand_24000_instance.txt --output-format indices

# python3 gen_instance_FOOD_augmented.py --ratings raw/FOOD_rating_final.csv --users raw/FOOD_userprofile.csv --places raw/FOOD_geoplaces2.csv -n 5000  --seed 42 --temp-x 0.9 --temp-y 0.9 --unrated-baseline 0.0 --strategy top --out-txt FOOD_5000_instance.txt  --augment true
# python3 gen_instance_FOOD_augmented.py --ratings raw/FOOD_rating_final.csv --users raw/FOOD_userprofile.csv --places raw/FOOD_geoplaces2.csv -n 10000 --seed 42 --temp-x 0.9 --temp-y 0.9 --unrated-baseline 0.0 --strategy top --out-txt FOOD_10000_instance.txt --augment true
# python3 gen_instance_FOOD_augmented.py --ratings raw/FOOD_rating_final.csv --users raw/FOOD_userprofile.csv --places raw/FOOD_geoplaces2.csv -n 15000 --seed 42 --temp-x 0.9 --temp-y 0.9 --unrated-baseline 0.0 --strategy top --out-txt FOOD_15000_instance.txt --augment true
# python3 gen_instance_FOOD_augmented.py --ratings raw/FOOD_rating_final.csv --users raw/FOOD_userprofile.csv --places raw/FOOD_geoplaces2.csv -n 20000 --seed 42 --temp-x 0.9 --temp-y 0.9 --unrated-baseline 0.0 --strategy top --out-txt FOOD_20000_instance.txt --augment true
# python3 gen_instance_FOOD_augmented.py --ratings raw/FOOD_rating_final.csv --users raw/FOOD_userprofile.csv --places raw/FOOD_geoplaces2.csv -n 25000 --seed 42 --temp-x 0.9 --temp-y 0.9 --unrated-baseline 0.0 --strategy top --out-txt FOOD_25000_instance.txt --augment true
# python3 gen_instance_FOOD_augmented.py --ratings raw/FOOD_rating_final.csv --users raw/FOOD_userprofile.csv --places raw/FOOD_geoplaces2.csv -n 30000 --seed 42 --temp-x 0.9 --temp-y 0.9 --unrated-baseline 0.0 --strategy top --out-txt FOOD_30000_instance.txt --augment true


# python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 5000  --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_5000_instance.txt --augment true
# python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 10000 --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_10000_instance.txt --augment true
# python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 15000 --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_15000_instance.txt --augment true
# python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 20000 --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_20000_instance.txt --augment true
# python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 25000 --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_25000_instance.txt --augment true
# python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 30000 --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_30000_instance.txt --augment true

# python3 gen_instance_BIKE_augmented.py --csv raw/metro-trips-2025-q4.csv -n 5000  --seed 42 --temp-x 0.9 --temp-y 0.9 --individual-noise 0.4 --sample-bikes --augment true --out-txt BIKE_5000_instance.txt
# python3 gen_instance_BIKE_augmented.py --csv raw/metro-trips-2025-q4.csv -n 10000 --seed 42 --temp-x 0.9 --temp-y 0.9 --individual-noise 0.4 --sample-bikes --augment true --out-txt BIKE_10000_instance.txt
# python3 gen_instance_BIKE_augmented.py --csv raw/metro-trips-2025-q4.csv -n 15000 --seed 42 --temp-x 0.9 --temp-y 0.9 --individual-noise 0.4 --sample-bikes --augment true --out-txt BIKE_15000_instance.txt
# python3 gen_instance_BIKE_augmented.py --csv raw/metro-trips-2025-q4.csv -n 20000 --seed 42 --temp-x 0.9 --temp-y 0.9 --individual-noise 0.4 --sample-bikes --augment true --out-txt BIKE_20000_instance.txt
# python3 gen_instance_BIKE_augmented.py --csv raw/metro-trips-2025-q4.csv -n 25000 --seed 42 --temp-x 0.9 --temp-y 0.9 --individual-noise 0.4 --sample-bikes --augment true --out-txt BIKE_25000_instance.txt
# python3 gen_instance_BIKE_augmented.py --csv raw/metro-trips-2025-q4.csv -n 30000 --seed 42 --temp-x 0.9 --temp-y 0.9 --individual-noise 0.4 --sample-bikes --augment true --out-txt BIKE_30000_instance.txt

python3 gen_instance_ADM_augmented_new.py --csv raw/ADM_Norway_raw.csv -n 10000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_new_10000_instance.txt
python3 gen_instance_ADM_augmented_new.py --csv raw/ADM_Norway_raw.csv -n 20000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_new_20000_instance.txt
python3 gen_instance_ADM_augmented_new.py --csv raw/ADM_Norway_raw.csv -n 30000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_new_30000_instance.txt
python3 gen_instance_ADM_augmented_new.py --csv raw/ADM_Norway_raw.csv -n 40000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_new_40000_instance.txt
python3 gen_instance_ADM_augmented_new.py --csv raw/ADM_Norway_raw.csv -n 50000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_new_50000_instance.txt


# python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 40000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_40000_instance.txt
# python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 50000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_50000_instance.txt

# python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 40000 --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_40000_instance.txt --augment true
# python3 gen_instance_RAP_augmented.py --author-dir raw/RAP_author --paper-dir raw/RAP_pub --coi-file raw/RAP_COI_pairs.csv -n 50000 --seed 42 --strategy top --temp-x 0.9 --temp-y 0.9 --out-txt RAP_50000_instance.txt --augment true
