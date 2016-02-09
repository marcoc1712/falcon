#!/usr/bin/perl
#
# @File getProcessInfo.pl
# @Author marco
# @Created 28-gen-2016 16.04.44
#

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

