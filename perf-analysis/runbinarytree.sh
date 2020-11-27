#!/bin/bash
malloclib=$1
tmpfile=$2

if [ $malloclib=="malloc" ]
then
	perf stat -e dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses  -x' ' -o $tmpfile ./a.out
else
	perf stat -e dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses  -x' ' -o $tmpfile ./binarytree-mesh.sh $malloclib
fi
