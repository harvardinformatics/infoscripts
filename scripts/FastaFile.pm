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
    $self->initCache();

    return $self;
}

sub initCache {
    my ($self) = @_;

    $self->{cache} = {};
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

    my $cmd = "samtools faidx " . $self->{filename};

    print "Indexing file...";
    system($cmd);
    print "done\n";

}

sub getRegion {
    my ($self,$id,$args) = @_;


    if (defined($self->{cache}{$id})) {
	return $self->{cache}{$id};
    }

    my $cmd = "samtools faidx " . $self->{filename} . " " . $id;

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

	$cmd .= ":$start-$end";
    }

    print "CMD ".$cmd."\n";
    my $fh= new FileHandle();
    
    $fh->open("$cmd |");
    
    my $str  = "";
    
    while (<$fh>) {
	print "LINE " .$_;
	if ($_ !~ /^>/) {
	    chomp;
	    $str .= $_;
	}
    }
    
    $self->{cache}{$id} = $str;

    return $str;
}

1;
