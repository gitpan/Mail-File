#!/usr/bin/perl -w
use strict;

use Test::More tests => 9;

use Mail::File;
use File::Path;

my $path = 'mailfiles';
my $temp = 'mailfiles/mail-XXXXXX.eml';

my $content = q!From: me@example.com
To: you@example.com
Subject: Blah Blah Blah
Cc: Them <them@example.com>
Bcc: Us <us@example.com>; anybody@example.com
X-Header-1: This is a test

Yadda Yadda Yadda
!;

my %hash = (
	From			=> 'me@example.com',
	To				=> 'you@example.com',
	Cc				=> 'Them <them@example.com>',
	Bcc				=> 'Us <us@example.com>; anybody@example.com',
	Subject			=> 'Blah Blah Blah',
	Body			=> 'Yadda Yadda Yadda',
	'X-Header-1'	=> 'This is a test',
	template		=> $temp,
  );

mkpath $path;
my $mail = Mail::File->new(%hash);

is($mail->From(),'me@example.com');
is($mail->To(),'you@example.com');
is($mail->Cc(),'Them <them@example.com>');
is($mail->Bcc(),'Us <us@example.com>; anybody@example.com');
is($mail->Subject(),'Blah Blah Blah');
is($mail->Body(),'Yadda Yadda Yadda');
is($mail->XHeader('X-Header-1'),'This is a test');

my $file = $mail->send();
my $exists = (-r $file ? 1 : 0);
is($exists,1);

open FH, $file or die "Failed to open file [$file]: $!\n";
{
	local $/ = undef;
	my $mailfile = <FH>;
	is($mailfile,$content);
}
close FH;
	
rmtree $path;
