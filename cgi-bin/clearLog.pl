#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use SqueezeliteR2::WebInterface::Controller;
use SqueezeliteR2::WebInterface::Utils;

my $controller = SqueezeliteR2::WebInterface::Controller->new();
my $utils = SqueezeliteR2::WebInterface::Utils->new();

my $return=$controller->clearLogfile("Web Interface");
my $error= $controller->getError();

print "Content-type: text/html\n\n";

if ($error ){

    $return = $error;
    
}

print $return;
#$utils->printHTML($return);
1;
