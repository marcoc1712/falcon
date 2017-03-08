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

package WebInterface::CommandLine;

use strict;
use warnings;
use utf8;

use WebInterface::Utils;
use WebInterface::Configuration;

my $utils= WebInterface::Utils->new();
my $conf;

my $log;

sub new {

    my $class           = shift;
    my $preferences     = shift;
    my $commandLine     = shift;
    
    $log= Log::Log4perl->get_logger("commandline");
    $log->info("started new"); 
    
    $conf = WebInterface::Configuration->new();
    
    my $self = bless {
            preferences => $preferences,
            commandLine => $commandLine,
            error => undef,
         }, $class;
    
    if ($preferences && $commandLine){
        
        $self->_validate();
        
    } elsif ($commandLine) {
        
        $self->_loadPreferencesFromCommandLine();

    } elsif ($preferences){
                  
        $self->setPreferences($preferences);

    } else {
		
		$self->{error}=$conf->getError();
	}
    return $self;
    
}
sub get {
    my $self = shift;
    
    return $self->{commandLine};
}
sub getPreferences {
    my $self = shift;
    return $self->{preferences};
}
sub setPreferences {
    my $self = shift;
    my $preferences=shift;

    $self->{preferences}  = $preferences;
    $self->{commandLine}  = $self->_buildCommandLineFromPreferences();
    
    return $self->_save();
}
sub getError {
    my $self = shift;
    
    return $self->{error};
}

####################################################################################################
sub _save{
    my $self = shift;

    if (! $conf->writeCommandLine($self->{commandLine})){
        $self->{error} = $conf->getError();
		$log->error("ERROR: Unable to write command line: ".$self->{commandLine}." to file ". $self->{error});
        return undef;
	}
	$log->info("command line: ".$self->{commandLine}." saved");
    return 1;
    
}

sub _buildCommandLineFromPreferences{
    my $self = shift;
    
    my $preferences= $self->{preferences};
    my $commandLine="";	
    
    if (! $preferences) {return "";}

    if (! $conf->getPathname() || ($conf->getPathname() eq "") ) {return ""};

    $commandLine=  $conf->getPathname();
    
    if ($preferences->getItem('playerName')){

            $commandLine = $commandLine." -n ".$preferences->getItem('playerName');
    } 

    if ($preferences->getItem('audioDevice')){

            $commandLine = $commandLine." -o ".$preferences->getItem('audioDevice');

    } 
    
    # $log->debug("supportsDOP: ".($preferences->getItem('supportsDOP') || 0));
    
    my $dsdFormat= $preferences->getItem('dsdFormat') ?  $preferences->getItem('dsdFormat') : 'disabled';
    $log->debug("dsdFormat: ".$dsdFormat);
    
    if (!($preferences->getItem('dsdFormat') eq 'disabled' )){

        $commandLine = $commandLine." -D";       

        if ($preferences->getItem('fromPcmToDOP')){

                $commandLine = $commandLine." ".$preferences->getItem('fromPcmToDOP');
        } 

        if (!($preferences->getItem('dsdFormat') eq 'DOP' )){

             $commandLine = $commandLine." : ".$preferences->getItem('dsdFormat');
        }
    }        

    $log->debug("AFTER dsdFormat: ".$commandLine);  
    
    $log->debug("lmsDownsampling: ".($preferences->getItem('lmsDownsampling') || 0)); 
    if (! $preferences->getItem('lmsDownsampling')){

            $commandLine = $commandLine." -x";
    }
    $log->debug("AFTER lmsDownsampling: ".$commandLine);  
    
    $log->debug("timeout: ".($preferences->getItem('timeout') ||0)); 
    
    if ($preferences->getItem('timeout')){

            $commandLine = $commandLine." -C ".$preferences->getItem('timeout');
    }
    $log->debug("AFTER timeout: ".$commandLine);
    
    $log->debug("serverIP: ".($preferences->getItem('serverIP') || "undef")); 
    if ($preferences->getItem('serverIP')){

            $commandLine = $commandLine." -s ".$preferences->getItem('serverIP');
    }
    $log->debug("AFTER serverIP: ".$commandLine);
    if ($preferences->getItem('playerId')){

            $commandLine = $commandLine." -m ".$preferences->getItem('playerId');
    }
    $log->debug("AFTER playerId: ".$commandLine);
    my $rateString=  _checkSampleRates($preferences->getPrefs());

    if ($rateString && ! ($rateString eq "")){

            $commandLine = $commandLine." -r ".$rateString;

            if ($preferences->getItem('fromPcmToPcm')){

                    $commandLine = $commandLine.":".$preferences->getItem('fromPcmToPcm');
            } 
    }
    $log->debug("AFTER rates: ".$commandLine);
    
    my $codecString=  _checkCodecs($preferences->getPrefs());

    if ($codecString && ! ($codecString eq "")){

            $commandLine = $commandLine." -c ".$codecString;
    }
    $log->debug("AFTER codecs: ".$commandLine);
    
    $log->debug("inBuffer: ".($preferences->getItem('inBuffer') || 0));
    $log->debug("outBuffer: ".($preferences->getItem('logOutput') || 0));
    
    if ($preferences->getItem('inBuffer') || $preferences->getItem('outBuffer')){

            $commandLine = $commandLine." -b ";
            $commandLine = $commandLine.($preferences->getItem('inBuffer') ? $preferences->getItem('inBuffer') : '4096');
            $commandLine = $commandLine.":";
            $commandLine = $commandLine.($preferences->getItem('outBuffer') ? $preferences->getItem('outBuffer') : '4096');
    }
    $log->debug("AFTER buffers: ".$commandLine);
    
    $log->debug("sampleFormat: ".($preferences->getItem('sampleFormat') || 0));
    $log->debug("periodCount: ".($preferences->getItem('periodCount') || 0));
    $log->debug("bufferSize: ".($preferences->getItem('bufferSize') || 0));
    $log->debug("useMmap: ".($preferences->getItem('useMmap') || 0));
    
    if ($preferences->getItem('sampleFormat') || $preferences->getItem('periodCount') || 
            $preferences->getItem('bufferSize') || $preferences->getItem('useMmap')){

            $commandLine = $commandLine." -a ";

            if ($preferences->getItem('periodCount') || $preferences->getItem('bufferSize') || $preferences->getItem('useMmap')){

                    $commandLine = $commandLine.$preferences->getItem('bufferSize').":";
                    $commandLine = $commandLine.$preferences->getItem('periodCount').":";
                    $commandLine = $commandLine.$preferences->getItem('sampleFormat').":";
                    $commandLine = $commandLine.($preferences->getItem('useMmap') ? "1" : "0");

            } else {

                    $commandLine= $commandLine.$preferences->getItem('sampleFormat');
            }
    } 
    $log->debug("AFTER alsa: ".$commandLine); 
    
    $log->debug("logSlimproto: ".($preferences->getItem('logSlimproto') || 0)); 
    $log->debug("logStream: ".($preferences->getItem('logStream') || 0));
    $log->debug("logDecode: ".($preferences->getItem('logDecode') || 0));
    $log->debug("logOutput: ".($preferences->getItem('logOutput') || 0));
    
    if ($preferences->getItem('logSlimproto') && $preferences->getItem('logStream') && 
            $preferences->getItem('logDecode') && $preferences->getItem('logOutput')){

            $commandLine=$commandLine." -d all=".$preferences->getItem('logLevel');

    } else {

            if ($preferences->getItem('logSlimproto')){

                    $commandLine=$commandLine." -d slimproto=".$preferences->getItem('logLevel');
            }
            if ($preferences->getItem('logStream')){

                    $commandLine=$commandLine." -d stream=".$preferences->getItem('logLevel');
            }
            if ($preferences->getItem('logDecode')){

                    $commandLine=$commandLine." -d decode=".$preferences->getItem('logLevel');
            }
            if ($preferences->getItem('logOutput')){

                    $commandLine=$commandLine." -d output=".$preferences->getItem('logLevel');
            }
    }
    $log->debug("AFTER log: ".$commandLine); 
    
    $log->debug("logFile: ".($preferences->getItem('logFile') || ""));
    
    if ($preferences->getItem('logFile')){

            $commandLine=$commandLine." -f ".$preferences->getItem('logFile');
    }
    $log->debug("AFTER logFile: ".$commandLine); 
    
    $log->debug("pidFile: ".($conf->getPIDFile() || ""));
     
    if ($conf->getPIDFile() && !($conf->getPIDFile() eq "")){

            $commandLine=$commandLine." -P ".$conf->getPIDFile();
    }	
    $log->debug("AFTER pidFile: ".$commandLine); 
    
    return $commandLine;
}

sub _loadPreferencesFromCommandLine{
    my $self = shift;
    
    my $preferences= $self->{preferences};
    my $commandLine= $self->{commandLine};

    if (! $commandLine || ($commandLine eq "")){
        
        $self->{preferences} = undef;
        return 1;
    }
     
    if (! $preferences ){ 
        $preferences= WebInterface::Preferences->new($conf->getPrefFile());
        $self->{preferences}=$preferences;
    }

    $commandLine = $self->_removePathname();

    my @elements= split " ", $commandLine;
   
    my $options= $self->_builsOptionsArray(\@elements);
    
    #set some values if not defined.
    
    $preferences->setItem('lmsDownsampling',"1" );
    
    for my $option (@$options){
        
       $self->_handleOption($option);
    }
    
}
sub _removePathname{
    my $self = shift;

    my $commandLine= $self->{commandLine};
    
    my $pathname = $conf->getPathname();
    
    $commandLine = $utils->trim($commandLine);
   
    if (! $pathname) {return $commandLine}
    
    if (length($commandLine) <  length($pathname)){
    
        return $commandLine;
    }
    
    if (substr($commandLine,0,length($pathname)) eq $pathname){
    
        return substr($commandLine, length($pathname)+1);
        
    }
    return $commandLine;
}

sub _builsOptionsArray{
    my $self = shift;
    my $elements = shift;
    
    my @options=();
    my $line;
    
    for my $e (@$elements){
    
        if ((substr($e,0,1) eq "-") && $line){
            
            push @options, $line;
            $line=$e;
                
        } elsif ($line){
                
            $line = $line." ".$e;
                 
        } else {

            $line = $e;
        }
    }
    push @options, $line;

    return \@options;
}

sub _setError{
    my $self = shift;
    my $msg  = shift;
    
	$log->warn("found error in command line: ".$msg);
	
    if ($self->{error}) {
		
        $self->{error}="WARNING: invalid options or values";
    } else{
    
        $self->{error}=$msg;
    
    }
}
sub _handleOption{
    my $self = shift;
    my $option= shift;
    
    if (!$option) {return 0;}
    
    my $preferences= $self->{preferences};
      
    my $key = substr($option,1,1);
    my $value = $utils->trim(substr($option,2));
    
    if ($key eq "n"){ #player name
    
        $preferences->setItem('playerName',$value );

    } elsif  ($key eq "o"){ #output device
    
        $preferences->setItem('audioDevice',$value );
    
    } elsif  ($key eq "x"){ #tell the server not to downsample
    
        $preferences->setItem('lmsDownsampling',"0" );
    
    } elsif  ($key eq "D"){ #PCM to DOP delay && dsdFormat
        
        if ($value) {
            
            my ($delay, $dsdFormat, $error) = _checkDelayAndDsdFormat($value);
            
            if ($error){
                
                $self->_setError("WARNING: $value is invalid for key $key");
                $preferences->setItem('fromPcmToDOP',0 );
                $preferences->setItem('dsdFormat','disabled' );
            
            } else
            
                if ($delay){
                    
                    $preferences->setItem('fromPcmToDOP',$delay );
                }
                if ($dsdFormat){
                    
                    $preferences->setItem('dsdFormat',$dsdFormat );
                }
            }
        }
    } elsif  ($key eq "C"){ #timeout
        
        if ($value && ($value  =~ /^[0-9,.E]+$/ )){

             $preferences->setItem('timeout',$value );
             
        } else{
             $self->_setError("WARNING: $value is invalid for key $key");
        }
    
    } elsif  ($key eq "s"){ #server
    
        if ($value && ($value  =~ /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\:[1-9][0-9][0-9][0-9])?$/ )){

             $preferences->setItem('serverIP',$value );
             
        } else{
             $self->_setError("WARNING: $value is invalid for key $key");
        }
    
    }  elsif  ($key eq "m"){ #player ID (mac address)
    
       
		if ($value && ($value  =~ /^([a-fA-F0-9]{2}\:){5}([a-fA-F0-9]{2})?$/ )){
             
			 $preferences->setItem('playerId',$value );
             
        } else{
             $self->_setError("WARNING: $value is invalid for key $key");
        }
    
    } elsif  ($key eq "r"){ #rates
    
        if ($value){
            
            $self->_checkSampleRateString($key, $value);
        
        } else{
        
            $self->_setError("WARNING: missing value for option $key");
        }
    
    } elsif  ($key eq "c"){ #supported codecs 
    
        if ($value){
            
            $self->checkCodecString($key, $value);
        
        } else{
        
            $self->_setError("WARNING: missing value for option $key");
        }
    
    } elsif  ($key eq "e"){ #unsupported codecs
    
        if ($value){
            
            $self->checkCodecString($key, $value);
        
        } else{
        
            $self->_setError("WARNING: missing value for option $key");
        }
    
    } elsif  ($key eq "b"){ #buffers
        
        # -b <stream>:<output>	Specify internal Stream and Output buffer sizes in Kbytes
         if ($value){
            
            my @string = split ':', $value;
            
            if (!(scalar @string) == 2) {
        
                $self->_setError("WARNING: $value is invalid for key $key");
                return 0;
            }
            
            my $stream = $string[0];
            my $output = $string[1];
            
            if (($stream =~ /^[0-9,.E]+$/ ) && ($output =~ /^[0-9,.E]+$/ )){
            
                my $str = (int $stream / 4096)*4096;
                my $out = (int $output / 4096)*4096;
                
                if (($str > 0) && ($out > 0)){
                
                    $preferences->setItem('inBuffer',$str );
                    $preferences->setItem('outBuffer',$out );
                
                } else{
                
                    $self->_setError("WARNING: $value is invalid for key $key");
                    return 0;
                }
            }
        
        } else{
        
            $self->_setError("WARNING: missing value for option $key");
            return 0;
        }
        return 1;
    
    } elsif  ($key eq "a"){ #alsa
    
        # -a <b>:<p>:<f>:<m>	Specify ALSA params to open output device, 
        # b = buffer time in ms or size in bytes, p = period count or size in bytes, 
        # f sample format (16|24|24_3|32), m = use mmap (0|1)
        
        #-a <f> Specify sample format (16|24|32) of output file when using -o - to output 
        # samples to stdout (interleaved little endian only)
        
        if ($value){
            
            my @string = split ':', $value;
            
            if ((scalar @string) == 1) {
                
                my $format = $string[0];
                
                if (($format eq 16) || ($format eq 24) || ($format eq 32)){
                
                    $preferences->setItem('sampleFormat',$format );
                } else {
                    
                    $self->_setError("WARNING: $value is invalid for key $key");
                    return 0;
                }
               
            } elsif ((scalar @string) == 4){
            
                my $buffer = $string[0];
                my $period = $string[1];
                my $format = $string[2];
                my $useMap = $string[3];
                
                if (!$buffer || ($buffer eq "")) {$buffer=100}
                if (!$period || ($period eq "")) {$period=3}
                if (!$format || ($format eq "")) {$format=16}
                if (!$useMap || ($useMap eq "")) {$useMap=0}

                if (($buffer =~ /^[0-9,.E]+$/ ) &&
                    ($period =~ /^[0-9,.E]+$/ ) &&  
                    (($format eq 16) || ($format eq 24) || ($format eq 32)) &&
                    (($useMap eq 0) || ($useMap eq 1))){
                    
                    $preferences->setItem('periodCount',$period );
                    $preferences->setItem('bufferSize',$buffer );
                    $preferences->setItem('sampleFormat',$format );
                    $preferences->setItem('useMmap',$useMap );
                    
                } else{
                
                    $self->_setError("WARNING: $value is invalid for key $key");
                    return 0;
                }

            } else {
                
                $self->_setError("WARNING: $value is invalid for key $key");
                return 0;
            }
        
        } else{
        
            $self->_setError("WARNING: missing value for option $key");
        }

    } elsif  ($key eq "d"){ #logging level
    
        # -d <log>=<level> Set logging level, logs: all|slimproto|stream|decode|output, level: info|debug|sdebug

        if ($value){
            
            my @string = split '=', $value;
            
             if (!(scalar @string) == 2) {
        
                $self->_setError("WARNING: $value is invalid for key $key");
                return 0;
            }
            
            my $log = $string[0];
            my $level = $string[1];

            if ((($level eq "info") || ($level eq "debug") || ($level eq "sdebug")) &&
                (($log eq "all")|| ($log eq "slimproto") ||($log eq "stream") || 
                 ($log eq "decode") ||($log eq "output"))) {
                
                if (($log eq "slimproto") || ($log eq "all")) {
                    $preferences->setItem('logSlimproto',1 );
                }
                
                if (($log eq "stream") || ($log eq "all")) {
                    $preferences->setItem('logStream',1);
                }
                
                if (($log eq "decode") || ($log eq "all")) {
                    $preferences->setItem('logDecode',1 );
                }
                
                if (($log eq "output") || ($log eq "all")) {
                    $preferences->setItem('logOutput',1 );
                }
                
                $preferences->setItem('logLevel',$level );
                
              
            } else {
            
                $self->_setError("WARNING: $value is invalid for key $key");
                return 0;
            }
        
        } else{
        
            $self->_setError("WARNING: missing value for option $key");
        }
    
    } elsif  ($key eq "f"){ #log file
    
        if ($value){
            
           $preferences->setItem('logFile',$value );
        
        } else{
        
            $self->_setError("WARNING: missing value for option $key");
        }
    
    }  
    # from here on, valid but ignored options.   
    
      elsif  ($key eq "P"){ #PID file
       
       # $self->_setError("WARNING: ingnored option $key");
         
    } 
    # from here on, valid but unspupported options.
    
      elsif  ($key eq "p"){ #priority
        $self->_setError("WARNING: unsupported option $key");
    
    #} elsif  ($key eq "m"){ #mac address
    #    $self->_setError("WARNING: unsupported option $key");
    
    } elsif  ($key eq "R"){ #Resample
        $self->_setError("WARNING: unsupported option $key"); 
        
    } elsif  ($key eq "u"){ #same as R
        $self->_setError("WARNING: unsupported option $key"); 
    
    } elsif  ($key eq "M"){ #Model name
        $self->_setError("WARNING: unsupported option $key"); 
    
    } elsif  ($key eq "N"){ #name filename
        $self->_setError("WARNING: unsupported option $key"); 
    
    } elsif  ($key eq "v"){ #visualizer support
        $self->_setError("WARNING: unsupported option $key"); 
    
    } elsif  ($key eq "L"){ #list volume controls
        $self->_setError("WARNING: unsupported option $key"); 
    
    } elsif  ($key eq "U"){ #unmute ALSA
        $self->_setError("WARNING: unsupported option $key"); 
    
    } elsif  ($key eq "V"){ #use alsa control for volume adjustement
        $self->_setError("WARNING: unsupported option $key"); 
    
    } 
    
    # from here on, invalid options at runtime
    
    elsif  ($key eq "z"){ #demonize
        $self->_setError("WARNING: invalid option $key"); 
    
    } elsif  ($key eq "t"){ #license
        $self->_setError("WARNING: invalid option $key"); 
    
    } elsif  ($key eq "?"){ #help
        $self->_setError("WARNING: invalid option $key"); 
        
    } elsif  ($key eq "l"){ #list audiodevices
        $self->_setError("WARNING: invalid option $key"); 
        
    } else { # any other option is invalid.
        $self->_setError("WARNING: unknown option $key"); 
    }

}


my %codecHash=();
my $codecMap=\%codecHash;

$codecMap->{'mp3'}="codecMp3";
$codecMap->{'mad'}="codecMp3";
$codecMap->{'mpg'}="codecMp3";
$codecMap->{'aac'}="codecAac";
$codecMap->{'wma'}="codecWma";
$codecMap->{'ogg'}="codecOgg";
$codecMap->{'flac'}="codecFlc";
$codecMap->{'flc'}="codecFlc";
$codecMap->{'alac'}="codecAlac";
$codecMap->{'alc'}="codecAlac";
$codecMap->{'pcm'}="codecPcm";
$codecMap->{'wav'}="codecWav";
$codecMap->{'aif'}="codecAif";
$codecMap->{'aiff'}="codecAif";
$codecMap->{'dff'}="codecDff";
$codecMap->{'dsf'}="codecDsf";


sub checkCodecString{
    my $self   = shift;
    my $key = shift;
    my $codecs  = shift;
    
     
    # -c <codec1>,<codec2>"
    # Restrict codecs to those specified, otherwise load all available codecs
    # known codecs: flac,pcm,mp3,ogg,aac,wma,alac,dsd (mad,mpg for specific mp3 codec)

    # OR  

    # -e <codec1>,<codec2>	
    # Explicitly exclude native support of one or more codecs; 
    # known codecs: flac,pcm,mp3,ogg,aac,wma,alac,dsd (mad,mpg for specific mp3 codec)

    my $preferences= $self->{preferences};
     
    for my $codec (keys %$codecMap){
    
        if ($key eq 'c'){
        
             $preferences->setItem($codecMap->{$codec}, 0);
        
        } else {
        
             $preferences->setItem($codecMap->{$codec}, 1);
        }
    
    }
   
    my @string = split ',', $codecs;
    
    for my $codec (@string){

        $codec = lc($codec);
        
        if ($codecMap->{$codec}){
            
            $preferences->setItem($codecMap->{$codec}, $key eq "c" ? 1 : 0);
            
        } else{
        
            $self->_setError("WARNING: $codec is not currently handled");
        }
    }

    return 1;
}

sub _checkSampleRateString{
    my $self   = shift;
    my $key = shift;
    my $value  = shift;
    
    # -r <rates>[:<delay>]	
    # Sample rates supported, allows output to be off when squeezelite is started; 
    # rates = <maxrate>|<minrate>-<maxrate>|<rate1>,<rate2>,<rate3>; 
    # delay = optional delay switching rates in ms
    
    my $preferences= $self->{preferences};
    
    my @string = split ':', $value;
    
    my $rates;
    my $delay;
    
    if ((scalar @string) > 2) {

        return 0;
    }
    
    if ((scalar @string) == 2) {
        
        $rates = $string[0];
        $delay = $string[1];
        
        if ($delay  =~ /^[0-9,.E]+$/ ) {
        
            $preferences->setItem('fromPcmToPcm', $delay);
            
        } else {
        
             $self->_setError("WARNING: delay $value is invalid for key $key");
        }
    } elsif ((scalar @string) == 1){
    
        $rates = $string[0];

    }
    
    if ($self->_decodeSampleRateString($key,$rates)){

        return 1;       
    }
    $self->_setError("WARNING: $value is invalid for key $key");
    return 0;
}

my %rateHash=();
my $rateMap=\%rateHash;

$rateMap->{'01'}->{'value'}=8000;
$rateMap->{'02'}->{'value'}=11025;
$rateMap->{'03'}->{'value'}=12000;
$rateMap->{'04'}->{'value'}=16000;
$rateMap->{'05'}->{'value'}=22050;
$rateMap->{'06'}->{'value'}=24000;
$rateMap->{'07'}->{'value'}=32000;
$rateMap->{'08'}->{'value'}=44100;
$rateMap->{'09'}->{'value'}=48000;
$rateMap->{'10'}->{'value'}=88200;
$rateMap->{'11'}->{'value'}=96000;
$rateMap->{'12'}->{'value'}=176400;
$rateMap->{'13'}->{'value'}=192000;
$rateMap->{'14'}->{'value'}=352800;
$rateMap->{'15'}->{'value'}=384000;
$rateMap->{'16'}->{'value'}=705600;
$rateMap->{'17'}->{'value'}=768000;
$rateMap->{'01'}->{'field'}="rate008000";
$rateMap->{'02'}->{'field'}="rate011025";
$rateMap->{'03'}->{'field'}="rate012000";
$rateMap->{'04'}->{'field'}="rate016000";
$rateMap->{'05'}->{'field'}="rate022050";
$rateMap->{'06'}->{'field'}="rate024000";
$rateMap->{'07'}->{'field'}="rate032000";
$rateMap->{'08'}->{'field'}="rate044100";
$rateMap->{'09'}->{'field'}="rate048000";
$rateMap->{'10'}->{'field'}="rate088200";
$rateMap->{'11'}->{'field'}="rate096000";
$rateMap->{'12'}->{'field'}="rate176400";
$rateMap->{'13'}->{'field'}="rate192000";
$rateMap->{'14'}->{'field'}="rate352800";
$rateMap->{'15'}->{'field'}="rate384000";
$rateMap->{'16'}->{'field'}="rate705600";
$rateMap->{'17'}->{'field'}="rate768000";
    
sub _decodeSampleRateString{
    my $self   = shift;
    my $key    = shift;
    my $rates  = shift;
   
    my $preferences= $self->{preferences};
    
	$log->debug("rates: ".$rates);
    
	my @string = split '-', $rates; 
    
    my $min;
    my $max;
	
    if (scalar @string == 2){ #max min
    
        $min = $string[0];
        $max = $string[1];
            
		$log->debug("min: ".$min);
		$log->debug("max: ".$max);
		
        $self->_handleMinMaxRate($min,$max);
		return 1;
    } 
    
    @string = split ',', $rates;
    
    if (scalar @string > 1){ #list of enabled
        
        for my $rate (@string){
        
            if ($rate  =~ /^[0-9,.E]+$/ ) {
        
                for my $i (keys %$rateMap){
                
                    if (($rateMap->{$i}->{'value'} == $rate*1) ){
                    
                        $preferences->setItem($rateMap->{$i}->{'field'}, 1);
                    }
                }
            
            } else {
        
                $self->_setError("WARNING: rate $rate is invalid.");
                
            }
            
        }
      
        return 1;
    } 
    
    if (scalar @string == 1){ #max sample rate
    
        $min = 0;
        $max = $string[0];
        
        $self->_handleMinMaxRate($min,$max);
        return 1;
    }
	return 0;
}

sub _handleMinMaxRate{
    my $self = shift;
    my $min = shift;
    my $max = shift;
    
    my $preferences= $self->{preferences};
    
    if (($min =~ /^[0-9,.E]+$/ ) && ($max =~ /^[0-9,.E]+$/ )){
      
        for my $rate (sort keys %$rateMap){

            if (($rateMap->{$rate}->{'value'} >= $min*1) && ($rateMap->{$rate}->{'value'} <= $max*1)){

                $preferences->setItem($rateMap->{$rate}->{'field'}, 1);
            }
        }
        
    } else {
    
         $self->_setError("WARNING: either $min or $max is not a valid rate.");
         return 0;
    }
    return 1;
}

sub _validate {
     my $self = shift;
     
     $log->error("Comandline::_validate: NOT IMPLEMENTED YET");
     $self->{error}= "WARNING: NOT IMPLEMENTED YET";
     return 0;
}

sub _checkCodecs{
    my $preferences = shift;

    my $out="";
    my $first=1;

    for my $p (keys %$preferences){

        if ($p =~ /^codec/ && $preferences->{$p}) {
        
            $log->debug("$p: ".($preferences->{$p} || 0));
        
            if (! $first){

                $out=$out.",";

            } else{

                $first=0;
            }
            $out=$out._cleanCodec($p);
        }
    }
    return $out;
}

sub _cleanCodec{
    my $codecIn = shift;
    
    my $out= lc(substr($codecIn,5));
   
    #print $codecIn." >>>> ".$out."\n";
    return $out;
}

sub _checkSampleRates{
    my $preferences= shift;

    my %sampleRate=();
    my $rate= \%sampleRate;

    for my $p (keys %$preferences){
    
        if ($p =~ /^rate/){

            $rate->{$p}=$preferences->{$p};
            $log->debug("$p: ".($preferences->{$p} || 0));
        }

    }

    return _getRateString($rate);
}
sub _cleanRate{
    my $rateIn = shift;
    
    my $out= substr($rateIn,4);
    $out =~ s/^0+//;
    
    #print $rateIn." >>>> ".$out."\n";
    return $out;
}

sub _getRateString{
    my $rate = shift;
    
    my $min;
    my $max;
    my $end=0;
    my $break=0;

    for my $r (sort keys %$rate){

        if  ($rate->{$r} && ! $min){
            $min= $r;
            $max= $r;
        } elsif ($rate->{$r} && ! $end) { 
            $max= $r;
        } elsif (! $rate->{$r} && $min) {
            $end=1;
        } elsif ($rate->{$r} && $end) { 
            $break= 1;
        } 
    }
   
    if ($break) {return _discontinuous($rate);}
    if (!$min ) {return "";}
    if ($min eq $max) {return _cleanRate($max);}
    
    return  _cleanRate($min)."-". _cleanRate($max);
}
sub _discontinuous{
    my $rate = shift;
    
    my $out="";
    my $first=1;
    for my $r (sort keys %$rate){
    
        if ($rate->{$r}){
            
            if (! $first){
            
                $out=$out.",";
                
            } else{
                
                $first=0;
            }
            $out=$out._cleanRate($r);
        }
    }
    return $out;
}
sub _checkDelayAndDsdFormat {
    my $value = shift;
    
    my @string = split ':', $value;

    my $delay=0;
    my $dsdFormat = '';

    my $primo = $utils->trim($string[0]);
    my $secon = $utils->trim($string[1]);
    my $terzo = $utils->trim($string[2]);
    
    #printf "originale: >".$value."<";
    #printf " primo: >".($primo ? $primo : 'UNDEF')."<";
    #printf " secon: >".($secon ? $secon : 'UNDEF')."<";
    #printf " terzo: >".($terzo ? $terzo : 'UNDEF')."<";

    if ($terzo) {return (undef,undef,1)};
    if (!$primo && !$secon) {return (undef,undef,0)};
    
    if ($primo && ($primo  =~ /^[0-9,.E]+$/ ) && _isDsdNativeFormatValid($secon)) {

        return ($primo,$secon,0);   
    }
    if ($primo && ($primo  =~ /^[0-9,.E]+$/ ) && !$secon) {
        
        return ($primo, undef,0);
    }

    if (!$primo && _isDsdNativeFormatValid($secon)) {return (undef,$secon,0)};

    if (_isDsdNativeFormatValid($primo) && !$secon) {return (undef,$secon,0)};
    
    return ($primo,$secon, 1);

}

sub _isDsdNativeFormatValid{
    my $val = shift;
    
    if (!$val){return 0;}
    
    my %params = map { $_ => 1 } @dsdNatives;
    if($params{$val}) {return 1} 
    
    return 0;
}
1;
