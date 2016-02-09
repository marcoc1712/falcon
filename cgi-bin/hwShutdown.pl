#!/usr/bin/perl

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

my $controller = SqueezeliteR2::WebInterface::Controller->new();
my $utils = SqueezeliteR2::WebInterface::Utils->new();

my $return=$controller->hwShutdown();
my $error= $controller->getError();

# TEXT is required.
print "Content-type: text/html\n\n";
if ($error ){$return = $error;}
print $return;

1;
