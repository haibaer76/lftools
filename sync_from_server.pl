#!/usr/bin/env perl
#
require 'config.pm';

use strict;
use LWP::Simple;
use DBI;
use XML::EasyOBJ;

my $xml_file = LWP::Simple::get($config::LQFB_ROOT."/api/initiative.html?key=$config::LQFB_API_KEY");

my $xml_doc = new XML::EasyOBJ(-type => 'string', -param=>$xml_file);

my @all_initiatives = $xml_doc->getElement('initiative');
foreach my $initiative (@all_initiatives) {
	update_initiative($initiative);
}

sub update_initiative { my $initiative = shift;
	
}
