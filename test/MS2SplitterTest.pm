#!/usr/bin/perl
$| = 1;
use strict;
use MS2Splitter;
use Test;
use Data::Dumper;

my $test = new Test("MS2Splitter");

my $cwd  = `pwd`; chomp($cwd);

eval {

    my $outdir =  "$cwd/test_split";

    if (-d $outdir) {
	`rm -rf $outdir`;
    }

    my $testfile = "test.ms2";
    
    my $fs       = new MS2Splitter($testfile);

    $fs->{chunksize}  = 100;
    $test->result($fs,"Created new MS2Splitter object");
    
    $test->result($fs->checkInputFile(),   "Testing input file exists");
    $test->result($fs->createOutputDir(),  "Creating output directory");

    my $files = $fs->split();

    print Dumper($files);

    $test->result($#$files == 2, "Test number of files returned");

    $test->result($files->[1] eq $fs->{cwd} . "/test_split/test.2.ms2","Test filename");

};

if ($@) {
    print "ERROR in " . $test->{name} . " " . $test->print_total() . " " . $@;
}

$test->print_total();

