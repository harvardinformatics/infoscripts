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
my $max;

while ($line) {

    chomp($line);
    
    my @f = split(/\t/,$line);

    my $samf  = SAMFeature::newFromString($line);

    my $rname = $samf->{rname};

    if (defined($id) && $samf->{qname} ne $id) {
	if ($max > 1000) {
	    my $qseq = $qff->getRegion($id);
	    if (length($qseq) < 200) {
		print "Length for $id < 200 [".length($qseq)."]. Skipping\n";
	    } else {
		print "\nClustering features for id $id " . length($qseq) . "\n\n";
		cluster_feat(\%out,$id,$qseq,$rff,$qff);
	    }
	} else {
	    print "Skipping id $id - too short $max\n";
	}
	%out = ();
	$max = 0;
    }
    $id = $samf->{qname};
    my $flen = $samf->{rend} - $samf->{rstart}+1;
    if ($flen > $max) {
	$max = $flen;
    }

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
    my ($out,$id,$qseq,$rff,$qff) = @_;
    my %out = %$out;

    my @allclus;
    
    foreach my $ref (keys (%out)) {
	
	my @feat = @{$out{$ref}};
	
	@feat = sort {$a->{rstart} <=> $b->{rstart}} @feat;
	
	my @clus = Cluster::cluster_sorted_SAMFeatures(\@feat,10000);
	
	push(@allclus,@clus);
    }
    
    
    
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
	$clus->{qstart} = $qstart;
	$clus->{qend}   = $qend;
    }

    foreach my $clus (@allclus) {
	$clus->{length} = $clus->{end} - $clus->{start};
	$clus->{qlen}   = $clus->{qend} - $clus->{qstart} +1;
    }

    @allclus = sort {$b->{qlen} <=> $a->{qlen}} @allclus;

    my $count = 0;
    
    
    foreach my $clus (@allclus) {

	if ($count > 1) {
	    last;
	}
	my @feat = @{$clus->{features}};
	@feat = sort {$a->{rstart} <=> $b->{rstart}} @feat;

	my $qend   = $clus->{qend};
	my $qstart = $clus->{qstart};
	my $qlen   = length($qseq);
	my $next   = "-";
	if ($count < scalar(@allclus)-1) {
	    $next = $allclus[$count+1]->{qlen};
	}
	print "Cluster\t$count\t$id\t" . scalar(@allclus) . "\t" . scalar(@feat). "\t" . $clus->{rname} . "\t" . $clus->{start} . "\t" . $clus->{end} . "\t" . $clus->{length} . "\t" . $qstart . "\t" . $qend ."\t" . ($qend-$qstart+1) . "\t$qlen\t" . (int(100*($qend-$qstart+1)/length($qseq)))."\t$next\n";

	foreach my $f (@feat) {
	    #print $f->{qname} . "\t" . $f->{qstart} . "\t" . $f->{qend} . "\t" . $f->{bflag} . "\n";
	    $f->getAlignment($rff,$qff);
	    #print $count . "\t" . $f->{line} . "\n";
	}
	$count++;
    }
}
    sub help {
    my ($exit) = shift;

    print "Usage: parse_samfile.pl -samfile <myfile> -rfile <reffile> -qfile <queryfile>\n";

    if ($exit) {
	exit(0);
    }
}
