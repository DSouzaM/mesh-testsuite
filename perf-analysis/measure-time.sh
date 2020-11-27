COUNT=25
# Directory to store output
DIR="."

# List of programs to interleave
#WORKLOADS=("timemysql.sh" "timelarson.sh" "timebinarytree.sh")
MALLOCLIBS=("/usr/lib/x86_64-linux-gnu/libjemalloc.so" "malloc" "/usr/lib/libmesh.so")
#MALLOCLIBS=("malloc" "/usr/lib/libmesh.so")
WORKLOADS=("timemysql.sh" "timebinarytree.sh")
TMP_FILE="temp"


if [[ -e "$TMP_FILE" ]]
then
	rm "$TMP_FILE"
fi


for workload in "${WORKLOADS[@]}"; do
	# Create output file for each program
	OUTPUT_FILE="output-$workload.csv"
	if [[ -e "$OUTPUT_FILE" ]]
	then
		rm "$OUTPUT_FILE"
	fi
	touch "$OUTPUT_FILE"
	echo "real,user,sys,allocator" >> "$OUTPUT_FILE"
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
			cat $TMP_FILE | grep -o '[0-9]\+\.[0-9]\+' | awk  '/^[0-9]/ { printf "%s,", $1; }' >> $OUTPUT_FILE
			echo $mlib >> $OUTPUT_FILE
			# echo "" >> $OUTPUT_FILE
		done
	done
done
