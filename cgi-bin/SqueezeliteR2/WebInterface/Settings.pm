#!/usr/bin/perl
#
# @File Settings.pm
# @Author Marco Curti <marcoc1712@gmail.com>
# @Created 20-gen-2016 18.23.15
#

package SqueezeliteR2::WebInterface::Settings;

use strict;
use warnings;
use utf8;

use SqueezeliteR2::WebInterface::Configuration;
use SqueezeliteR2::WebInterface::Preferences;
use SqueezeliteR2::WebInterface::CommandLine;

my $log;

sub new {
    my $class = shift;

    $log = Log::Log4perl->get_logger("settings");

    my $conf = SqueezeliteR2::WebInterface::Configuration->new();
    my $prefs;
    my $commandLine;

    if ($conf->getPrefFile() && -e $conf->getPrefFile() && -r $conf->getPrefFile()){
    
        $prefs = SqueezeliteR2::WebInterface::Preferences->new($conf->getPrefFile());
        $commandLine = SqueezeliteR2::WebInterface::CommandLine->new($prefs);

    } else {
        
		my $commandLineText=$conf->readCommandLine();
		$self->{error} = $conf->getError();
		
		if (! $commandLineText){
			
			#load defaults.
			$prefs = SqueezeliteR2::WebInterface::Preferences->new($conf->getPrefFile());
			$commandLine = SqueezeliteR2::WebInterface::CommandLine->new($prefs);
			
		} else{
			
			#load command line.
			$commandLine = SqueezeliteR2::WebInterface::CommandLine->new(undef, $commandLineText);
			$prefs = $commandLine->getPreferences();
		}

    }
    my $self = bless {
                    conf => $conf,
                    prefs => $prefs,
                    commandLine => $commandLine,
                    error => undef,
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
     
    
    return undef;
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

    if (! $self->commandLine()->setPreferences($self->prefs())) {$self->{error} =$self->commandLine()->getError();}

    if (! $self->{error} && ! $self->conf()->setAutostart($self->getItem('autostart'))) {
        $self->{error} =  $self->conf()->getError();
    }

    if (! $self->{error} && ! $self->conf()->setWakeOnLan($self->getItem('allowWakeOnLan'))) {
        $self->{error} =  $self->conf()->getError();
    }

    if (! $self->{error} && ! $self->prefs()->save()) {
        $self->{error} = $self->prefs()->getError();
    }

    if (! $self->{error}) {return "DONE. Please restart.";};

    return undef; 
	
}
1;
