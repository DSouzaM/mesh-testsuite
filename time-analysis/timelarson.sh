#!/bin/bash
malloclib=$1
tmpfile=$2

echo $malloclib

if [ $malloclib == "malloc" ]
then
	echo "reached malloc"
	{ time -p ./larson  10 7 8 10000 10000 1 16 ; } 2> $tmpfile
else
	echo "reached $malloclib"
	{ time -p ./larson-ldpreload.sh $malloclib ; } 2> $tmpfile
fi
