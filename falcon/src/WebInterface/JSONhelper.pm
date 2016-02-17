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

package WebInterface::JSONhelper;
#simple, one level JSON encoder/decoder, just to avoid dependancy.

use strict;
use warnings;
use utf8; 

sub new {
    my $class = shift;
    my $data = shift || undef;

    return $class;
}
sub encode{
    my $class= shift;
    my $data= shift;
    my $out="";

    if (! $data) {return undef;}
	
    $out= $out."{";

    if (ref $data eq "ARRAY"){
	
        $out= $out."    [";

        my $first=1;

        for my $e (@$data){
			
            if (! $first){

                $out = $out.",";

            } else {
                $out = $out."\n";
                $first = 0;
            }		
            
            $out= $out.qq("$e");
        }
        $out= $out."]\n";

	} elsif (ref $data eq "HASH") {
		
            my $first=1;

            for my $k (keys %$data){

                if (! $first){

                        $out = $out.",";

                } else{

                        $first = 0;
                }

                $out = $out."\n";
                my $v = $data->{$k};

                $out= $out.qq(    "$k": "$v");
            }
        
    } else {

        $out = $out.qq("$data");
    }
    $out = $out."\n}";

    return $out;
}

sub decode{
    my $class= shift;
    my $data= shift;
    my $out="";

    if (! $data) {return undef;}
	
	#simple one level implementation.
	
    return undef;
}
1;
