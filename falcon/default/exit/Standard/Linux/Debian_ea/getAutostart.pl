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
use Data::Dumper;
use Storable 'dclone';

my $command= "/sbin/chkconfig squeezelite";

my @rows = `$command 2>&1`;

printJSON(validateResult(\@rows));

sub validateResult{
	my $result = shift;
	
	my %outHash;
	my $out= \%outHash;
	my @data=();
	
	$out->{'error'}=0;
	$out->{'message'}="";
	$out->{'data'}=\@data;
	
	if ((scalar @$result == 1) && (trim($$result[0])  =~ /^squeezelite/)){
	
		my $str = trim(substr(trim($$result[0]),11));
		push @data, $str;
		
	} else {
	
		for my $row (@$result){
		
			push @data, trim($row);
		}
	}
	return $out;
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

sub printJSON{
	my $in = shift;
	
	print "{"."\n";
	
	print qq("ERROR" : "$in->{'error'}").","."\n";
	print qq("MESSAGE" : "'$in->{'message'}").","."\n";
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