#!/bin/bash
malloclib=$1
tmpfile=$2

if [ $malloclib=="malloc" ]
then
	perf stat -e dTLB-load-misses,iTLB-load-misses -x' ' -o $tmpfile ./larson  10 7 8 1000 10000 1 3
else
	LD_PRELOAD=$malloclib perf stat -e dTLB-load-misses,iTLB-load-misses -x' ' -o $tmpfile ./larson  10 7 8 1000 10000 1 3
fi
