package CInitiative;

sub new {my ($obj, $xml)=@_;
	my $ref = {};
	bless($ref, $obj);
	$ref->{'id'} = int($xml->id->getString());
	$ref->{'issue_id'} = int($xml->issue_id->getString());
	$ref->{'name'} = $xml->name->getString();
	$ref->{'state'} = $xml->issue_state->getString();
	$ref->{'xml'} = $xml;
	return $ref;
}

sub getId {my $obj = shift;$obj->{'id'};}
sub getIssueId {my $obj = shift;$obj->{'issue_id'};}
sub getName {my $obj = shift;$obj->{'name'};}
sub getState {my $obj = shift;$obj->{'state'};}

sub getTimestamp {my {$obj, $what, $max)=@_;
	my $ret = int($obj->{'xml'}->$what->getString());
	$$max = $ret if ($max and $ret > $$max);
	return $ret;
}

1;

