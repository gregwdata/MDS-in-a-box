#! /bin/bash

#http://www.eeoc.gov/sites/default/files/migrated_files/eeoc/statistics/employment/jobpat-eeo1/2015/datasets/year15_state_nac3.txt
#2010: https://www.eeoc.gov/eeoc/statistics/employment/jobpat-eeo1/2010/upload/2010_EEO-1_Job_Patterns_Data.zip
#https://www.eeoc.gov/sites/default/files/migrated_files/eeoc/statistics/employment/jobpat-eeo1/2017/datasets/year17_state_nac3.txt
#https://www.eeoc.gov/sites/default/files/migrated_files/eeoc/statistics/employment/jobpat-eeo1/2018/datasets/year18_state_nac3.txt

# for i in {1..21}
# do
# for filename_base in "state_nac3" "state_nac2"
# do 
#    zero_padded_i=$(printf "%02d" $i)
#    filename="year${zero_padded_i}_${filename_base}.txt"
#    download_URL="http://www.eeoc.gov/sites/default/files/migrated_files/eeoc/statistics/employment/jobpat-eeo1/20${zero_padded_i}/datasets/${filename}"
#    echo "Downloading: $download_URL ..."
#    download_dir="./data/${filename_base}/"
#    mkdir -p $download_dir
#    wget -O ${download_dir}/${filename} $download_URL
# done
# done

# xlsx2csv utility needed to convert to csv to allow removing the *
pip install xlsx2csv

declare -A excel_files

excel_files['EEO1_2014_PUF.xlsx']='https://www.eeoc.gov/sites/default/files/2021-12/EEO1%202014%20PUF.xlsx'
excel_files['EEO1_2015_PUF.xlsx']='https://www.eeoc.gov/sites/default/files/2021-12/EEO1%202015%20PUF.xlsx'
excel_files['EEO1_2016_PUF.xlsx']='https://www.eeoc.gov/sites/default/files/2021-12/EEO1%202016%20PUF.xlsx'
excel_files['EEO1_2017_PUF.xlsx']='https://www.eeoc.gov/sites/default/files/2021-12/EEO1%202017%20PUF.xlsx'
excel_files['EEO1_2018_PUF.xlsx']='https://www.eeoc.gov/sites/default/files/2021-12/EEO1%202018%20PUF.xlsx'
excel_files['EEO1_2019_PUF.xlsx']='https://www.eeoc.gov/sites/default/files/2022-09/EEO1_2019_PUF.xlsx'
for filename in "${!excel_files[@]}"
do 
   download_dir="./data/Excel_PUFs"
   cleaned_dir="./data/Excel_PUFs_cleaned"
   csv_filename="${filename%.*}.csv"
   mkdir -p $download_dir
   mkdir -p $cleaned_dir
   echo "Downloading: ${excel_files[$filename]} ..."
   wget -O ${download_dir}/${filename} ${excel_files[$filename]} # download xlsx file
   echo "Converting: $filename to csv ..."
   xlsx2csv ${download_dir}/${filename} ${cleaned_dir}/${csv_filename} #convert to csv
   echo "Removing asterisks ..."
   sed -i 's/[*]//g' ${cleaned_dir}/${csv_filename} #remove the *s
   echo "DONE: $filename "
done

unset excel_files
