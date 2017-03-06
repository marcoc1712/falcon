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

package WebInterface::Status;

use strict;
use warnings;
use utf8;

use WebInterface::Configuration;
use WebInterface::CommandLine;
use WebInterface::Utils;

my $log;

my $utils= WebInterface::Utils->new();

sub new {
    my $class = shift;
    
    $log = Log::Log4perl->get_logger("status");
    
    my $conf= WebInterface::Configuration->new();
    my $self = bless {
                    conf => $conf,
                    status => {},
                    error => undef,
                 }, $class;
    
    $self->_init();
    return $self;
}
sub conf {
    my $self = shift;  
    return $self->{conf};
}

sub getStatus{
    my $self = shift;
    return $self->{status};
}

sub getError{
    my $self 		= shift;
    
    return $self->{error};
}

sub getAudioCardsHTML{
    my $self = shift;
    
    # PLEASE NOTE: The web server user MUST be in the audio group in order to correctly list 
    # ALL audio devices.
    
    if (!$self->_initPathname()){return undef};
    
    my $squeezelitePath =  $self->getStatus()->{'pathname'} ;
       
    my @html=();
    
    my @devicelist = `$squeezelitePath -l`;

    my ($key, $desc, $opt);
    my $id=0;

    for my $dev (@devicelist){
	
		($key, $desc)= split /-/, $dev, 2;

		if ($key && $desc){
			$key=$utils->trim($key);
			$desc=$utils->trim($desc);
	
			if (substr($key,0,7) eq "default"){
				
				#add the hw: plugin to the device list.
				$id=$id+1;
				my $dev = substr($key,8,length($key)-7);
				my $hw = "hw:".$dev;
				my $text = $hw." - ".$desc;		
				push @html, qq (<option value= "$hw"> "$text" </option>)."\n";
			}
			
			$id=$id+1;

			my $text = $key." - ".$desc;		

			push @html, qq (<option value= "$key"> "$text" </option>)."\n";
			$id=$id+1;
		}
    }
    return \@html;
}

####################################################################################################

sub _init{
    my $self = shift;
    
    if (!$self->_initPathname()){ return undef};
    
    if ($self->_checkExecutable( $self->getStatus()->{'pathname'})){

        my $commandLineText=$self->conf()->readCommandLine();
		
        my $commandLine = WebInterface::CommandLine->new(undef, $commandLineText);
        
        $log->info("actual command line: ".$commandLine->get());
        $log->debug($commandLine->getError() || "ok");
        
        $self->{error}=$commandLine->getError();

		if ($commandLine->get() && $commandLine->getError()){
		
			$self->getStatus()->{'commandLine'} = $utils->trim($commandLine->get())." (".$self->{error}.")";
		
		} elsif ($commandLine->get()){
		
			$self->getStatus()->{'commandLine'} = $utils->trim($commandLine->get());
		
		} else {
			
			$self->getStatus()->{'commandLine'} = $commandLine->getError();
		}
    }
    
    # if ($self->{error}) {return undef;}

    if ($self->{conf}->isDisabled('getProcessInfo')) {
		$self->getStatus()->{'running'} ="Unknown (disabled))";
		$self->getStatus()->{'process'}=" ";
        return  $self->getStatus();
    }
    
    my $PIDfile	= $self->{conf}->getPIDFile();
	
    if ($PIDfile && !($PIDfile eq "") && !(-e $PIDfile)){

            $self->getStatus()->{'running'} ="Not running";
            $self->getStatus()->{'process'}=" ";
            return $self->getStatus();
    }

    if ($PIDfile && !($PIDfile eq "") && ! $self->_checkPidFile($PIDfile)) {

            return $self->getStatus();
    }
	
    if (!$self->_checkProcess()){
		
		$self->getStatus()->{'running'} ="Unknown (Permission Error)";
		$self->getStatus()->{'process'}=$self->getError();
		#$self->{error}=undef;
		
		return $self->getStatus();
	}
	return $self->getStatus();
}
sub _checkProcess{
    my $self = shift;
	
	my $PIDfile = $self->{conf}->getPIDFile();
	my $pid;
	
	if ($PIDfile){

		my $FH;
	
		if (! (open($FH, '<', $PIDfile))){
			$self->{error} = "ERROR: Unable to open $PIDfile for reading, $!";
			return undef;
		};

		#in this case there should be just one line.
		my @lines=<$FH>;
		close $FH;

		if (!(scalar @lines == 1)) { 
			my $error = "ERROR: ";

			for my $r (@lines){		
				$error = $error." ".trim($r);
			}
			$self->{error}=$error;
			return 0;
		}
		
		$pid = $utils->trim($lines[0]);
	}
	# some system does not use PID to get info about services.
	return $self->_getProcesInfo($pid);
}
sub _getProcesInfo{
	my $self = shift;
	my $pid  = shift;
	
	my $stat= $self->{conf}->getProcessInfo($pid);
	
	if ($pid && $stat){
		 $self->getStatus()->{'process'} = $stat;		
		 $self->getStatus()->{'running'} = "Running";
		 
	} elsif ($stat){
	
		 $self->getStatus()->{'process'} = $stat;		
		 $self->getStatus()->{'running'} = "See below";
		 
	} elsif ($self->getError()){
        
		$self->getStatus()->{'running'} ="Unknown (Exit Error)";
		$self->getStatus()->{'process'}= $self->getError();
        
	} else {
        
		$self->getStatus()->{'running'} ="Probably stopped";
		$self->getStatus()->{'process'}= "Warning: Invalid PID";
	}
	return  1;
}
sub _checkPidFile{
	my $self = shift;
	my $PIDfile = shift;

	if (! -e $PIDfile) {
	
		$self->getStatus()->{'running'} ="Unknown";
		$self->getStatus()->{'process'}="WARNING: PID file $PIDfile does not exists";
		return 0;
	}
	if (!  -r $PIDfile) {
	
		$self->getStatus()->{'running'} ="Unknown";
		$self->getStatus()->{'process'}="WARNING: Can't read $PIDfile ";
		return 0;
	}
	return 1;
}
sub _initPathname{
    my $self = shift;
    
    my $squeezelitePath	= $self->{conf}->getPathname();
    
    $self->{error}=$self->{conf}->getError();
    if ( $self->{error}) {return undef;}

    $self->getStatus()->{'pathname'} = $squeezelitePath;
    
    if (!$squeezelitePath) {
        
        $self->{error}= "ERROR: Squeezelite-R2 pathname is not defined";
        return undef; 
    }
    if (! -e $squeezelitePath) {
    
        $self->{error}= "ERROR: Squeezelite-R2 pathname $squeezelitePath is invalid";
        return undef; 
    
    }
    if (! -x $squeezelitePath) {
    
        $self->{error}= "ERROR: could not execute $squeezelitePath";
        return undef; 
    
    }
    if ( $self->{error}) {return undef;}
    
     $self->getStatus()->{'isPathnameValid'} = '1';
}

sub _checkExecutable{
    my $self = shift;
    
    my $squeezelitePath     = shift;

    my @license = `$squeezelitePath -t`;

    if (scalar(@license) == 0) {

		# TODO check the eerror with a second call.
		#To capture a command's STDERR but discard its STDOUT
		#$output = `cmd 2>&1 1>/dev/null`;  
	
        $self->{error} = "ERROR unable to run $squeezelitePath -t";
        return undef;
    }

     $self->getStatus()->{'copyrigth'} ="";

    for my $row (@license){

        $row=$utils->trim($row);

        #look for R2 version tag
        #if (lc($row) =~ /v1\.8\...\(r2\)/){
        if (lc($row) =~ /v...\(r2\)/){}  

             $self->getStatus()->{'version'} =substr($row,23,11);
             $self->getStatus()->{'isR2version'}=1;

        }
		while (length($row) > 80 ){
				
				my $join = $self->getStatus()->{'copyrigth'} eq "" ? "" : "\n";
				$self->getStatus()->{'copyrigth'} = $self->getStatus()->{'copyrigth'}.$join.substr($row,0,80);
				$row = substr($row,80);
		}
		my $join = $self->getStatus()->{'copyrigth'} eq "" ? "" : "\n";
		$self->getStatus()->{'copyrigth'} = $self->getStatus()->{'copyrigth'}.$join.$row;

    }
    my @help = `$squeezelitePath -?`;

    if (scalar(@help) == 0) {

        $self->{error} = "ERROR unable to run $squeezelitePath -?";
        return undef;
    }

    for my $row (@help){

        $row=$utils->trim($row);

        #look for R2 build options
        if (lc($row) =~ /^build options:/){

             $self->getStatus()->{'buildOptions'} =substr($row,15);
            last;
        }
    }
    for my $opt (split ' ',$self->getStatus()->{'buildOptions'}){
       
        $self->getStatus()->{'opts'}->{$opt} =1;
    }
}
1;
