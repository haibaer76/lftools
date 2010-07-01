#!/usr/bin/env perl
#
require 'config.pm';

use strict;
use LWP::UserAgent;
use XML::EasyOBJ;
use Db;
use CUpdateCollection;
use Data::Dumper;
use encoding 'utf8';
use MyMailer;
use CInitiative;

my $browser = LWP::UserAgent->new;
my $xml_file = $browser->get($config::LQFB_ROOT."/api/initiative.html?key=$config::LQFB_API_KEY");
my $xml_doc = new XML::EasyOBJ(-type => 'string', -param=>$xml_file->content);
my $after_action = $ARGV[0];
if ($after_action ne '' && $after_action ne 'mail' && $after_action ne 'summary') {
	die("Usage: sync_from_server.pl [mail|summary]");
}
my $sthGetArea = Db::dbh->prepare(q(
		SELECT * FROM t_areas WHERE id=?
	));
my $sthInsertArea = Db::dbh->prepare(q(
		INSERT INTO t_areas(id, name) VALUES (?, ?)
	));
my $sthGetIssue = Db::dbh->prepare(q(
	SELECT * FROM t_issues WHERE id=?
));
my $sthUpdateIssue = Db::dbh->prepare(q(
	UPDATE t_issues SET
		state=?,
		created_at=?,
		accepted_at = ?,
		half_frozen_at = ?,
		fully_frozen_at = ?,
		closed_at = ?
	WHERE id=?
));
my $sthInsertIssue = Db::dbh->prepare('
	INSERT INTO t_issues(id, area_id, state, created_at, accepted_at, half_frozen_at, fully_frozen_at, closed_at)
	VALUES (?, ?, ?, ?, ?, ?, ?, ?)
');
my $sthGetInitiative = Db::dbh->prepare('
	SELECT * FROM t_initiatives WHERE id=?
');
my $sthUpdateInitiative = Db::dbh->prepare('
	UPDATE t_initiatives SET
		name = ?,
		discussion_url = ?,
		created_at = ?,
		draft_updated_at = ?,
		draft_content = ?
	WHERE id = ?
');
my $sthInsertInitiative = Db::dbh->prepare('
	INSERT INTO t_initiatives(
		id, issue_id, name, discussion_url, created_at, draft_updated_at, draft_content)
		VALUES (?, ?, ?, ?, ?, ?, ?)
');

my @all_initiatives = $xml_doc->getElement('initiative');
my $updates = new CUpdateCollection;
foreach (@all_initiatives) {
	my $initiative = new CInitiative($_, 1);
	$initiative->check_updates_from_db($updates);
}

if ($after_action eq 'mail') {
	MyMailer::mail_single_updates($updates);
} elsif ($after_action eq 'summary') {
	MyMailer::mail_all_updates($updates);
}

