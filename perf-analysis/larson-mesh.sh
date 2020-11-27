#!/bin/bash
$malloclib=$1
LD_PRELOAD=$malloclib ./larson 20 7 8 10000 10000 1 16
