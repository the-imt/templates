=head1 NAME

libtemplate1.pm

=head1 DESCRIPTION

This class holds and handles the functional elements
for template1.

=head1 GENERATED BY

Some guy with a keyboard

=head1 AUTHOR

Colin Wass

=head1 LICENSE

Copyright (c) 2016, Colin Wass, CFTech.ca
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that
the following conditions are met:

1. Redistributions of source code must retain the above copyright notice, this list of conditions and the
following disclaimer.

2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the
following disclaimer in the documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or
promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED
WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH
DAMAGE.

=cut

package libtemplate1;

use Moose;
use MooseX::Configuration;
use DBI;
use CGI;
use CGI::Session qw/-ip-match/;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);
use autodie;
use Data::Dumper;
use Digest::SHA;



has	'Version'		=>  (
						is		=> 	'ro',
						isa		=>	'Str',
						default	=>	'0.1a'
						);
						
has 'DBH'			=>  (
						is			=> 	'rw',
						isa			=>	'DBI::db'
						);
						
has 'DBName'		=> 	(
						is 			=>	'ro',
						isa			=>	'Str',
						default		=>	'DB',
						section		=>	'database',
						key			=>	'DBName',
						documentation => 'Pretty self explanatory'
						);

has	'DBHost'			=>	(
						is			=>	'ro',
						isa			=>	'Str',
						default		=>	'127.0.0.1',
						section		=>	'database',
						key			=>	'DBHost'
						);

has 'DBUser'		=>	(
						is			=>	'ro',
						isa			=>	'Str',
						default		=>	'user',
						section		=>	'database',
						key			=>	'DBUser'
						);
						
has 'DBPass'		=>	(
						is			=>	'ro',
						isa			=>	'Str',
						default		=>	'password',
						section		=>	'database',
						key			=>	'DBPass'
						);
						
has 'Port'			=>	(
						is			=>	'rw',
						isa			=>	'Int',
						default		=>	'3306',
						section		=>	'database',
						key			=>	'DBPort'
						);
						
has 'BaseUrl'		=>	(
						is			=>	'ro',
						isa			=>	'Str',
						default		=>	'http://localhost/',
						section		=>	'server',
						key			=>	'Server'
						);

has 'Session'		=>	(
						is			=> 	'rw',
						isa			=>	'CGI::Session',
						);

has 'Cookie'		=>	(
						is			=>	'rw',
						isa			=>	'CGI::Cookie',
						);
						
has 'UserCgi'		=>	(
						is			=>	'rw',
						isa			=>	'CGI',
						);

has 'Credential'	=>	(
						is			=>	'rw',
						isa			=>	'Str',
						default		=>	'other',
						);
						
has 'UserName'		=>	(
						is			=>	'rw',
						isa			=>	'Str',
						default		=>	'nobody',
						documentation => 'This is the string used to login'
						);
						
has 'UserId'		=>	(
						is			=>	'rw',
						isa			=>	'Int',
						default		=>	0
						);
						
has	'ScreenName'	=>	(						
						is			=>	'rw',
						isa			=>	'Str',
						default		=>	'other',
						documentation => 'String returned by the DB as identifying the owner of the credential'
						);
						
has 'Email'			=>  (
						is			=> 'rw',
						isa			=>	'Str',
						default		=>	'nobody@cftech.ca'
						);
						
						
has 'TemplateFile'	=>	(
						is			=>	'rw',
						isa			=>	'Str',
						default		=>	'templates/index.tt'
						);
						
has 'TemplateStash'	=>	(
						is			=>	'rw',
						isa			=>	'HashRef',
						default		=>	sub {{}},
						);
						
has	'ActionReq'	=>	(
						is			=>	'ro',
						isa			=>	'HashRef',
						default		=>	sub{ {	login=>\&login, 
												logout=>\&logout} },
						lazy		=>	1
						);
						
has 'ButtonProc'	=>	(
						is			=>	'ro',
						isa			=>	'HashRef',
						default		=>	sub{ {  search=>\&search,
												adminpage=>\&adminpage,
												extras=>\&extras,
												cancel=>\&cancel} },
						lazy		=>	1
						);
						
has 'AvailPages'	=>	(
						is			=>	'ro',
						isa			=>	'HashRef',
						default		=>	sub{  { us=>\&us,
												news=>\&news}  },
						lazy		=>	1
						);
						
has 'Authorities'	=>	(
						is			=>	'ro',
						isa			=>'HashRef',
						default		=>	sub{	{ other=>\&nobody,
												  user=>\&user,
												  admin=>\&admin} },
						lazy		=>	1
						);
						
has 'Authorisation'	=>	(
						is			=>	'ro',
						isa			=>	'HashRef',
						default		=>	sub{	{	other=>0,
													pundit=>1,
													admin=>2}  },
						lazy		=>	1
						);						
						
has 'Bounds'		=>	(
						is			=>	'ro',
						isa			=>	'ArrayRef',
						default		=>	sub {  [ 1, 2 ] },
						lazy		=>	1
						);						
						
sub BUILD {
    my $self = shift;
    
    $\ = $/;
    
    my $DSN = "DBI:mysql:" . $self->DBName . ":" . $self->DBHost . ":" . $self->Port;
    $self->DBH(DBI->connect($DSN, $self->DBUser, $self->DBPass)) or die "Connect to DSN fail.";
    $self->UserCgi(CGI->new);
	$self->Session(CGI::Session->new("driver:MySQL", $self->UserCgi, {Handle=>$self->DBH}));
	
	#Block 1 -- Establish session state from either cookie or login/logout button
	
	$self->Credential($self->Session->param('sessionauthority') || 'other');
	
	if(exists($self->Authorities->{$self->Credential}))  {
		$self->Authorities->{$self->Credential}->($self);
	}
	#needs else and throw error, though should be no way to miss that call
	
	foreach my $label ($self->UserCgi->param)  {
		if ($label =~ /ActionReq?/)  {
			my $option = $self->UserCgi->param($label);
			if (exists($self->ActionReq->{$option}))  {
				$self->	ActionReq->{$option}->($self);
				
			}
		}
	}
	
	initialisestash($self);
	
	#This needs to get cleaned and parameterised
	foreach my $request ($self->UserCgi->param)  {
		next unless $request =~ /listid|page|DataReq|Button?/;
		if ($request =~ /listid/)  {
			managelists($self);
		} elsif (($request =~ /page/) && exists($self->AvailPages->{$self->UserCgi->param($request)}))  {
			$self->AvailPages->{$self->UserCgi->param($request)}->($self);
		} elsif ($request =~ /DataReq/)  {
			
		} elsif (($request =~ /Button*/)  && exists($self->ButtonProc->{$self->UserCgi->param($request)}))  {
			$self->ButtonProc->{$self->UserCgi->param($request)}->($self);
		}
	}
	fetchblock1($self);
	fetchlist($self);
	return;
}

#Action requests, limited to login and logout in this model

sub login  {
	my $self = shift;
	my ($userid, $screenname, $createdate, $email, $authoritylabel);
	
	if (defined($self->UserCgi->param('userid')) && defined($self->UserCgi->param('password')))  {
		
		my $UserName = $self->UserCgi->param('userid');
		my $Password = $self->UserCgi->param('password');
		my $UserPasswd = Digest::SHA::sha256_hex($Password);
		my $Query = 'select userid, screenname, createdate, email, authoritylabel from v01credentials where screenname = ? and password = ? and terminatedate IS NULL';
		my $Sth = $self->DBH->prepare($Query);
		$Sth->execute($UserName, $UserPasswd) or die "DB Query fail: validatecredential()";
		
		if(($userid, $screenname, $createdate, $email, $authoritylabel) = $Sth->fetchrow_array)  {
			unless(exists($self->Authorities->{$authoritylabel}))  { logout($self); }
			$self->UserName($UserName);
			$self->UserId($userid);
			$self->Credential($authoritylabel);
			$self->ScreenName($screenname);
			$self->Email($email || 'nobody@cftech.ca');
			
			$self->Session->param('username', $UserName);
			$self->Session->param('userid', $userid);
			$self->Session->param('sessionauthority', $authoritylabel);
			$self->Session->param('screenname', $screenname);
			$self->Session->param('email', $email);
			$self->Session->param('activelist', 0);
			$self->TemplateFile('templates/template1.tt');
		} else  {
			logout($self);
		}
	}  else  {
		logout($self);
	}
	return;
}

sub logout  {
	my $self = shift;
	
	$self->UserName('nobody');
	$self->UserId(0);
	$self->Credential('other');
	$self->ScreenName('nobody');
	$self->Email('nobody@cftech.ca');
	$self->Session->param('username', undef);
	$self->Session->param('userid', 0);
	$self->Session->param('sessionauthority', 'other');
	$self->Session->param('screenname', 'nobody');
	$self->Session->param('activelist', 0);
	$self->Session->param('email', 'nobody@cftech.ca');
	$self->TemplateFile('templates/index.tt');
	
	return;
}

#Button press handlers

sub adminpage  {
	my $self = shift;
	
	$self->TemplateFile('templates/admin.tt');
	return;
}

sub search  {
	my $self = shift;
	
	#Need to split inside from outside here.
	
	$self->TemplateFile('templates/results.tt');
	return;
}	

sub extras  {
	my $self = shift;
	
	$self->TemplateFile('templates/extras.tt');
	return;
}

sub cancel   {
	my $self = shift;
	
	$self->TemplateFile('templates/template1.tt');
	return;
}

#Pages available

sub  us {
	my $self = shift;
	
	$self->TemplateFile('templates/us.tt');
	return;
}

sub news  {
	my $self = shift;
	
	$self->TemplateFile('templates/news.tt');
	return;
}

#Authority and credential management functions

sub user  {
	my $self = shift;
	
	$self->UserName($self->Session->param('username'));
	$self->UserId($self->Session->param('userid'));
	$self->Credential($self->Session->param('sessionauthority'));
	$self->ScreenName($self->Session->param('screenname'));
	$self->Email($self->Session->param('email') || 'nobody@cftech.ca');
	$self->TemplateFile('templates/template1.tt');
	return;
}

sub admin  {
	my $self = shift;
		
	$self->UserName($self->Session->param('username'));
	$self->UserId($self->Session->param('userid'));
	$self->Credential($self->Session->param('sessionauthority'));
	$self->ScreenName($self->Session->param('screenname'));
	$self->Email($self->Session->param('email') || 'nobody@cftech.ca');
	$self->TemplateFile('templates/template1.tt');
	return;
}

sub nobody  {
	my $self = shift;
	
	$self->UserName('nobody');
	$self->UserId(0);
	$self->Credential('other');
	$self->ScreenName('nobody');
	$self->Email('nobody@cftech.ca');
	$self->TemplateFile('templates/index.tt');
	
	return;
}

#Internal utilities and interface handlers

sub dropheader  {
	my $self = shift;
	
	#This is a bit of a kludge, ultimately need to track ajax versus link requests
	if (defined($self->UserCgi->param('reqtype')))  {
		print $self->UserCgi->header('application/json');
		
	} else  {
		$self->Cookie($self->UserCgi->cookie(CGISESSID => $self->Session->id));
		print $self->UserCgi->header( -cookie=>$self->Cookie );
	}
	return;
}

sub fetchblock1  {
	my $self = shift;
	
	my $Query = 'select typeid, typelabel from v02listtypes';
	my $Sth = $self->DBH->prepare($Query);
	$Sth->execute() or die "Error fetching list types";
	my $Result = $Sth->fetchall_hashref('typeid');
	$self->TemplateStash->{'listtypes'} = $Result;
	return;
}

sub initialisestash  {
	my $self = shift;
	
	#This can be expanded easily to allow more authority levels, only requiring the highbound to be changed
	#Note, if that is needed, the new authority also needs to be pointed at a credential management handler
	# a 0 for authority counts as not logged in
	
	if(( sort {$a<=>$b} $self->Bounds->[0], $self->Bounds->[1], $self->Authorisation->{$self->Credential})[1] == $self->Authorisation->{$self->Credential})  {
		$self->TemplateStash->{'loggedin'} = 'true';
	}  else  {
		$self->TemplateStash->{'loggedin'} = 'false';
	}
	
	$self->TemplateStash->{'username'} = $self->UserName;
	$self->TemplateStash->{'userid'} = $self->UserId;
	$self->TemplateStash->{'authority'} = $self->Credential;
	$self->TemplateStash->{'screenname'} = $self->ScreenName;
	$self->TemplateStash->{'email'} = $self->Email;
	$self->TemplateStash->{'baseurl'} = $self->BaseUrl;
	
	return;
}



__PACKAGE__->meta->make_immutable;
1;
