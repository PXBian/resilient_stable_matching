#! /bin/sh
#SBATCH --partition=long_cpu
#SBATCH --mem=500G
#SBATCH --time=5-00:00:00


python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 60000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_60000_instance.txt
python3 gen_instance_TAXI_new.py --csv raw/TAXI_raw.csv -n 70000 --sample --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt TAXI_new_70000_instance.txt

python3 gen_instance_FOOD_augmented.py --ratings raw/FOOD_rating_final.csv --users raw/FOOD_userprofile.csv --places raw/FOOD_geoplaces2.csv -n 60000 --seed 42 --temp-x 0.9 --temp-y 0.9 --unrated-baseline 0.0 --strategy top --out-txt FOOD_60000_instance.txt --augment true
python3 gen_instance_FOOD_augmented.py --ratings raw/FOOD_rating_final.csv --users raw/FOOD_userprofile.csv --places raw/FOOD_geoplaces2.csv -n 70000 --seed 42 --temp-x 0.9 --temp-y 0.9 --unrated-baseline 0.0 --strategy top --out-txt FOOD_70000_instance.txt --augment true

python3 gen_instance_ADM_augmented.py --csv raw/ADM_Norway_raw.csv -n 60000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_60000_instance.txt
python3 gen_instance_ADM_augmented.py --csv raw/ADM_Norway_raw.csv -n 70000 --seed 42 --temp-x 0.9 --temp-y 0.9 --out-txt  ADM_70000_instance.txt



