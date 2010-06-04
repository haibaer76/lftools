package Db;

use config;
use DBI;
use strict;

my $_dbh = undef;
my $_sthGetAppContext = undef;
my $_sthUpdateAppContext = undef;

sub dbh {
	unless($_dbh) {
		$_dbh = DBI->connect("dbi:mysql:host=$config::DATABASE_HOST;database=$config::DATABASE_NAME",
			$config::DATABASE_USER, $config::DATABASE_PASSWORD);
		$_dbh->do("SET NAMES utf8");
	}
	return $_dbh;
}

sub sthGetAppContext {
	unless($_sthGetAppContext) {
		$_sthGetAppContext = dbh->prepare('SELECT value FROM t_application_context WHERE name=?');
	}
	return $_sthGetAppContext;
}

sub sthUpdateAppContext {
	$_sthUpdateAppContext = dbh->prepare(
		'REPLACE INTO t_application_context(name, value) VALUES (?, ?)'
	) unless($_sthUpdateAppContext);
	return $_sthUpdateAppContext;
}

sub getApplicationContext {my $name = shift;
	sthGetAppContext->execute($name);
	my @row = sthGetAppContext->fetchrow_array;
	return $row[0];
}

sub setApplicationContext {my ($name, $value) = @_;
	sthUpdateAppContext->execute($name, $value);
}

1;

