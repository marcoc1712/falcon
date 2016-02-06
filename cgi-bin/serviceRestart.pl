#!/usr/bin/perl

binmode STDOUT, ':utf8';

use strict;
use warnings;
use utf8;

use SqueezeliteR2::WebInterface::Controller;
use SqueezeliteR2::WebInterface::Utils;

my $controller = SqueezeliteR2::WebInterface::Controller->new();
my $utils = SqueezeliteR2::WebInterface::Utils->new();

my $return=$controller->serviceRestart();

if (! $return ){

    my $error= $controller->getError();
    $return = $error;  
} 

$utils->printHTML($return);

1;
