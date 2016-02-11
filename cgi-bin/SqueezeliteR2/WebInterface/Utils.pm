#!/usr/bin/perl
#
# @File utils.pm
# @Author Marco Curti <marcoc1712@gmail.com>
# @Created 20-gen-2016 18.23.15
#

package SqueezeliteR2::WebInterface::Utils;

use strict;
use warnings;
use utf8;

use CGI qw(:standard);
use SqueezeliteR2::WebInterface::JSONhelper;

my $helper = SqueezeliteR2::WebInterface::JSONhelper->new();


sub new{
	my $class = shift;
	return $class;
}

sub asciiClean {
	my $class = shift;
	my ($val) = shift;
	
	if (defined $val) {
	
	$val= !~ s/[^[:ascii:]]//g;
	
	}
	return $val;


}
sub trim{
	my $class = shift;
	my ($val) = shift;

  	if (defined $val) {

    	$val =~ s/^\s+//; # strip white space from the beginning
    	$val =~ s/\s+$//; # strip white space from the end
		
		if (! utf8::is_utf8($val)) {
			
			utf8::upgrade($val);
    	}
		
    }
    
    return $val;         
}
sub printJSON{
    my $class = shift;
    my $data = shift;
    
    my $jsonText = $helper->encode($data);

    print header('application/json');
    print $jsonText;
}

sub printHTML{
	my $class = shift;
	my $in = shift;
	my $title = shift || "";
	
	my @lines=();
	my $lines=\@lines;	
	
	if (! $in) {$in = "";}

	if (ref($in) eq 'ARRAY' ) {

		$lines= $in;
	
	} elsif ( ! ref($in) ) { 

		push @lines, $in;
	}
	
	print "Content-type: text/html\r\n\r\n";
	print qq(<html lang="en-US">\n);
	print qq(<head>\n);
	print qq(<meta charset="UTF-8" />\n);
	print qq(<title>$title</title>\n);
	print qq(</head>\n);
	print qq(<body>\n);

	for my $line (@$lines){

		$line = $class->trim($line);

	print qq (<p> $line </p>\n);
	
	}
	print qq(</body>\n);
	print qq(</html>\n);
}

1;
