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

use strict;
use warnings;

if (! scalar @ARGV == 1){

    print "WARNING: Missing action";
    exit 0;
}

my $action = $ARGV[0];

if ((! ($action eq "enable") ) && (! ($action eq "disable") )){

    print "WARNING: Invalid action";
    exit 0;

}
my $command= "update-rc.d -n squeezelite $action";

my @rows = `$command 2>&1`;

print validateResult(\@rows);

sub validateResult{
	my $result = shift;
	
	# insert here any logit to validate the result.
	# NOTE $result i a pointer to an array!
	
	#You could use something like that to investigate each line:
	
	for my $row (@$result){
	
		# do something with the line i.e.
		if (($row  =~ /^ERROR/) || ($row  =~ /^WARNING/)){
		
			return $row; #error condition.
		}
		# Return a string stating with "ERROR" or "WARNING" to explicity
		# set an axception, but any string <> "ok" is handles as an exception.
	}
	
	# if nothing wrong is detected, returns "ok".
	return "ok";
}
1;