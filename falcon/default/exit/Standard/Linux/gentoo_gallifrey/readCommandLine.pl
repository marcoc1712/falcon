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

my $commandLine="";

###############################################################################
#
# apply your mods here
#
###############################################################################

#FULL PATHNAME of the file to write to (please, double check permissions)  

my $pathname = "/etc/conf.d/squeezelite-R2";


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

my $FH;
if (! (-e $pathname)) {

    $out->{'status'}='WARNING';
    $out->{'message'}="file does not exists $pathname";   
    printJSON($out);
    exit 0;
        
}
if (! open($FH, "< $pathname")) {

    $out->{'status'}='ERROR';
    $out->{'message'}="Failure opening '$pathname' for reading- $!";   
    printJSON($out);
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

    #print $row."\n";

    if (substr($row,0,8) eq "SL_NAME="){

        #$name= "-n ".trim(substr($row,8));
		$name= trim(substr($row,8));
		
        #sanity check on name.
        if ($name =~ m/\s/) {

                $name = "squeezelite-R2";
        }
        #print "name is: ".$name."\n";
		$name= "-n ".$name;
		
    } elsif (substr($row,0,13) eq "SL_SOUNDCARD="){

        $card= "-o ".trim(substr($row,13));
        #print "card is: ".$card."\n";

    } elsif (substr($row,0,13) eq "SB_SERVER_IP="){

        $server= "-s ".trim(substr($row,13));
        #print "server is: ".$server."\n";

    } elsif (substr($row,0,14) eq "SB_EXTRA_ARGS="){

        $extra= trim(substr($row,14));
        #print "extra is: ".$extra."\n";

    }elsif (substr($row,0,9) eq "SL_NAME ="){

        $name= "-n ".trim(substr($row,9));
        #print "name is: ".$name."\n";

    } elsif (substr($row,0,14) eq "SL_SOUNDCARD ="){

        $card= "-o ".trim(substr($row,14));
        #print "card is: ".$card."\n";

    } elsif (substr($row,0,14) eq "SB_SERVER_IP ="){

        $server= "-s ".trim(substr($row,14));
        #print "server is: ".$server."\n";

    } elsif (substr($row,0,15) eq "SB_EXTRA_ARGS ="){

        $extra= trim(substr($row,15));
        #print "extra is: ".$extra."\n";
    }
}
$commandLine=$name." ".$card." ".$server." ".$extra;

################################################################################
# Please don't change anything beyond this line
################################################################################

push @data, $commandLine;
printJSON($out);

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