#!/usr/bin/perl
$| = 1;
use strict;
use FastaSplitter;
use Test;
use Data::Dumper;

my $test = new Test("FastaSplitter");

my $cwd  = `pwd`; chomp($cwd);

eval {

    my $outdir =  "$cwd/test_multi_pep_fasta_split";

    if (-d $outdir) {
	`rm -rf $outdir`;
    }

    my $testfile = "test_multi_pep_fasta.fa";
    
    my $fs       = new FastaSplitter($testfile);
    
    $test->result($fs,"Created new FastaSplitter object");
    
    $test->result($fs->checkInputFile(),   "Testing input file exists");
    $test->result($fs->createOutputDir(),  "Creating output directory");

    my $files = $fs->split();

    $test->result($#$files == 1, "Test number of files returned");

    $test->result($files->[1] eq $fs->{cwd} . "/test_multi_pep_fasta_split/test_multi_pep_fasta.1001-1727.fa","Test filename");

};

if ($@) {
    print "ERROR in " . $test->{name} . " " . $test->print_total() . " " . $@;
}

$test->print_total();

