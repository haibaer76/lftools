package CStack;

sub new {
	my $obj=shift;
	my $referenz={};
	bless($referenz,$obj);
	$referenz->{size}=0;
	$referenz;
}

sub sPush {
	my ($self,$obj)=@_;
	$self->{$self->{size}}=$obj;
	$self->{size}++;
}

sub sPop {
	my $self=shift;
	my $obj=$self->{($self->{size}-1)};
	$self->{size}--;
	delete $self->{$self->{size}};
	return $obj;
}

sub sDup {
	my $self=shift;
	my $obj=$self->pop();
	$self->push($obj);
	$self->push($obj);
}

1;

