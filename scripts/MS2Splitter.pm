package MS2Splitter;

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

    if (! $file)                        { die "Input ms2 file not defined. Cant split using MS2Splitter";}

    if ($file !~ /^\//) {
	$file = $self->{cwd} . "/" . $file;
    }
    
    if (! -e $file)                     { die "MS2 file [$file] doesnt exist. Cant split using MS2Splitter";}
    
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

    mkdir $outdir                     || die "Can't make output dir [$outdir] in MS2Splitter";
    chmod 0755, $outdir               || die "Can't change permissions on  output dir [$outdir] in MS2Splitter";

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


    my $line;
    
    # reading header
    while ( $line = <$infh>) {
        last if($line =~ /^S/);
    }

    my $numProcessed   = 0;
    my $fileCounter    = 0;
    my @splitFiles;

    while($line) {
       if($numProcessed == 0) {

            $fileCounter++;

            my $splitfilename    = "$outdir/$stub.$fileCounter.ms2";
	    
            print "Split filename: $splitfilename\n";
            open (OUTFILE, ">$splitfilename") or die "Couldn't open $splitfilename! Exiting...\n";

            push(@splitFiles, $splitfilename);      
       }

       # output each spectrum including header (S, Z, I lines) and peaks
       while ($line) {
	   print OUTFILE $line;
	   $line = <$infh>;
	   last if($line =~ /^S+/);
       }
       
       $numProcessed++;
       
       if($numProcessed == $chunk) {
	   close(OUTFILE);
	   $numProcessed = 0;
       }
    }
    
    close(INPUTFILE);

    $self->{splitfiles} = \@splitFiles;

    return $self->{splitfiles};
}

1;
