#!/usr/bin/perl
#
# @File JSONhelper.pm
# @Author Marco Curti <marcoc1712@gmail.com>
# @Created 20-gen-2016 18.23.15
#

package SqueezeliteR2::WebInterface::JSONhelper;

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

    #tobe handled
    return undef;
}
1;
