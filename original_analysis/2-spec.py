#!/usr/bin/env python3

import argparse
import os
import sys
import csv
import numpy

from os import path
from collections import defaultdict

ALLOCATORS = [
    'glibc',
    'jemalloc',
    'mesh0n',
    'mesh0y',
    'mesh1y',
    'mesh2y',
]

DATA_DIR = path.join('results/2-spec')

DATASET_PREFIX = ''

RELATIVE_TO = 'glibc'

# key to use for benchmark runtime
RUNTIME = 'Est. Base Run Time'

# from rainbow
def make_reporter(verbosity, quiet, filelike):
    '''
    Returns a function suitible for logging use.
    '''
    if not quiet:
        def report(level, msg, *args):
            'Log if the specified severity is <= the initial verbosity.'
            if level <= verbosity:
                if len(args):
                    filelike.write(msg % args + '\n')
                else:
                    filelike.write('%s\n' % (msg, ))
    else:
        def report(level, msg, *args):
            '/dev/null logger.'
            pass

    return report


ERROR = 0
WARN = 1
INFO = 2
DEBUG = 3
log = make_reporter(WARN, False, sys.stderr)


# with open('data/specint2006-mesh/CINT2006.001.ref.csv', newline='') as file:
#     reader = csv.reader(file)
#     for row in reader:
#         print(row)

def mem_stats(allocator, benchmark):
    benchmark = benchmark.split('.')[1]
    if benchmark == 'xalancbmk':
        benchmark = 'Xalan'
    mstats_dir = path.join(DATA_DIR, DATASET_PREFIX + allocator, 'mstat')
    logs = [f for f in os.listdir(mstats_dir) if f.startswith(benchmark + '-')]
    usage = []
    for log_file in logs:
        log_path = path.join(mstats_dir, log_file)
        with open(log_path, newline='') as log_file:
            reader = csv.DictReader(log_file, dialect=csv.excel_tab)
            for row in reader:
                # convert from bytes to MB
                usage.append(int(row['rss'])/1024.0/1024.0)
    usage = numpy.array(usage)

    amax = numpy.amax(usage)
    mean = numpy.mean(usage)
    median = numpy.median(usage)
    stddev = numpy.std(usage)

    log(DEBUG, '%s/%s: %d %.2f %.2f (+- %.2f) %.2f', allocator, benchmark, len(usage), median, mean, stddev, amax)

    return {
        'max': amax,
        'mean': mean,
        'median': median,
        'stddev': stddev,
    }

def build_table(output_file):
    dirs = sorted([d for d in os.listdir(DATA_DIR) if d.startswith(DATASET_PREFIX) and os.path.isdir(path.join(DATA_DIR, d))])
    log(DEBUG, 'dirs: %s', dirs)

    runs = {}
    for d in dirs:
        d = path.join(DATA_DIR, d)
        name = path.basename(d).split('-', 1)[-1]
        if name == 'libc':
            log(WARN, 'skipping %s -- glibc now used, ShareLaTeX bug.' % name)
            continue
        log(DEBUG, 'reading %s', name)

        csv_files = sorted([f for f in os.listdir(d) if f.endswith('.csv')])
        if len(csv_files) != 1:
            log(ERROR, 'expected only one CSV, not %s', csv_files)
            sys.exit(-1)

        csv_file = path.join(d, csv_files[-1])
        with open(csv_file, newline='') as file:
            reader = csv.reader(file)

            table = []
            found_table = False
            should_skip = True
            for row in reader:
                if len(row) > 0 and row[0] == 'Selected Results Table':
                    found_table = True
                    continue
                elif not found_table:
                    continue

                if len(row) == 0:
                    if should_skip:
                        should_skip = False
                        continue
                    else:
                        break

                table.append(row)

            # build a mapping of string column names to column offsets
            keys = {}
            for col_name in table[0]:
                keys[col_name] = len(keys)

            dataset = {}
            for row in table[1:]:
                run = {}
                for key in sorted(keys.keys()):
                    run[key] = row[keys[key]]

                dataset[run['Benchmark']] = run
            runs[name] = dataset

    allocator_stats = {}

    benchmark_count = len(sorted(runs[next(iter(runs.keys()))]))

    bench_rows = []
    # pivot so that we have a row per SPECint benchmark
    for benchmark in sorted(runs[next(iter(runs.keys()))]):
        benchmark_runtime = float(runs[RELATIVE_TO][benchmark][RUNTIME])
        memory_by_allocator = defaultdict(map)

        if set(runs.keys()) - set(ALLOCATORS) != set():
            missing = set(runs.keys()) - set(ALLOCATORS)
            log(ERROR, 'Error: skipping results for %s', missing)
            # raise Exception('Skipping results')

        for run in ALLOCATORS:
            runtime = runs[run][benchmark][RUNTIME]
            runtime_relative = float(runtime)/benchmark_runtime

            mem_info = mem_stats(run, benchmark)
            memory_by_allocator[run] = mem_info

            max_rel = mem_info['max'] / memory_by_allocator['glibc']['max']
            median_rel = mem_info['median'] / memory_by_allocator['glibc']['median']
            mean_rel = mem_info['mean'] / memory_by_allocator['glibc']['mean']
            stddev_rel = mem_info['stddev'] / memory_by_allocator['glibc']['stddev']

            row = {
                'benchmark': benchmark,
                'allocator': run,
                'runtime': runtime,
                'runtime_relative': runtime_relative,
                'mem_max_rel': max_rel,
                'mem_median_rel': median_rel,
                'mem_mean_rel': mean_rel,
                'mem_stddev_rel': stddev_rel,
                'mem_max_mb': mem_info['max'],
                'mem_median_mb': mem_info['median'],
                'mem_mean_mb': mem_info['mean'],
                'mem_stddev_mb': mem_info['stddev'],
            }
            bench_rows.append(row)
            if run not in allocator_stats:
                allocator_stats[run] = defaultdict(lambda: float(1))
            allocator_stats[run]['runtime_relative'] *= runtime_relative
            allocator_stats[run]['mem_max'] *= max_rel
            allocator_stats[run]['mem_mean'] *= mean_rel
            if 'runtime_median' not in allocator_stats[run]:
                allocator_stats[run]['runtime_median'] = [runtime_relative]
            else:
                allocator_stats[run]['runtime_median'].append(runtime_relative)
            if 'mem_median' not in allocator_stats[run]:
                allocator_stats[run]['mem_median'] = [mean_rel]
            else:
                allocator_stats[run]['mem_median'].append(mean_rel)
            allocator_stats[run]['mem_stddev'] *= stddev_rel

            # mybe we want a different default dict, but whatever
            if allocator_stats[run]['mem_max_mb'] == 1:
                allocator_stats[run]['mem_max_mb'] = 0
                allocator_stats[run]['mem_mean_mb'] = 0
                allocator_stats[run]['mem_median_mb'] = 0
                allocator_stats[run]['mem_stddev_mb'] = 0

            allocator_stats[run]['mem_max_mb'] += mem_info['max']
            allocator_stats[run]['mem_mean_mb'] += mem_info['mean']
            allocator_stats[run]['mem_median_mb'] += mem_info['median']
            allocator_stats[run]['mem_stddev_mb'] += mem_info['stddev']

    for allocator in ALLOCATORS:
        stats = allocator_stats[allocator]
        benchmark_count = float(benchmark_count)
        exp = 1 / benchmark_count
        mem_median = (stats['mem_median'][int(benchmark_count/2)] +
                      stats['mem_median'][int((benchmark_count+1)/2)]) / 2
        run_median = (stats['runtime_median'][int(benchmark_count/2)] +
                      stats['runtime_median'][int((benchmark_count+1)/2)]) / 2

        row = {
            'benchmark': 'geomean',
            'allocator': allocator,
            'runtime': '',
            'runtime_relative': stats['runtime_relative'] ** exp,
            'runtime_median': run_median,
            'mem_max_rel': stats['mem_max'] ** exp,
            'mem_median_rel': mem_median,
            'mem_mean_rel': stats['mem_mean'] ** exp,
            'mem_stddev_rel': stats['mem_stddev'] ** exp,
            'mem_max_mb': stats['mem_max_mb'] / benchmark_count,
            'mem_median_mb': stats['mem_max_mb'] / benchmark_count,
            'mem_mean_mb': stats['mem_max_mb'] / benchmark_count,
            'mem_stddev_mb': stats['mem_max_mb'] / benchmark_count,
        }
        bench_rows.append(row)

    col_names = [
        'benchmark', 'allocator', 'runtime', 'runtime_relative', 'runtime_median',
        'mem_max_rel', 'mem_median_rel', 'mem_mean_rel', 'mem_stddev_rel',
        'mem_max_mb', 'mem_median_mb', 'mem_mean_mb', 'mem_stddev_mb',
    ]
    writer = csv.DictWriter(output_file, col_names, dialect=csv.excel_tab)
    writer.writeheader()
    writer.writerows(bench_rows)

    log(DEBUG, '%d runs', len(runs))
    log(DEBUG, '\t%s', runs[RELATIVE_TO]['400.perlbench'][RUNTIME])


def main():
    global log

    parser = argparse.ArgumentParser(description='Build a table we can easily use in R from raw SPEC data.')
    parser.add_argument('-v', action='store_const', const=True, help='print commit messages too')
    parser.add_argument('output', nargs='?', type=str, default='results/2-spec/results.tsv', help='output file')
    args = parser.parse_args()

    if args.v:
        log = make_reporter(DEBUG, False, sys.stderr)

    log(DEBUG, 'writing to %s', args.output)

    if not args.output:
        build_table(sys.stdout)
    else:
        try:
            with open(args.output, 'w') as output_file:
                build_table(output_file)
        except Exception as e:
            os.remove(args.output)
            raise e


if __name__ == '__main__':
    sys.exit(main())
