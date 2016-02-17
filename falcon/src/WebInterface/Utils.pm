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

package WebInterface::Utils;

use strict;
use warnings;
use utf8;

use CGI qw(:standard);
use WebInterface::JSONhelper;

my $helper = WebInterface::JSONhelper->new();


sub new{
	my $class = shift;
	return $class;
}

sub asciiClean {
	my $class = shift;
	my ($val) = shift;
	
	if (defined $val) {
	
	$val =~ s/[^[:ascii:]+]//g;
	
	}
	return $class->trim($val);
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
sub trimQuotes{
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
