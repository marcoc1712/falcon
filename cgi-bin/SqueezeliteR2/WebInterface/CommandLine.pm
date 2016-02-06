#!/usr/bin/perl
#
# @File CommandLine.pm
# @Author Marco Curti <marcoc1712@gmail.com>
# @Created 20-gen-2016 18.23.15
#

package SqueezeliteR2::WebInterface::CommandLine;

use strict;
use warnings;
use utf8;
use SqueezeliteR2::WebInterface::Settings;

sub new {

    my $class       = shift;
    my $settings    = shift;
    my $commandLine = shift;
    
    my $self = bless {
            settings => $settings,
            commandLine => $commandLine,
            error => undef,
         }, $class;
    
    if ($settings && $commandLine){
        
        $self->_validate();
        
    } elsif ($commandLine) {
        
        $self->_load();
        
    } else {
    
        $self->set($settings);
    }
    return $self;
    
}
sub get {
    my $self = shift;
    return $self->{commandLine};
}
sub set {
    my $self = shift;
    my $settings=shift || SqueezeliteR2::WebInterface::Settings->new();

    $self->{settings}     = $settings;
    $self->{commandLine}  = $self->_buildCommandLineFromSettings();

    $self->_save();
}
sub getError {
    my $self = shift;
    
    return $self->{error};
}

####################################################################################################
sub _save{
    my $self = shift;
    
    my $conf = SqueezeliteR2::WebInterface::Configuration->new();
    
    if (! $conf->writeCommandLine($self->{commandLine})){
    
        $self->{error} = $conf->getError();
        return undef;
    }
    return 1;
    
}
sub _load{
     my $self = shift;
     
     $self->{error}= "WARNING: NOT IMPLEMENTED YET";
     $self->{settings}=undef; #should be loaded.
     return 0;
     
}
sub _validate {
     my $self = shift;
     
     $self->{error}= "WARNING: NOT IMPLEMENTED YET";
     return 0;
}

sub _buildCommandLineFromSettings{
    my $self = shift;
    
    my $settings= $self->{settings};
    my $commandLine="";	


    if (! $settings->getPathname() || ($settings->getPathname() eq "") ) {return ""};

    $commandLine=  $settings->getPathname();


    if ($settings->get('playerName')){

            $commandLine = $commandLine." -n ".$settings->get('playerName');

    } 

    if ($settings->get('audioDevice')){

            $commandLine = $commandLine." -o ".$settings->get('audioDevice');

    } 

    if ($settings->get('supportsDOP')){

            $commandLine = $commandLine." -D";

            if ($settings->get('fromPcmToDOP')){

                    $commandLine = $commandLine." ".$settings->get('fromPcmToDOP');
            } 
    }

    if (! $settings->get('lmsDownsampling')){

            $commandLine = $commandLine." -x";

    }

    if ($settings->get('timeout')){

            $commandLine = $commandLine." -C ".$settings->get('timeout');
    }

    if ($settings->get('serverIP')){

            $commandLine = $commandLine." -s ".$settings->get('serverIP');
    }

    my $rateString=  _checkSampleRates();

    if ($rateString && ! ($rateString eq "")){

            $commandLine = $commandLine." -r ".$rateString;

            if ($settings->get('fromPcmToPcm')){

                    $commandLine = $commandLine.":".$settings->get('fromPcmToPcm');
            } 
    }

    my $codecString=  _checkCodecs();

    if ($codecString && ! ($codecString eq "")){

            $commandLine = $commandLine." -c ".$codecString;
    }

    if ($settings->get('inBuffer') || $settings->get('outBuffer')){

            $commandLine = $commandLine." -b ";
            $commandLine = $commandLine.($settings->get('inBuffer') ? $settings->get('inBuffer') : '4096');
            $commandLine = $commandLine.":";
            $commandLine = $commandLine.($settings->get('outBuffer') ? $settings->get('outBuffer') : '4096');
    }

    if ($settings->get('sampleFormat') || $settings->get('periodCount') || 
            $settings->get('bufferSize') || $settings->get('useMmap')){

            $commandLine = $commandLine." -a ";

            if ($settings->get('periodCount') || $settings->get('bufferSize') || $settings->get('useMmap')){

                    $commandLine = $commandLine.$settings->get('periodCount').":";
                    $commandLine = $commandLine.$settings->get('bufferSize').":";
                    $commandLine = $commandLine.$settings->get('sampleFormat').":";
                    $commandLine = $commandLine.($settings->get('useMmap') ? "1" : "0");

            } else {

                    $commandLine= $commandLine.$settings->get('sampleFormat');

            }

    } 

    if ($settings->get('logSlimproto') && $settings->get('logStream') && 
            $settings->get('logDecode') && $settings->get('logOutput')){

            $commandLine=$commandLine." -d all=".$settings->get('logLevel');

    } else {

            if ($settings->get('logSlimproto')){

                    $commandLine=$commandLine." -d slimproto=".$settings->get('logLevel');
            }
            if ($settings->get('logStream')){

                    $commandLine=$commandLine." -d stream=".$settings->get('logLevel');
            }
            if ($settings->get('logDecode')){

                    $commandLine=$commandLine." -d decode=".$settings->get('logLevel');
            }
            if ($settings->get('logOutput')){

                    $commandLine=$commandLine." -d output=".$settings->get('logLevel');
            }
    }

    if ($settings->get('logFile')){

            $commandLine=$commandLine." -f ".$settings->get('logFile');
    }

    if ($settings->getPIDFile()){

            $commandLine=$commandLine." -P ".$settings->getPIDFile();
    }	

    return $commandLine;
}

sub _checkCodecs{
	my $settings = shift;

    my $out="";
    my $first=1;

    for my $p (keys %$settings){

        if ($p =~ /^codec/ && $settings->{$p}) {

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
	my $settings = shift;

	my %sampleRate=();
	my $rate= \%sampleRate;

	for my $p (keys %$settings){

		if ($p =~ /^rate/){
		  
		  $rate->{$p}=$settings->{$p};
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

1;
