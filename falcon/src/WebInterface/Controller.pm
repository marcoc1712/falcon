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
    die;
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
sub saveAsPreset{
    my $self = shift;
    my $in = shift;

    my $path =$self-> _getPresetPathname($in);
    
    if (!$path) {
        # $self->{error} ="invalid preset filename: $path";
        return undef;
    }
    
    my $return = $self->settings()->saveAs($path, $in);
    $self->{error}= $self->settings()->getError();
    
    return $return;
    
}
sub loadPreset{
    my $self = shift;
    my $in = shift;
    
    my $path =$self-> _getPresetPathname($in);
    
    if (!$path) {
        $self->{error} ="invalid preset filename: $path";
        return undef;
    }
        
    my $return = $self->settings()->load($path);
    $self->{error}= $self->settings()->getError();
    
    return $return;
}
sub listPresetsHTML {
    my $self = shift;
   
    my $return = $self->settings()->listHTML();
    $self->{error}= $self->settings()->getError();
    
    return $return;
}
sub deletePreset {
    my $self = shift;
    my $in   = shift;
    
    my $path =$self-> _getPresetPathname($in);
    
    if (!$path) {
        $self->{error} ="invalid preset filename: $path";
        return undef;
    }
    
    my $return = $self->settings()->remove($path);
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
sub getDsdFormatsHTML{
    my $self = shift;
    
    my $return = $self->status()->getDsdFormatsHTML();
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
sub _getPresetPathname {
    my $self   = shift;
    my $in     = shift;

    my $pathname="";
   
    if ($in->{'preset'}){
        
       if ($self->conf()->getPrefFolder() &&  -d $self->conf()->getPrefFolder()&& -r $self->conf()->getPrefFolder()){

          my $filename = $in->{'preset'}.".set";
          my $dir = $self->conf()->getPrefFolder();
          
          $pathname =  File::Spec->catfile( $dir, $filename );

       } else{

           $self->{error} = "unable to read from preference directory";
           return undef;
       }
    
    } else{
    
        $self->{error} ='missing preset name';
        return undef;
    }

    $self->{error}=undef;
    return $pathname;
    
}
1;
