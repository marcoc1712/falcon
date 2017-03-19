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

use FindBin qw($Bin);
use lib $Bin;
#use lib "./falcon/src/Installer";

use utf8;
use File::Path;
use Cwd;
use File::Copy qw(move copy);

use constant ISWINDOWS    => ( $^O =~ /^m?s?win/i ) ? 1 : 0;
use constant ISMAC        => ( $^O =~ /darwin/i ) ? 1 : 0;
use constant ISLINUX      => ( $^O =~ /linux/i ) ? 1 : 0;

use constant REMOVE       => ( grep { /--remove/ } @ARGV ) ? 1 : 0;
use constant CLEAN        => ( grep { /--clean/ } @ARGV ) ? 1 : 0;
use constant NOGIT        => ( grep { /--nogit/ } @ARGV ) ? 1 : 0;
use constant ISDEBUG      => ( grep { /--debug/ } @ARGV ) ? 1 : 0;

my $installer;
my $src;
my $main;

my $branch       = 'master';
my $url          = "https://github.com/marcoc1712/installFalcon/archive/".$branch.".tar.gz";
my $archive      = 'master';
my $extracted    = 'installFalcon-master';
my $installerDir = 'installer';


main();

sub main{
    
    if (!prepare()){return undef;}
    if (!execute()){return undef;}
    if (!finalize()){return undef;}
    
    return 1;
}

sub prepare{

    if (ISLINUX){

        $src          = '/var/www/falcon/falcon/src/installer';
        $main         = '/var/www/falcon/falcon/src/installer/main.pl';

        if (-e $main) {

            #nothing to do, will update.

        } elsif (-d $extracted){
            rmtree( $extracted, {error => \my $msg} );
            if (@$msg) {

                print "Error deleting tree starting at: $extracted";

                for my $diag (@$msg) {
                    my ($file, $message) = %$diag;
                    if ($file eq '') {

                        print  "general error: $message";

                    } else {

                        print  "problem unlinking $file: $message";
                    }
                }
                die;
            }
        }
        if (-d $installerDir){
            rmtree( $installerDir, {error => \my $msg} );
            if (@$msg) {

                print "Error deleting tree starting at: $installerDir";

                for my $diag (@$msg) {
                    my ($file, $message) = %$diag;
                    if ($file eq '') {

                        print  "general error: $message";

                    } else {

                        print  "problem unlinking $file: $message";
                    }
                }
                die;
            }
        }
        my $command = qq(wget $url);
        my @ret= `$command`;
        my $err=$?;

        if ($err){
            print "Fatal: ".$err."\n";
            print (join "\n", @ret);
            die;
        }  
        
        $command = qq(tar -zxvf $archive.tar.gz);
        @ret= `$command`;
        $err=$?;

        if ($err){
            print "Fatal: ".$err."\n";
            print (join "\n", @ret);
            die;
        } 
        print "Info: ".$archive." unpacked in ".getcwd."\n";
        
        move $extracted, $installerDir;

        if (-e $extracted && !-e $installerDir){

            print "Fatal: can't rename $extracted to $installerDir\n";
            die;  
        }
        print "Info: ".$extracted." renamed to ".$installerDir."\n";

        my $file= $archive.".tar.gz";

        unlink $file;

        if (-e $file){

            print "WARNING: can't remove ".$file;
        }
      
        push @INC, "./$installerDir";
        
        require Linux::Installer;
        $installer= Linux::Installer->new(ISDEBUG, NOGIT);

    } elsif(ISMAC){
   
        require Mac::Installer;
        $installer= Mac::Installer->new(ISDEBUG, NOGIT);
        return 0; 

    } elsif(ISWINDOWS){

        require Windows::Installer;
        $installer= Windows::Installer->new(ISDEBUG, NOGIT);
        return 0; 

    }else {

        warn "Architecture: $^O is not supported";
        return 0; 
    }
    return 1;
}

sub execute{

    my $err;

    if (REMOVE){

        print "\n***************************** REMOVE ******************************\n";
        if (!$installer->remove(ISDEBUG)){$err=1};

    } elsif (CLEAN){

        print "\n************************* CLEAN INSTALL ***************************\n";

        if (!$installer->remove(ISDEBUG) || !$installer->install(ISDEBUG, NOGIT)) {$err=1};

    } else {

        print "\n*************************** INSTALL *******************************\n";

        if (!$installer->install(ISDEBUG, NOGIT)) {$err=1};
    }

    if ($installer->getError()){
        
        require Status;
        require Linux::Installer;
        require Mac::Installer;
        require Windows::Installer;
        
        #$installer->getStatus()->printout(); #use 1 for debug,3 for info.
        $installer->getStatus()->printout(ISDEBUG);

    } elsif ($err){

        warn "something went wrong.";
        return 0; 
    }
    
    return 1;
}
sub finalize {
    
    if (-d $src){
        
        rmtree( $src, {error => \my $msg} );
        if (@$msg) {

            print "Error deleting tree starting at: $src";

            for my $diag (@$msg) {
                my ($file, $message) = %$diag;
                if ($file eq '') {

                    print  "general error: $message";

                } else {

                    print  "problem unlinking $file: $message";
                }
            }
            return 0;
        }
    } 
    
    if (REMOVE){ 
        
        rmtree( $installerDir, {error => \my $msg} );
        if (@$msg) {

            print "Error deleting tree starting at: $installerDir";

            for my $diag (@$msg) {
                my ($file, $message) = %$diag;
                if ($file eq '') {

                    print  "general error: $message";

                } else {

                    print  "problem unlinking $file: $message";
                }
            }
            return 0;
        }
        return 1;
    } 
    
    mkpath  $src, 0755;

    if (! -d $src){
        
        print "WARNING: can't create $src\n";
        return 0;
    }  

    move $installerDir, $src;

    if (-e $installerDir && !-e $src){

        print "WARNING: can't rename $installerDir to $src\n";
        return 0;
    }
    return 1;
}
1;