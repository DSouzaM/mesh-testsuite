#!/bin/bash
malloclib=$1
tmpfile=$2

if [ $malloclib=="malloc" ]
then
	perf stat -e dTLB-load-misses,iTLB-load-misses -x' ' -o $tmpfile ./binarytree.out
else
	LD_PRELOAD=$malloclib perf stat -e dTLB-load-misses,iTLB-load-misses -x' ' -o $tmpfile ./binarytree.out
fi
