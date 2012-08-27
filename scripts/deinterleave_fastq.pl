#!/usr/bin/perl
 
use strict;
use Getopt::Long;
$| = 1; 

my $infile;
my $outfile;
my $help;

GetOptions("infile:s"  => \$infile,
	   "outfile:s" => \$outfile,
           "help"      => \$help);

my $infh = \*STDIN;

if (defined($infile)) {
    if (! -e $infile) {
	print "ERROR: Input file [$infile] doesn't exist\n";
	help(1);
    }
    $infh = new FileHandle();
    $infh->open("$infile","r");
}

if (!defined($outfile)) {
   $outfile = $infile;
   $outfile =~ s/\.fastq$//;
   $outfile =~ s/\.fq$//;

}

my $of1 = new FileHandle();
my $of2 = new FileHandle();

$of1->open("$outfile.1.fastq","w");
$of2->open("$outfile.2.fastq","w");

my $line;
my $count = 0;
my $previd;

#@HWI-ST1233:94:C0YE6ACXX:3:1115:13318:92781 2:N:0:ATCACG
#@HWI-ST1233:94:C0YE6ACXX:3:1115:13318:92781 1:N:0:ATCACG

while ($line = <$infh>) {

    $line = chomp($line);

    if ($line =~ /^\@(\S+) +(\d):(\S+)/) {
	my $tmp1 = $1;
	my $end  = $2;
	my $tmp2 = $3;
	
	if ($end == 1) {
	    $of = $of1;
	    $previd = $tmp1;
	} elsif ($end == 2) {
	    $of = $of2;
	    if ($tmp1 ne $previd) {
		print "ERROR: Expecting interleaved reads (read 1 then read 2).  Mismatching header lines\n";
		print "   $previd\n";
		print "   $tmp1\n";
		help(1);
	    }
	} else {
	    print "ERROR: Unrecognized end (should be 1 or 2) from header line $line\n";
	    help(1);
	}

	$count++;

	print $of $line . "\n";

	while ($count%4!= 0) {
	    $tmp = <$infh>;
	    print $of $tmp;
	    $count++;
	}
    } else {
	print "ERROR: Expecting a header line starting with @ and like @HWI-ST1233:94:C0YE6ACXX:3:1115:13318:92781 2:N:0:ATCACG\n";
	help(1);
    }
}
	 
$of1->close();
$of2->close();

sub help($exit) {
    print "\nUsage: deinterleave_fastq.pl [-infile <infile>] [-outfile <outfile]\n\n";
    print "infile  :  defaults to stdin\n";
    print "outfile :  defaults to stdout\n";

    if ($exit) {
	exit(0);
    }
}
