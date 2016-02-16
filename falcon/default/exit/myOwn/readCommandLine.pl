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

my $commandLine="";
my $FH;

###############################################################################
#
# apply your mods here
#
###############################################################################

#FULL PATHNAME of the file to write to (please, double check permissions)  

my $pathname = "/home/marco/Scrivania/squeezelite-R2/squeezelite-R2.sh";

if (-e $pathname) {

    if (! open($FH, "< $pathname")) {
            print "ERROR: Failure opening '$pathname' for reading- $!";
            exit 0;
    }

    my @lines = <$FH>;

    close $FH;

    for my $row (@lines){

        $row = trim($row);
        
        if (! (substr($row,0,1) eq "#")) {

            $commandLine=$commandLine.$row;
        }

    }
	
}

################################################################################
# Please don't change anything beyond this line
################################################################################

print $commandLine;

sub trim{
	my ($val) = shift;

  	if (defined $val) {

    	$val =~ s/^\s+//; # strip white space from the beginning
    	$val =~ s/\s+$//; # strip white space from the end
    }
    
    return $val;         
}
1;

