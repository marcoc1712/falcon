#!/usr/bin/perl
#
# @File getProcessInfo.pl
# @Author marco
# @Created 28-gen-2016 16.04.44
#

binmode STDOUT, ':utf8';

use strict;
use warnings;
use utf8;


my $pid;

if (! scalar @ARGV == 1){

	$pid = $ARGV[0];
}
my $command;

if ($pid){

	$command= qq(ps -p $pid -o command=);
	
else {

	$command = "service squeezelite status";
}

my @rows = `$command 2>&1`;

for my $row (@rows){
	print $row;
}	
1;

