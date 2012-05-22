#!/usr/bin/perl
$| = 1;
use strict;
use IprscanJob;
use Test;
use Data::Dumper;

my $test = new Test("IprscanJob");

my $cwd  = `pwd`; chomp($cwd);

eval {

    my $outdir =  "$cwd/test_multi_pep_small_split";

    if (-d $outdir) {
	`rm -rf $outdir`;
    }

    my $testfile = "test_multi_pep_small.fa";
    
    my $iprjob   = new IprscanJob();

    $iprjob->is_multijob(1);

    $test->result($iprjob->chunksize(2) == 2,"Test chunksize changing");

    $test->result($iprjob->is_multijob() == 1,"Testing multijob status");

    $test->result($iprjob,"Created new IprscanJob object");

    $test->result($iprjob->input({"Input_1:MultiFastaFile" => $testfile}),"Added input to Iprscan");

    my $jobs = $iprjob->submit();

    $test->result($#$jobs == 8,"Test number of multijobs");

    my $outfiles= $jobs->[1]->{outputfiles};

    $test->result(scalar(@$outfiles) == 1,"Test number of output files");

    $test->result($outfiles->[0] eq "$cwd/test_multi_pep_small_split/test_multi_pep_small.3-4.fa.xml","Testing output filename");

};

if ($@) {
    print "ERROR in " . $test->{name} . " " . $test->print_total() . " " . $@;
}

$test->print_total();

