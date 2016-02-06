#!/usr/bin/perl
#
# @File getProcessInfo.pl
# @Author marco
# @Created 28-gen-2016 16.04.44
#

use strict;
use warnings;

if (!scalar @ARGV == 1) {exit 0;}

my $pid = $ARGV[0];

my $command= qq(ps -p $pid -o command=);

my @row = `$command`;

if (!scalar @row == 1) {exit 0;}

print $row[0];
