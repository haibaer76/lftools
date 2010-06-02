package Db;

use config;
use DBI;
use strict;

my $_dbh = undef;
sub dbh {
	unless($_dbh) {
		$_dbh = DBI->connect("dbi:mysql:host=$config::DATABASE_HOST;database=$config::DATABASE_NAME",
			$config::DATABASE_USER, $config::DATABASE_PASSWORD);
		$_dbh->do("SET NAMES utf8");
	}
	return $_dbh;
}

1;

