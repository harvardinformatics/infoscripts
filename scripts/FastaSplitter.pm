package FastaSplitter;

use strict;
use FileHandle;
use Data::Dumper;

sub new {
    my ($class,$_file,$_outdir) = @_;


    my $self = {
	file           => $_file,
	filestub       => undef,
	splitfiles     => [],
	outdir         => $_outdir,
	chunksize      => 1000,
	input_checked  => 0,
	outdir_created => 0,
    };

    my $cwd  = `pwd`; chomp($cwd);

    $self->{cwd} = $cwd;

    bless $self, $class;

    return $self;
}


sub split {
    my $self = shift;

    if (!$self->{input_checked})  { $self->checkInputFile();}
    if (!$self->{outdir_created}) { $self->createOutputDir();}
    
    $self->splitFile();

    return $self->{splitfiles};

}

sub checkInputFile {
    my $self = shift;
    
    my $file = $self->{file};

    if (! $file)                        { die "Input fasta file not defined. Cant split using FastaSplitter";}

    if ($file !~ /^\//) {
	$file = $self->{cwd} . "/" . $file;
    }
    
    if (! -e $file)                     { die "Fasta file [$file] doesnt exist. Cant split using FastaSplitter";}
    
    my $filestub = $file;

    $filestub =~ s/.*\/(.*)\..*/$1/;
    
    $self->{file}     = $file;
    $self->{filestub} = $filestub;
    
    $self->{input_checked} = 1;

    # print "Checked input for file [$file]\n";
    # print "Checked input for stub [$filestub]\n";
  
}

sub createOutputDir {
    my ($self) = @_;

    my $outdir = $self->{cwd}  . "/" . $self->{filestub} . "_split";
    
    if (-d $outdir)                    { die "Output dir [$outdir] exists.";}

    mkdir $outdir                     || die "Can't make output dir [$outdir] in FastaSplitter";
    chmod 0755, $outdir               || die "Can't change permissions on  output dir [$outdir] in FastaSplitter";

    $self->{outdir}         = $outdir;
    $self->{outdir_created} = 1;
}

sub splitFile {
    my ($self) = @_;
 
     my $infile = $self->{file};
     my $outdir = $self->{outdir};
     my $stub   = $self->{filestub};
     my $chunk  = $self->{chunksize};

     my $infh = new FileHandle();

     $infh->open("<$infile")              || die "Can't open input file [$infile]\n";

     my $count = 0;

    my @ids;
    my @seqs;
    my @files;

     while (<$infh>) {
 	chomp;
	
 	if (/^>(.*)/) {
 	    my $tmpid = $1;
	    
 	    if (scalar(@ids) == $chunk) {
 		my $tmpfile = $self->writeSeqs(\@ids,\@seqs,$count,$chunk,$outdir,$stub);
	
		push(@files,$tmpfile);

 		undef @ids;
 		undef @seqs;
 	    }
	    
 	    $count++;
	    
 	    push(@ids,$tmpid);
 	} else {
 	    $seqs[$#ids] .= $_;
 	}
     }
   
    my $tmpfile = $self->writeSeqs(\@ids,\@seqs,$count);

    push(@files,$tmpfile);

    $self->{splitfiles} = \@files;

    return $self->{splitfiles};
 }

sub writeSeqs {

    my ($self,$ids,$seqs,$count) = @_;
    
    my $outdir = $self->{outdir};
    my $chunk  = $self->{chunksize};
    my $stub   = $self->{filestub};

    my @ids    = @$ids;
    my @seqs   = @$seqs;
    
    my $ofh = new FileHandle();
    
    my $start = $count-scalar(@ids)+1;
    my $end   = $count;
    
    my $ofilename = $outdir . "/" . $stub . ".$start-$end.fa";
    
    print STDERR "Saving sequences $start - $end to $ofilename\n";
    
    $ofh->open(">$ofilename") || die "Couldn't open output file $ofilename\n";
    
    my $i = 0;

    while ($i < scalar(@ids)) {
	my $seq = $seqs[$i];
	my $id  = $ids[$i];
	
	$seq =~ s/(.{70})/$1\n/g;
	$seq =~ s/\n$//;
	
	print $ofh ">$id\n$seq\n";
	
	$i++;
    }

    $ofh->close();

    return $ofilename;
}

1;
