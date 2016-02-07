#!/usr/bin/perl
#
# @File hello_get.cgi.pl
# @Author Marco Curti <marcoc1712@gmail.com>
# @Created 20-gen-2016 18.23.15
#

use strict;
use warnings;

use FindBin qw($Bin);
use lib $Bin;

use SqueezeliteR2::WebInterface::Controller;
use SqueezeliteR2::WebInterface::Utils;

my $utils = SqueezeliteR2::WebInterface::Utils->new();
my $controller= SqueezeliteR2::WebInterface::Controller->new();

my %incoming = read_input();
my $in = \%incoming;

foreach my $name (keys %incoming) {
	
    $controller->setSetting($name, $in->{$name});
}

my $message= $controller->saveSettings();
my $error = $controller->getError();

print "Content-type: text/html\n\n";

if ($error) {

    print $error;
    exit 0;
}

print "DONE. New command line is: ".$message." Please restart";

#my @out=($message);
#$utils->printHTML(\@out);

sub read_input
{
    my ($buffer, @pairs, $pair, $name, $value);
	
	my  %FORM = ();
    
    if (! $ENV{'REQUEST_METHOD'}) {return %FORM;};
    
    # Read in text
    $ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
    if ($ENV{'REQUEST_METHOD'} eq "POST")
    {
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    } else
    {
	$buffer = $ENV{'QUERY_STRING'};
    }
    # Split information into name/value pairs
    @pairs = split(/&/, $buffer);
    foreach $pair (@pairs)
    {
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%(..)/pack("C", hex($1))/eg;
	$FORM{$name} = $value;
    }
   return  %FORM;
}
1;
