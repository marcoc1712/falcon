#!/usr/bin/perl
#
# @File getProcessInfo.pl
# @Author marco
# @Created 28-gen-2016 16.04.44
#

use strict;
use warnings;


my $command= "reboot";

my @row = `$command`;

if (!scalar @row == 0) {exit 0;}

print "ok";
1;
