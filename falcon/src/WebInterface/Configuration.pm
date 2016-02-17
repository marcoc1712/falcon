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
sub getAutostart {
	my $self        = shift;
	
	if ($self->isDisabled('autostart')) {return 0};
	
	my @rows = $self->_runExit('getAutostart');
	
	my $result = _getResult(\@rows);
	
	return undef;
}
sub setAutostart {
    my $self        = shift;
    my $autostart   = shift;

    if ($self->isDisabled('autostart')) {return 1};
	
	my @rows = $self->_runExit('setAutostart', $autostart);

	if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){
	
		 return 1;
	}
	my $error="ERROR: from exit: setAutostart. Message is: ";

	for my $r (@rows){
		
		$error = $error." ".$utils->trim($r);
		
	}
	$self->{error}=$error;
	return undef;
}
sub setWakeOnLan {
    my $self = shift;    
    my $wakeOnLan	= shift;

    if ($self->isDisabled('allowWakeOnLan')) {return 1};
	
	my @rows = $self->_runExit('setWakeOnLan', $wakeOnLan);
    
	if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){
	
		 return 1;
	}
	my $error="ERROR: from exit: setWakeOnLan. Message is: ";

	for my $r (@rows){
		
		$error = $error." ".$utils->trim($r);
		
	}
	
	$self->{error}=$error;
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
        
	if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){
	
		 return 1;
	}
	my $error="ERROR: from exit: reboot. Message is: ";

	for my $r (@rows){
		
		$error = $error." ".$utils->trim($r);
		
	}
	
	$self->{error}=$error;
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
    	
	$log->debug(@rows ? 'defined' : "undefined"); #undefined
	$log->debug(scalar @rows); #0
	
	if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){
	
		 return 1;
	}
	my $error="ERROR: from exit: shutdown. Message is: ";

	for my $r (@rows){
		
		$error = $error." ".$utils->trim($r);
		
	}
	
	$self->{error}=$error;
	return undef;
}
sub serviceStart {
    my $self = shift;

    if ($self->isDisabled('start')) {return undef};

	my @rows = $self->_runExit('start');
    
    if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){
	
		 return 1;
	}
	my $error="ERROR: from exit: start. Message is: ";

	for my $r (@rows){
		
		$error = $error." ".$utils->trim($r);
		
	}
	
	$self->{error}=$error;
	return undef;
}
sub serviceStop {
    my $self = shift;

    if ($self->isDisabled('stop')) {return undef};
	
	my @rows = $self->_runExit('stop');
	
	if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){
	
		 return 1;
	}
	my $error="ERROR: from exit: stop. Message is: ";

	for my $r (@rows){
		
		$error = $error." ".$utils->trim($r);
		
	}
	
	$self->{error}=$error;
	return undef;
}
sub serviceRestart {
    my $self = shift;

    if ($self->isDisabled('restart')) {return undef};
	
	my @rows = $self->_runExit('restart');
    
	if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){
	
		 return 1;
	}
	my $error="ERROR: from exit: restart. Message is: ";
	
	#$log->debug(@rows ? 'defined' : "undefined"); #undefined
	#$log->debug(scalar @rows); #0
	
	for my $r (@rows){
		#$log->debug("error value BEFORE. ".$error);
		#$log->debug("row value. ".$r);
		$error = $error." ".$utils->trim($r);
		#$log->debug("error value AFTER. ".$error);
	}
	#$log->debug("error value XXX. ".$error);
	$self->{error}=$error;
	#$log->debug("self error at the end: ".$self->{error});
		
	return undef;
}
sub testAudioDevice{
    my $self = shift;
    my $audiodevice	= shift;

    if ($self->isDisabled('testAudioDevice')) {return undef};

	my @rows = $self->_runExit('testAudioDevice', $audiodevice);
    
    return \@rows;

}
sub getProcessInfo{
    my $self = shift;
    my $pid	 = shift;

    if ($self->isDisabled('getProcessInfo')) {return undef};
	
	my @rows = $self->_runExit('getProcessInfo', $pid);
   
	my $info="";
	if ($pid && (scalar @rows > 0)){
		
		$info = $pid." - ";
	}
	for my $row (@rows){

			$row = $utils->asciiClean($row);
			$info = $info." ".$row;
	}
    return $info;
}
sub writeCommandLine{
    my $self		= shift;
    my $commandLine = shift;
	
	my @rows = $self->_runExit('saveCommandLine', $commandLine);
    
    if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){

        return 1;
    }
    
    #$log->debug("script. ".$script);
    #$log->debug("command line. ".$commandLine);
    
    my $error="ERROR: from exit: saveCommandLine. Message is: ";

   #$log->debug(@rows ? 'defined' : "undefined");
   # $log->debug(scalar @rows);

    for my $r (@rows){
        #$log->debug("error value BEFORE. ".$error);
        #$log->debug("row value. ".$r);
        $error = $error." ".$utils->trim($r);
        #log->debug("error value AFTER. ".$error);
    }
    
    #$log->debug("error value XXX. ".$error);
    $self->{error}=$error;
    #$log->debug("self error at the end: ".$self->{error});

    return undef;
}
sub readCommandLine{
    my $self = shift;

    my @rows = $self->_runExit('readCommandLine');
    
	if (!@rows || (scalar @rows == 0)){
		
		my $error="WARNING: can't read command line";
		return undef;
	}
    my $commandLine="";
    
    for my $row (@rows){
		
		if (($row  =~ /^ERROR/) || ($row  =~ /^WARNING/)){
			my $error=$row;
			return undef;
		} 
		
        $commandLine = $commandLine." ".$row;
    }
    return $commandLine;

}

####################################################################################################

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

sub _getResult{
	my $self = shift;
	my $in = shift;
	
	my $out=();
	
	if (!$in){
		return undef;
	}

	my $result="";
	
	for my $line (@$in){
		$result = $result.$utils->trim($line);
	}
	#print $result."\n";
	
	#validate json first and last char;
	if (! $result || length($result)<3) {return undef;}
	
	if (! ((substr($result,0,1)) eq "{")){return undef;}
	if (! ((substr($result,length($result)-1)) eq "}")){return undef;}
	
	$result= substr($result,1);
	$result= substr($result,0,length($result)-1)."\n";
	
	my @elements= split ",", $result;
	
	my $inArray=0;
	my $curKey;
	
	for my $el (@elements){
		
		if (! $inArray){

			my @keyVals= split ":", $el;
			#Data::Dump::dump @keyVals;	

			if (! scalar @keyVals == 2){return undef;}
			
			$curKey = $utils->trim($keyVals[0]);
			my $val = $utils->trim($keyVals[1]);
			
			if (substr($val,0,1) eq "[") {
				
				$out->{$curKey}= substr($val,1);
				$inArray =1;
			} else{
			
				$out->{$curKey}=$val;
			}
			
		} else { # in array 

			if (substr($el,length($el)-2) eq "]\n") {

				$out->{$curKey}=$out->{$curKey}.", ".substr($el,0,length($el)-2);
				$inArray =0;
				
			} else{
			
				$out->{$curKey}=$out->{$curKey}.", ".$el;
			}
		}
	}
	return $out;
}

sub _initDefault {
       
	my %defaultHash;
	my $default = \%defaultHash;
	
	$default->{'isDefault'} = 1;
	$default->{'pathname'} = "/usr/bin/squeezelite-R2";
	$default->{'prefFile'} = "/var/www/falcon/data/squeezelite-R2.pref";
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

	$default->{DISABLED}->{'start'} 	= 1;
	$default->{'start'} = "/var/www/falcon/exit/ServiceStart.pl";

	$default->{DISABLED}->{'stop'} 	= 1;
	$default->{'stop'} = "/var/www/falcon/exit/ServiceStop.pl";

	$default->{DISABLED}->{'restart'} 	= 1;
	$default->{'restart'} = "/var/www/falcon/exit/ServiceRestart.pl";

	#$default->{DISABLED}->{'getProcessInfo'} 	= 1;
	$default->{'getProcessInfo'} = "/var/www/falcon/exit/getProcessInfo.pl";

	#$default->{DISABLED}->{'testAudioDevice'} = 1;
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
