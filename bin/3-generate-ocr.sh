#!/bin/bash

export HOME_CMHC="/app/cmhc"
export HOME_OCR="/app/cmhc-ocr"

##
# stage.sh
# args: year collection label pid-suffix ingest-date
##
if [ $# -ne 5 ]; then
  echo "Five positional args required: $#"
  echo "  - year       (e.g. 1860)"
  echo "  - collection (e.g. census)"
  echo "  - collection-label (e.g. 1860 Lake County Census)"
  echo "  - pid-suffix (e.g. ci)"
  echo "  - ingest-date (e.g. 2023-01-28)"  
  exit 1
fi

export YEAR=$1
export COLLECTION=$2
export LABEL=$3
export SUFFIX=$4
export INGEST_DATE=$5

function check_status() {
  if [ $1 -ne 0 ]; then
    echo "Command failed: $2"
    exit 1
  fi
} 

cd ${HOME_OCR}

# Generate OCR for each page
python3 pdf-data/do-ocr.py -i input/${COLLECTION}/${YEAR}/images/ -o output/${COLLECTION}/${YEAR}/
check_status $? do-ocr

#read -p "-> Check contents of ${HOME_OCR}/output/${COLLECTION}/${YEAR}" -n 1
ls ${HOME_OCR}/output/${COLLECTION}/${YEAR}

# Populate spreadsheet
#read -p "-> Populate spreadsheet: ${COLLECTION}.csv?" -n 1
clear;python3 pdf-data/txt2csv.py -c ../cmhc/_data/${COLLECTION}.csv -t output/${COLLECTION}/${YEAR}/ -f label:"${LABEL}" -f key:${YEAR}${SUFFIX} -f ingest_date:${INGEST_DATE} -f layout:cmhc_item

#read -p "-> Check spreadsheet: libreoffice ${HOME_CMHC}/_data/${COLLECTION}.csv" -n 1
