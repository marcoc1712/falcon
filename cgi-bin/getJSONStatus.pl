#!/usr/bin/perl
#binmode STDOUT, ':utf8';

use strict;
use warnings;
use utf8;

use CGI qw(:standard);

use FindBin qw($Bin);
use lib $Bin;

use SqueezeliteR2::WebInterface::Controller;
use SqueezeliteR2::WebInterface::Utils;

my $controller = SqueezeliteR2::WebInterface::Controller->new();
my $utils = SqueezeliteR2::WebInterface::Utils->new();

if ($controller->getError()){
    
    $utils->printHTML($controller->getError());
    exit 0;
}
my $result = $controller->getStatus();
$utils->printJSON($result);

1;

