#!/bin/bash

export HOME_CMHC=/app/cmhc
export HOME_OCR=/app/cmhc-ocr

##
# stage.sh
# args: year collection pid-suffix pid-offset
##
if [ $# -ne 4 ]; then
  echo "Four positional args required: $#"
  echo "  - year       (e.g. 1860)"
  echo "  - collection (e.g. census)"
  echo "  - pid-suffix (e.g. ci)"
  echo "  - pid-offset (e.g. 102)"
  exit 1
fi

export YEAR=$1
export COLLECTION=$2
export SUFFIX=$3
export OFFSET=$4

function check_status() {
  if [ $1 -ne 0 ]; then
    echo "Command failed: $2"
    exit 1
  fi
} 

cd ${HOME_OCR}/input/${COLLECTION}/${YEAR}
mkdir images

pdfimages -p -tiff ${YEAR}.pdf images/page
check_status $? pdfimages

# Delete single-pixel files
cd images
find . -name '*.tif' -type f -size -100b -delete

# Remove page offsets in file names
rename 's/(?:-[0-9]{3}).tif$/.tif/' *.tif
rename 's/(?:-[0-9]{4}).tif$/.tif/' *.tif

# Rename files into collection series (where "100" is offset from highest number of last PID in collection)
# ** Necessary for keeping a sequential series of PIDs for subsequent PDFs
rename 's/page-([0-9]{3}).tif/sprintf("%05d$ENV{SUFFIX}.tif",$1+$ENV{OFFSET})/e' *.tif

#read -p "-> Check contents of ${HOME_OCR}/input/${COLLECTION}/${YEAR}/images" -n 1
ls ${HOME_OCR}/input/${COLLECTION}/${YEAR}/images
