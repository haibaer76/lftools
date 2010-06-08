package CArray;

sub new {my $obj=shift;
	my $referenz={};
	bless($referenz,$obj);
	$referenz->{nof}=0;
	return $referenz;
}

sub addElement {my ($obj,$ele)=@_;
	$obj->{$obj->{nof}}=$ele;
	$obj->{nof}++;
}

sub getAt {my ($obj,$index)=@_;
	die "Index out of Bound" if ($index>=$obj->{nof});
	return $obj->{$index};
}

sub setAt {my ($obj,$index,$ele)=@_;
	$obj->{$index}=$ele;
	($index<$obj->{nof}) or $obj->{nof}=$index-1;
};

sub removeAt {my ($obj,$index)=@_;
	die "Index out of Bound" if ($index>=$obj->{nof});
	for (my $i=$index;$i<$obj->{nof}-1;$i++) {
		$obj->{$i}=$obj->{($i+1)};
	}
	$obj->{nof}--;
}

sub getSize {my $obj=shift;
	return $obj->{nof};
}

sub exists {my ($obj, $elem) = shift;
	for (my $i=0;$i<$obj->{nof};$i++) {
		return 1 if ($obj->{$i} == $elem);
	}
	return 0;
}

1;

