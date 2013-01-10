#!/opt/local/bin/perl


use strict;
use BSearch;
use SAMFeature;
use FastaFile;

$| = 1;

use FileHandle;
use Getopt::Long;
use Data::Dumper;
my $samfile;
my $outfile;

my $qfile;
my $rfile;

my $samfh  = \*STDIN;
my $outfh = \*STDOUT;
my $id;
my $field;
my $pos = 1;

my $help;

GetOptions("-samfile:s"  => \$samfile,
           "-outfile:s" => \$outfile,
	   "-qfile:s"   => \$qfile,
	   "-rfile:s"   => \$rfile,
	   "-id:s"      => \$id,
	   "-field:s"   => \$field,
	   "-pos:s"     => \$pos,
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

if (!$id) {
    print "ERROR: No id input\n";
    help(1);
}

if ($field < 1 || !defined($field)) {
    print "ERROR: No or invalid field number input\n";
    help(1);
}
if ($pos < 1 || !defined($pos)) {
    print "ERROR: No or invalid field postion input\n";
    help(1);
}

my $rff = new FastaFile($rfile);
my $qff = new FastaFile($qfile);

$field = $field - 1;
$pos   = $pos   - 1;

my $fh = BSearch::search_file_pos($samfile, $id,$field,"\t",$pos);

my $line = <$fh>;

my %out;

while ($line) {
    print $line;
    chomp($line);
    
    my @f = split(/\t/,$line);

    my $str = $f[$field];
    my $ref = $f[2];

    if ($str ne $id) {
	last;
    } else {
	my $samf  = SAMFeature::newFromString($line);

	my $rname = $samf->{rname};
	
	push(@{$out{$rname}},$samf);
	
	#print Dumper($samf);
	$line = <$fh>;
    }
}

foreach my $ref (keys (%out)) {

    my @feat = @{$out{$ref}};
    
    @feat = sort {$a->{rstart} <=> $b->{rstart}} @feat;

    foreach my $f (@feat) {

	$f->getAlignment($rff,$qff);
	


    }
}

sub help {
    my ($exit) = shift;

    print "Usage: search_file.pl -infile <myfile> -outfile <outfile> -id <id> -field <fieldnum>\n";

    if ($exit) {
	exit(0);
    }
}
