#!/usr/bin/perl
#
# @File getProcessInfo.pl
# @Author marco
# @Created 28-gen-2016 16.04.44
#

use strict;
use warnings;

my $command= "/sbin/chkconfig squeezelite";

my @rows = `$command 2>&1`;

print validateResult(\@rows);

sub validateResult{
	my $result = shift;
	
	if ((scalar @$result == 1) && (trim($$result[0])  =~ /^squeezelite/)){
	
		my $str = trim(substr(trim($$result[0]),11));
		return $str;
	
	} 
	
	my $message="";
	
	for my $row (@$result){
		
		$message= $message." ".trim($row);
	}
	return $message;
}
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
1;