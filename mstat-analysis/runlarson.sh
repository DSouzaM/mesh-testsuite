#!/bin/bash
malloclib=$1
DIR=$2
FREQ=$3
i=$4
mlibname=$5

if [ $malloclib == "malloc" ]
then
	mstat -o "$DIR/output/runlarson.sh/$i-$mlibname.tsv" -freq "$FREQ" -- ./larson 10 7 8 1000 10000 1 8
else
	mstat -o "$DIR/output/runlarson.sh/$i-$mlibname.tsv" -freq "$FREQ" -env LD_PRELOAD=$malloclib -- ./larson 10 7 8 1000 10000 1 8
fi
