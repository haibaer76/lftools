#!/bin/bash

source load_config.sh

tmpfile=`$tmpmaker`
cd dbsetup
for i in *.sql ; do echo $i >> $tmpfile ; done
migration_files=`cat $tmpfile | sort`
rm $tmpfile

for i in $migration_files ; do
	nof=`mysql -e "SELECT COUNT(*) FROM t_migrations_performed WHERE filename='$i';" -B -N $mysql_args`
	if [ $nof -eq 0 ] ; then
		echo "Migrating $i..."
		(cat $i ; echo "INSERT INTO t_migrations_performed(filename) VALUES ('$i');" ) | mysql $mysql_args
	fi
done
cd ..

