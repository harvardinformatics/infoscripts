#!/usr/bin/perl

use strict;

$| = 1;

use Getopt::Long;
use FileHandle;

my $infile;
my $chunk  = 1000;
my $stub   = "splitFasta";
my $outdir = ".";
my $infh   = \*STDIN;
my $help;

GetOptions("infile:s"    => \$infile,
	   "outdir:s"    => \$outdir,
	   "chunk:s"     => \$chunk,
	   "stub:s"      => \$stub,
	   "help"        => \$help);


my @ids;
my @seqs;

if ($outdir && ! -d $outdir) {
    mkdir($outdir);
}

if ($infile) {
    $infh = new FileHandle();
    $infh->open("<$infile") || die "Can't open input file [$infile]\n";

    if ($stub eq "splitFasta") {
	$stub = $infile;
	$stub =~ s/(.*)\..*/$1/;
    }
}

my $count = 0;

while (<$infh>) {
    chomp;

    if (/^>(.*)/) {
	my $tmpid = $1;

	if (scalar(@ids) == $chunk) {
	    writeSeqs(\@ids,\@seqs,$count,$chunk,$outdir,$stub);

	    undef @ids;
	    undef @seqs;
	}

	$count++;

	push(@ids,$tmpid);
    } else {
	$seqs[$#ids] .= $_;
    }
}

writeSeqs(\@ids,\@seqs,$count,$chunk,$outdir,$stub);

sub writeSeqs {

    my ($ids,$seqs,$count,$chunk,$outdir,$stub) = @_;

    my @ids  = @$ids;
    my @seqs = @$seqs;

    my $ofh = new FileHandle();

    my $start = $count-scalar(@ids)+1;
    my $end   = $count;

    my $ofilename = $outdir . "/" . $stub . ".$start-$end.fa";

    print STDERR "Saving sequences $start - $end to $ofilename\n";


    $ofh->open(">$ofilename") || die "Couldn't open output file $ofilename\n";

    my $i = 0;
    while ($i < scalar(@ids)) {
	my $seq = $seqs[$i];
	my $id  = $ids[$i];
	
	$seq =~ s/(.{70})/$1\n/g;
	$seq =~ s/\n$//;
	
	print $ofh ">$id\n$seq\n";
	
	$i++;
    }

    $ofh->close();
}




    
