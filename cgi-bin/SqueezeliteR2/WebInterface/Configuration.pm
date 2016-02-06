#!/usr/bin/perl
#
# @File preferences.pm
# @Author Marco Curti <marcoc1712@gmail.com>
# @Created 20-gen-2016 18.23.15
#

package SqueezeliteR2::WebInterface::Configuration;

use strict;
use warnings;
use utf8;

use SqueezeliteR2::WebInterface::Utils;
use SqueezeliteR2::WebInterface::DataStore;
my $utils= SqueezeliteR2::WebInterface::Utils->new();

#use constant DISABLED      => "DISABLED";

use constant ISWINDOWS    => ( $^O =~ /^m?s?win/i ) ? 1 : 0;
use constant ISMAC        => ( $^O =~ /darwin/i ) ? 1 : 0;

use base qw(SqueezeliteR2::WebInterface::DataStore);

sub new {
    my $class = shift;

    my $self=$class->SUPER::new("../conf/Squeezelite-R2.conf", 
                       "Squeezelite-R2 web interface configuration file", 
                       _initDefault());

    bless $self, $class;   
    return $self;
}
sub getPathname{
    my $self = shift;
    return $self->get()->{'pathname'};
}
sub getPrefFile{
    my $self = shift;
    return $self->get()->{'prefFile'};
}
sub getPIDFile{
    my $self = shift;
    return $self->get()->{'PIDFile'};
}
sub getDisabled{
    my $self = shift;
    return $self->get()->{DISABLED};

}
sub isDisabled {
    my $self = shift;
    my $item = shift;

    return $self->get()->{DISABLED}->{$item};
	
}
sub setAutostart {
    my $self        = shift;
    my $autostart   = shift;

    if ($self->isDisabled('autostart')) {return 1};

    my $script=  $self->get()->{'setAutostart'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script." ".($autostart ? 1 : 0);

    my @rows = `$command`;
    if (!scalar @rows == 1) {return undef;}

    return $utils->trim($rows[0]);
}
sub setWakeOnLan {
    my $self = shift;    
    my $wakeOnLan	= shift;

    if ($self->isDisabled('allowWakeOnLan')) {return 1};

    my $script= $self->get()->{'setWakeOnLan'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script." ".($wakeOnLan ? 1 : 0);

    my @rows = `$command`;
    if (!scalar @rows == 1) {return undef;}

    return $utils->trim($rows[0]);
}
sub hwReboot {
    my $self = shift;

    if ($self->isDisabled('allowReboot')) {return undef};

    my $script= $self->get()->{'reboot'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script;

    my @rows = `$command`;
    if (!scalar @rows == 0) {return undef;}

    return "ok";
}
sub hwShutdown {
    my $self = shift;

    if ($self->isDisabled('allowShutdown')) {return undef};

    my $script= $self->get()->{'shutdown'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script;

    my @rows = `$command`;
    if (!scalar @rows == 0) {return undef;}

    return "ok";
}
sub serviceStart {
    my $self = shift;

    if ($self->isDisabled('start')) {return undef};

    my $script= $self->get()->{'start'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script;

    my @rows = `$command`;
    if (!scalar @rows == 0) {return undef;}

    return "ok";
}
sub serviceStop {
    my $self = shift;

    if ($self->isDisabled('stop')) {return undef};

    my $script= $self->get()->{'stop'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script;

    my @rows = `$command`;
    if (!scalar @rows == 0) {return undef;}

    return "ok";
}
sub serviceRestart {
    my $self = shift;

    if ($self->isDisabled('restart')) {return undef};

    my $script= $self->get()->{'restart'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script;

    my @rows = `$command`;
    if (!scalar @rows == 0) {return undef;}

    return "ok";
}
sub getProcessInfo{
    my $self = shift;
    my $pid			= shift;

    if ($self->isDisabled('getProcessInfo')) {return undef};

    my $script= $self->get()->{'getProcessInfo'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script." ".$pid;

    my @rows = `$command`;

    if (!scalar @rows == 1) {return undef;}

    return $pid." - ". $utils->trim($rows[0]);
}
sub testAudioDevice{
    my $self = shift;
    my $audiodevice	= shift;

    if ($self->isDisabled('testAudioDevice')) {return undef};

    my $script= $self->get()->{'testAudioDevice'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script." ".$audiodevice;

    my @rows = `$command`;

    return \@rows;

}
sub writeCommandLine{
    my $self = shift;
    my $commandLine = shift;

    
    my $script= $self->get()->{'saveCommandLine'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script." ".$commandLine;

    my @rows = `$command`;

    return \@rows;

}
sub readCommandLine{
    my $self = shift;

    my $script= $self->get()->{'readCommandLine'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script;

    my @rows = `$command`;

    return \@rows;

}

####################################################################################################

sub _initDefault {
       
	my %defaultHash;
	my $default = \%defaultHash;
	

	$default->{'pathname'} = "/home/marco/Scrivania/squeezelite-R2/squeezelite-R2-deb-x86_64";
	$default->{'prefFile'} = "/home/marco/Scrivania/squeezelite-R2/squeezelite-R2.pref";
	$default->{'PIDFile'} = "/home/marco/Scrivania/squeezelite-R2/squeezelite-R2.pid";

	# disabled settings and  local installation scripts;

	$default->{DISABLED}->{'autostart'} 	= 1;
	$default->{'setAutostart'} = "/var/www/exit/Local/setAutostart.pl";

	$default->{DISABLED}->{'allowWakeOnLan'} 	= 1;
	$default->{'setWakeOnLan'} = "/var/www/exit/Local/setWakeOnLan.pl";

	$default->{DISABLED}->{'allowReboot'} 	= 1;
	$default->{DISABLED}->{'reboot'} 		= 1;
	$default->{'reboot'} = "/var/www/exit/Local/hwReboot.pl";

	$default->{DISABLED}->{'allowShutdown'} 	= 1;
	$default->{DISABLED}->{'shutdown'} 	= 1;
	$default->{'shutdown'} = "/var/www/exit/Local/hwShutdown.pl";

	$default->{DISABLED}->{'start'} 	= 1;
	$default->{'start'} = "/var/www/exit/Standard/Linux/ServiceStart.pl";

	$default->{DISABLED}->{'stop'} 	= 1;
	$default->{'stop'} = "/var/www/exit/Standard/Linux/ServiceStop.pl";

	$default->{DISABLED}->{'restart'} 	= 1;
	$default->{'restart'} = "/var/www/exit/Standard/Linux/ServiceRestart.pl";

	#$default->{DISABLED}->{'getProcessInfo'} 	= 1;
	$default->{'getProcessInfo'} = "/var/www/exit/Standard/Linux/getProcessInfo.pl";

	#$default->{DISABLED}->{'testAudioDevice'} = 1;
	$default->{'testAudioDevice'} = "/var/www/exit/Local/testAudioDevice.pl";
        
        $default->{'saveCommandLine'} = "/var/www/exit/Local/saveCommandLine.pl";
        $default->{'readCommandLine'} = "/var/www/exit/Local/readCommandLine.pl";

	return $default;
}
sub _checkScript{
        my $self = shift;
	my $script= shift;
	
	if (! $script) {
            $self->{error}="ERROR: script is undefined"; 
            return undef;
        }
	if (! -e $script) {
            $self->{error}="ERROR: script idoes not exists"; 
            return undef;
        }
	if (! -r $script) {
            $self->{error}="ERROR: could not read script"; 
            return undef;
        }
	if (! -x $script) {
            $self->{error}="ERROR: could not execute script"; 
            return undef;
        }
        
        $self->{error}=undef;
	return 1;
}
1;
