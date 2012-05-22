package ProlucidJob;

use strict;

use AnalysisJob;
use MS2Splitter;
use Data::Dumper;

our @ISA = qw(ProlucidJob);

sub new {
    my ($class) = @_;

    my $self = $class->SUPER::new("Prolucid");

    bless $self, $class;

    return $self;
}

sub submitMultiJob {
    my ($self) = @_;

    my $input = $self->input();

    if (!$input)                             { die "No input for Iprscan analysis job. Can't submit";}
    
    if (!$input->{'Input_1:MultiMS2File'}) { die "No fasta file input for Iprscan analysis job. Can't submit";}
    
    my $inputfile = $input->{'Input_1:MultiMS2File'};

    my $fs        = new MS2Splitter($inputfile);
    $fs->{chunksize}  = $self->chunksize();
    my $files     = $fs->split();

    my @jobs;

    my $fh = new FileHandle();

    my $filename = $inputfile . ".multijob";
    
    $fh->open(">$filename");

    foreach my $file (@$files) {

	my $tmpjob = new ProlucidJob();

	$tmpjob->input({"Input_1:MS2File",$file});

	push(@jobs,$tmpjob);

	$tmpjob->submit();

	print $fh $tmpjob->toSingleLine() . "\n";
    }

    $fh->close();

    print "Ref " . $self . "\n";

    $self->{multijobs} = \@jobs;

    return $self->{multijobs};
    
}

sub submitSingleJob {
    my ($self) = @_;

    my $input = $self->input();

    if (!$input)                             { die "No input for Prolucid analysis job. Can't submit";}
    
    if (!$input->{'Input_1:MS2File'})       { die "No MS2 file input for Prolucid analysis job. Can't submit";}
    if (!$input->{'Input_2:SearchXMLFile'}) { die "No search.xml input for Prolucid analysis job. Can't submit";}

    my $inputfile = $input->{'Input_1:MS2File'};
    my $searchxml = $input->{'Input_1:SearchXMLFile'};

    my $cwd       = $self->{'cwd'};

    #my $cmd = "iprscan -cli -i $inputfile -o $inputfile.xml -format xml -iprlookup -goterms -altjobs -appl hmmpfam";

    my $prolucidjarfile       = "/n/ip2/ip2sys/lib/ProLuCID1_3.jar";
    my $cmd                   = "/n/ip2/ip2sys/jdk1.6.0_21_64/bin/java -Xmx4144M -jar $prolucidjarfile $cwd/$splitfile.ms2 $searchxml 2";

    print "Command is ".substr($cmd,0,100) . "...\n";
    
    my $inputstub = $inputfile;
    $inputstub =~ s/(.*)\..*?/$1/;

    $self->{outputfiles} = [$inputstub.".sqt"];

    my $jobid = $self->submitLSFJob($inputfile,$cmd);

    return [$self];

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
