#!/usr/bin/env perl
# this is a script which simply checks the LQFB Host and mails the updated initiatives.
# it uses a status file defined in config.pm to check the date for the last run
# and the minimum initiative id
#
# if run for the first time, nothing will done only the min id and the last time is set
# to the current timestamp
#
# add the parameter 'summary' if you want only a summary mail

use config;
use Date::Parse;
use strict;
use MyMailer;
use encoding 'utf8';
use LWP::UserAgent;
use XML::EasyOBJ;
use CUpdateCollection;

my $lastRunTimestamp=undef;
my $minid = 0;
if (open(STATUSFILE, "<$config::SIMPLE_CHECK_FILE")) {
	my @lines = <STATUSFILE>;
	$lastRunTimestamp = $lines[0];
	$minid = $lines[1];
	close(STATUSFILE);
}

my $after_action = $ARGV[0];
if ($after_action ne '' && $after_action ne 'summary') {
	die("Usage: simple_check_script.pl [summary]");
}

my $browser = LWP::UserAgent->new;
my $xml_file = $browser->get("$config::LQFB_ROOT/api/initiative.html?key=$config::LQFB_API_KEY&min_id=$minid");
my $xml_doc = new XML::EasyOBJ(-type => 'string', -param=>$xml_file->content);
my @all_initiatives = $xml_doc->getElement('initiative');

$minid = 0;
my $min_fixed = 0;
my $updates = new CUpdateCollection();
foreach my $initiative (@all_initiatives) {
	check_for_update($initiative, $updates) if $lastRunTimestamp;
	unless ($min_fixed) {
		if ($initiative->issue_state->getString() eq 'finished' || $initiative->issue_state->getString() eq 'cancelled') {
			$minid = int($initiative->id->getString());
		} else {
			$min_fixed = 1;
		}
	}
}

if ($lastRunTimestamp) {
	if ($after_action eq 'summary') {
		MyMailer::mail_all_updates($updates);
	} else {
		# TODO: Refac this CopyPaste shit to the CUpdateCollection class
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
	}
}

open(STATUSFILE, ">$config::SIMPLE_CHECK_FILE") or die("Could not open Status File for writing!");
print STATUSFILE time()."\n$minid\n";
close(STATUSFILE);

sub check_for_update {my ($initiative, $updates)=@_;
	my $issue_id = int($initiative->issue_id->getString());
	if ($lastRunTimestamp < asTimestamp($initiative, 'issue_created')) {
		$updates->newIssue($issue_id);
	} elsif (
		$lastRunTimestamp < asTimestamp($initiative, "issue_accepted") ||
		$lastRunTimestamp < asTimestamp($initiative, "issue_half_frozen") ||
		$lastRunTimestamp < asTimestamp($initiative, "issue_fully_frozen") ||
		$lastRunTimestamp < asTimestamp($initiative, 'issue_closed')) {
		$updates->newIssueState($issue_id, $initiative->issue_state->getString());
	}
	my $draft_text = $initiative->current_draft_content->getString();
	my $name = $initiative->name->getString();
	my $id = int($initiative->id->getString());
	if ($lastRunTimestamp < asTimestamp($initiative, 'created')) {
		$updates->newInitiative($id, $issue_id, $name, $draft_text);
	} elsif ($lastRunTimestamp < asTimestamp($initiative, 'current_draft_created')) {
		$updates->initiativeTextUpdated($id, $draft_text, $name);
	}
}

sub asTimestamp {my ($initiative, $what)=@_;
	int(str2time($initiative->$what->getString()));
}

