#!/usr/bin/perl
#
# @File preferences.pm
# @Author Marco Curti <marcoc1712@gmail.com>
# @Created 20-gen-2016 18.23.15
#

package SqueezeliteR2::WebInterface::Preferences;

use strict;
use warnings;

use SqueezeliteR2::WebInterface::DataStore;
use base qw(SqueezeliteR2::WebInterface::DataStore);

sub new {
    my $class = shift;
    my $file = shift;

    my $self=$class->SUPER::new( $file,
                       "Squeezelite-R2 settings", 
                       _initDefault());

    bless $self, $class;
    return $self;
}

sub getPrefs {
    my $self = shift;

    return $self->get();
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

    $default->{"playerName"}='squeezelite-R2@pc-ubuntu';
    $default->{"audioDevice"}='front:CARD=NVidia_1,DEV=0';
    $default->{"supportsDOP"}=0;
    $default->{"lmsDownsampling"}=0;
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
    $default->{"rate352000"}=0;
    $default->{"rate384000"}=0;
    $default->{"rate705600"}=0;
    $default->{"rate768000"}=0;
    $default->{"codecMp3"}=0;
    $default->{"codecAacc"}=0;
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
    $default->{"periodCount"}=3;
    $default->{"bufferSize"}=100;
    $default->{"sampleFormat"}=16;
    $default->{"useMmap"}=1;
    $default->{"logSlimproto"}=0;
    $default->{"logStream"}=0;
    $default->{"logDecode"}=0;
    $default->{"logOutput"}=0;
    $default->{"logLevel"}="info";
    $default->{"logFile"}="/home/marco/Scrivania/squeezelite-R2/squeezelite-R2.log";
    $default->{"allowWakeOnLan"}=0;
    $default->{"allowShutdown"}=0;
    $default->{"allowReboot"}=0;

    return $default;

}
1;
