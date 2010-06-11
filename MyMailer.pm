package MyMailer;

require config;
use strict;
use Net::SMTP;

sub send_mail {my ($subject, $body) = @_;
	if ($config::MAIL_USE_SMTP) {
		  my ($subject, $body) = @_;
			my $reci = $config::MAIL_RECEIVER;
			my $absender = $config::MAIL_SENDER;
			my $smtp = Net::SMTP->new('localhost',
																Timeout => 60,
																Hello => 'root@localhost'
																);
			$smtp->mail($absender);
			$smtp->to($reci);
			$smtp->data();
			$smtp->datasend("To: $reci\n");
			$smtp->datasend("From: LiquidFeedback Service<$absender>\n");
			$smtp->datasend("Subject: $subject\n");
			$smtp->datasend("\n");
			$smtp->datasend($body);
			$smtp->datasend("\n");
			$smtp->dataend();
			$smtp->quit;
			
	} else {
		my $prog = $config::MAIL_PROGRAM;
		$prog =~ s/\{subject\}/$subject/;
		$prog =~ s/\{receiver\}/$config::MAIL_RECEIVER/;
		open(MAILPROG,"|$prog");
		print MAILPROG $body;
		close(MAILPROG);
	}
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
).($initiativeHash->{'discussion_url'} eq ''?''
:qq(
Diskussion zur Initiative unter
$initiativeHash->{'discussion_url'}
)).qq(
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

Dieses Thema beinhaltet die folgenden Initiativen:
).eval {
	my $tmp='';
	my $ary = $changeHash->{'initiatives'};
	for (my $i=0;$i<$ary->getSize();$i++) {
		$tmp.=($i+1).". ".$ary->getAt($i)->{'name'}."
$config::LQFB_ROOT/initiative/show/".$ary->getAt($i)->{'id'}.".html
";
	}
	$tmp;
}.qq(
Mit freundlichen Gruessen,
Dein LiquidFeedback-Service-Skript
));
}

sub mail_revoked_initiative {my $data = shift;
	send_mail("Liquid Feedback -- Initiative wurde zurueckgezogen",
qq(Hallo,

Die zum Thema # $data->{'issue_id'} zugehoerige Initiative mit dem Namen
$data->{'name'}
wurde vom Initiator zurueckgezogen.

Zum Betrachten des Themas (und der alternativen Initiativen) hier klicken:
$config::LQFB_ROOT/issue/show/$data->{'issue_id'}.html

Mit freundlichen Gruessen
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

Mit freundlichen Gruessen
Dein LiquidFeedback-Service-Skript
));
}

sub mail_all_updates {my $updates = shift;
	my $changedIssues = $updates->getChangedIssues();
	my $changedInitiatives = $updates->getChangedInitiatives();
	send_mail("Liquid Feedback -- Zusammenfassung",
qq(Hallo,

hier kommt die Zusammenfassung aller Updates im Liquid Feedback.

).($updates->getNewIssues()->getSize()<=0?"":eval {
		my $tmp = "Neu erstellte Themen:\n";
		$tmp.= "--------------------:\n";
		for (my $i=0;$i<$updates->getNewIssues()->getSize();$i++) {
			$tmp.="$config::LQFB_ROOT/issue/show/".$updates->getNewIssues()->getAt($i).".html\n";
		}
		$tmp;
}).(!(keys %$changedIssues)?"":eval {
	my $tmp = "Diese Themen haben ihren Status geaendert:\n";
	$tmp.=    "------------------------------------------\n";
	foreach my $key (keys %$changedIssues) {
		$tmp.= "Thema $key hat seinen Status auf $changedIssues->{$key}->{'newState'} aktualisiert.\n";
	}
	$tmp;
}).($updates->getNewInitiatives()->getSize()<=0?"":eval {
	my $tmp = "Neue Initiativen wurden angelegt:\n";
	$tmp.=    "---------------------------------\n";
	for (my $i=0;$i<$updates->getNewInitiatives()->getSize();$i++) {
		my $ini = $updates->getNewInitiatives->getAt($i);
		$tmp.=($i+1).". $ini->{'name'} (Zu Thema # $ini->{'issue_id'})\n";
		$tmp.="$config::LQFB_ROOT/initiative/show/$ini->{'id'}.html\n\n";
	}
	$tmp;
}).(!(keys %$changedInitiatives)?"":eval {
	my $tmp = "Initiativen mit geaendertem Entwurfstext:\n";
	$tmp.=    "-----------------------------------------\n";
	foreach my $key (keys %$changedInitiatives) {
		$tmp.="'$changedInitiatives->{$key}->{'name'}'\n";
		$tmp.="$config::LQFB_ROOT/initiative/show/$key.html\n\n";
	}
	$tmp;
}).($updates->getRevokedInitiatives()->getSize()<=0?"":eval {
	my $tmp = "Folgende Initiativen wurden zurueckgezogen:\n";
	$tmp.=    "-------------------------------------------\n";
	for(my $i=0;$i<$updates->getRevokedInitiatives()->getSize();$i++) {
		my $ini = $updates->getRevokedInitiatives->getAt($i);
		$tmp.=($i+1).". $ini->{'name'} (Zu Thema # $ini->{'issue_id'})\n";
	}
	$tmp;
}).qq(
Mit freundlichen Gruessen
Dein LiquidFeedback-Service-Skript
));
}
1;

