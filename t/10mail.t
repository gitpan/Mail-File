#!/usr/bin/perl -w
use strict;

use Test::More tests => 10;

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

mkpath($path);
my $mail = Mail::File->new(template => $temp);
isa_ok($mail,'Mail::File');

$mail->From('me@example.com');
$mail->To('you@example.com');
$mail->Cc('Them <them@example.com>');
$mail->Bcc('Us <us@example.com>; anybody@example.com');
$mail->Subject('Blah Blah Blah');
$mail->Body('Yadda Yadda Yadda');
$mail->XHeader('X-Header-1','This is a test');

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
