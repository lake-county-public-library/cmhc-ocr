#!/bin/bash

###
# This script is used to batch together the other scripts in this directory:
#  - 2-stage-pdf-images.sh
#  - 3-generate-ocr.sh
#  - 4-link-images.sh
#
# This enables processing multiple PDF files without user intervention
#
# NOTE: Some elements are hard-coded and should be refactored
###

export HOME_CMHC=/app/cmhc
export HOME_OCR=/app/cmhc-ocr

##
# batch.sh
# args: collection pid-suffix
##
if [ $# -ne 2 ]; then
  echo "Two positional args required: $#"
  echo "  - collection (e.g. census)"
  echo "  - pid-suffix (e.g. ci)"
  exit 1
fi

export COLLECTION=$1
export SUFFIX=$2
export OFFSET="4955"

function pushd () {
    command pushd "$@" > /dev/null
}

function popd () {
    command popd "$@" > /dev/null
}

function check_status() {
  if [ $1 -ne 0 ]; then
    echo "Command failed: $2"
    exit 1
  fi
} 


for x in `ls -1 ${HOME_OCR}/input/directories`; do

  # Move image pages into hidden directory
  pushd ${HOME_OCR}/input/directories/${x}
  if [ -e "images" ]; then
    echo "found images: "
    mv images .images
  fi
  # Call script 2
  echo "${HOME_OCR}/bin/2-stage-pdf-images.sh $x directories cd $OFFSET"
  ${HOME_OCR}/bin/2-stage-pdf-images.sh $x directories cd $OFFSET
  OFFSET=$(( $OFFSET + $((`ls -1 images/*.tif|wc -l`)) ))
  check_status $? "2-stage-${x}"
  popd
 
  echo "offset after $x = $OFFSET"

  # Move ocr pages into hidden directory
  if [ -d ${HOME_OCR}/output/directories/${x} ]; then
    pushd ${HOME_OCR}/output/directories/${x}
    count=`ls -1 *.txt 2>/dev/null | wc -l`
    if [ $count != 0 ]; then
      echo "found ocr: "
      ls *.txt | head -1
      mkdir .ocr
      mv *.txt .ocr
    fi
    popd
  fi

  # Call script 3
  echo "${HOME_OCR}/bin/3-generate-ocr.sh $x directories '${x} City Directory' cd 2023-08-10"
  ${HOME_OCR}/bin/3-generate-ocr.sh $x directories "${x} City Directory" cd 2023-08-09
  check_status $? "3-generate-${x}"

  # Call script 4
  echo "${HOME_OCR}/bin/4-link-images.sh $x directories"
  ${HOME_OCR}/bin/4-link-images.sh $x directories
  check_status $? "4-link-${x}"

done
