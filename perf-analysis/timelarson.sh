#!/bin/bash
malloclib=$1
tmpfile=$2

echo $malloclib

if [ $malloclib == "malloc" ]
then
	echo "reached malloc"
	{ time -p ./larson  10 7 8 10000 10000 1 16 ; } 2> $tmpfile
	#perf stat -e dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses  -x' ' -o $tmpfile ./larson  10 7 8 1000 10000 1 8
else
	echo "reached $malloclib"
	{ time -p ./larson-mesh.sh $malloclib ; } 2> $tmpfile
	# perf stat -e dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses -x' ' -o $tmpfile ./larson-mesh.sh $malloclib
fi
