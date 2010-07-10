package CInitiative;

use Date::Parse;
use CArea;
use config;
use strict;

sub new {my ($obj, $xml, $use_db)=@_;
	my $ref = {};
	bless($ref, $obj);
	$ref->{'id'} = int($xml->id->getString());
	$ref->{'issue_id'} = int($xml->issue_id->getString());
	$ref->{'name'} = $xml->name->getString();
	$ref->{'issueState'} = $xml->issue_state->getString();
	$ref->{'draftText'} = $xml->current_draft_content->getString();
	$ref->{'discussionUrl'} = $xml->discussion_url->getString();
	$ref->{'xml'} = $xml;
	if ($use_db) {
		$ref->{'area'} = CArea::load_from_db(int($xml->area_id->getString()),
			$xml->area_name->getString());
	} else {
		$ref->{'area'} = new CArea(int($xml->area_id->getString()),
			$xml->area_name->getString());
	}
	return $ref;
}

sub getId {my $obj = shift;$obj->{'id'};}
sub getIssueId {my $obj = shift;$obj->{'issue_id'};}
sub getName {my $obj = shift;$obj->{'name'};}
sub getIssueState {my $obj = shift;$obj->{'issueState'};}
sub getDraftText {my $obj=shift;$obj->{'draftText'};}
sub getDiscussionUrl {my $obj=shift;$obj->{'discussionUrl'};}
sub getXML {my $obj=shift;$obj->{'xml'};}
sub getArea {my $obj=shift;$obj->{'area'};}

sub hasDiscussion {my $obj = shift;
	length($obj->{'discussionUrl'})>0;
}

sub getTimestamp {my ($obj, $what, $max)=@_;
	my $ret = int(str2time($obj->{'xml'}->$what->getString()));
	$$max = $ret if ($max and $ret > $$max);
	return $ret;
}

sub isRevoked {my $obj = shift;
	$obj->getTimestamp('revoked') > 0;
}

sub check_updates_from_db {my ($obj, $updates)=@_;
	my $row;
	Db::sthGetIssue->execute($obj->getIssueId());
	if ($row = Db::sthGetIssue->fetchrow_hashref) {
		if ($obj->getIssueState() ne $row->{'state'}) {
			$updates->newIssueState($obj) unless $obj->isRevoked();
		}
		Db::sthUpdateIssue->execute(
			$obj->getIssueState(),
			$obj->getXML->issue_created->getString(),
			$obj->getXML->issue_accepted->getString(),
			$obj->getXML->issue_half_frozen->getString(),
			$obj->getXML->issue_fully_frozen->getString(),
			$obj->getXML->issue_closed->getString(),
			$obj->getIssueId()
		);
	} else {
		$updates->newIssue($obj);
		Db::sthInsertIssue->execute(
			$obj->getIssueId(), $obj->getArea->getId(), $obj->getIssueState(),
			$obj->getXML->issue_created->getString(),
			$obj->getXML->issue_accepted->getString(),
			$obj->getXML->issue_half_frozen->getString(),
			$obj->getXML->issue_fully_frozen->getString(),
			$obj->getXML->issue_closed->getString()
		);
	}
	
	Db::sthGetInitiative->execute($obj->getId());
	if ($row = Db::sthGetInitiative->fetchrow_hashref) {
		if ($obj->getDraftText() ne $row->{'draft_content'} || $obj->getName() ne $row->{'name'}) {
			$updates->initiativeTextUpdated($obj);
		}
		Db::sthUpdateInitiative->execute(
			$obj->getName(),
			$obj->getDiscussionUrl(),
			$obj->getXML()->created_at->getString(),
			$obj->getXML()->draft_updated_at->getString(),
			$obj->getDraftText(), $obj->getId());
	} else {
		$updates->newInitiative($obj);
		Db::sthInsertInitiative->execute(
			$obj->getId(), $obj->getArea()->getId(), $obj->getName(),
			$obj->getDiscussionUrl(),
			$obj->getXML()->created->getString(),
			$obj->getXML()->current_draft_created->getString(),
			$obj->getDraftText());
	}
}

sub check_lr_updates {my ($obj, $lastRunTimestamp, $updates, $max)=@_;
	if ($lastRunTimestamp < $obj->getTimestamp('issue_created', $max)) {
		$updates->newIssue($obj);
	} elsif (
		$lastRunTimestamp < $obj->getTimestamp('issue_accepted', $max) ||
		$lastRunTimestamp < $obj->getTimestamp('issue_half_frozen', $max) ||
		$lastRunTimestamp < $obj->getTimestamp('issue_fully_frozen', $max) ||
		$lastRunTimestamp < $obj->getTimestamp('issue_closed', $max)) {
		$updates->newIssueState($obj) unless $obj->isRevoked();
	}
	if ($lastRunTimestamp < $obj->getTimestamp('created', $max)) {
		$updates->newInitiative($obj);
	} elsif ($lastRunTimestamp < $obj->getTimestamp('current_draft_created', $max)) {
		$updates->initiativeTextUpdated($obj);
	}
	if ($lastRunTimestamp < $obj->getTimestamp('revoked', $max)) {
		$updates->initiativeRevoked($obj);
	}
}

1;

