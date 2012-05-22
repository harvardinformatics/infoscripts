#!/usr/bin/perl

use strict;

$| = 1;

my $id;
my $seq;

while (<>) {

    chomp;

    if (/^>(.*)/) {

	my $tmpid = $1;

	if ($id && $id =~ /^Reverse_sp/) {
	    $id  =~ s/Reverse_//;
	    $seq =~ s/(.{72})/$1/g;

	    print ">$id\n$seq\n";
	}
	$id = $tmpid;
	$seq = "";
    } else {
	$seq .= $_;
    }
}

    
if ($id && $id =~ /^Reverse_sp/) {
    $id  =~ s/Reverse_//;
    $seq =~ s/(.{72})/$1/g;
    
    print ">$id\n$seq\n";
}
