#!/usr/bin/perl
#
# @File getProcessInfo.pl
# @Author marco
# @Created 28-gen-2016 16.04.44
#

use strict;
use warnings;

for my $a (@ARGV) {

	print $a."\n";
	
}

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

1;

