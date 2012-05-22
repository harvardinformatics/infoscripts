package AnalysisJob;

use strict;
use FileHandle;

sub new {
    my ($class) = @_;


    my $self = {
        id          => undef,
        name        => undef,
	type        => undef,
        status      => "NEW",
	is_multijob => 0,
	analysis    => undef,
	parentjob   => undef,
	input       => {},
	output      => undef,
	parameters  => undef,
    };

    bless $self, $class;

    return $self;
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

sub toSingleLine {
    my ($self) = @_;

    my $str = $self->{bsubfile};

    $str .= "\t" . $self->{jobid};

    my $key;
    my $value;

    $str .= "\t";

    while ( ($key, $value) = each %{$self->{input}} ){
	$str .= "$key=>$value,";
    }
    $str .= "\t";
    foreach my $outfile (@{$self->{outputfiles}}) {
	$str .= "$outfile,";
    }
    return $str;
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

    $jobid =~ s/.*<(.*?)>.*<(.*?)>.*\n/$1/;

    $self->{jobid} = $jobid;
    
    return $jobid;
}

sub init {
    my $self = shift;
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


# Getsets from here
sub chunksize{
    my $self = shift;

    return $self->{'chunksize'} = shift if @_;
    return $self->{'chunksize'};
}

sub id{
    my $self = shift;

    return $self->{'id'} = shift if @_;
    return $self->{'id'};
}
sub name{
    my $self = shift;

    return $self->{'name'} = shift if @_;
    return $self->{'name'};
}
sub type{
    my $self = shift;

    return $self->{'type'} = shift if @_;
    return $self->{'type'};
}
sub is_multijob{
    my $self = shift;

    return $self->{'is_multijob'} = shift if @_;
    return $self->{'is_multijob'};
}
sub analysis{
    my $self = shift;

    return $self->{'analysis'} = shift if @_;
    return $self->{'analysis'};
}
sub parentjob{
    my $self = shift;

    return $self->{'parentjob'} = shift if @_;
    return $self->{'parentjob'};
}
sub input{
    my $self = shift;

    return $self->{'input'} = shift if @_;
    return $self->{'input'};
}
sub output{
    my $self = shift;

    return $self->{'output'} = shift if @_;
    return $self->{'output'};
}
sub parameters{
    my $self = shift;

    return $self->{'parameters'} = shift if @_;
    return $self->{'parameters'};
}

1;
