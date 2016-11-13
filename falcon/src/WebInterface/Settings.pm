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

package WebInterface::Settings;

use strict;
use warnings;
use utf8;

use File::Basename;
use File::Spec;

use WebInterface::Configuration;
use WebInterface::Preferences;
use WebInterface::CommandLine;

my $log;

sub new {
    my $class = shift;

    $log = Log::Log4perl->get_logger("settings");

    my $conf = WebInterface::Configuration->new();
    my $prefs;
    my $commandLine;
    my $error;
	
    if ($conf->getPrefFile() && -e $conf->getPrefFile() && -r $conf->getPrefFile()){
    
        $prefs = WebInterface::Preferences->new($conf->getPrefFile());
        $commandLine = WebInterface::CommandLine->new($prefs);

    } else {
        
		my $commandLineText=$conf->readCommandLine();
		$error = $conf->getError();
		
		$log->info($commandLineText);
		
		if (! $commandLineText || $commandLineText eq ""){
			
			#load defaults.
			$prefs = WebInterface::Preferences->new($conf->getPrefFile());
			$commandLine = WebInterface::CommandLine->new($prefs);
			
		} else{
			
			#load command line.
			$commandLine = WebInterface::CommandLine->new(undef, $commandLineText);
			$prefs = $commandLine->getPreferences();
			
			# try to detect autostart.
			$error = $conf->getError();
			$prefs->setItem('autostart', $conf->getAutostart());
		}
    }
    my $self = bless {
                    conf => $conf,
                    prefs => $prefs,
                    commandLine => $commandLine,
                    error => $error,
                 }, $class;
    
    return $self;
}
sub conf {
    my $self = shift;  
    return $self->{conf};
}
sub prefs{
    my $self = shift;
    return $self->{prefs};
}
sub commandLine{
    my $self = shift;
    return $self->{commandLine};
}
sub getError{
    my $self            = shift;
    
    return $self->{error};
}
sub getPathname{
    my $self = shift;

    $self->{error} = $self->conf()->getError();
    return  $self->conf()->getPathname();
}

sub getPIDFile{
    my $self = shift;

    $self->{error} =  $self->conf()->getError();
    return  $self->conf()->getPIDFile();
}
sub getSettings{
    my $self 		= shift;
    
    if (! $self->prefs()) {return undef}
    
    $self->{error} = $self->prefs()->getError();
    return $self->prefs()->getPrefs();

}
sub setSettings{
    my $self 		= shift;
    my $in              = shift;
    
    if (! $self->prefs()) {return undef}
    
    if (!$self->prefs()->setPrefs($in)){
        $self->{error} = $self->prefs()->getError();
        return 0;
    }  
    $self->{error}=undef;
    return 1;
}

sub getItem{
    my $self 		= shift;
    my $item		= shift;
    
    if (! $self->prefs()) {return undef}
     
    $self->{error} = $self->prefs()->getError();
    return $self->prefs()->getItem($item);

}
sub setItem {
    my $self 		= shift;
    my $item		= shift;
    my $value		= shift || undef;

    if (! $self->prefs()) {return undef}
    
    if (!$self->prefs()->setItem($item, $value)){
        $self->{error} = $self->prefs()->getError();
        return 0;
    }  
    $self->{error}=undef;
    return 1;
}
sub isEnabled{
    my $self            = shift;
    my $item            = shift;

    $self->{error} =  $self->conf()->getError();
    return (! $self->conf()->isDisabled($item));
}
sub save{
    my $self = shift;

    $self->{error} =undef;

    if (! ($self->commandLine()->setPreferences($self->prefs()))) {
        $self->{error} =$self->commandLine()->getError();
    }
    $log->info("after command line: ".($self->{error} ? $self->{error} : ""));
	
    if (! $self->{error} && ! $self->conf()->setAutostart($self->getItem('autostart'))) {
        $self->{error} =  $self->conf()->getError();
    }
    $log->info("after autostart : ".($self->{error} ? $self->{error} : ""));
	
    if (! $self->{error} && ! $self->conf()->setWakeOnLan($self->getItem('allowWakeOnLan'))) {
        $self->{error} =  $self->conf()->getError();
    }
    $log->info("after wakeOnLan : ".($self->{error} ? $self->{error} : ""));
    
    if (! $self->{error} && ! $self->prefs()->save()) {
        $self->{error} = $self->prefs()->getError();
    }
    $log->info("after prefs : ".($self->{error} ? $self->{error} : ""));
    
    if (! $self->{error}) {return "DONE. Please restart.";};

    return undef; 
	
}

sub saveAs{
    my $self = shift;
    my $file = shift;
    my $in = shift;
    
    my $path =  $self->_getSetPathname($file);
    
    if (!$path) {return undef}
    
    my $saved = WebInterface::Preferences->new($path);
    
    if (!$saved) {return undef}
    
    if (!$saved->setPrefs($in)){
        $self->{error} = $saved->getError();
        return 0;
    }  
    $self->{error}=undef;
    return 1;
}

sub load{
    my $self = shift;
    my $file = shift;
    
    my $path =  $self->_getSetPathname($file);   
    if (!$path) {return undef}
    
    if (-e $path && -r $path){
    
        $self->prefs = WebInterface::Preferences->new($path);
        $self->commandline = WebInterface::CommandLine->new( $self->prefs());

    } else {
        $self->{error} = "unable to load settings from file";
        return 0;
    }
    $self->{error}=undef;
    return 1;
}

sub list{
    my $self = shift;
    
    my @files;
    
    if ($self->conf()->getPrefFolder() &&  -d $self->conf()->getPrefFolder()&& -r $self->conf()->getPrefFolder()){
     
        my $dir = $self->conf()->getPrefFolder();
    
        opendir(DIR, $dir) || die "Can't open directory $dir: $!";
        my @pathnames = grep { (!/^\./) && -f "$dir/$_.set" } readdir(DIR);
        closedir DIR;
        
        foreach my $p (@pathnames) {
            my $filename = fileparse($p);
            push @files, $filename;
        }
    }

    } else {
    
        $self->{error} = "unable to read from preference directory";
        return 0;
    }

    $self->{error}=undef;
    return @files;
}
sub listHTML{
    my $self = shift;
    my @files = $self->list();
    
    my @html;
    push @html, qq (<option value= "0"> "" </option>)."\n";
     
    my ($key, $desc);
    my $id=1;
   
    for my $f (@files){
	
	$key="".$id;
        $desc=$f;

        push @html, qq (<option value= "$key"> "$desc" </option>)."\n";
        $id=$id+1;

    }
    return \@html;

}
sub remove{
    my $self = shift;
    my $file = shift;
    
    my $path =  $self->_getSetPathname($file);   
    if (!$path) {return undef}
    
    if (!($conf->getPrefFolder() &&  -d $conf->getPrefFolder()&& -w $conf->getPrefFolder())){

        $self->{error} = "can't write to preference directory";
        return 0;
    }
    
    if (-e $path && -w $path){
        
        unlink $path;
        
    } elsif (-e $path){
        
        $self->{error} = "can't delete $file";
        return 0;
    }
    
    $self->{error}=undef;
    return 1;
}
####################################################################################################

sub _getSetPathname{
    my $self     = shift;
    my $file     = shift;
    
    my $pathname="";
    
    if ($conf->getPrefFolder() &&  -d $conf->getPrefFolder()&& -r $conf->getPrefFolder()){
     
       my $filename = $file.".set";
       my $dir = $conf->getPrefFolder();
       $pathname =  File::Spec->catfile( $dir, $filename );
      
    } else{
    
        $self->{error} = "unable to read from preference directory";
        return 0;
    }
   
    $self->{error}=undef;
    return $pathname;
}

1;
