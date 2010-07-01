package CArea;

use strict;
use Db;

sub new {my ($obj, $id, $name)=@_;
	my $ref = {};
	bless($ref, $obj);
	$ref->{'id'} = $id;
	$ref->{'name'} = $name;
	return $ref;
}

sub load_from_db { my ($id, $name) = @_ ;
	Db::sthGetArea->execute($id);
	my $row = Db::sthGetArea->fetchrow_hashref;
	return new CArea($row->{'id'}, $row->{'name'}) if ($row);
	Db::sthInsertArea->execute($id, $name);
	return new CArea($id, $name);
}

sub getId { my $obj = shift; $obj->{'id'}; }
sub getName { my $obj = shift; $obj->{'name'};}

1;
