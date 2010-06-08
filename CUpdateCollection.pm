package CUpdateCollection;

use strict;
use MyUtils::CArray;

sub new {my $obj = shift;
	my $ref = {};
	bless($ref, $obj);
	$ref->{'changedIssues'} = {};
	$ref->{'newIssues'} = new CArray;
	$ref->{'changedInitiatives'} = {};
	$ref->{'newInitiatives'} = new CArray;
	return $ref;
}

sub newIssueState {my ($obj, $issue_id, $newState)=@_;
	unless ($obj->{'changedIssues'}->{$issue_id}) {
		$obj->{'changedIssues'}->{$issue_id}={};
	}
	$obj->{'changedIssues'}->{$issue_id}->{'newState'} = $newState;
}

sub newIssue {my ($obj, $issue_id)=@_;
	$obj->{'newIssues'}->addElement($issue_id) unless $obj->{'newIssues'}->exists($issue_id);
}

sub initiativeTextUpdated {my ($obj, $id, $text, $name) = @_;
	unless ($obj->{'changedInitiatives'}->{$id}) {
		$obj->{'changedInitiatives'}->{$id} = {};
	}
	
	$obj->{'changedInitiatives'}->{$id}->{'draft_text'} = $text;
	$obj->{'changedInitiatives'}->{$id}->{'name'} = $name;
}

sub newInitiative {my ($obj, $id, $issue_id, $name, $draft_text) = @_;
	my $h = {};
	$h->{'id'} = $id;
	$h->{'issue_id'} = $issue_id;
	$h->{'name'} = $name;
	$h->{'draft_text'} = $draft_text;
	$obj->{'newInitiatives'}->addElement($h);
}

sub getNewIssues {my $obj = shift;
	return $obj->{'newIssues'};
}

sub getNewInitiatives {my $obj=shift;
	return $obj->{'newInitiatives'};
}

sub getChangedIssues() {my $obj=shift;
	return $obj->{'changedIssues'};
}

sub getChangedInitiatives() {my $obj=shift;
	return $obj->{'changedInitiatives'};
}
1;
