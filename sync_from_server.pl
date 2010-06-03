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
foreach my $initiative (@all_initiatives) {
	update_initiative($initiative, $updates);
}

if ($after_action eq 'mail') {
	my $newIssues = $updates->getNewIssues();
	for (my $i=0;$i<$newIssues->getSize();$i++) {
		MyMailer::mail_new_issue($newIssues->getAt($i));
	}
	my $newInitiatives = $updates->getNewInitiatives();
	for (my $i=0;$i<$newInitiatives->getSize();$i++) {
		MyMailer::mail_new_initiative($newInitiatives->getAt($i));
	}
	my $changedIssues = $updates->getChangedIssues();
	foreach my $key (keys(%$changedIssues)) {
		MyMailer::mail_changed_issue($key, $changedIssues->{$key});
	}
	my $changedInitiatives = $updates->getChangedInitiatives();
	foreach my $key (keys(%$changedInitiatives)) {
		MyMailer::mail_changed_initiative($key, $changedInitiatives->{$key});
	}
} elsif ($after_action eq 'summary') {
	MyMailer::mail_all_updates($updates);
}

sub update_initiative { my ($initiative, $updates)=@_;
	# first check if theme already exists
	my $area_id = int($initiative->area_id->getString());
	$sthGetArea->execute($area_id);
	my $row;
	if ($row = $sthGetArea->fetchrow_hashref) {
		$area_id = $row->{'id'};
	} else {
		$sthInsertArea->execute(
			$area_id,
			$initiative->area_name->getString()
		);
	}
	my $ret = {};
	my $issue_id = int($initiative->issue_id->getString());
	my $state = $initiative->issue_state->getString();
	$sthGetIssue->execute($issue_id);
	if ($row = $sthGetIssue->fetchrow_hashref) {
		# Check if something in the issue has been changed
		if ($state ne $row->{'state'}) {
			$updates->newIssueState($issue_id, $state);
		}
		$sthUpdateIssue->execute(
			$state, 
			$initiative->issue_created->getString(),
			$initiative->issue_accepted->getString(),
			$initiative->issue_half_frozen->getString(),
			$initiative->issue_fully_frozen->getString(),
			$initiative->issue_closed->getString(),
			$issue_id
		);
	} else {
		$updates->newIssue($issue_id);
		$sthInsertIssue->execute(
			$issue_id, $area_id, $state,
			$initiative->issue_created->getString(),
			$initiative->issue_accepted->getString(),
			$initiative->issue_half_frozen->getString(),
			$initiative->issue_fully_frozen->getString(),
			$initiative->issue_closed->getString()
		);
	}
	# now check if the initiative already exists
	my $id = int($initiative->id->getString());
	my $draft_text = $initiative->current_draft_content->getString();
	my $name = $initiative->name->getString();
	$sthGetInitiative->execute($id);
	$row = $sthGetInitiative->fetchrow_hashref;
	if ($row) {
		if ($draft_text ne $row->{'draft_content'} ||
			$name ne $row->{'name'}) {
			$updates->initiativeTextUpdated($id, $draft_text, $name);
		}
		$sthUpdateInitiative->execute(
			$name,
			$initiative->discussion_url->getString(),
			$initiative->created->getString(),
			$initiative->current_draft_created->getString(),
			$draft_text,
			$id
		);
	} else {
		$updates->newInitiative($id, $issue_id, $name, $draft_text);
		$sthInsertInitiative->execute(
			$id, $issue_id, $name,
			$initiative->discussion_url->getString(),
			$initiative->created->getString(),
			$initiative->current_draft_created->getString(),
			$draft_text
		);
	}
}
