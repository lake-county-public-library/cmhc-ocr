#!/bin/bash

export HOME_CMHC="/app/cmhc"
export HOME_OCR="/app/cmhc-ocr"

##
# link-images.sh
# args: year collection
##
if [ $# -ne 2 ]; then
  echo "Two positional args required: $#"
  echo "  - year       (e.g. 1860)"
  echo "  - collection (e.g. census)"
  exit 1
fi

export YEAR=$1
export COLLECTION=$2

function check_status() {
  if [ $1 -ne 0 ]; then
    echo "Command failed: $2"
    exit 1
  fi
} 

cd ${HOME_CMHC}
mkdir -p _data/raw_images/${COLLECTION}
pushd _data/raw_images/${COLLECTION}

if [ ! -z "$(ls -A .)" ]; then
   echo "Directory not empty: ${PWD}"
#   echo "Remove contents then run this script again."
#   exit 1
fi

# Link images
for x in ${HOME_OCR}/input/${COLLECTION}/${YEAR}/images/*.tif; do ln -s $x ; done

#read -p "-> Check linked images" -n 1
ls *

echo "ls -l ${HOME_CMHC}/_data/raw_images/${COLLECTION}"
popd
