#!/bin/bash
malloclib=$1
DIR=$2
FREQ=$3
i=$4
mlibname=$5

if [ $malloclib == "malloc" ]
then
	mstat -o "$DIR/output/runbinarytree.sh/$i-$mlibname.tsv" -freq "$FREQ" -- ./a.out
else
	mstat -o "$DIR/output/runbinarytree.sh/$i-$mlibname.tsv" -freq "$FREQ" -env LD_PRELOAD=$malloclib -- ./a.out
fi
