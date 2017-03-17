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
package WebInterface::Configuration;

use strict;
use warnings;
use utf8;

use File::Spec;
use File::Basename;

use WebInterface::Utils;
use WebInterface::DataStore;

my $utils= WebInterface::Utils->new();

#use constant DISABLED      => "DISABLED";

use constant ISWINDOWS    => ( $^O =~ /^m?s?win/i ) ? 1 : 0;
use constant ISMAC        => ( $^O =~ /darwin/i ) ? 1 : 0;

use base qw(WebInterface::DataStore);

my $log;

sub new {
    my $class = shift;
    
    $log = Log::Log4perl->get_logger("configuration");
    
    my $self=$class->SUPER::new("../data/falcon.conf", 
                       "Squeezelite-R2 web interface configuration file", 
                       _initDefault());
    
    bless $self, $class;  
    $self->_upgrade(); # handle changes.
    return $self;
}
sub getPathname{
    my $self = shift;
    return $self->get()->{'pathname'};
}

sub getPrefFolder{
    my $self = shift;
    return $self->get()->{'prefFolder'};
}
sub getPrefFile{
    my $self = shift;
    
    my $folder = $self->getPrefFolder();
    my $filename =  $self->get()->{'prefFile'};
    
    return File::Spec->catfile( $folder, $filename );
   
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
sub getAutostart {
	my $self        = shift;
	
	if ($self->isDisabled('autostart')) {return 0};
	
	my @rows = $self->_runExit('getAutostart');
	my $result = $self->_getExitResult(\@rows);

	if ($result->{'data'}){
        
        my $data =  $result->{'data'};

        print scalar @$data;
        print "\n";
        print $$data[0;
        print "\n";
        print  ($$data[0]  =~ /^on+$/) ? "SI" : "NO";
        print "\n";
		if ((scalar @$data == 1) && ($$data[0]  =~ /^on+$/)){
            
            print "TROVATO";

            die;
			return 1;
		}
		if ((scalar @$data == 1) && ($$data[0]  =~ /^off+$/)){

            print "NON TROVATO";

            die;
			return 0;
		}
	}
    

        
	$self->{error}=$result->{'status'};
	$self->{error}= $self->{error}.": from exit: getAutostart. Message is: ";

	if ( $result->{'message'}){

		$self->{error}=$self->{error}.$result->{'message'};
	}
	return undef;
}
sub setAutostart {
    my $self        = shift;
    my $autostart   = shift;

    if ($self->isDisabled('autostart')) {return 1};
	
	my @rows = $self->_runExit('setAutostart', ($autostart ? 'enable' : 'disable'));
	my $result = $self->_getExitResult(\@rows);
	
	if ( $result->{'status'} eq "DONE"){
		
		return 1;
	}
	$self->{error}=$result->{'status'};
	$self->{error}= $self->{error}.": from exit: getAutostart. Message is: ";

	if ( $result->{'message'}){

		$self->{error}=$self->{error}.$result->{'message'};
	}
	return undef;
}
sub setWakeOnLan {
    my $self = shift;    
    my $wakeOnLan	= shift;

    if ($self->isDisabled('allowWakeOnLan')) {return 1};
	
	my @rows = $self->_runExit('setWakeOnLan', $wakeOnLan);
    my $result = $self->_getExitResult(\@rows);
	
	if ( $result->{'status'} eq "DONE"){
		
		return 1;
	}
	$self->{error}=$result->{'status'};
	$self->{error}= $self->{error}.": from exit: setWakeOnLan. Message is: ";

	if ( $result->{'message'}){

		$self->{error}=$self->{error}.$result->{'message'};
	}
	return undef;
}
sub hwReboot {
    my $self = shift;

    if ($self->isDisabled('reboot')) {return undef};
	if (! $self->get('allowReboot')) {
		$self->{error}="WARNING: reboot id disabled, check settings.";
		return undef;
	};
	
	my @rows = $self->_runExit('reboot');
	
	#reboot reboots, so normaly it wil not pass trougth here.
	my $result = $self->_getExitResult(\@rows);
	
	if ( $result->{'status'} eq "DONE"){
		
		return 1;
	}
	$self->{error}=$result->{'status'};
	$self->{error}= $self->{error}.": from exit: reboot. Message is: ";

	if ( $result->{'message'}){

		$self->{error}=$self->{error}.$result->{'message'};
	}
	return undef;
}
sub hwShutdown {
    my $self = shift;

    if ($self->isDisabled('shutdown')) {return undef};
    if (! $self->get('allowShutdown')) {
            $self->{error}="WARNING: shoutdown id disabled, check settings.";
            return undef;
    };

    my @rows = $self->_runExit('shutdown');
    my $result = $self->_getExitResult(\@rows);

    if ( $result->{'status'} eq "DONE"){

            return 1;
    }
    $self->{error}=$result->{'status'};
    $self->{error}= $self->{error}.": from exit: shutdown. Message is: ";

    if ( $result->{'message'}){

            $self->{error}=$self->{error}.$result->{'message'};
    }
    return undef;
}
sub hwPoweroff {
    my $self = shift;

    if ($self->isDisabled('poweroff')) {return undef};
    if (! $self->get('allowPoweroff')) {
            $self->{error}="WARNING: power off is disabled, check settings.";
            return undef;
    };

    my @rows = $self->_runExit('poweroff');
    my $result = $self->_getExitResult(\@rows);

    if ( $result->{'status'} eq "DONE"){

            return 1;
    }
    $self->{error}=$result->{'status'};
    $self->{error}= $self->{error}.": from exit: power off. Message is: ";

    if ( $result->{'message'}){

            $self->{error}=$self->{error}.$result->{'message'};
    }
    return undef;
}
sub serviceStart {
    my $self = shift;

    if ($self->isDisabled('start')) {return undef};

	my @rows = $self->_runExit('start');
    my $result = $self->_getExitResult(\@rows);
	
    if ( $result->{'status'} eq "DONE"){
		
		return 1;
    }
    $self->{error}=$result->{'status'};
    $self->{error}= $self->{error}.": from exit: start. Message is: ";

    if ( $result->{'message'}){

            $self->{error}=$self->{error}.$result->{'message'};
    }
    return undef;
}
sub serviceStop {
    my $self = shift;

    if ($self->isDisabled('stop')) {return undef};
	
	my @rows = $self->_runExit('stop');
	my $result = $self->_getExitResult(\@rows);
	
    if ( $result->{'status'} eq "DONE"){
		
		return 1;
    }
    $self->{error}=$result->{'status'};
    $self->{error}= $self->{error}.": from exit: stop. Message is: ";

    if ( $result->{'message'}){

            $self->{error}=$self->{error}.$result->{'message'};
    }
    return undef;
}
sub serviceRestart {
    my $self = shift;

    if ($self->isDisabled('restart')) {return undef};
	
    my @rows = $self->_runExit('restart');
    my $result = $self->_getExitResult(\@rows);
	
    if ( $result->{'status'} eq "DONE"){
		
		return 1;
    }
    $self->{error}=$result->{'status'};
    $self->{error}= $self->{error}.": from exit: restart. Message is: ";

    if ( $result->{'message'}){

            $self->{error}=$self->{error}.$result->{'message'};
    }
    return undef;
}
sub testAudioDevice{
    my $self = shift;
    my $audiodevice	= shift;

    if ($self->isDisabled('testAudioDevice')) {return undef};

    my @rows = $self->_runExit('testAudioDevice', $audiodevice);
    my $result = $self->_getExitResult(\@rows);

    if ( $result->{'status'} eq "DONE"){

            return $result->{'data'};
    }

    $self->{error}=$result->{'status'};
    $self->{error}= $self->{error}.": from exit: testAudioDevice. Message is: ";

    if ( $result->{'message'}){

            $self->{error}=$result->{'message'};
    }
}
sub getProcessInfo{
    my $self = shift;
    my $pid	 = shift;

    if ($self->isDisabled('getProcessInfo')) {return undef};
	
    my @rows = $self->_runExit('getProcessInfo', $pid);
    my $result = $self->_getExitResult(\@rows);
    
    if ( $result->{'status'} eq "DONE"){

        my $data = $result->{'data'};
        my $info="";
        if ($pid && (scalar @$data > 0)){

            $info = $pid." - ";
        }
        for my $row (@$data){
			while (length($row) > 80 ){
				my $join = $info eq "" ? "" : "\n";
				$info = $info.$join.substr($row,0,80);
				$row = substr($row,80);
			}
            my $join = $info eq "" ? "" : "\n";
			$info = $info.$join.$row;
        }
        return $info;
    }

    $self->{error}=$result->{'status'};
    $self->{error}= $self->{error}.": from exit: getProcessInfo. Message is: ";

    if ( $result->{'message'}){

            $self->{error}=$result->{'message'};
    }
    return undef;
}
sub writeCommandLine{
    my $self		= shift;
    my $commandLine = shift;
	
    my @rows = $self->_runExit('saveCommandLine', $commandLine);
    my $result = $self->_getExitResult(\@rows);
    
    if ( $result->{'status'} eq "DONE"){

            return 1;
    }

    $self->{error}=$result->{'status'};
    $self->{error}= $self->{error}.": from exit: saveCommandLine. Message is: ";

    if ( $result->{'message'}){

            $self->{error}=$result->{'message'};
    }
    return undef;
}
sub readCommandLine{
    my $self = shift;

    my @rows = $self->_runExit('readCommandLine');
    
    #print $self->{error};
    #die;
    
    my $result = $self->_getExitResult(\@rows);

    if ( $result->{'status'} eq "DONE"){

        my $data = $result->{'data'};
        my $info="";
        
        for my $row (@$data){

            $info = $info." ".$row;
        }
        return $info;
    }

    $self->{error}=$result->{'status'};
    $self->{error}= $self->{error}.": from exit: saveCommandLine. Message is: ";

    if ( $result->{'message'}){

            $self->{error}=$result->{'message'};
    }
    return undef;
}
sub getDsdNatives{
    my @dsdNatives = ('u8', 'u16le', 'u32le', 'u16be', 'u32be');
    my %out = map { $_ => 1 } @dsdNatives;
    return \%out;
}
####################################################################################################
sub _upgrade{
    my $self = shift;
    
    # upgrade from pref file to pref folder and file.
    if (!$self->getPrefFolder() && $self->getPrefFile()){
        
        $log->info("_upgrade: ".$self->getPrefFile());
       
        my $file = $self->getPrefFile();
        my ($filename, $folder) = fileparse($file);
             
        $self->get()->{'prefFolder'}=$folder;
        $self->get()->{'prefFile'}=$filename;
        $self->write();
        
    }
    return 1;

}
sub _runExit{
	my $self = shift;
	my $exit = shift;
	my $options	= shift;
	
	$self->{error}=undef;
	my $script= $self->get()->{$exit};
    
    if (! $self->_checkScript($script)){return undef;}
    
	my $command;
	
	if ($options){
		$command = $script." ".$options;
	} else{
		$command = $script;
	}
    my @rows = `$command`;	
	return @rows;
}
sub _getExitResult{
    my $self = shift;
	my $in   = shift;
	
	my @eData=();
	my $err={};
	$err->{'status'}='ERROR';
	$err->{'message'}="Exit did not return a valid result";
	$err->{'data'}=\@eData;
	
	my @data=();
	my $out={};
	$out->{'status'}='';
	$out->{'message'}="";
	$out->{'data'}=\@data;
	
	if (!$in){
		return $err;
	}
	my $result="";
	
	for my $line (@$in){
		$result = $result." ".$utils->trim($line);
	}
	#print $result;
        
    $out = $utils->decodeJson($result);
        
    ### minimal Sanity check
	if (! $out->{'status'} || (lc($out->{'status'}) eq "ok")) {
	
		$out->{'status'}="DONE";
	}
	$out->{'status'}=uc($out->{'status'});
	
	return $out;

}

sub _initDefault {
       
	my %defaultHash;
	my $default = \%defaultHash;
	
	$default->{'isDefault'} = 1;
	$default->{'pathname'} = "/usr/bin/squeezelite-R2";
        $default->{'prefFolder'} = "/var/www/falcon/data";
        $default->{'prefFile'} = "squeezelite-R2.pref";
	$default->{'PIDFile'} = "/run/squeezelite-R2.pid";

	# disabled settings and  local installation scripts;

	$default->{DISABLED}->{'autostart'} 	= 1;
	$default->{'setAutostart'} = "/var/www/falcon/exit/setAutostart.pl";

	$default->{DISABLED}->{'allowWakeOnLan'} 	= 1;
	$default->{'setWakeOnLan'} = "/var/www/falcon/exit/setWakeOnLan.pl";

	$default->{DISABLED}->{'allowReboot'} 	= 1;
	$default->{DISABLED}->{'reboot'} 		= 1;
	$default->{'reboot'} = "/var/www/falcon/exit/hwReboot.pl";

	$default->{DISABLED}->{'allowShutdown'} 	= 1;
	$default->{DISABLED}->{'shutdown'} 	= 1;
	$default->{'shutdown'} = "/var/www/falcon/exit/hwShutdown.pl";

	$default->{DISABLED}->{'allowPoweroff'} 	= 1;
	$default->{DISABLED}->{'poweroff'} 	= 1;
	$default->{'shutdown'} = "/var/www/falcon/exit/hwPoweroff.pl";
	
	$default->{DISABLED}->{'start'} 	= 1;
	$default->{'start'} = "/var/www/falcon/exit/ServiceStart.pl";

	$default->{DISABLED}->{'stop'} 	= 1;
	$default->{'stop'} = "/var/www/falcon/exit/ServiceStop.pl";

	$default->{DISABLED}->{'restart'} 	= 1;
	$default->{'restart'} = "/var/www/falcon/exit/ServiceRestart.pl";

	$default->{DISABLED}->{'getProcessInfo'} 	= 1;
	$default->{'getProcessInfo'} = "/var/www/falcon/exit/getProcessInfo.pl";

	$default->{DISABLED}->{'testAudioDevice'} = 1;
	$default->{'testAudioDevice'} = "/var/www/falcon/exit/testAudioDevice.pl";
        
	$default->{'saveCommandLine'} = "/var/www/falcon/exit/saveCommandLine.pl";
	$default->{'readCommandLine'} = "/var/www/falcon/exit/readCommandLine.pl";

	return $default;
}
sub _checkScript{
    my $self = shift;
	my $script= shift;
	
	$log->info("_checkScript: ".$script);
	
	if (! $script) {
		$self->{error}="ERROR: script is undefined"; 
		return undef;
	}
	if (! -e $script) {
		$self->{error}="ERROR: script $script does not exists"; 
		return undef;
	}
	if (! -r $script) {
		$self->{error}="ERROR: could not read script $script"; 
		return undef;
	}
	if (! -x $script) {
		$self->{error}="ERROR: could not execute script $script"; 
		return undef;
	}
        
	$self->{error}=undef;
	return 1;
}
1;
