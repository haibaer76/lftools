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
	$ref->{'revokedInitiatives'} = new CArray;
	return $ref;
}

sub newIssueState {my ($obj, $issue_id, $newState, $initiative_id, $initiative_name, $ini_discussion_url)=@_;
	unless ($obj->{'changedIssues'}->{$issue_id}) {
		$obj->{'changedIssues'}->{$issue_id}={};
		$obj->{'changedIssues'}->{$issue_id}->{'initiatives'} = new CArray;
	}
	$obj->{'changedIssues'}->{$issue_id}->{'newState'} = $newState;
	my $hlp = {};
	$hlp->{'id'} = $initiative_id;
	$hlp->{'name'} = $initiative_name;
	$hlp->{'discussion_url'} = $ini_discussion_url;
	$obj->{'changedIssues'}->{$issue_id}->{'initiatives'}->addElement($hlp);
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

sub newInitiative {my ($obj, $id, $issue_id, $name, $draft_text, $discussion_url) = @_;
	my $h = {};
	$h->{'id'} = $id;
	$h->{'issue_id'} = $issue_id;
	$h->{'name'} = $name;
	$h->{'draft_text'} = $draft_text;
	$h->{'discussion_url'} = $discussion_url;
	$obj->{'newInitiatives'}->addElement($h);
}

sub initiativeRevoked {my ($obj, $issue_id, $name)=@_;
	my $h = {};
	$h->{'issue_id'} = $issue_id;
	$h->{'name'} = $name;
	$obj->{'revokedInitiatives'}->addElement($h);
}

sub getNewIssues {my $obj = shift;
	return $obj->{'newIssues'};
}

sub getNewInitiatives {my $obj=shift;
	return $obj->{'newInitiatives'};
}

sub getChangedIssues {my $obj=shift;
	return $obj->{'changedIssues'};
}

sub getChangedInitiatives {my $obj=shift;
	return $obj->{'changedInitiatives'};
}

sub getRevokedInitiatives {my $obj=shift;
	return $obj->{'revokedInitiatives'};
}

1;

