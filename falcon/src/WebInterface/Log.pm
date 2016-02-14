#!/usr/bin/perl
#
# @File Log.pm
# @Author Marco Curti <marcoc1712@gmail.com>
# @Created 20-gen-2016 18.23.15
#

package WebInterface::Log;

use strict;
use warnings;

use WebInterface::Log;
use WebInterface::Utils;
my $utils = WebInterface::Utils->new();
my $log;

sub new{
    my $class 	= shift;
    my $file 	= shift || die;
    $log= Log::Log4perl->get_logger("log");
	
    my $self = bless {
                        file => $file,
                        error => undef,
                        lines => undef,
                     }, $class;
    
    $self->_read();
        
    return $self;
}

sub getLines{
    my $self 	= shift;
    
    if ($self->{error}) {return undef;}
    return $self->{lines};
}
sub getHTML{
    my $self 	= shift;
    my $limit   = shift;
    
    if ($self->{error}) {return undef;}
    return $self->_encodeHTML($limit);
}
sub clear{
    my $self = shift;
    my $who   = shift || "";
    
    if (open(my $fh, '>', $self->{file})) {

            my $datestring = localtime();
            print $fh "Log file cleared by $who at $datestring\n";
            close $fh;
            
            $self->{error}=undef;
            return "DONE: created empty: $self->{file}";

    }
    
    $self->{error} = "WARNING: could not open $self->{file} for writing: $!";
    return undef;
    
}
sub getError{
    my $self 	= shift;
    return $self->{error};
}

##################################################################
sub _read{
    my $self 	= shift;
    
	$log->info($self->{file});
	
    if (! -e $self->{file}) {
		
		$log->error($self->{file});
        $self->{error} = "WARNING: Log file $self->{file} does not exists";
        return undef;
    }
    if (! -r  $self->{file}) {
        
        $self->{error} = "ERROR: could not read Log file: $self->{file}";
        return undef;
    }
    my $fh;
    if (! open($fh, '<',  $self->{file})) {
	
		$self->{error} = "ERROR: Unable to open  Log file: $self->{file}, $!";
		 return undef;
	};

    my @lines=<$fh>;
    
    $self->{lines}=\@lines;
    
    close $fh;

}
sub _encodeHTML{
    my $self 	= shift;
    my $limit   = shift || 10000;
    
    my $lines   = $self->getLines();
    my @empty=();
	if (! $lines){
	
		$lines= \@empty;
		#push @empty, $self->getError();)
	}
	
    my $size= scalar @$lines;
    my $start=0;
   
    my @html =();
    
    push @html, "Content-type: text/html\r\n\r\n";
    push @html, qq(<html lang="en-US">\n);
    push @html, qq(<head>\n);
    push @html, qq(<meta charset="UTF-8" />\n);
    push @html, qq(<title>log File></title>\n);
    push @html, qq(</head>\n);
    push @html, qq(<body>\n);


    if ($size > $limit) {

            push @html, qq (<h1> found $size lines, display only last $limit </h1>)."\n";
            $start = $size -$limit;
    }
    my $i;

    for ($i=$start; $i < $size; $i++) {

            my $l = $utils->trim(@$lines[$i]);
            #my $l =  @$lines[$i];
           
            push @html, qq (<p> $l </p>\r\n);
    }

    push @html, qq(</body>\n);
    push @html, qq(</html>\n);
    
    return \@html;
}
1;
