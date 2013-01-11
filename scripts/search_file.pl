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


# Cluster the features by rname and coord - allow gap of 100kb? to group things.


# Go through each cluster

#   1.  Sort by coord

#   2.  Chain them together by qcoord (deal with forward and reverse strands)

#   2a.  Remove overlapping pieces <= This could be tricky.

#   3.  Get the alignments  - filter by pid?

#   4.  Print the alignments

#   5.  Print the sam lines.

my @allclus;

foreach my $ref (keys (%out)) {

    my @feat = @{$out{$ref}};
    
    @feat = sort {$a->{rstart} <=> $b->{rstart}} @feat;

    my @clus = Cluster::cluster_sorted_SAMFeatures(\@feat,100000);

    push(@allclus,@clus);
}


foreach my $clus (@allclus) {
    $clus->{length} = $clus->{end} - $clus->{start} + 1;
}
@allclus = sort {$b->{length} <=> $a->{length}} @allclus;

foreach my $clus (@allclus) {
    my @feat = @{$clus->{features}};
    my $qstart;
    my $qend;
    
    foreach my $feat (@feat) {
	if (!defined($qstart) || $feat->{qstart}<$qstart) { 
	    $qstart = $feat->{qstart};
	}
	if (!defined($qend)   || $feat->{qend}>$qend)     { 
	    $qend   = $feat->{qend};
	}
    }
    print "Cluster " . scalar(@feat). "\t" . $clus->{rname} . "\t" . $clus->{start} . "\t" . $clus->{end} . "\t" . $clus->{length} . "\t" . $qstart . "\t" . $qend ."\t" . ($qend-$qstart+1) . "\n";
}
my $count = 0;
foreach my $clus (@allclus) {
    my @feat = @{$clus->{features}};
    @feat = sort {$a->{rstart} <=> $b->{rstart}} @feat;
    
    print "Cluster " . scalar(@feat) . "\t" . $clus->{rname} . "\t" . $clus->{start} . "\t" . $clus->{end} . "\t" . $clus->{length} . "\n";
    foreach my $f (@feat) {
	#print $f->{qname} . "\t" . $f->{qstart} . "\t" . $f->{qend} . "\t" . $f->{bflag} . "\n";
	#$f->getAlignment($rff,$qff);
	print $count . "\t" . $f->{line} . "\n";
    }
    $count++;
}

sub help {
    my ($exit) = shift;

    print "Usage: search_file.pl -infile <myfile> -outfile <outfile> -id <id> -field <fieldnum>\n";

    if ($exit) {
	exit(0);
    }
}
