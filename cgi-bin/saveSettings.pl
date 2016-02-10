#!/usr/bin/perl
#
# @File saveSettings.pl
# @Author Marco Curti <marcoc1712@gmail.com>
# @Created 20-gen-2016 18.23.15
#

binmode STDOUT, ':utf8';

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib $Bin;
use lib "./SqueezeliteR2/lib";

use Log::Log4perl;
Log::Log4perl->init_once("log.conf");

my $log = Log::Log4perl->get_logger("falcon");
$log->info("started");

use SqueezeliteR2::WebInterface::Controller;
use SqueezeliteR2::WebInterface::Utils;

my $utils = SqueezeliteR2::WebInterface::Utils->new();
my $controller= SqueezeliteR2::WebInterface::Controller->new();

my %incoming = read_input();
my $in = \%incoming;

my $return= $controller->saveSettings($in);
my $error = $controller->getError();

# TEXT is required.
print "Content-type: text/html\n\n";
if ($error ){$return = $error;}
print $return;

sub read_input
{
    my ($buffer, @pairs, $pair, $name, $value);
	
    my  %FORM = ();
       
    if (! $ENV{'REQUEST_METHOD'}) {return %FORM;};
    
    # Read in text
    $ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
    if ($ENV{'REQUEST_METHOD'} eq "POST") {
    
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    
    } else {
    
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
