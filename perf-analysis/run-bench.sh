#!/usr/bin/env bash

COUNT=50
# Directory to store output
DIR="."


# List of programs to interleave
WORKLOADS=("runmysql.sh" "runbinarytree.sh" "runlarson.sh") # add Firefox and Redis
# List of malloc libraries
MALLOCLIBS=("malloc" "/usr/lib/x86_64-linux-gnu/libjemalloc.so" "/usr/lib/libmesh.so")

TMP_FILE="temp"


for workload in "${WORKLOADS[@]}"; do
	# Create output file for each program
	OUTPUT_FILE="output-$workload.csv"
	if [[ -e "$OUTPUT_FILE" ]]
	then
q		rm "$OUTPUT_FILE"
	fi
	touch "$OUTPUT_FILE"
	echo "dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses,memlib" >> "$OUTPUT_FILE"
	#echo "dTLB-load-misses,iTLB-load-misses,memlib" >> "$OUTPUT_FILE"
done

for workload in "${WORKLOADS[@]}"; do
	# iterate through each of the workloads 
	# append their output to their respective files
	# Add column names indicating what the stats are
	# Will be helpful when analyzing using a library like Pandas
	for ((i = 0 ; i < $COUNT+1 ; i++)); do
		# Create output file for each program
		OUTPUT_FILE="output-$workload.csv"

		#sudo perf stat -e dTLB-load-misses,iTLB-load-misses -x' ' -o $TMP_FILE $workload
		# iterate through malloc, jemalloc, mesh
		for mlib in "${MALLOCLIBS[@]}"; do
			./$workload $mlib $TMP_FILE
			if [ $i -ne 0 ]
			then
				x=$(awk  '/^[0-9]/ { printf "%s,", $1; }' $TMP_FILE); echo "$x$mlib" >> "$OUTPUT_FILE"
			fi
		done
	done
done

for workload in "${WORKLOADS[@]}"; do
	OUTPUT_FILE="output-$workload.csv"
	python3.6 get_ci_tlb.py $OUTPUT_FILE
done
