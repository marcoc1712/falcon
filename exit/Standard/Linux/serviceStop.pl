#!/usr/bin/perl
#
# @File getProcessInfo.pl
# @Author marco
# @Created 28-gen-2016 16.04.44
#

use strict;
use warnings;


my $command= qq(service squeezelite stop);

my @rows = `$command`;

if (scalar @rows == 0) {

	@rows=();
	push @rows, "ok";
}

for my $row (@rows){
	print $row;
}
1;
