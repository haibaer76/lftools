#!/bin/bash

source load_config.sh

cat <<EOF | mysql $mysql_cmd_opts -h $db_host -u $db_user -p$db_pass
DROP DATABASE IF EXISTS $db_name;
CREATE DATABASE $db_name;
USE $db_name
CREATE TABLE t_migrations_performed(
	id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
	filename VARCHAR(255),
	UNIQUE INDEX(filename)
);
EOF

./migrate.sh

