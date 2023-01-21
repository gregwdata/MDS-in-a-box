#! /bin/bash

#http://www.eeoc.gov/sites/default/files/migrated_files/eeoc/statistics/employment/jobpat-eeo1/2015/datasets/year15_state_nac3.txt
#2010: https://www.eeoc.gov/eeoc/statistics/employment/jobpat-eeo1/2010/upload/2010_EEO-1_Job_Patterns_Data.zip
#https://www.eeoc.gov/sites/default/files/migrated_files/eeoc/statistics/employment/jobpat-eeo1/2017/datasets/year17_state_nac3.txt
#https://www.eeoc.gov/sites/default/files/migrated_files/eeoc/statistics/employment/jobpat-eeo1/2018/datasets/year18_state_nac3.txt

for i in {1..21}
do
for filename_base in "state_nac3" "state_nac2"
do 
   zero_padded_i=$(printf "%02d" $i)
   filename="year${zero_padded_i}_${filename_base}.txt"
   download_URL="http://www.eeoc.gov/sites/default/files/migrated_files/eeoc/statistics/employment/jobpat-eeo1/20${zero_padded_i}/datasets/${filename}"
   echo "Dowloading: $download_URL ..."
   download_dir="./data/${filename_base}/"
   mkdir -p $download_dir
   wget -O ${download_dir}/${filename} $download_URL
done
done