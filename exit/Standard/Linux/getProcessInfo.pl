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

if ($pid){
	my $command= qq(ps -p $pid -o command=);

	my @row = `$command`;

	if (!scalar @row == 1) {exit 0;}

	print $row[0];
	
} else {

	my $command = "service squeezelite status";
	my @row = `$command`;
	
	for my $r (@row){
	
		print $r;
	}
}
1;

