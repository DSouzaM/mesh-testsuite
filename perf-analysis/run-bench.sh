#!/usr/bin/env bash

COUNT=3
# Directory to store output
DIR="."


# List of programs to interleave
WORKLOADS=("runmysql.sh" "runlarson.sh" "runbinarytree.sh") # add Firefox and Redis
# List of malloc libraries
MALLOCLIBS=("malloc" "/usr/lib/x86_64-linux-gnu/libjemalloc.so" "/usr/lib/libmesh.so")

TMP_FILE="temp"


for workload in "${WORKLOADS[@]}"; do
	# Create output file for each program
	OUTPUT_FILE="output-$workload.csv"
	if [[ -e "$OUTPUT_FILE" ]]
	then
		rm "$OUTPUT_FILE"
	fi
	touch "$OUTPUT_FILE"
	echo "dTLB-load-misses,iTLB-load-misses,memlib" >> "$OUTPUT_FILE"
done

for ((i = 0 ; i < $COUNT ; i++)); do
	# iterate through each of the workloads 
	# append their output to their respective files
	# Add column names indicating what the stats are
	# Will be helpful when analyzing using a library like Pandas

	for workload in "${WORKLOADS[@]}"; do
		# Create output file for each program
		OUTPUT_FILE="output-$workload.csv"
		
		#sudo perf stat -e dTLB-load-misses,iTLB-load-misses -x' ' -o $TMP_FILE $workload
		# iterate through malloc, jemalloc, mesh
		for mlib in "${MALLOCLIBS[@]}"; do
			./$workload $mlib $TMP_FILE
			x=$(awk  '/^[0-9]/ { printf "%s,", $1; }' $TMP_FILE); echo "$x$mlib" >> "$OUTPUT_FILE"
		done
	done
done

for workload in "${WORKLOADS[@]}"; do
	OUTPUT_FILE="output-$workload.csv"
	python3.6 get_ci_tlb.py $OUTPUT_FILE
done
