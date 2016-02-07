#!/usr/bin/perl

binmode STDOUT, ':utf8';

use FindBin;
use lib $FindBin::Bin;

use strict;
use warnings;
use utf8;

use SqueezeliteR2::WebInterface::Controller;
use SqueezeliteR2::WebInterface::Utils;

my $controller = SqueezeliteR2::WebInterface::Controller->new();
my $utils = SqueezeliteR2::WebInterface::Utils->new();

my $return=$controller->getAudioCardsHTML();

print "Content-type: text/html\n\n";

if (! $return ){

    my $error= $controller->getError();
    print $error."\n";
    exit 0;
    
}

# AudioCards are already in HTML.

#$utils->printHTML($return); 

for my $line (@$return){

    print $line;
	
}
1;
