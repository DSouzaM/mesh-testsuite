#!/bin/bash
malloclib=$1
tmpfile=$2

if [ $malloclib == "malloc" ]
then
	perf stat -e dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses  -x' ' -o $tmpfile ./larson  10 7 8 1000 10000 1 8
else
	perf stat -e dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses -x' ' -o $tmpfile ./larson-ldpreload.sh $malloclib
fi
