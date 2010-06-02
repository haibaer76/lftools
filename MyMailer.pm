package MyMailer;

require config;
use strict;

sub send_mail {my ($subject, $body) = @_;
	open(MAILPROG,"|mail -s \"$subject\" -t $config::MAIL_RECIEVER");
	print MAILPROG $body;
	close(MAILPROG);
}

sub mail_new_issue {my $issue_id = shift;
	send_mail("Neues Thema im Liquid Feedback",
qq(Hallo,

es wurde ein neues Thema ins Liquid Feedback gestellt. Zum Betrachten bitte
hier klicken:
$config::LQFB_ROOT/issue/show/$issue_id.html

Mit freundlichen Gruessen,
Dein LiquidFeedback-Service-Skript
));
}

sub mail_new_initiative {my $initiativeHash = shift;
	send_mail("Neue Initiative in Liquid Feedback",
qq(Hallo,

es wurde eine neue Initative im Thema # $initiativeHash->{'issue_id'} erzeugt.

Name der Initiative: $initiativeHash->{'name'}

Entwurfstext:
$initiativeHash->{'draft_text'}

Zum Betrachten der Initiative hier klicken:
$config::LQFB_ROOT/initiative/show/$initiativeHash->{'id'}.html

Zum Betrachten des Themas hier klicken:
$config::LQFB_ROOT/issue/show/$initiativeHash->{'issue_id'}.html

Mit freundlichen Gruessen,
Dein LiquidFeedback-Service-Skript
));

}

sub mail_changed_issue {my ($issue_id, $changeHash)=@_;
	send_mail("Liquid Feedback -- Thema neuer Status",
qq(Hallo,

Beim Thema # $issue_id hat sich der Status auf $changeHash->{'newState'}
geaendert.

Zum Betrachten des Themas bitte hier klicken:
$config::LQFB_ROOT/issue/show/$issue_id.html

Mit freundlichen Gruessen,
Dein LiquidFeedback-Service-Skript
));
}

sub mail_changed_initiative {my ($initiative_id, $changeHash)=@_;
	send_mail("Liquid Feedback -- Initiative wurde geaendert",
qq(Hallo,

Der Entwurfstext der Initiative
$changeHash->{'name'}
hat wurde vom Initiator bearbeitet. Der neue Entwurfstext lautet:
$changeHash->{'draft_text'}

Zum Betrachten der neuen Initiative bitte hier klicken:
$config::LQFB_ROOT/initiative/show/$initiative_id.html

Mit freunlichen Gruessen
Dein LiquidFeedback-Service-Skript
));
}
1;

