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

use JSON::PP;

# the return MUST be in form of an hash with three elements:
#
# 'status'  = values "ok", "ERROR", "WARNING". Any other is "INFO".
# 'message' = status message displayed to the user, MUST be a valid UTF_8 string,
#             please avoid special and control characters.
# 'data'		= ARRAY of valid UTF_8 string containing the command result, 
#             contents is validated only by the application.
#
# any other element is discharged.
#
# here the PROTOTYPE:

my @data=();
my $out={};
$out->{'status'}='ok';
$out->{'message'}="";
$out->{'data'}=\@data;

#tobe converted in JSON format and printed out.

if (! scalar @ARGV == 1){

    $out->{'status'}="WARNING";
	$out->{'message'}="Missing action";
	
	printJSON($out);
	exit 0;
}

my $action = $ARGV[0];

if ((! ($action eq "enable") ) && (! ($action eq "disable") )){

	$out->{'status'}="WARNING";
	$out->{'message'}="Invalid action";
	
	printJSON($out);
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
# as supposed in the following code, as for an example.
#

my $script= "/usr/bin/setWakeOnlan.sh";
my $error = checkScript($script);

if ($error) {

	$out->{'status'}="ERROR";
	$out->{'message'}=$error;
	
	printJSON($out);
	exit 0;
}

my $command= $script." ".$action;
my @rows = `$command 2>&1`;

validateResult(\@rows);

sub validateResult{
	my $result = shift;
	
	my $message="";
	for my $row (@$result){
	
		if ($row  =~ /^ERROR/){
		
			$out->{'status'}="ERROR";
			$out->{'message'}=trim(substr($row,5));
			
			printJSON($out);
			exit 0;
			
		} elsif ( $row  =~ /^WARNING/){
		
			$out->{'status'}="WARNING";
			$out->{'message'}=trim(substr($row,7));
						
			printJSON($out);
			exit 0;
			
		}
		else{
			$message = $message." ".trim($row);
		}
	}
	
	$out->{'status'}="ok";
	$out->{'message'}=$message;

	printJSON($out);
	exit 1;
}

sub checkScript{
   my $script= shift;
	
	if (! $script) {
		return "script is undefined"; 
	}
	if (! -e $script) {
		return "script $script does not exists"; 
	}
	if (! -r $script) {
		return "could not read script $script"; 
	}
	if (! -x $script) {
		return "could not execute script $script"; 
	}
	return 0;
}

###############################################################################
# This code should be in a library, please do not modify it.
###############################################################################

sub trim {
	my ($val) = shift;

  	if (defined $val) {

    	$val =~ s/^\s+//; # strip white space from the beginning
    	$val =~ s/\s+$//; # strip white space from the end
    }
	if (($val =~ /^\"/) && ($val =~ /\"+$/)) {#"
	
		$val =~ s/^\"+//; # strip "  from the beginning
    	$val =~ s/\"+$//; # strip "  from the end 
	}
	if (($val =~ /^\'/) && ($val =~ /\'+$/)) {#'
	
		$val =~ s/^\'+//; # strip '  from the beginning
    	$val =~ s/\'+$//; # strip '  from the end
	}
    
    return $val;         
}

sub printJSON{
	my $in = shift;
	print  encode_json $in;
}
1;