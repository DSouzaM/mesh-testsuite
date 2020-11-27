#!/bin/bash
malloclib=$1
tmpfile=$2

if [ $malloclib == "malloc" ]
then
	echo "this is malloc"
fi

echo $malloclib

if [ $malloclib == "malloc" ]
then
	echo "reached malloc"
	{ time -p ./a.out ; } 2> $tmpfile
	# perf stat -e dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses  -x' ' -o $tmpfile ./a.out
else
	echo "reached $malloclib"
	{ time -p ./binarytree-mesh.sh $malloclib ; } 2> $tmpfile
	echo "after time command"	
#perf stat -e dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses  -x' ' -o $tmpfile ./binarytree-mesh.sh $malloclib
fi
