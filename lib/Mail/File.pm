package Mail::File;

use warnings;
use strict;

use vars qw($VERSION $AUTOLOAD);
$VERSION = '0.07';

#----------------------------------------------------------------------------

=head1 NAME

Mail::File - mail module which writes to a flat file.

=head1 SYNOPSIS

  use Mail::File;

  my $mail = Mail::File->new(template => 'mailXXXX.tmp');
  $mail->From('me@example.com');
  $mail->To('you@example.com');
  $mail->Cc('Them <them@example.com>');
  $mail->Bcc('Us <us@example.com>; anybody@example.com');
  $mail->Subject('Blah Blah Blah');
  $mail->Body('Yadda Yadda Yadda');
  $mail->XHeader('X-Header' => 'Blah Blah Blah');
  $mail->send;

  # Or use a hash
  my %hash = (
	From       => 'me@example.com',
	To         => 'you@example.com',
	Cc         => 'Them <them@example.com>',
	Bcc        => 'Us <us@example.com>, anybody@example.com',
	Subject    => 'Blah Blah Blah',
	Body       => 'Yadda Yadda Yadda',
	'X-Header' => 'Blah Blah Blah',
	template   => 'mailXXXX.tmp'
  );

  my $mail = Mail::File->new(%hash);
  $mail->send;

=head1 DESCRIPTION

This module was written to overcome the problem of sending mail messages, 
where there is no mail application is available. 

The aim of the module is to write messages to a text file, that will format
the contents to include all the key elements of the message, such that the 
file can be transported to another machine, which is then capable of sending 
mail messages.

Notes that the filename template defaults to 'mail-XXXXXX.eml'.

=head1 ABSTRACT

A mail module to write mail messages to a plain text flat file.

=cut

#----------------------------------------------------------------------------

#############################################################################
#Library Modules															#
#############################################################################

use File::Basename;
use File::Path;
use File::Temp	qw(tempfile);

#############################################################################
#Variables
#############################################################################

my @autosubs = qw( From To Cc Bcc Subject Body );
my %autosubs = map {$_ => 1} @autosubs;

#----------------------------------------------------------------------------

#############################################################################
#Interface Functions														#
#############################################################################

=head1 METHODS

=over 4

=item new()

Create a new mailer object. Returns the object on success or undef on
failure.

All the following can be pass as part of an anonymous hash:

  From
  To
  Cc
  Bcc
  Subject
  Body
  template

The template entry is optional, and is only supplied when you call the 
constructor. The format of the string to template follows the format as
fox File::Temp. However, a suffix is automatically extracted. An example
template would be:

  mail-XXXX.tmp

Where the temnplate to File::Temp would be 'mail-XXXX' and the suffix
would be '.tmp'.

The default template, if none is supplied is:
	
  mail-XXXXXX.eml

=cut

sub new {
	my ($self, %hash) = @_;

	# create an attributes hash
	my $atts = {
		'From'		=> $hash{From}		|| '',
		'To'		=> $hash{To}		|| '',
		'Cc'		=> $hash{Cc}		|| '',
		'Bcc'		=> $hash{Bcc}		|| '',
		'Subject'	=> $hash{Subject}	|| '',
		'Body'		=> $hash{Body}		|| '',
		'template'	=> $hash{template}	|| 'mail-XXXXXX.eml',
	};

	# store the x-headers
	my @xheaders = grep /^X-/, keys %hash;
	foreach my $xhdr (@xheaders) { $atts->{$xhdr} = $hash{$xhdr} }

	# attempt to create the reports directory if necessary
	my $file = basename($atts->{template});
	my ($path) = ($atts->{template} =~ /(.*)$file/);
	mkpath($path)	if($path && !-d $path);

	# create the object
	bless $atts, $self;
	return $atts;
}

sub DESTROY {}

# -------------------------------------
# The Get & Set Methods Interface Subs

=item Accessor Methods

The following accessor methods are available:

  From  
  To  
  Cc  
  Bcc  
  Subject  
  Body

All functions can be called to return the current value of the associated
object variable, or be called with a parameter to set a new value for the
object variable.

=cut

sub AUTOLOAD {
	no strict 'refs';
	my $name = $AUTOLOAD;
	$name =~ s/^.*:://;
	die "Unknown sub $AUTOLOAD\n"	unless($autosubs{$name});
	
	*$name = sub { @_==2 ? $_[0]->{$name} = $_[1] : $_[0]->{$name};	};
	goto &$name;
}

=item XHeader($xheader,$value)

Adds a header in the style of 'X-Header' to the headers of the message. 
Returns undef if header cannot be added.

=cut

sub XHeader {
	my ($self,$xheader,$value) = @_;
	return undef	unless($xheader =~ /^X-/);
	$value ? $self->{$xheader} = $value : $self->{$xheader};
}

=item send()

Sends the message. Returns the filename on success, 0 on failure.

Really just writes to a file.

=cut

sub send {
	my ($self) = @_;

	# we need a basic message fields
	return undef	unless(	$self->{From} && 
						$self->{To} && 
						$self->{Subject} && 
						$self->{Body});

	# Build the message
	my $msg  = "From: $self->{From}\n" .
			"To: $self->{To}\n" .
			"Subject: $self->{Subject}\n";
	$msg .= "Cc: $self->{Cc}\n"				if($self->{Cc});
	$msg .= "Bcc: $self->{Bcc}\n"			if($self->{Bcc});

	# store the x-headers
	my @xheaders = grep /^X-/, keys %$self;
	foreach my $xhdr (@xheaders) { $msg .= "$xhdr: $self->{$xhdr}\n"; }

	$msg .= "\n$self->{Body}\n";

	my ($template,$suffix) = ($self->{template} =~ /(.*)(\.\w+)$/);
	my ($fh, $filename) = tempfile( $template, SUFFIX => $suffix, UNLINK => 0 );
	print $fh $msg;
	undef $fh;

	return $filename;
}

1;

__END__

#----------------------------------------------------------------------------

=back

=head1 BUGS, PATCHES & FIXES

There are no known bugs at the time of this release. However, if you spot a
bug or are experiencing difficulties that are not explained within the POD
documentation, please send an email to barbie@cpan.org or submit a bug to the
RT system (http://rt.cpan.org/). However, it would help greatly if you are 
able to pinpoint problems or even supply a patch. 

Fixes are dependant upon their severity and my availablity. Should a fix not
be forthcoming, please feel free to (politely) remind me.

=head1 TODO

May add the ability to handle MIME content headers and attachments.

=head1 SEE ALSO

  File::Basename
  File::Path
  File::Temp

=head1 DSLIP

  b - beta
  d - Developer
  p - Perl only
  O - Object oriented
  p - Standard Perl

=head1 AUTHOR

Barbie, C< <<barbie@cpan.org>> >
for Miss Barbell Productions, L<http://www.missbarbell.co.uk>

=head1 COPYRIGHT AND LICENSE

  Copyright (C) 2003-2005 Barbie for Miss Barbell Productions
  All Rights Reserved.

  This module is free software; you can redistribute it and/or 
  modify it under the same terms as Perl itself.

=cut
