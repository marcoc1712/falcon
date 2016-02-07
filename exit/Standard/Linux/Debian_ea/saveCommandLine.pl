#!/usr/bin/perl
#
# @File getProcessInfo.pl
# @Author marco
# @Created 28-gen-2016 16.04.44
#

use strict;
use warnings;

###############################################################################
#
# apply your mods here
#
###############################################################################

#FULL PATHNAME of the file to write to (please, double check permissions)  

my $pathname = "/etc/default/squeezelite";
my $backup = "/etc/default/squeezelite.wbak";

# Some text line to include BEFORE the command line.

my @before = (

    "#!/bin/bash", # NEVER remove this one.
    " ",
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
	"# $backup is the original file.",
);
# 

################################################################################
# Please don't change anything beyond this line
################################################################################

my $commandLine = join (" ", @ARGV);

my $FH;
if (-e $pathname && ! -e $backup){

	if (! open($FH, "< $pathname")) {
		print "ERROR: Failure opening '$pathname' for reading- $!";
		exit 0;
	}
	
	my @lines = <$FH>;
	
	close $FH;
	
	if (! open($FH, "> $backup")) {

		print "ERROR: Failure opening '$backup' for writing - $!";
		exit 0;
	}
	for my $line (@before){

		print $FH $line."\n";
    }

	close $FH;
}

if (! open($FH, "> $pathname")) {

    print "ERROR: Failure opening '$pathname' - $!";
    exit 0;
}

for my $line (@before){

    print $FH $line."\n";
    
}

my $name= getName($commandLine);
if ($name && ! ($name eq "") ){

	print $FH "SL_NAME=".$name."\n";
	
} 

my $card= getSoundcard($commandLine);
if ($card && ! ($card eq "") ){

	print $FH "SL_SOUNDCARD=".$card."\n";
}

my $server= getServer($commandLine);
if ($server && ! ($server eq "") ){

	print $FH "SB_SERVER_IP=".$server."\n";
}

my $extra= getExtra($commandLine);
if ($extra && ! ($extra eq "") ){

	print $FH "SB_EXTRA_ARGS=".$extra."\n";
}

for my $line (@after){

    print $FH $line."\n";
    
}
close $FH;

# This way the complete command line is returned by extra, as a eorking example
# you could define how to split the command line to have the four variables filled
# instead.

sub getName{
	my $commandLine=shift;
	
	my $name="";
	
	return $name;
	
}
sub getServer{
	my $commandLine=shift;
	
	my $server="";
	
	return $server;
	
}
sub getSoundcard{
	my $commandLine=shift;
	
	my $soundcard="";
	
	return $soundcard;
	
}
sub getExtra{
	my $commandLine=shift;
	
	my $extra="";
	
	return $commandLine;
}

1;

