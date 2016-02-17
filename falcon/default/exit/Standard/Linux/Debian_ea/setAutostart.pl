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

my $action;

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
#here the command to be executed;
my $command= "update-rc.d -n squeezelite $action";

my @rows = `$command 2>&1`;

#result validation and return.
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
			
		} elsif if ( $row  =~ /^WARNING/){
		
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
	
	print "{"."\n";
	
	print qq("status" : "$in->{'status'}").","."\n";
	print qq("message" : "$in->{'message'}").","."\n";
	print qq("data" : [)."\n";
	
	my $lines = $in->{'data'};
	my $first=1;
	for my $row (@$lines){
		if (!$first) {
			print","."\n";
		} else {
			print"\n";
			$first=0;
		}
		print "            ".qq("$row");
	}
	print "\n";
	print "         ]"."\n";
	print "}"."\n";
}
1;
1;