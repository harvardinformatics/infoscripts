package AnalysisJob;

use strict;

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

sub init {
    my $self = shift;
}

sub submit {
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
