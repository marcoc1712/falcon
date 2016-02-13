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
# You must first check if your system could handle wakeonLan, then
# follow the instructions here: http://community.linuxmint.com/tutorial/view/1062
# 
# At the end, you should put here only the command to switch your /etc/network/interfaces
# file from a version that enable wake on lan (when action == "enabled")  
# and the original one.
#
# You could do this in many way, one is to have a couple of script in 
# /usr/bin doing this, i.e.
#
# /usr/bin/enableWakeOnlan.sh
# /usr/bin/disableWakeOnlan.sh
#
# or just one: /usr/bin/setWakeOnlan.sh <enable|disable>
# 
# as supposed in the following code:

my $scripr= "/usr/bin/setWakeOnlan.sh";
my $error = checkScript($scripr);

if ( ! $error && (($action eq "enable") ||($action eq "disable"))){
	 
	my $command= $script." ".$action;

	my @rows = `$command 2>&1`;

	print validateResult(\@rows);
	
} else{

	print $error; 
}

sub checkScript{
   my $script= shift;
	
	if (! $script) {
		return "ERROR: script is undefined"; 
	}
	if (! -e $script) {
		return "ERROR: script $script does not exists"; 
	}
	if (! -r $script) {
		return "ERROR: could not read script $script"; 
	}
	if (! -x $script) {
		return "ERROR: could not execute script $script"; 
	}
	return 0;
}

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