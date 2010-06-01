mysql_cmd_opts="--default-character-set=utf8"

db_host=`cat config.pm ; echo "print \\$DATABASE_HOST;"`; db_host=`echo "$db_host" | perl`
db_name=`cat config.pm ; echo "print \\$DATABASE_NAME;"`; db_name=`echo "$db_name" | perl`
db_user=`cat config.pm ; echo "print \\$DATABASE_USER;"`; db_user=`echo "$db_user" | perl`
db_pass=`cat config.pm ; echo "print \\$DATABASE_PASSWORD;"`; db_pass=`echo "$db_pass" | perl`

mysql_args="$mysql_cmd_opts -h $db_host -u $db_user -p$db_pass $db_name"

tmpmaker=mktemp

