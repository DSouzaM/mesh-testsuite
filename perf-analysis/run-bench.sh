#!/usr/bin/env bash

COUNT=20
# Directory to store output
DIR="."


# List of programs to interleave
WORKLOADS=("./a.out" "./run.sh")
OUTPUT_FILE="output.csv"
TMP_FILE="temp"

if [[ -e "$OUTPUT_FILE" ]]
then
	rm "$OUTPUT_FILE"
fi


# Create output file for each program
touch "$OUTPUT_FILE"
echo "dTLB-load-misses,iTLB-load-misses,workload" >> "$OUTPUT_FILE"

for ((i = 0 ; i < $COUNT ; i++)); do
	# iterate through each of the workloads 
	# append their output to their respective
	# files
	# Add column names indicating what the stats are
	# Will be helpful when analyzing using a library like Pandas

	for workload in "${WORKLOADS[@]}"; do
		sudo perf stat -e dTLB-load-misses,iTLB-load-misses -x' ' -o $TMP_FILE $workload
		x=$(awk  '/^[0-9]/ { printf "%s,", $1; }' $TMP_FILE); echo "$x$workload" >> "$OUTPUT_FILE"
	done
done