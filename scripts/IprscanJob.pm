package IprscanJob;

use strict;

use AnalysisJob;
use FastaSplitter;
use Data::Dumper;

our @ISA = qw(AnalysisJob);

sub new {
    my ($class) = @_;

    my $self = $class->SUPER::new("Iprscan");

    bless $self, $class;

    return $self;
}

sub init {
    my $self = shift;
}


sub submitMultiJob {
    my ($self) = @_;
    my $input = $self->input();

    if (!$input)                             { die "No input for Iprscan analysis job. Can't submit";}
    
    if (!$input->{'Input_1:MultiFastaFile'}) { die "No fasta file input for Iprscan analysis job. Can't submit";}
    
    my $inputfile = $input->{'Input_1:MultiFastaFile'};

    my $fs        = new FastaSplitter($inputfile);
    $fs->{chunksize}  = $self->chunksize();
    my $files     = $fs->split();

    my @jobs;

    foreach my $file (@$files) {

	my $tmpjob = new IprscanJob();

	$tmpjob->input({"Input_1:FastaFile",$file});

	push(@jobs,$tmpjob);

	$tmpjob->submit();
    }

    # Now we need to store the jobs in a file (and be able to read from it)
    
    print "Ref " . $self . "\n";

    $self->{multijobs} = \@jobs;

    return $self->{multijobs};
    
}

# newFromFile

# checkstatus - 
sub submitSingleJob {
    my ($self) = @_;

    my $input = $self->input();

    if (!$input)                             { die "No input for Iprscan analysis job. Can't submit";}
    
    if (!$input->{'Input_1:FastaFile'}) { die "No fasta file input for Iprscan analysis job. Can't submit";}
    
    my $inputfile = $input->{'Input_1:FastaFile'};

    my $cmd = "iprscan -cli -i $inputfile -o $inputfile.xml -format xml -iprlookup -goterms -altjobs -appl hmmpfam";

    print "Command is ".substr($cmd,0,100) . "...\n";
    
    $self->{outputfiles} = [$inputfile.".xml"];


    # So here we have a choice of running locally serially or submitting to LSF - let's do the LSF one first as that's 
    # what we're going to use first.

    # -u user
    # -J Jobname - the jobfile.
    # -o bsubout
    # -e bsuberr
    # -q queue
    # -C 0
    # Command
    
    # Create the job file

    # Submit to lsf - get the job id

    my $jobid = $self->submitLSFJob($inputfile,$cmd);

    return [$self];

}
sub submitLSFJob {
    my ($self,$inputfile,$cmd) = @_;

    my $jobstub  =   $inputfile;
    my $jobdir   =   $inputfile;

    $jobdir   =~ s/^(\/.*\/).*/$1/;
    $jobstub     =~  s/^\/.*\///;

    my $jobfilename = "$jobdir/$jobstub.job";

    print "Job stub/dir $jobstub $jobdir\n";
    print "Got job file $jobfilename";

    my $jfh = new FileHandle();
    $jfh->open(">$jobfilename");

    print $jfh "#/bin/bash\n";
    print $jfh "#BSUB -u michele.clamp\@gmail.com\n";
    print $jfh "#BSUB -J $jobstub\n";
    print $jfh "#BSUB -o $jobdir/$jobstub.bout\n";
    print $jfh "#BSUB -e $jobdir/$jobstub.berr\n";
    print $jfh "#BSUB -q short_serial\n";
    print $jfh "#BSUB -C 0\n";
    print $jfh $cmd . "\n";

    $jfh->close();

    $self->{bsubfile}  = $jobfilename;
    $self->{bsubdir}   = $jobdir;
    $self->{bsubstub}  = $jobstub;
    
    my $jobid = `bsub < $jobfilename`;

    $self->{jobid} = $jobid;
    
    return $jobid;
}
    
sub check_status {
    my $self = shift;
}

sub resubmit {
    my $self = shift;
}

sub is_finished {
    my $self = shift;
}
sub pre_submit {
    my $self = shift;
}
sub post_submit {
    my $self = shift;
}

sub store {
    my $self = shift;
}

sub read {
    my $self = shift;
}


# Getsets inherited from AnalysisJob

1;
