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

package WebInterface::Preferences;

use strict;
use warnings;

use WebInterface::DataStore;
use base qw(WebInterface::DataStore);

my $log;

sub new {
    my $class = shift;
    my $file = shift;
    
    $log = Log::Log4perl->get_logger("preferences");
    
    my $self=$class->SUPER::new( $file,
                       "Squeezelite-R2 settings", 
                       _initDefault());

    bless $self, $class;
    return $self;
}

sub getPrefs {
    my $self = shift;
    # return the hash table
    
    return $self->get();
}
sub setPrefs{
    my $self 		= shift;
    my $in              = shift;
    
    # The post method olways pass ONLY the thrue booleans, no matter if they 
    # changed or not, so we need to set all them to false before.
    
    $self->setItem('supportsDOP',0);
    $self->setItem('lmsDownsampling',0);
    $self->setItem('autostart',0);
    $self->setItem('rate008000',0);
    $self->setItem('rate011025',0);
    $self->setItem('rate012000',0);
    $self->setItem('rate016000',0);
    $self->setItem('rate022050',0);
    $self->setItem('rate024000',0);
    $self->setItem('rate032000',0);
    $self->setItem('rate044100',0);
    $self->setItem('rate048000',0);
    $self->setItem('rate088200',0);
    $self->setItem('rate096000',0);
    $self->setItem('rate176400',0);
    $self->setItem('rate192000',0);
    $self->setItem('rate352800',0);
    $self->setItem('rate384000',0);
    $self->setItem('rate705600',0);
    $self->setItem('rate768000',0);
    $self->setItem('codecMp3',0);
    $self->setItem('codecAac',0);
    $self->setItem('codecWma',0);
    $self->setItem('codecOgg',0);
    $self->setItem('codecFlc',0);
    $self->setItem('codecAlac',0);
    $self->setItem('codecPcm',0);
    $self->setItem('codecWav',0);
    $self->setItem('codecAif',0);
    $self->setItem('codecDff',0);
    $self->setItem('codecDsf',0);
    $self->setItem('useMmap',0);
    $self->setItem('logSlimproto',0);
    $self->setItem('logStream',0);
    $self->setItem('logDecode',0);
    $self->setItem('logOutput',0);
    $self->setItem('allowWakeOnLan',0);
    $self->setItem('allowShutdown',0);
    $self->setItem('allowReboot',0);
    
    foreach my $name (keys %$in) {

        $self->setItem($name, $in->{$name});
    }
}
sub getItem {
    my $self 		= shift;
    my $item		= shift;

    return $self->get()->{$item};
}
sub setItem {
    my $self 		= shift;
    my $item		= shift;
    my $value		= shift || undef;

    $self->get()->{$item}=$value;
}
sub save {
    my $self = shift;

    $self->write();

    if ($self->getError()){return undef}

    return 1;	
}

####################################################################################################

sub _initDefault{

    my %defaultHash;
    my $default = \%defaultHash;	

    $default->{"playerName"}='squeezelite-R2';
    $default->{"audioDevice"}="";
    $default->{"supportsDOP"}=0;
    $default->{"lmsDownsampling"}=1;
    $default->{"autostart"}=0;
    $default->{"timeout"}=0;
    $default->{"serverIP"}="";
    $default->{"rate008000"}=0;
    $default->{"rate011025"}=0;
    $default->{"rate012000"}=0;
    $default->{"rate016000"}=0;
    $default->{"rate022050"}=0;
    $default->{"rate024000"}=0;
    $default->{"rate032000"}=0;
    $default->{"rate044100"}=0;
    $default->{"rate048000"}=0;
    $default->{"rate088200"}=0;
    $default->{"rate096000"}=0;
    $default->{"rate176400"}=0;
    $default->{"rate192000"}=0;
    $default->{"rate352800"}=0;
    $default->{"rate384000"}=0;
    $default->{"rate705600"}=0;
    $default->{"rate768000"}=0;
    $default->{"codecMp3"}=0;
    $default->{"codecAac"}=0;
    $default->{"codecWma"}=0;
    $default->{"codecOgg"}=0;
    $default->{"codecFlc"}=0;
    $default->{"codecAlac"}=0;
    $default->{"codecPcm"}=0;
    $default->{"codecWav"}=0;
    $default->{"codecAif"}=0;
    $default->{"codecDff"}=0;
    $default->{"codecDsf"}=0;
    $default->{"fromPcmToPcm"}=0;
    $default->{"fromPcmToDOP"}=0;
    $default->{"inBuffer"}=0;
    $default->{"outBuffer"}=0;
    $default->{"periodCount"}=0;
    $default->{"bufferSize"}=0;
    $default->{"sampleFormat"}=0;
    $default->{"useMmap"}=0;
    $default->{"logSlimproto"}=0;
    $default->{"logStream"}=0;
    $default->{"logDecode"}=0;
    $default->{"logOutput"}=0;
    $default->{"logLevel"}="info";
    $default->{"logFile"}="";
    $default->{"allowWakeOnLan"}=0;
    $default->{"allowShutdown"}=0;
    $default->{"allowReboot"}=0;

    return $default;

}
1;
