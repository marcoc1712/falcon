#!/usr/bin/perl
#
# @File getProcessInfo.pl
# @Author marco
# @Created 28-gen-2016 16.04.44
#

use strict;
use warnings;


my $command= qq(service squeezelite restart);

my $error;
my @rows = `$command 2>&1`;

#print "rows defined: ".(defined @rows ? "defined" : "undefined")." scalar ".(scalar @rows)."\n";

if (scalar @rows == 0) { push @rows, "ok";}

for my $row (@rows){
	print $row;
}
1;
