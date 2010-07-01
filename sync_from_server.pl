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

