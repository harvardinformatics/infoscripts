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

my $help;

my $samfh;
my $outfh;
GetOptions("-samfile:s"  => \$samfile,
           "-outfile:s" => \$outfile,
	   "-qfile:s"   => \$qfile,
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
my $qff = new FastaFile($qfile);

my $line = <$samfh>;
my $id;

my %out;

while ($line) {

    chomp($line);
    
    my @f = split(/\t/,$line);


    my $samf  = SAMFeature::newFromString($line);

    my $rname = $samf->{rname};

    if (defined($id) && $samf->{qname} ne $id) {
	cluster_feat(\%out);
	%out = ();
    }
    $id = $samf->{qname};

    push(@{$out{$rname}},$samf);

    $line = <$samfh>;
    
}


# Cluster the features by rname and coord - allow gap of 100kb? to group things.


# Go through each cluster

#   1.  Sort by coord

#   2.  Chain them together by qcoord (deal with forward and reverse strands)

#   2a.  Remove overlapping pieces <= This could be tricky.

#   3.  Get the alignments  - filter by pid?

#   4.  Print the alignments

#   5.  Print the sam lines.

sub cluster_feat {
    my ($out) = @_;
    my %out = %$out;

    my @allclus;
    
    foreach my $ref (keys (%out)) {
	
	my @feat = @{$out{$ref}};
	
	@feat = sort {$a->{rstart} <=> $b->{rstart}} @feat;
	
	my @clus = Cluster::cluster_sorted_SAMFeatures(\@feat,10000);
	
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
}
    sub help {
    my ($exit) = shift;

    print "Usage: search_file.pl -infile <myfile> -outfile <outfile> -id <id> -field <fieldnum>\n";

    if ($exit) {
	exit(0);
    }
}
