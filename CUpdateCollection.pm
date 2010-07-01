package CUpdateCollection;

use strict;
use MyUtils::CArray;

sub new {my $obj = shift;
	my $ref = {};
	bless($ref, $obj);
	$ref->{'changedIssues'} = {};
	$ref->{'newIssues'} = new CArray;
	$ref->{'changedInitiatives'} = new CArray;
	$ref->{'newInitiatives'} = new CArray;
	$ref->{'revokedInitiatives'} = new CArray;
	return $ref;
}

sub newIssueState {my ($obj, $initiative)=@_;
	my $issue_id = $initiative->getIssueId();
	unless ($obj->{'changedIssues'}->{$issue_id}) {
		$obj->{'changedIssues'}->{$issue_id}={};
		$obj->{'changedIssues'}->{$issue_id}->{'initiatives'} = new CArray;
		$obj->{'changedIssues'}->{$issue_id}->{'newState'} = $initiative->getIssueState();
	}
	$obj->{'changedIssues'}->{$issue_id}->{'initiatives'}->addElement($initiative);
}

sub newIssue {my ($obj, $initiative)=@_;
	$obj->{'newIssues'}->addElement($initiative->getIssueId()) unless $obj->{'newIssues'}->exists($initiative->getIssueId());
}

sub initiativeTextUpdated {my ($obj, $initiative) = @_;
	$obj->{'changedInitiatives'}->addElement($initiative);
}

sub newInitiative {my ($obj, $initiative)=@_;
	$obj->{'newInitiatives'}->addElement($initiative);
}

sub initiativeRevoked {my ($obj, $initiative)=@_;
	$obj->{'revokedInitiatives'}->addElement($initiative);
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

