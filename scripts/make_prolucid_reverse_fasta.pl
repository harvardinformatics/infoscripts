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
              die "There are reverse sequences already in here [$id].  Use strip_reverse.pl to remove them";
            }
            push(@ids,$id);
	    my $tmpseq = $seq;
            $tmpseq =~ s/(.{72})/$1\n/g;
            push(@seqs,$seq);
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
      die "There are reverse sequences already in here [$id].  Use strip_reverse.pl to remove them";
    }
    push(@ids,$id);
    my $tmpseq = $seq;
    $tmpseq =~ s/(.{72})/$1\n/g;
    push(@seqs,$seq);
    print ">$id\n$tmpseq\n";
}

my $i = 0;

while ($i < scalar(@ids)) {

    my $id = $ids[$i];
    my $seq = reverse($seqs[$i]);

    $seq =~ s/(.{72})/$1\n/g;

    $id = "Reverse_$id";

    print ">$id\n$seq\n";
    $i++;

}
