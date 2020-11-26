#!/bin/bash
dbname="testdb"
tablename="usertable"

malloclib=$1 
DIR=$2
FREQ=$3
i=$4
mlibname=$5


mkdir -p /var/run/mysqld
chown mysql:mysql /var/run/mysqld
 
mysqladmin processlist > /dev/null 2>&1

if [ $? == 0 ] # $? tells you if the previous command errored out
then
	mysqladmin shutdown mysqld_safe
fi

if [ $malloclib == "malloc" ]
then
	mstat -o "$DIR/output/runmysql.sh/$i-$mlibname.tsv" -freq "$FREQ" -- mysqld_safe &
else
	mstat -o "$DIR/output/runmysql.sh/$i-$mlibname.tsv" -freq "$FREQ" -- mysqld_safe --malloc-lib=$malloclib &
fi

sleep 2
mysql -u root -D $dbname -e "drop table if exists $tablename;" 

ycsbpath="/usr/local/bin"
export PATH="$PATH:$ycsbpath/go-ycsb/bin"

go-ycsb load mysql -p mysql.host=127.0.0.1 -p mysql.port=3306 -p mysql.user=root -p mysql.password=password -p mysql.db=testdb -p recordcount=1000 -p threadcount=2

go-ycsb run mysql -P $ycsbpath/go-ycsb/workloads/workloada -p mysql.host=127.0.0.1 -p mysql.port=3306 -p mysql.user=root -p mysql.password=password -p mysql.db=testdb -p recordcount=1000 -p threadcount=2

mysqladmin shutdown mysqld_safe

