#!/usr/bin/perl
#
# @File getProcessInfo.pl
# @Author marco
# @Created 28-gen-2016 16.04.44
#

use strict;
use warnings;

my $command= "/sbin/chkconfig squeezelite";

my @rows = `$command 2>&1`;

print validateResult(\@rows);

sub validateResult{
	my $result = shift;
	
	if (scalar @$result == 1) && ($$result[0]  =~ /^squeezelite on/)){
	
		return "on";
	
	} elsif (scalar @$result == 1) && ($$result[0]  =~ /^squeezelite off/)){
	
		return "off";
	}
	my $message=""
	for my $row (@$result){
		
		$message= $message." ".$row;
	}
	return $message;
}
1;