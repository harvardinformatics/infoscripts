#!/usr/bin/perl
 
use strict;
use Getopt::Long;
$| = 1; 

my $infile1;
my $infile2;
my $outfile;
my $help;

GetOptions("infile1:s"  => \$infile1,
	   "infile2:s"  => \$infile2,
	   "outfile:s"  => \$outfile,
           "help"       => \$help);

if (defined($infile1)) {
    if (! -e $infile1) {
	print "ERROR: Input file 1 [$infile1] doesn't exist\n";
	help(1);
    }
    $infh1 = new FileHandle();
    $infh1->open("<$infile1");
}
if (defined($infile2)) {
    if (! -e $infile2) {
	print "ERROR: Input file 2 [$infile2] doesn't exist\n";
	help(1);
    }
    $infh2 = new FileHandle();
    $infh2->open("<$infile2");
}

my  $of= \*STDOUT;

if (defined($outfile)) {
    $of = new FileHandle();
    $of->open(">$outfile") || ( print "ERROR: Can't open output file [$outfile]\n"; help(1););
}

my $line1;
my $line2;
my $count = 0;

#@HWI-ST1233:94:C0YE6ACXX:3:1115:13318:92781 2:N:0:ATCACG
#@HWI-ST1233:94:C0YE6ACXX:3:1115:13318:92781 1:N:0:ATCACG

while ($line1 = <$infh1>) {

    $line1 = chomp($line1);
    $line2 = <$infh2>;
    $line2 = chomp($line2);

    if ($line1 =~ /^\@(\S+) +(\d):(\S+)/) {
	my $line1stub  = $1;
	my $line1end   = $2;
	my $line1index = $3;

	if ($line2 =~ /^\@(\S+) +(\d):(\S+)/) {
	    my $line2stub  = $1;
	    my $line2end   = $2;
	    my $line2index = $3;
	}
	
	if ($line1stub ne $line2stub) {
	    print "ERROR: Expecting read pairs to be in the same position in each file. Mismatched headers\n";
	    print "   $line1\n";
	    print "   $line2\n";
	    help(1);
	}

	if ($line1end != 1 || $line2end != 2) {
	    print "ERROR: Expecting 1 for file 1 end (got [$line1end]) and 2 for file2 end (got [$line2end])\n";
	    help(1);
	}
	

	$tmp = 1;
	print $of $line1 . "\n";
	
	while ($tmp%4!= 0) {
	    $tmp1 = <$infh1>;
	    print $of $tmp1;
	    $tmp++;
	}

	$tmp = 1;
	print $of $line2 . "\n";
	while ($tmp%4!= 0) {
	    $tmp2 = <$infh2>;
	    print $of $tmp2;
	    $tmp++;
	}
	
    } else {
	print "ERROR: Expecting a header line starting with @ and like @HWI-ST1233:94:C0YE6ACXX:3:1115:13318:92781 2:N:0:ATCACG\n";
	help(1);
    }
}
	 
$of->close();

sub help($exit) {
    print "\nUsage: interleave_fastq.pl -infile1 <infile1> -infile2 <infile2> [-outfile <outfile]\n\n";
    print "infile1  :  fastq file containing reads from end 1\n";
    print "infile2  :  fastq file containing reads from end 2\n";
    print "outfile  :  defaults to stdout\n";

    if ($exit) {
	exit(0);
    }
}
