package Db;

use config;
use DBI;
use strict;

my $_dbh = undef;
my $_sthGetAppContext = undef;
my $_sthUpdateAppContext = undef;
my $_sthGetArea = undef;
my $_sthInsertArea = undef;
my $_sthGetIssue = undef;
my $_sthUpdateIssue = undef;
my $_sthInsertIssue = undef;
my $_sthGetInitiative = undef;
my $_sthUpdateInitiative = undef;
my $_sthInsertInitiative = undef;

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

sub sthGetArea {
	$_sthGetArea = dbh->prepare(
		'SELECT * FROM t_areas WHERE id = ?'
	) unless ($_sthGetArea);
	$_sthGetArea;
}

sub sthInsertArea {
	$_sthInsertArea = dbh->prepare(
		'INSERT INTO t_areas(id, name) VALUES (?, ?)'
	) unless ($_sthInsertArea);
	$_sthInsertArea;
}

sub sthGetIssue {
	$_sthGetIssue = dbh->prepare(
		'SELECT * FROM t_issues WHERE id=?'
	) unless ($_sthGetIssue);
	$_sthGetIssue;
}

sub sthUpdateIssue {
	$_sthUpdateIssue = dbh->prepare('
		UPDATE t_issues SET
			state=?,
			created_at=?,
			accepted_at = ?,
			half_frozen_at = ?,
			fully_frozen_at = ?,
			closed_at = ?
		WHERE id=?') unless $_sthUpdateIssue;
	$_sthUpdateIssue;
}

sub sthInsertIssue {
	$_sthInsertIssue = dbh->prepare('
		INSERT INTO t_issues(id, area_id, state, created_at, accepted_at, half_frozen_at, fully_frozen_at, closed_at)
		VALUES (?, ?, ?, ?, ?, ?, ?, ?)') unless $_sthInsertIssue;
	$_sthInsertIssue;
}

sub sthGetInitiative {
	$_sthGetInitiative = dbh->prepare('
		SELECT * FROM t_initiatives WHERE id = ?
	') unless $_sthGetInitiative;
	$_sthGetInitiative;
}

sub sthInsertInitiative {
	$_sthInsertInitiative = dbh->prepare('
		INSERT INTO t_initiatives(
			id, issue_id, name, discussion_url, created_at, draft_updated_at, draft_content)
			VALUES (?, ?, ?, ?, ?, ?, ?)') unless $_sthInsertInitiative;
	$_sthInsertInitiative;
}

sub sthUpdateInitiative {
	$_sthUpdateInitiative = dbh->prepare('
		UPDATE t_initiatives SET
			name = ?,
			discussion_url = ?,
			created_at = ?,
			draft_updated_at = ?,
			draft_content = ?
		WHERE id = ?') unless $_sthUpdateInitiative;
	$_sthUpdateInitiative;
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

