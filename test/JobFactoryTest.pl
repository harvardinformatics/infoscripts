#!/usr/bin/perl
$| = 1;
use strict;
use JobFactory;
use Test;
use Data::Dumper;

my $test = new Test("JobFactory");

my $cwd  = `pwd`; chomp($cwd);

eval {

    my $bsubfile     = "data/test_multi_pep_small.1-2.fa.job";
    my $multijobfile = "data/test_multi_pep_small.fa.multijob";
    my $bsuboutfile  = "data/test_multi_pep_small.1-2.fa.bsubout";

    my $job          = JobFactory::newFromMultiJobFile($multijobfile);

    my $jobs         = $job->{subjobs};
    
    
    $test->result($#$jobs == 8,"Testing number of sub jobs");

    my %status;

    foreach my $job (@$jobs) {
	#print Dumper($job);
	my $status = $job->{status};
	$status{$status}++;
	print $job->{jobid} . "\t" . $status . "\t" . $job->{bsubout} . "\n";
    }
    my $job = $jobs->[0];

    $test->result($job->{jobid} == 28155116,"Testing jobid");
    $test->result($job->{name}  == "test_multi_pep_small.1-2.fa","Testing job name");

};

if ($@) {
    print "ERROR in " . $test->{name} . " " . $test->print_total() . " " . $@;
}

$test->print_total();

