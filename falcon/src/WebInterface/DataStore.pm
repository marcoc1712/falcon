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

package WebInterface::DataStore;

use Data::Dumper;
use Storable 'dclone';

sub new{
    my $class 	= shift;
    my $file    = shift;
    my $marker 	= shift;
    my $default = shift;
     
    my $self = bless {
                file => $file,
                marker => $marker,
                default => $default,
                error => undef,
                data => {},
             }, $class;

    $self->_read();       
    return $self;
}

sub get{
    my $self = shift;

    if ($self->getError() || ! $self->{data}) {return {};}
    return $self->{data};
}

sub write{
    my $self     	= shift;
    my $inRef 		= shift;
   
    if (! $inRef){ $inRef = $self->get();}
   
    if ($self->_write($inRef)){

        $self->_read();	
        return 1;
    }
    return undef;

}
sub getError{
    my $self	= shift;
    return  $self->{error};
}

##################################################################

sub _read{
    my $self 	= shift;
    if ((! -e $self->{file}) || ! -r $self->{file}) {

        $self->{data}= $self->{default};
        $self->{error} = undef; 
 
        return 1
    }

    # Process the contents of the config file
    my $rc = do($self->{file});

    # Check for errors
    if ($@) {
        $self->{error} = "ERROR: Failure compiling $file - $@";
        $self->{data}=undef;
        return 0;
    } elsif (! defined($rc)) {
        $self->{error} = "ERROR: Failure reading $file - $!";
        $self->{data}=undef;
        return 0;
    } elsif (! $rc) {
        $self->{error} = "ERROR: Failure processing $file";
        $self->{data}=undef;
        return 0;
    }
    
    $self->{data} = dclone \%data;

    $self->{error} = undef;

    return 1;
}

sub _write{
    my $self   = shift;
    my $data   = shift;
    
    my $file   =  $self->{file};

    my $CFG;
    if (! open($CFG, "> $file")) {
        $self->{error} = ("ERROR: Failure opening '$file' - $!");
        return 0;
    }

    print $CFG <<_MARKER_;
#####
#
# $marker
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

    close($CFG);
    $self->{error}= undef;   # Success
    return 1;
}
1;
