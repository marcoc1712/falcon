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
my $faultback = "/var/www/falcon/data/squeezelite.default"; #used if can't write backup.

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

my $backupLine="";

my $FH;
if (-e $pathname && !(-e $backup)& !(-e $faultback)){

	if (! open($FH, "< $pathname")) {
		print "ERROR: Failure opening '$pathname' for reading- $!";
		exit 0;
	}
	
	my @lines = <$FH>;
	
	close $FH;
	
	if (! open($FH, "> $backup")) {

		if (! open($FH, "> $faultback")) {
		
			print "ERROR: Failure opening $backup and $faultback for writing - $!";
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

    print "ERROR: Failure opening '$pathname' for writing - $!\n";
    exit 0;
}

my $commandLine = join (" ", @ARGV);

my @elements= split " ", $commandLine;
my $options= builsOptionsArray(\@elements);

my $executable;
my $name;
my $card;
my $server;
my $extra="";
	
for my $line (@before){

    print $FH $line."\n";
}

my $datestring = localtime();
print $FH "created at $datestring\n";
print $FH "input commandline is: ".$commandLine."\n";
print $FH " "."\n";
print $FH "#########################################################################"."\n";
print $FH " "."\n";

for my $opt (@$options){

	if (!(substr ($opt,0,1) eq "-")){
		$executable= $opt;
	
	} elsif (substr ($opt,0,2) eq "-n"){
	
		$name = trim(substr($opt,3));
	
	} elsif (substr ($opt,0,2) eq "-o"){
	
		$card = trim(substr($opt,3));
	
	} elsif (substr ($opt,0,2) eq "-s"){
		
		$server = trim(substr($opt,3));
		
	} else {
	
		$extra=$extra." ".$opt;
	}
}

if ($name && ! ($name eq "") ){

	print $FH qq(SL_NAME="$name")."\n";
	
} 

if ($card && ! ($card eq "") ){

	print $FH qq(SL_SOUNDCARD="$card")."\n";
}

if ($server && ! ($server eq "") ){

	print $FH qq(SB_SERVER_IP="$server")."\n";
}

if ($extra && ! ($extra eq "") ){

	print $FH qq(SB_EXTRA_ARGS="$extra")."\n";
}

for my $line (@after){

    print $FH $line."\n";
    
}
if ($backupLine){

	print $FH $backupLine."\n";
}
close $FH;

print "ok"; #never remove this line! 

#########################################

sub trim{
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

1;

