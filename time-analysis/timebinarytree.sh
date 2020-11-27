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
else
	echo "reached $malloclib"
	{ time -p ./binarytree-ldpreload.sh $malloclib ; } 2> $tmpfile
	echo "after time command"	
fi
