#!/bin/bash
dbname="testdb"
tablename="usertable"

# first command line arg:
# for mesh -> "/usr/lib/libmesh.so" 
# for jemalloc -> "/usr/lib/x86_64-linux-gnu/libjemalloc.so"
# for malloc -> "malloc"
malloclib=$1 
# second command line arg: tmp filename which is used to create o/p csv
tmpfile=$2


mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld
 
mysqladmin processlist > /dev/null 2>&1

if [ $? == 0 ] # $? tells you if the previous command errored out
then
	mysqladmin shutdown mysqld_safe
fi

echo $malloclib
if [ $malloclib == "malloc" ]
then
	echo "reached malloc"
	(time -p mysqld_safe &) 2> $tmpfile
	#tail -n 3 $tmpfile > t
	#cat t > $tmpfile
	# nohup perf stat -e dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses -x' ' -o $tmpfile mysqld_safe &
else
	echo "reachd $malloclib"
	(time -p mysqld_safe --malloc-lib=$malloclib &) 2> $tmpfile
#	tail -n 3 $tmpfile > t
 #       cat t > $tmpfile
	# nohup perf stat -e dTLB-load-misses,iTLB-load-misses,dTLB-store-misses,cache-references,cache-misses  -x' ' -o $tmpfile mysqld_safe --malloc-lib=$malloclib &
fi

sleep 2
mysql -u root -D $dbname -e "drop table if exists $tablename;" 

ycsbpath="/usr/local/bin"
export PATH="$PATH:$ycsbpath/go-ycsb/bin"

go-ycsb load mysql -p mysql.host=127.0.0.1 -p mysql.port=3306 -p mysql.user=root -p mysql.password=password -p mysql.db=testdb -p recordcount=1000 -p threadcount=2

go-ycsb run mysql -P $ycsbpath/go-ycsb/workloads/workloada -p mysql.host=127.0.0.1 -p mysql.port=3306 -p mysql.user=root -p mysql.password=password -p mysql.db=testdb -p recordcount=1000 -p threadcount=2

mysqladmin shutdown mysqld_safe

