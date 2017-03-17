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
binmode STDOUT, ':utf8';
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

#here the command to be executed;
#my $command= "/sbin/chkconfig squeezelite";
my $command = qq(ls -l /etc/rc?.d/*squeezelite);

#command execution;
my @rows = `$command 2>&1`;
my $err=$?;

#result validation
validateResult($err, \@rows);

sub validateResult{
	my $err = shift;
    my $result = shift;
	
	#here your validation code.
	
    my %rc;

    if ($err){

        $out->{'status'}='error';

    } elsif (scalar @$result == 7){

        for my $rc (@$result){

            my $str= trim($rc);
            my $ind=(index($str, "/etc/rc"));

            my $lev= substr($str,$ind+7,1);
            $str= substr($str,length($str)-$ind);

            my $end=index($str, "squeezelite -> ../init.d/squeezelite");

            if ($end ge 3){

                my $act  = substr($str,0,1);
                my $prio = substr($str,1,$end-1);

                if (($lev ge 0 && $lev le 6) &&
                    ($act eq "S" || $act eq "K") &&
                    ($prio ge 0 && $prio le 100)){

                    $rc{$lev}{'act'}=$act;
                    $rc{$lev}{'prio'}=$prio;

                    next;
                }
                $out->{'status'}='warning';
            }
        }

    } else {

        $out->{'status'}='warning';
    }

    if (($rc{2} && $rc{2}{'act'} eq "S") ||
        ($rc{3} && $rc{3}{'act'} eq "S") || 
        ($rc{4} && $rc{4}{'act'} eq "S") ||
        ($rc{5} && $rc{5}{'act'} eq "S")){

        $out->{'status'}='ok';
        @data=('on');
        
    } else{
        
        $out->{'status'}='warning';
        @data=('off');
    }

    my $message="";
    for my $row (@$result){
		
        $message= $message.trim($row);
    }
    $out->{'message'}=$message;
	
	printJSON($out);
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