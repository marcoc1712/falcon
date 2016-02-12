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
use WebInterface::Utils;

my $controller = WebInterface::Controller->new();
my $utils = WebInterface::Utils->new();

my $return=$controller->serviceStop();
my $error= $controller->getError();

# TEXT is required.
print "Content-type: text/html\n\n";
if ($error ){$return = $error;}
print $return;

1;
