set -euo pipefail

sudo su -c 'echo 655350 > /proc/sys/vm/max_map_count'
sudo cpupower frequency-set -g performance 2>/dev/null || true

COUNT=20
# Directory to store output
DIR="."

MALLOCLIBS=("/usr/lib/x86_64-linux-gnu/libjemalloc.so" "malloc" "/usr/lib/libmesh.so")
#associative array to help with file names
declare -A mlibname
mlibname["malloc"]="malloc"
mlibname["/usr/lib/x86_64-linux-gnu/libjemalloc.so"]="jemalloc"
mlibname["/usr/lib/libmesh.so"]="mesh"

for mlib in "${MALLOCLIBS[@]}"; do
	OUTPUT_FILE="output-mysql-ycsb-${mlibname[$mlib]}.txt"
	if [[ -e "$OUTPUT_FILE" ]]
	then
        	rm "$OUTPUT_FILE"
	fi
	touch "$OUTPUT_FILE"
done

for ((i = 0 ; i < $COUNT ; i++)); do
                # iterate through malloc, jemalloc, mesh
                for mlib in "${MALLOCLIBS[@]}"; do
			OUTPUT_FILE="output-mysql-ycsb-${mlibname[$mlib]}.txt"
                        ./timemysql-ycsb.sh $mlib $OUTPUT_FILE
                done
done

