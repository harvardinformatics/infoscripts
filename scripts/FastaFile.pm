package FastaFile;

use vars qw(@ISA);
use strict;
use FileHandle;

sub new {
    my $class = shift;
    my $file  = shift;
    my $self  = {};

    bless $self, $class;
    
    $self->setFilename($file);

    return $self;
}

sub setFilename {
    my ($self,$file) = @_;

    if (! -e $file) {
	print("ERROR: FastaFile [$file] doesn't exist. Can't open");
	exit(0);
    }

    $self->{filename} = $file;

    if (! -e "$file.fai") {
	$self->index();
    }
}

sub index {
    my ($self) = @_;

    if (! -e $self->{filename}) {
	print "ERROR: FastaFile [".$self->{filename}."] doesn't exist. Can't index\n";
	exit(0);
    }

    my $cmd = "samtools index " . $self->{filename};

    print "Indexing file...";
    system($cmd);
    print "done\n";

}

sub getRegion {
    my ($self,$id,$args) = @_;

    my $cmd = "samtools index " . $self->{filename} . " " . $id;

    if (defined($args->{start}) && defined($args->{end})) {

	my $start = $args->{start};
	my $end   = $args->{end};

	if (! $start =~ /\d+/ ||
	    ! $end   =~ /\d+/ ||
	    $start < 1        ||
	    $end   < 1        ||
	    $end < $start) {
	    print "ERROR: Start and end coords invalid [$start][$end}\n";
	    exit(0);
	}

	$cmd .= ":$start=$end";
    }
    my $fh= new FileHandle();
    
    $fh->open("$cmd |");
    
    my $str  = "";
    
    while (<$fh>) {
	$str .= $_;
    }

    return $str;
}

1;
