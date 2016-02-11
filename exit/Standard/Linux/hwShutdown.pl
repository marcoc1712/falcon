#!/usr/bin/perl
#
# @File getProcessInfo.pl
# @Author marco
# @Created 28-gen-2016 16.04.44
#

use strict;
use warnings;


my $command= "shutdown";

my @row = `$command`;

if (scalar @rows == 0) { push @rows, "ok";}

for $row (@rows){
	print $row;
}
1;
