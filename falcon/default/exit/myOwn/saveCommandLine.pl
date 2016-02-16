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

###############################################################################
#
# apply your mods here
#
###############################################################################

#FULL PATHNAME of the file to write to (please, double check permissions)  

my $pathname = "/home/marco/Scrivania/squeezelite-R2/squeezelite-R2.sh";

# Some text line to include BEFORE the command line.

my @before = (

    "#!/bin/bash", # NEVER remove this one.
    " ",
    "# Squeezelite-R2 command line.",
    "# Please do not modify this file, use Web Interface instead",
    " ",
    # You could add as many line as you like, remember the # sign and use " ",
);

# some comments AFTER the command line line

my @after = (
    
    " ",
    "# Bye bye...",
);
# 

################################################################################
# Please don't change anything beyond this line
################################################################################

my $commandLine = join (" ", @ARGV);

my $FH;

if (! open($FH, "> $pathname")) {

    print "ERROR: Failure opening '$pathname' - $!";
    exit 0;
}

for my $line (@before){

    print $FH $line."\n";
    
}

print $FH $commandLine."\n";

for my $line (@after){

    print $FH $line."\n";
    
}
close $FH;

print "ok"; #never remove this line! 

1;
