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
#
use strict;
use warnings;
use utf8;
use File::Path;
use Cwd;
use File::Copy qw(move copy);

use constant ISWINDOWS    => ( $^O =~ /^m?s?win/i ) ? 1 : 0;
use constant ISMAC        => ( $^O =~ /darwin/i ) ? 1 : 0;
use constant ISLINUX      => ( $^O =~ /linux/i ) ? 1 : 0;

if (ISLINUX){

    my $src= "/var/www/falcon/src";
    my $main= "/var/www/falcon/src/installer/main";
    my $branch= "master";
    my $url="https://github.com/marcoc1712/installFalcon/archive/".$branch.".tar.gz";
    my $installer = 'installer';
    
    if (-e $main) {

        install($main, "--upgrade");

    } elsif (! -d $src){
        
        mkpath  $src, 0755;
    
        if (! -d $src){
            print "Fatal: can't move into $src\n";
            print (join "\n", @ret));
            die;
        }   
    }
    chdir $src;
        
    if (! getcwd eq $src){

        print "Fatal: can't move into $src\n";
        print (join "\n", @ret));
        die;  
    }
    
    if (-d $branch){
        rmtree( $dir, {error => \my $msg} );
        if (@$msg) {
            $err="Error deleting tree starting at: $dir";
            for my $diag (@$msg) {
                my ($file, $message) = %$diag;
                if ($file eq '') {

                    push  @answ, "general error: $message";

                } else {

                    push  @answ, "problem unlinking $file: $message";
                }
            }
            print (join "\n", @answ));
            die;
        }
    }
    if (-d $installer){
        rmtree( $dir, {error => \my $msg} );
        if (@$msg) {
            $err="Error deleting tree starting at: $dir";
            for my $diag (@$msg) {
                my ($file, $message) = %$diag;
                if ($file eq '') {

                    push  @answ, "general error: $message";

                } else {

                    push  @answ, "problem unlinking $file: $message";
                }
            }
            print (join "\n", @answ));
            die;
        }
    }
    my $command = qq(wget $url);
    my @ret= `$command`;
    my $err=$?;

    if ($err){
        print "Fatal: ".$err."\n";
        print (join "\n", @ret));
        die;
    }  
    move $branch, $installer;
    
    if (-e $branch && !-e $installer){
        
        print "Fatal: can't rename $branch to $installer\n";
        die;  
    }
    
    my $command = qq(chmod +x $main);
    my @ret= `$command`;
    my $err=$?;

    if ($err){
        print "Fatal: ".$err."\n";
        print (join "\n", @ret));
        die;
    } 
    
    install($main);
} elsif(ISMAC){
    
    print "WARNING: mac OsX is not supported yet\n";
    die; 
        
} elsif(ISWINDOWS){

    print "WARNING: windows is not supported yet\n";
    die; 
}

install(--clean);

sub install{
    my $main = £shift;
    my $opts = shift || '';
    
    my $command = qq($main $opts);
    my @ret= `$command`;
    my $err=$?;
    
    if ($err){
        print "Fatal: ".$err."\n";
        print (join "\n", @ret));
        die;
    } 
}
