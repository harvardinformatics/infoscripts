#!/usr/bin/perl
$| = 1;
use strict;
use AnalysisJob;
use Test;

my $test = new Test("AnalysisJob");

my $job  = new AnalysisJob();

$test->result($job,"Created new AnaylsisJob object");

$test->result($job->id("Job_1")         eq "Job_1",  "Tested id get/set");
$test->result($job->name("Jobname")     eq "Jobname","Tested name get/set");
$test->result($job->analysis("Iprscan") eq "Iprscan","Tested analysis get/set");
$test->result($job->type("LSF")         eq "LSF",    "Tested type get/set");
$test->result($job->is_multijob(0)       eq "0",      "Tested is_multijob get/set");
$test->result($job->parentjob("Parent") eq "Parent", "Tested parentjob get/set");

$job->input({"Input_1:MultiFastaFile" => "myfile.fasta"});

my $input = $job->input();

my @keys  = keys %$input;

$test->result($#keys == 0,"Testing number of input keys");

$test->result($keys[0] eq "Input_1:MultiFastaFile","Testing number of input keys");

$test->result($input->{'Input_1:MultiFastaFile'} eq "myfile.fasta","Testing input val");

print $test->print_total();

