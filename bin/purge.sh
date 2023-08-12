#!/bin/bash

###
# This script removes all derivative files associated with a single image
#
# Example Usage:
#  ./purge.sh 05567cd
#
# In Batch:
#  for x in `seq -w 00123 04567`; do y="${x}cd"; echo $y; ./purge $y; done
#
#
#
###

if [[ $# -ne 1 ]]; then
  echo "There must be one arg: 'pid': '$@'"
  exit 0
fi

# base=/home/awoods/programming/www/leadville-library/small-cmhc
base=/data/programming/cmhc
x=$1

rm -rf ${base}/_directories/${x}.md ; 
rm -rf ${base}/img/derivatives/iiif/${x} ; 
rm -rf ${base}/img/derivatives/iiif/images/${x} ; 
rm -rf ${base}/img/derivatives/iiif/annotation/${x}.json ; 
rm -rf ${base}/img/derivatives/iiif/canvas/${x}.json ;
rm -rf ${base}/img/derivatives/iiif/sequence/${x}.json ;

#ls ${base}/_directories/${x}.md ; 
#ls ${base}/img/derivatives/iiif/${x} ; 
#ls ${base}/img/derivatives/iiif/images/${x} ; 
#ls ${base}/img/derivatives/iiif/annotation/${x}.json ; 
#ls ${base}/img/derivatives/iiif/canvas/${x}.json ;
#ls ${base}/img/derivatives/iiif/sequence/${x}.json ;

