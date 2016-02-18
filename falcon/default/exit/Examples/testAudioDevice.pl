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

my %commandHash=();
my $cmd= \%commandHash;

##########################################################
#
# Insert here the command to use for your AudioDevice, i.e.
#
###########################################################

$cmd->{'front:CARD=NVidia_1,DEV=0'} = 'cat /proc/asound/NVidia_1/codec#0';
$cmd->{'hw:CARD=NVidia_1,DEV=0'} = 'cat /proc/asound/NVidia_1/codec#0';
$cmd->{'front:CARD=I82801AAICH,DEV=0'} = 'cat /proc/asound/I82801AAICH/codec97#0/ac97#0-0';
$cmd->{'hw:CARD=I82801AAICH,DEV=0'} = 'cat /proc/asound/I82801AAICH/codec97#0/ac97#0-0';

$cmd->{'front:CARD=X20,DEV=0'} = 'cat /proc/asound/X20/stream0';

#... and so on.

#############################################################
#
# You could even rewrite _getTestCommand
#
#############################################################

sub _getTestCommand{

	my $audioDevice = shift;

	if ($cmd->{$audioDevice}){ 

		return $cmd->{$audioDevice};
	}
	return undef;
}

##############################################################
#
# Or do whatever you like, but just remember to print the result.
#
##############################################################

if (!scalar @ARGV == 1) {exit 0;}

my $audiodevice = $ARGV[0];
my @lines=();
my $command = _getTestCommand($audiodevice);

if (!$command) {
	push @lines, "WARNING: Unable to find test command for: $audiodevice";

} else{
	@lines = `$command 2>&1`;
}	
for my $row (@lines){

	print $row;
}
1;

