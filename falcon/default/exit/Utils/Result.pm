#!/usr/bin/perl
#
# @File Result.pm
# @Author Marco Curti <marcoc1712@gmail.com>
# @Created 17-feb-2016 11.35.59
#

package Util::Result;

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
	
	print qq("ERROR" : "$in->{'error'}").","."\n";
	print qq("MESSAGE" : "$in->{'message'}").","."\n";
	print qq("DATA" : [)."\n";
	
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