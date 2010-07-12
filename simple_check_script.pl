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
use strict;
use MyMailer;
use encoding 'utf8';
use LWP::UserAgent;
use XML::EasyOBJ;
use CUpdateCollection;
use CInitiative;
use MyUtils::CArray;

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
my $parsed_initiatives = new CArray;

$minid = 0;
my $min_fixed = 0;
my $maxTimestamp = 0;
my $updates = new CUpdateCollection();
foreach (@all_initiatives) {
	my $initiative = new CInitiative($_);
	$initiative->check_lr_updates($lastRunTimestamp, $updates, \$maxTimestamp) if $lastRunTimestamp;
	unless ($min_fixed) {
		if ($initiative->getIssueState() eq 'finished' || $initiative->getIssueState() eq 'cancelled') {
			$minid = int($initiative->getId());
		} else {
			$min_fixed = 1;
		}
	}
	$parsed_initiatives->addElement($initiative);
}

if ($lastRunTimestamp) {
	if ($after_action eq 'summary') {
		MyMailer::mail_all_updates($updates);
	} else {
		MyMailer::mail_single_updates($updates);
	}
}

for (my $i=0;$i<$parsed_initiatives->getSize();$i++) {
	$parsed_initiatives->getAt($i)->save();
}
open(STATUSFILE, ">$config::SIMPLE_CHECK_FILE") or die("Could not open Status File for writing!");
print STATUSFILE  "$maxTimestamp\n$minid\n";
close(STATUSFILE);
