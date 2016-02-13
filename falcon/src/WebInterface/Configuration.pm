#!/usr/bin/perl
#
# @File preferences.pm
# @Author Marco Curti <marcoc1712@gmail.com>
# @Created 20-gen-2016 18.23.15
#

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
	my $script=  $self->get()->{'getAutostart'};
	
	if (! $self->_checkScript($script)){return undef;}
	
	my $command = $script;
	
	my @rows = `$command`;

	if ((scalar @rows == 1) && ($rows[0]  =~ /^on+$/)){
	
		 return 1;
	}
	if ((scalar @rows == 1) && ($rows[0]  =~ /^off+$/)){
	
		 return 0;
	}
	
	my $error="ERROR: from exit: $script. Message is: ";

	for my $r (@rows){
		
		$error = $error." ".$utils->trim($r);
		
	}
	$self->{error}=$error;
	return undef;
}
sub setAutostart {
    my $self        = shift;
    my $autostart   = shift;

    if ($self->isDisabled('autostart')) {return 1};

    my $script=  $self->get()->{'setAutostart'};

    if (! $self->_checkScript($script)){return undef;}
	
    my $command = $script." ".($autostart ? "enable" : "disable");
	
	my @rows = `$command`;

	if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){
	
		 return 1;
	}
	my $error="ERROR: from exit: $script. Message is: ";

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

    my $script= $self->get()->{'setWakeOnLan'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script." ".($wakeOnLan ? "enable" : "disable");

    my @rows = `$command`;
	
   	if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){
	
		 return 1;
	}
	my $error="ERROR: from exit: $script. Message is: ";

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
    my $script= $self->get()->{'reboot'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script;

    my @rows = `$command`;
    
	if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){
	
		 return 1;
	}
	my $error="ERROR: from exit: $script. Message is: ";

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

    my $script= $self->get()->{'shutdown'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script;

    my @rows = `$command`;
	
	$log->info(@rows ? 'defined' : "undefined"); #undefined
	$log->info(scalar @rows); #0
	
	if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){
	
		 return 1;
	}
	my $error="ERROR: from exit: $script. Message is: ";

	for my $r (@rows){
		
		$error = $error." ".$utils->trim($r);
		
	}
	
	$self->{error}=$error;
	return undef;
}
sub serviceStart {
    my $self = shift;

    if ($self->isDisabled('start')) {return undef};

    my $script= $self->get()->{'start'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script;

    my @rows = `$command`;
    if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){
	
		 return 1;
	}
	my $error="ERROR: from exit: $script. Message is: ";

	for my $r (@rows){
		
		$error = $error." ".$utils->trim($r);
		
	}
	
	$self->{error}=$error;
	return undef;
}
sub serviceStop {
    my $self = shift;

    if ($self->isDisabled('stop')) {return undef};

    my $script= $self->get()->{'stop'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script;

    my @rows = `$command`;
	
	if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){
	
		 return 1;
	}
	my $error="ERROR: from exit: $script. Message is: ";

	for my $r (@rows){
		
		$error = $error." ".$utils->trim($r);
		
	}
	
	$self->{error}=$error;
	return undef;
}
sub serviceRestart {
    my $self = shift;

    if ($self->isDisabled('restart')) {return undef};

    my $script= $self->get()->{'restart'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script;

    my @rows = `$command`;

	if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){
	
		 return 1;
	}
	my $error="ERROR: from exit: $script. Message is: ";
	
	#$log->info(@rows ? 'defined' : "undefined"); #undefined
	#$log->info(scalar @rows); #0
	
	for my $r (@rows){
		#$log->info("error value BEFORE. ".$error);
		#$log->info("row value. ".$r);
		$error = $error." ".$utils->trim($r);
		#$log->info("error value AFTER. ".$error);
	}
	#$log->info("error value XXX. ".$error);
	$self->{error}=$error;
	#$log->info("self error at the end: ".$self->{error});
		
	return undef;
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
sub getProcessInfo{
    my $self = shift;
    my $pid			= shift;

    if ($self->isDisabled('getProcessInfo')) {return undef};

    my $script= $self->get()->{'getProcessInfo'};

    if (! $self->_checkScript($script)){return undef;}
	
    my $command = $script." ".($pid ? $pid : "");
    my @rows = `$command`;
    
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
    my $self = shift;
    my $commandLine = shift;

    my $script= $self->get()->{'saveCommandLine'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script." ".$commandLine;
   
    my @rows = `$command`;
	
    if ((scalar @rows == 1) && ($rows[0]  =~ /^ok+$/)){

        return 1;
    }
    
    #$log->info("script. ".$script);
    #$log->info("command line. ".$commandLine);
    
    my $error="ERROR: from exit: $script. Message is: ";

   #$log->info(@rows ? 'defined' : "undefined");
   # $log->info(scalar @rows);

    for my $r (@rows){
        #$log->info("error value BEFORE. ".$error);
        #$log->info("row value. ".$r);
        $error = $error." ".$utils->trim($r);
        #log->info("error value AFTER. ".$error);
    }
    
    #$log->info("error value XXX. ".$error);
    $self->{error}=$error;
    #$log->info("self error at the end: ".$self->{error});

    return undef;
}
sub readCommandLine{
    my $self = shift;

    my $script= $self->get()->{'readCommandLine'};

    if (! $self->_checkScript($script)){return undef;}

    my $command = $script;

    my @rows = `$command`;

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

sub _initDefault {
       
	my %defaultHash;
	my $default = \%defaultHash;

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
	
	$log->debug($script);
	
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
