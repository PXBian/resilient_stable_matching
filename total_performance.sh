#!/bin/bash

mkdir peak_ram
gunzip data/*.gz

make total


(/usr/bin/time -v ./total_test data/ADM_1000_instance.txt 1000 50 ) &> peak_ram/total_test_adm1000_1000_50.txt
(/usr/bin/time -v ./total_test data/ADM_2000_instance.txt 2000 50 ) &> peak_ram/total_test_adm2000_2000_50.txt
(/usr/bin/time -v ./total_test data/ADM_3000_instance.txt 3000 50 ) &> peak_ram/total_test_adm3000_3000_50.txt
(/usr/bin/time -v ./total_test data/ADM_4000_instance.txt 4000 50 ) &> peak_ram/total_test_adm4000_4000_50.txt
(/usr/bin/time -v ./total_test data/ADM_5000_instance.txt 5000 50 ) &> peak_ram/total_test_adm5000_5000_50.txt

(/usr/bin/time -v ./total_test data/ADM_1000_instance.txt 1000 100) &> peak_ram/total_test_adm1000_1000_100.txt
(/usr/bin/time -v ./total_test data/ADM_2000_instance.txt 2000 100) &> peak_ram/total_test_adm2000_2000_100.txt
(/usr/bin/time -v ./total_test data/ADM_3000_instance.txt 3000 100) &> peak_ram/total_test_adm3000_3000_100.txt
(/usr/bin/time -v ./total_test data/ADM_4000_instance.txt 4000 100) &> peak_ram/total_test_adm4000_4000_100.txt
(/usr/bin/time -v ./total_test data/ADM_5000_instance.txt 5000 100) &> peak_ram/total_test_adm5000_5000_100.txt

(/usr/bin/time -v ./total_test data/ADM_1000_instance.txt 1000 150) &> peak_ram/total_test_adm1000_1000_150.txt
(/usr/bin/time -v ./total_test data/ADM_2000_instance.txt 2000 150) &> peak_ram/total_test_adm2000_2000_150.txt
(/usr/bin/time -v ./total_test data/ADM_3000_instance.txt 3000 150) &> peak_ram/total_test_adm3000_3000_150.txt
(/usr/bin/time -v ./total_test data/ADM_4000_instance.txt 4000 150) &> peak_ram/total_test_adm4000_4000_150.txt
(/usr/bin/time -v ./total_test data/ADM_5000_instance.txt 5000 150) &> peak_ram/total_test_adm5000_5000_150.txt

(/usr/bin/time -v ./total_test data/ADM_1000_instance.txt 1000 200) &> peak_ram/total_test_adm1000_1000_200.txt
(/usr/bin/time -v ./total_test data/ADM_2000_instance.txt 2000 200) &> peak_ram/total_test_adm2000_2000_200.txt
(/usr/bin/time -v ./total_test data/ADM_3000_instance.txt 3000 200) &> peak_ram/total_test_adm3000_3000_200.txt
(/usr/bin/time -v ./total_test data/ADM_4000_instance.txt 4000 200) &> peak_ram/total_test_adm4000_4000_200.txt
(/usr/bin/time -v ./total_test data/ADM_5000_instance.txt 5000 200) &> peak_ram/total_test_adm5000_5000_200.txt

(/usr/bin/time -v ./total_test data/ADM_1000_instance.txt 1000 250) &> peak_ram/total_test_adm1000_1000_250.txt
(/usr/bin/time -v ./total_test data/ADM_2000_instance.txt 2000 250) &> peak_ram/total_test_adm2000_2000_250.txt
(/usr/bin/time -v ./total_test data/ADM_3000_instance.txt 3000 250) &> peak_ram/total_test_adm3000_3000_250.txt
(/usr/bin/time -v ./total_test data/ADM_4000_instance.txt 4000 250) &> peak_ram/total_test_adm4000_4000_250.txt
(/usr/bin/time -v ./total_test data/ADM_5000_instance.txt 5000 250) &> peak_ram/total_test_adm5000_5000_250.txt

(/usr/bin/time -v ./total_test data/ADM_1000_instance.txt 1000 300) &> peak_ram/total_test_adm1000_1000_300.txt
(/usr/bin/time -v ./total_test data/ADM_2000_instance.txt 2000 300) &> peak_ram/total_test_adm2000_2000_300.txt
(/usr/bin/time -v ./total_test data/ADM_3000_instance.txt 3000 300) &> peak_ram/total_test_adm3000_3000_300.txt
(/usr/bin/time -v ./total_test data/ADM_4000_instance.txt 4000 300) &> peak_ram/total_test_adm4000_4000_300.txt
(/usr/bin/time -v ./total_test data/ADM_5000_instance.txt 5000 300) &> peak_ram/total_test_adm5000_5000_300.txt