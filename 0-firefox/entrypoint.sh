#!/bin/bash
set -euo pipefail

if [ "$#" -ne 3 ]; then
    echo "usage: ./entrypoint.sh N_RUNS WAIT_TIME METRIC" >&2
    exit 1
fi

N=$1
export TEST_WAIT_SECS=$2
export TEST_METRIC=$3

case $TEST_METRIC in
  "memory")
    echo "Measuring memory using mstat"
    ;;
  "speed")
    echo "Measuring speedometer speed (without mstat)"
    ;;
  *)
    echo "Unrecognized metric $TEST_METRIC"
    exit 1
    ;;
esac

echo "doing $N runs"

(cd Speedometer && serve &)

cd atsy

i=0
while [ $i -lt $N ]; do
    echo "run $i"
    export RUN_NUMBER=$i
    ./run_speedometer
    i=$(($i+1))
done
