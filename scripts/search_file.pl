#!/opt/local/bin/perl


use strict;
use BSearch;

$| = 1;

use FileHandle;
use Getopt::Long;

my $infile;
my $outfile;

my $infh  = \*STDIN;
my $outfh = \*STDOUT;
my $id;
my $field;
my $pos = 0;

my $help;

GetOptions("-infile:s"  => \$infile,
           "-outfile:s" => \$outfile,
	   "-id:s"      => \$id,
	   "-field:s"   => \$field,
	   "-pos:s"     => \$pos,
           "-help"      => \$help);

if ($help) {
	help(1);
}

if ($infile) {
	$infh = new FileHandle();
	$infh->open("<$infile") || die "Can't open input file [$infile]\n";
}
if ($outfile) {
	$outfh = new FileHandle();
	$outfh->open(">$outfile") || die "Can't open output file [$outfile]\n";
}

if (!$id) {
    print "ERROR: No id input\n";
    help(1);
}

if ($field < 0 || !defined($field)) {
    print "ERROR: No or invalid field number input\n";
    help(1);
}

my $fh = BSearch::search_file_pos($infile, $id,$field,"\t",$pos);

my $line = <$fh>;

while ($line) {
    chomp($line);

    my @f = split(/\t/,$line);
    
    my $str = $f[$field];
    
    if ($str ne $id) {
	exit(0);
    }
    print $line;
    $line = <$fh>;
}


sub help {
    my ($exit) = shift;

    print "Usage: search_file.pl -infile <myfile> -outfile <outfile> -id <id> -field <fieldnum>\n";

    if ($exit) {
	exit(0);
    }
}
