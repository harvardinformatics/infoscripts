#!/usr/bin/perl

use strict;

$| = 1;

my @ids;
my @seqs;

my $id;
my $seq;

while (<>) {

    chomp;

    if (/^>(.*)/) {

	my $tmpid = $1;

	if ($id) {

           if ($id =~ /^Reverse_/) {
              die "There are reverse sequences already in here [$id].";
            }
            $id = "Reverse_$id";
	    my $tmpseq = reverse($seq);
            $tmpseq =~ s/(.{72})/$1\n/g;

            print ">$id\n$tmpseq\n";
	}
	$id = $tmpid;
	$seq = "";
    } else {
	$seq .= $_;
    }
}

    
if ($id) {
    if ($id =~ /^Reverse_/) {
      die "There are reverse sequences already in here [$id].";
    }
    $id = "Reverse_$id";
    my $tmpseq = reverse($seq);
    $tmpseq =~ s/(.{72})/$1\n/g;
    print ">$id\n$tmpseq\n";
}
