#!/bin/bash

malloclib=$1
DIR=$(realpath $2)
FREQ=$3
i=$4
mlibname=$5

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

docker run $RUN_FLAGS mwdsouza/mesh-artifact-1-redis ./test --runs=1 --data-dir=/data/1-redis --metric=memory --freq=$FREQ --config=$config frag

# copy results into destination location
docker run $RUN_FLAGS --mount type=bind,src=$DIR,dst=$DIR mwdsouza/mesh-artifact-1-redis sh -c "find /data/1-redis/memory/ -type f -exec cp {} $DIR/output/runredis.sh/$i-$mlibname.tsv \;"
