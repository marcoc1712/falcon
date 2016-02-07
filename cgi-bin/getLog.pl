#!/usr/bin/perl

use strict;
use warnings;
use utf8;

binmode STDOUT, ':utf8';

use SqueezeliteR2::WebInterface::Controller;

my $controller = SqueezeliteR2::WebInterface::Controller->new();

my $return=$controller->getLogHTML(10000);

print "Content-type: text/html\n\n";

if (! $return ){

    my $error= $controller->getError();
    
    $return = ($error);
    
}

# Log is already in HTML.

for my $line (@$return){

    print $line;
	
}
1;
