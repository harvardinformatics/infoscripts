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

sub submit {
    my $self = shift;

    if ($self->is_multijob())              {

	my $jobs = $self->submitMultiJob();

	return $jobs;

    } else {

	$self->submitSingleJob();

	return [$self];

    }
}

sub submitMultiJob {
    my ($self) = @_;
    my $input = $self->input();

    if (!$input)                             { die "No input for Iprscan analysis job. Can't submit";}
    
    if (!$input->{'Input_1:MultiFastaFile'}) { die "No fasta file input for Iprscan analysis job. Can't submit";}
    
    my $inputfile = $input->{'Input_1:MultiFastaFile'};

    my $fs        = new FastaSplitter($inputfile);

    my $files     = $fs->split();

    my @jobs;

    foreach my $file (@$files) {
	my $tmpjob = new IprscanJob();

	$tmpjob->input({"Input_1:FastaFile",$file});

	push(@jobs,$tmpjob);

	$tmpjob->submit();
    }

    $self->{multijobs} = \@jobs;

    return $self->{multijobs};
    
}

sub submitSingleJob {
    my ($self) = @_;

    my $input = $self->input();

    if (!$input)                             { die "No input for Iprscan analysis job. Can't submit";}
    
    if (!$input->{'Input_1:FastaFile'}) { die "No fasta file input for Iprscan analysis job. Can't submit";}
    
    my $inputfile = $input->{'Input_1:FastaFile'};

    my $cmd = "iprscan -cli -i $inputfile -o $inputfile.xml -format xml -iprlookup -goterms -altjobs -appl hmmpfam";

    print "Command is ".substr($cmd,0,100) . "...\n";
    
    $self->{outputfiles} = [$inputfile.".xml"];

    return $cmd;
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
