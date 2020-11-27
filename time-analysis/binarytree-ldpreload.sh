#!/usr/bin/env bash
malloclib=$1
echo "reached custom allocator script"
LD_PRELOAD=$malloclib ./a.out
