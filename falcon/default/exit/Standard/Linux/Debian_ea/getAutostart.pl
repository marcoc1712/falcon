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

#print validateResult(\@rows);
printMarker(validateResult(\@rows));

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
	} 
	# else
	my $message="";
	
	for my $row (@$result){
		
		push @data, trim($row);
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
sub printMarker{
    my $data   = shift;

    print <<_MARKER_;
#####
#
# 
#
#####

use strict;
use warnings;

our (%data);

# The configuration data
@{[Data::Dumper->Dump([$data], ['*data'])]}
1;
# EOF
_MARKER_

return 1;
}


1;