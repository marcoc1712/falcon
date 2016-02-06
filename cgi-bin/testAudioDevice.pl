#!/usr/bin/perl

binmode STDOUT, ':utf8';

use strict;
use warnings;
use utf8;

use SqueezeliteR2::WebInterface::Controller;
use SqueezeliteR2::WebInterface::Utils;

my $controller = SqueezeliteR2::WebInterface::Controller->new();
my $utils = SqueezeliteR2::WebInterface::Utils->new();

my $return=$controller->testAudioDevice();

if (! $return ){

    my $error= $controller->getError();
    $return = $error;  
} 

$utils->printHTML($return);

1;


use SqueezeliteR2::WebInterface::Utils;
use SqueezeliteR2::WebInterface::Configuration;
use SqueezeliteR2::WebInterface::Settings;

my $utils  = SqueezeliteR2::WebInterface::Utils->new();
my $conf  = SqueezeliteR2::WebInterface::Configuration->new();
my $settings= SqueezeliteR2::WebInterface::Settings->new();

my $audiodevice = $settings->get('audioDevice');
my $out= $conf->testAudioDevice($audiodevice);

$utils->printHTML($out);

1;
