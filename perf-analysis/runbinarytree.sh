#!/bin/bash
malloclib=$1
tmpfile=$2

if [ $malloclib == "malloc" ]
then
<<<<<<< HEAD
	perf stat -e dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses  -x' ' -o $tmpfile ./a.out
else
	perf stat -e dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses  -x' ' -o $tmpfile ./binarytree-mesh.sh $malloclib
=======
	perf stat -e dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses -x' ' -o $tmpfile ./a.out
else
	perf stat -e dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses -x' ' -o $tmpfile ./binarytree-ldpreload.sh $malloclib
>>>>>>> 6364a83429513be3bc7016826e9868fd5a0291a6
fi
