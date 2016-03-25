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

binmode STDOUT, ':utf8';

use strict;
use warnings;
use utf8;

use FindBin qw($Bin);
use lib $Bin;
use lib "../falcon/lib";
use lib "../falcon/src";

use Log::Log4perl;
Log::Log4perl->init_once("log.conf");

my $log = Log::Log4perl->get_logger("falcon");
$log->info("started");

use WebInterface::Controller;
use WebInterface::Utils;

my $utils = WebInterface::Utils->new();
my $controller= WebInterface::Controller->new();

my %incoming = read_input();
my $in = \%incoming;

my $return= $controller->saveSettings($in);
my $error = $controller->getError();

# TEXT is required.
print "Content-type: text/html\n\n";
if ($error ){$return = $error;}
print $return;


sub read_input {
    my ($buffer, @pairs, $pair, $name, $value);
	
    my  %FORM = ();
       
    if (! $ENV{'REQUEST_METHOD'}) {return %FORM;};
    
    # Read in text
    $ENV{'REQUEST_METHOD'} =~ tr/a-z/A-Z/;
    if ($ENV{'REQUEST_METHOD'} eq "POST") {
    
	read(STDIN, $buffer, $ENV{'CONTENT_LENGTH'});
    
    } else {
    
	$buffer = $ENV{'QUERY_STRING'};
    }

    # Split information into name/value pairs
    @pairs = split(/&/, $buffer);
    foreach $pair (@pairs)
    {
	($name, $value) = split(/=/, $pair);
	$value =~ tr/+/ /;
	$value =~ s/%(..)/pack("C", hex($1))/eg;
	$FORM{$name} = $value;
    }
	# replace "none" with "" in fields from selects.
	for my $item, (keys %FORM){
	
		if ($form{$item} && ($form{$item} eq "none")){
		
			$form{$item}="";
		} 
	}
    return  %FORM;
}
1;
