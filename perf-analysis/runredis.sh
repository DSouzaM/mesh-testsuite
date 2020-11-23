#!/bin/bash

malloclib=$1

tmpfile=$2

case $malloclib in
  *"jemalloc"*)
    config="jemalloc"
    ;;
  *"mesh"*)
    config="mesh2y"
    ;;
  "malloc")
    config="libc"
    ;;
  *)
    echo "Unrecognized malloc implementation $malloclib"
    exit 1
    ;;
esac

# Set up a docker volume through which to share data
VOLUME="mesh-artifact-data"
docker volume rm "$VOLUME" > /dev/null || true
docker volume create "$VOLUME" > /dev/null || true

RUN_FLAGS="--privileged --rm -t --mount type=volume,src=$VOLUME,dst=/data"

# TODO: configure to run mstat and cache tests
docker run $RUN_FLAGS mwdsouza/mesh-artifact-1-redis ./test --runs=1 --data-dir=/data/1-redis --metric=tlb --config=$config frag

# copy results into temp file
docker run $RUN_FLAGS --mount type=bind,src=$PWD,dst=/results mwdsouza/mesh-artifact-1-redis sh -c "find /data/1-redis/tlb/ -type f -exec cp {} /results/$tmpfile \;"