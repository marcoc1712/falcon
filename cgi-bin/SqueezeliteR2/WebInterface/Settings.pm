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

sub new {
    my $class = shift;

    my $conf = SqueezeliteR2::WebInterface::Configuration->new();
    my $prefs = SqueezeliteR2::WebInterface::Preferences->new($conf->getPrefFile());
    
    my $self = bless {
                    conf => $conf,
                    prefs => $prefs,
                    commandLine => undef,
                    error => undef,
                 }, $class;
    
    my $commandLine = SqueezeliteR2::WebInterface::CommandLine->new($self);
    $self->{commandLine}= $commandLine;
    
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

sub save{
    my $self = shift;

    $self->{error} =undef;

    if (! $self->commandLine()->set($self)) {$self->{error} =$self->commandLine()->getError();}

    if (! $self->{error} && ! $self->conf()->setAutostart($self->get('autostart'))) {
        $self->{error} =  $self->conf()->getError();
    }

    if (! $self->{error} && ! $self->conf()->setWakeOnLan($self->get('allowWakeOnLan'))) {
        $self->{error} =  $self->conf()->getError();
    }

    if (! $self->{error} && ! $self->prefs()->save()) {
        $self->{error} = $self->prefs()->getError();
    }

    if (! $self->{error}) {return $self->commandLine()->get()};

    return undef; 
	
}
sub getSettings{
    my $self 		= shift;

    $self->{error} = $self->prefs()->getError();
    return $self->prefs()->getPrefs();

}
sub get{
    my $self 		= shift;
    my $item		= shift;

    $self->{error} = $self->prefs()->getError();
    return $self->prefs()->getItem($item);

}
sub set {
    my $self 		= shift;
    my $item		= shift;
    my $value		= shift || undef;

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
1;
