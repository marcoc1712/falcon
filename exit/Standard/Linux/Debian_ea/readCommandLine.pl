#!/usr/bin/perl
#
# @File getProcessInfo.pl
# @Author marco
# @Created 28-gen-2016 16.04.44
#

use strict;
use warnings;

my $commandLine="";

###############################################################################
#
# apply your mods here
#
###############################################################################

#FULL PATHNAME of the file to write to (please, double check permissions)  

my $pathname = "/etc/default/squeezelite";

my $FH;
if (! (-e $pathname)) {
	print "WARNING: file does not exists $pathname";
	exit 0;
}
if (! open($FH, "< $pathname")) {
	print "ERROR: Failure opening '$pathname' for reading- $!";
	exit 0;
}
my @lines = <$FH>;

close $FH;

my $name="";
my $card=""; 
my $server="";
my $extra="";

for my $row (@lines) {

	$row = trim($row);
	
	print $row;
	
	if (substr($row,0,8) eq "SL_NAME="){

		$name= trim(substr($row,9));
		print "name is: ".$name;

	} elsif (substr($row,0,13) eq "SL_SOUNDCARD="){

		$card= trim(substr($row,14));
		print "card is: ".$card;
		
	} elsif (substr($row,0,13) eq "SB_SERVER_IP="){

		$server= trim(substr($row,14));
		print "server is: ".$server;

	} elsif (substr($row,0,14) eq "SB_EXTRA_ARGS="){

		$extra= trim(substr($row,15));
		print "extra is: ".$extra;

	}elsif (substr($row,0,9) eq "SL_NAME ="){

		$name= trim(substr($row,10));
		print "name is: ".$name;
		
	} elsif (substr($row,0,14) eq "SL_SOUNDCARD ="){

		$card= trim(substr($row,15));
		print "card is: ".$card;
		
	} elsif (substr($row,0,14) eq "SB_SERVER_IP ="){

		$server= trim(substr($row,15));
		print "server is: ".$server;
		
	} elsif (substr($row,0,15) eq "SB_EXTRA_ARGS ="){

		$extra= trim(substr($row,16));
		print "extra is: ".$extra;
	}
}
$commandLine=$name." ".$card." ".$server." ".$extra;

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

