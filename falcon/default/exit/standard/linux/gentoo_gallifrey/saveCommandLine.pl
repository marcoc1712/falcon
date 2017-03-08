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

###############################################################################
#
# apply your mods here
#
###############################################################################

#FULL PATHNAME of the file to write to (please, double check permissions)  

my $pathname = "/etc/conf.d/squeezelite-R2";
my $backup = "/etc/conf.d/squeezelite-R2.wbak";
my $faultback = "/var/www/falcon/data/squeezelite-R2.conf.d"; #used if can't write backup.

# Some text line to include BEFORE the command line.

my @before = (

    "# Squeezelite-R2 command line.",
    "# Please do not modify this file, use Falcon Web Interface instead",
    " ",
	"#########################################################################",
	" ",
    # You could add as many line as you like, remember the # sign and use " ",
);

# some comments AFTER the command line line

my @after = (
    
    " ",
	"#########################################################################",
    " ",
);
# 

################################################################################
# Please don't change anything beyond this line
################################################################################

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

my $backupLine="";

my $FH;
if (-e $pathname && !(-e $backup) && !(-e $faultback)){

    if (! open($FH, "< $pathname")) {

        $out->{'status'}='ERROR';
        $out->{'message'}="Failure opening '$pathname' for reading- $!";   
        printJSON($out);
        exit 0;
    }
	
    my @lines = <$FH>;

    close $FH;

    if (! open($FH, "> $backup")) {

            if (! open($FH, "> $faultback")) {

                $out->{'status'}='ERROR';
                $out->{'message'}="Failure opening $backup and $faultback for writing - $!";   
                printJSON($out);
                exit 0;
            }

            $backupLine = "# Original file has been saved as $faultback.";

    } else{

            $backupLine = "# Original file has been saved as $backup.";
    }
    
    for my $line (@lines){

        print $FH $line."\n";
    }

    close $FH;
}
elsif (-e $backup){

	$backupLine = "# Original file has been saved as $backup.";
	
} elsif (-e $faultback){

	$backupLine = "# Original file has been saved as $faultback.";
}

if (! open($FH, "> $pathname")) {

    $out->{'status'}='ERROR';
    $out->{'message'}="Failure opening '$pathname' for writing - $!\n";  
    printJSON($out);
    exit 0;
}

my $commandLine = join (" ", @ARGV);

my @elements= split " ", $commandLine;

# my @elements = @ARGV; 

my $options= builsOptionsArray(\@elements);

my $executable;
my $slOpts="";
	
for my $line (@before){

    print $FH $line."\n";
}

my $datestring = localtime();
print $FH "# created at $datestring\n";
print $FH "# input commandline is: ".$commandLine."\n";
print $FH " "."\n";
print $FH "#########################################################################"."\n";
print $FH " "."\n";

for my $opt (@$options){

	if (!(substr ($opt,0,1) eq "-")){
		$executable= $opt;
	
	} else {
	
		$slOpts=$slOpts." ".$opt;
	}
}

print $FH qq(SL_OPTS="$slOpts")."\n";

for my $line (@after){

    print $FH $line."\n";
    
}
if ($backupLine){

	print $FH $backupLine."\n";
}
close $FH;

printJSON($out); #never remove this line! 

#########################################

sub builsOptionsArray{
    my $elements = shift;
    
    my @options=();
    my $line;
    
    for my $e (@$elements){
    
        if ((substr($e,0,1) eq "-") && $line){
            
            push @options, $line;
            $line=$e;
                
        } elsif ($line){
                
            $line = $line." ".$e;
                 
        } else {

            $line = $e;
        }
    }
    push @options, $line;

    return \@options;
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


