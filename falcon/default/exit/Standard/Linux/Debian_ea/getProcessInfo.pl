#!/usr/bin/perl
# $Id$
#
# WEB INTERFACE and Controll application for an headless squeezelite
# installation.
#
# Best used with Squeezelite-R2 
# (https://github.com/marcoc1712/squeezelite/releases)
#
# Copyright 2016 Marco Curti, marcoc1712 at gmail dot com.
# Please visit www.marcoc1712.it
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License,
# version 3.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
################################################################################
binmode STDOUT, ':utf8';
use strict;
use warnings;

use utf8;
use JSON::PP;

my $pid;

if (scalar @ARGV == 1){

	$pid = $ARGV[0];
}
my $command;

if ($pid){

	$command= qq(ps -p $pid -o command=);
	
} else {

	$command = "service squeezelite status";
}

my @rows = `$command 2>&1`;

for my $row (@rows){
	print $row;
}	
1;

