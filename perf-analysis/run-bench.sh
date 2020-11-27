#!/usr/bin/env bash

<<<<<<< HEAD
=======
set -euo pipefail

sudo su -c 'echo 655350 > /proc/sys/vm/max_map_count'
sudo cpupower frequency-set -g performance 2>/dev/null || true

>>>>>>> 6364a83429513be3bc7016826e9868fd5a0291a6
COUNT=50
# Directory to store output
DIR="."


# List of programs to interleave
<<<<<<< HEAD
WORKLOADS=("runmysql.sh" "runbinarytree.sh" "runlarson.sh") # add Firefox and Redis
=======
WORKLOADS=("runmysql.sh" "runlarson.sh" "runbinarytree.sh", "runredis.sh")
>>>>>>> 6364a83429513be3bc7016826e9868fd5a0291a6
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
<<<<<<< HEAD
	#echo "dTLB-load-misses,iTLB-load-misses,memlib" >> "$OUTPUT_FILE"
=======
>>>>>>> 6364a83429513be3bc7016826e9868fd5a0291a6
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
