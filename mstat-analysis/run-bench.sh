#!/usr/bin/env bash

COUNT=1
# Directory to store output
DIR="."

FREQ=100

WORKLOADS=("runbinarytree.sh" "runlarson.sh" "runmysql.sh")
# List of malloc libraries
MALLOCLIBS=("malloc" "/usr/lib/x86_64-linux-gnu/libjemalloc.so" "/usr/lib/libmesh.so")

#associative array to help with file names
declare -A mlibname
mlibname["malloc"]="malloc"
mlibname["/usr/lib/x86_64-linux-gnu/libjemalloc.so"]="jemalloc"
mlibname["/usr/lib/libmesh.so"]="mesh"


# If output directory exists, delete it
if [[ -e "$DIR/output" ]]
then
	rm -rf "$DIR/output"
fi


# Create output directory for each program


for workload in "${WORKLOADS[@]}"; do
	mkdir -p "$DIR/output/$workload"
done

for workload in "${WORKLOADS[@]}"; do
	# iterate through each of the workloads 
	# append their output to their respective
	# files
	# Add column names indicating what the stats are
	# Will be helpful when analyzing using a library like Pandas

	for ((i = 0 ; i < $COUNT ; i++)); do
		for mlib in "${MALLOCLIBS[@]}"; do
			echo "$DIR/output/$workload/$i-${mlibname[$mlib]}.tsv"
			touch $DIR/output/$workload/$i-${mlibname[$mlib]}.tsv
			echo "$workload"
			./$workload $mlib $DIR $FREQ $i ${mlibname[$mlib]}
		done
	done
done
