#!/usr/bin/perl
#
# @File getProcessInfo.pl
# @Author marco
# @Created 28-gen-2016 16.04.44
#

use strict;
use warnings;


my $command= qq(sudo /etc/init.d/squeezelite restart);

my @rows = `$command 2>&1`;

if (scalar @rows == 0) { push @rows, "ok";}

for my $row (@rows){
	print $row;
}
1;
