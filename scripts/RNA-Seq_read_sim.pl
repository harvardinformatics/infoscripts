#!/usr/bin/perl
$| = 1;

use strict;


my $tlen = shift;
my $rlen = shift;
my $elen = shift;


# loop over number of transcripts

# choose a read start position 1 - tlen-rlen

# find read end position

# does it overlap an exon boundary?

my $num = 10000;

my $i = 0;
my %count;

while ($i < $num) {

    my $start = int(rand($tlen-$rlen));
    my $end   = $start + $rlen-1;

    my $j = 100;
    my $found = 0;

    while ($j < $tlen) {
	if ($j >= $start && $j <= $end) {
	    $found = 1;
	}
	$j += $elen;
    }

    $count{$found}++;

    $i++;
}

foreach my $k (keys (%count)) {
    print $k . "\t" . $count{$k} . "\n";
}

