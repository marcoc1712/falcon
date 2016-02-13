#!/usr/bin/perl
#
# @File getProcessInfo.pl
# @Author marco
# @Created 28-gen-2016 16.04.44
#

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