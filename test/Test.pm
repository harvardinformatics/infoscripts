package Test;

use strict;
use Data::Dumper;

sub new {
    my ($class,$name) = @_;

    my $self = {
	name        => $name,
	fail        => 0,
	count       => 0,
    };

    bless $self, $class;

    print "Testing " . $self->name(). "\n\n";

    return $self;
}

sub result {
    my ($self,$out,$message) = @_;

    $self->{count}++;

    if ($out) {
	print "Test " . $self->count() . " ok     : $message\n";
    } else {
	print "Test " . $self->count() . " FAILED : $message\n";
	$self->{fail}++;
    }
}

sub print_total {
    my ($self,$label) = @_;

    if ($self->fail() == 0) {
	print "\nResult: SUCCESS:";
    } else {
	print "\nResult: FAILED:\t";
	
    }
    printf("%5d tests of %5d failed for %s\n",$self->fail(),$self->count(),$self->name());
}

sub name{
    my $self = shift;

    return $self->{'name'} = shift if @_;
    return $self->{'name'};
}
sub count{
    my $self = shift;

    return $self->{'count'} = shift if @_;
    return $self->{'count'};
}
sub fail{
    my $self = shift;

    return $self->{'fail'} = shift if @_;
    return $self->{'fail'};
}

1;
