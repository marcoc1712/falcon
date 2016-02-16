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

package WebInterface::Controller;

use strict;
use warnings;
use utf8;

use WebInterface::Configuration;
use WebInterface::Settings;
use WebInterface::Status;
use WebInterface::Log;

my $log;

sub new {
    my $class = shift;
    $log= Log::Log4perl->get_logger("controller");
    
    my $conf        = WebInterface::Configuration->new();
    my $settings    = WebInterface::Settings->new();
    my $status      = WebInterface::Status->new();

    my $self = bless {
                conf => $conf,
                settings => $settings,
                status => $status,
                error => undef,
             }, $class;
    return $self;
}
sub conf {
    my $self = shift;
    return $self->{conf};
}
sub settings {
    my $self = shift;
    return $self->{settings};
}
sub status {
    my $self = shift;
    return $self->{status};
}
sub getError{
    my $self = shift;
       
    return $self->{error};
}

sub getDisabled {
    my $self = shift;

    my $return = $self->conf()->getDisabled();
    $self->{error}= $self->conf()->getError();
    
    return $return;
}
sub getSettings {
    my $self = shift;
    
    my $return = $self->settings()->getSettings();
    $self->{error}= $self->settings()->getError();
    
    #my $return = undef;
    #$self->{error}= "ERROR: testo di prova";
    
    return $return;
   
}

sub setSetting{
    my $self 		= shift;
    my $item		= shift;
    my $value		= shift || undef;
    
    my $return = $self->settings()->set($item,$value);
    $self->{error}= $self->settings()->getError();
    
    return $return;
}
sub saveSettings{
    my $self = shift;
    my $in = shift;
    
    if ($in){
    
        $self->settings()->setSettings($in);
    }
    
    my $return = $self->settings()->save();
    $self->{error}= $self->settings()->getError();
    
    return $return;
}
sub getStatus {
    my $self = shift;
    
    my $return = $self->status()->getStatus();
    $self->{error}= $self->status()->getError();

    return $return;
   
}
sub getAudioCardsHTML{
    my $self = shift;
    
    my $return = $self->status()->getAudioCardsHTML();
    $self->{error}= $self->status()->getError();

    return $return;
}
sub clearLogfile{
    my $self = shift;
    my $who = shift || "";
    
    my $logFile= $self->settings()->getItem('logFile');
    $self->{error}= $self->settings()->getError();
    
    if ($self->{error}) {return undef;}
    if (!$logFile) {
        
        $self->{error}= "WARNING: log file is not defined";
        return undef; 
    }
    
    my $log  = WebInterface::Log->new($logFile);
    
    my $return = $log->clear($who);
    $self->{error}=$log->getError();
    
    return $return;

}
sub getLogHTML{
    my $self = shift;
    my $limit = shift;
    
    my $logFile= $self->settings()->getItem('logFile');
    $self->{error}= $self->settings()->getError();
    
    if ($self->{error}) {return undef;}
    if (!$logFile) {
        
        $self->{error}= "WARNING: log file is not defined";
        return undef;
    }
    
    my $log  = WebInterface::Log->new($logFile);
    
    my $return = $log->getHTML($limit);
    $self->{error}= $log->getError();
    
    return $return;

}
sub testAudioDevice {
    my $self = shift;
    my $audiodevice = shift;
    
    if (! $audiodevice) {
    
        $audiodevice = $self->settings()->getItem('audioDevice');
    }
    $self->{error}= $self->settings()->getError();
    if (! $audiodevice) {return undef;}
    
    my $return = $self->conf()->testAudioDevice($audiodevice);
    $self->{error}= $self->conf()->getError();

    return $return;
}
sub hwReboot {
    my $self = shift;
    
    my $return = $self->conf()->hwReboot();
    $self->{error}= $self->conf()->getError();

    return $return;
}
sub hwShutdown {
    my $self = shift;
    
    my $return = $self->conf()->hwShutdown();
    $self->{error}= $self->conf()->getError();

    return $return;
}
sub serviceStart {
    my $self = shift;
    
    my $return = $self->conf()->serviceStart();
    $self->{error}= $self->conf()->getError();

    return $return;
}
sub serviceStop {
    my $self = shift;
    
    my $return = $self->conf()->serviceStop();
    $self->{error}= $self->conf()->getError();

    return $return;
}
sub serviceRestart {
    my $self = shift;
    
    my $return = $self->conf()->serviceRestart();
    $self->{error}= $self->conf()->getError();

    return $return;
}

####################################################################################################

1;
