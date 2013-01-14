#!/opt/local/bin/perl


use strict;
use BSearch;
use SAMFeature;
use FastaFile;
use Cluster;

$| = 1;

use FileHandle;
use Getopt::Long;
use Data::Dumper;

my $samfile;
my $outfile;

my $rfile;

my $help;

my $samfh;
my $outfh;
GetOptions("-samfile:s"  => \$samfile,
           "-outfile:s" => \$outfile,
	   "-rfile:s"   => \$rfile,
           "-help"      => \$help);

if ($help) {
	help(1);
}

if ($samfile) {
	$samfh = new FileHandle();
	$samfh->open("<$samfile") || die "Can't open input file [$samfile]\n";
}
if ($outfile) {
	$outfh = new FileHandle();
	$outfh->open(">$outfile") || die "Can't open output file [$outfile]\n";
}


my $rff = new FastaFile($rfile);

my $line = <$samfh>;
my $id;

my %out;

while ($line) {

    chomp($line);
    
    my @f = split(/\t/,$line);

    my $samf  = SAMFeature::newFromString($line);

    $samf->getReadAlignment($rff);

    $line = <$samfh>;
    
}


sub help {
    my ($exit) = shift;

    print "Usage: search_file.pl -infile <myfile> -outfile <outfile> -id <id> -field <fieldnum>\n";

    if ($exit) {
	exit(0);
    }
}
