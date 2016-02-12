#!/usr/bin/perl

binmode STDOUT, ':utf8';

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib $Bin;
use lib "../falcon/lib";
use lib "../falcon/src";

use Log::Log4perl;
Log::Log4perl->init_once("log.conf");

my $log = Log::Log4perl->get_logger("falcon");
$log->info("started");

use WebInterface::Controller;

my $controller = WebInterface::Controller->new();

my $return=$controller->getLogHTML(10000);

print "Content-type: text/html\n\n";

if (! $return ){

    my $error= $controller->getError();
    my @errors =();
	push @errors, $error;
	
    $return = \@errors;
    
}

# Log is already in HTML.

for my $line (@$return){

    print $line;
	
}
1;
