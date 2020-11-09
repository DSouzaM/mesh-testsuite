# About 

This work is part of a project for our [Experimental Performance Evaluation course](https://cs.uwaterloo.ca/~brecht/courses/854/index.html).

This repo is a fork of the original [Mesh testsuite](https://github.com/plasma-umass/mesh-testsuite), repurposed and extended to examine other programs and performance metrics. Thank you to the original authors for not only making these artifacts available, but also for making them well-written and straighforward to extend.


# Code overview

The driver for this test suite is `run`. It can be run as `./run`.

At a high level, this script:
1. Creates a Docker volume to persist test results
2. Runs each benchmark (which is itself a Docker image), mounting the results volume at `/data`
3. Moves results from the volume into `./results`
4. Runs analysis scripts (defined inside `./analysis`) which output tsv files inside the `./results` folder. These scripts run under a special Docker image (defined inside `./support`) which contains relevant analysis packages/libraries

Each benchmark has its own driver and analysis script, so each part is fairly self-contained. Sometimes the script contains specific code to support certain benchmarks (especially firefox).
