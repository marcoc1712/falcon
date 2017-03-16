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
use JSON::PP;

sub new {
    my $class = shift;
    my $data = shift || undef;

    return $class;
}
sub encode{
    my $class   = shift;
    my $data    = shift;

    if (! $data) {return undef;}
    my $json_txt = encode_json $data;
    
    return $json_txt;
}

sub decode{
    my $class       = shift;
    my $json_txt    = shift;
    
    my $out;

    if (! $json_txt && !$json_txt eq '') {return undef;}
    print $json_txt;
    die;
    my $data = decode_json $json_txt;
    
    return $data;
}

sub _encodeOLD{
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
1;
