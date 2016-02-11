#!/usr/bin/perl
#
# @File preferences.pm
# @Author Marco Curti <marcoc1712@gmail.com>
# @Created 20-gen-2016 18.23.15
#

package SqueezeliteR2::WebInterface::Status;

use strict;
use warnings;
use utf8;

use SqueezeliteR2::WebInterface::Configuration;
use SqueezeliteR2::WebInterface::CommandLine;
use SqueezeliteR2::WebInterface::Utils;

my $log;

my $utils= SqueezeliteR2::WebInterface::Utils->new();

sub new {
    my $class = shift;
    
    $log = Log::Log4perl->get_logger("status");
    
    my $conf= SqueezeliteR2::WebInterface::Configuration->new();
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
        my $commandLine = SqueezeliteR2::WebInterface::CommandLine->new(undef, $commandLineText);
        
        $log->debug("actual command line: ".$commandLine->get());
        $log->debug($commandLine->getError() || "ok");
        
        $self->{error}=$commandLine->getError();
        if (! $self->{error}){
            
          $self->getStatus()->{'commandLine'} = 
                $utils->trim(substr($commandLine->get(),length( $self->getStatus()->{'pathname'})+1));
                
                $log->debug("reported command line: ".$self->getStatus()->{'commandLine'});
            
        } else{
           
           $self->getStatus()->{'commandLine'} = $self->{error};
           
        }
        
        
    }
    
    if ( $self->{error}) {return undef;}

    if ($self->{conf}->isDisabled('getProcessInfo')) {

        return  $self->getStatus();
    }
    
    my $PIDfile	= $self->{conf}->getPIDFile();
    
    $self->getStatus()->{'running'} ="Not Running";
    
    if ($PIDfile && -e $PIDfile && -r $PIDfile) {

        my $stat= $self->_checkPiD($self->{conf});

        if ($stat){
             $self->getStatus()->{'process'} = $stat;		
             $self->getStatus()->{'running'} = "Running:";
        } else{
            $self->{error}="ERROR: unable to read PID file";
        }
    } else {
	
		$self->{error}="ERROR: unable to read PID file";
	}

    if ( $self->{error}) {return undef;}
    return  $self->getStatus();
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

        $self->{error} = "ERROR unable to run $squeezelitePath -t";
        return undef;
    }

     $self->getStatus()->{'copyrigth'} ="";

    for my $row (@license){

        $row=$utils->trim($row);

        #look for R2 version tag
        if (lc($row) =~ /v1\.8\...\(r2\)/){

             $self->getStatus()->{'version'} =substr($row,23,11);
             $self->getStatus()->{'isR2version'}=1;

        }

         $self->getStatus()->{'copyrigth'} = $self->getStatus()->{'copyrigth'}.$row.'\\r\\n';

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
    return 1;
}
sub _checkPiD{
    my $self = shift;
	my $PIDfile = $self->{conf}->getPIDFile();

	my $FH;
	
 	if (! (open($FH, '<', $PIDfile))){
		$self->{error} = "ERROR: Unable to open $fh for reading, $!";
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
	my $pid = $utils->trim($lines[0]);
	return $self->{conf}->getProcessInfo($pid);
}
1;
