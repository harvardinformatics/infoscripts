#!/usr/bin/perl

use strict;

$| = 1;

use Bio::SeqUtils;
use Bio::SeqIO;
use Getopt::Long;

my $len = 10;
my $infile;
my $help;

&GetOptions("infile:s"   => \$infile,
           "len:s"      => \$len,
           "help"       => \$help);

if ($help) {
   usage(1);
} 

my $in  = Bio::SeqIO->new(-file => $infile, '-format' => 'Fasta');

while (my $seq = $in->next_seq()) {
 print STDERR $seq->id() . "\n";
 my @seqs = Bio::SeqUtils->translate_6frames($seq);
 foreach my $s2 (@seqs) {
    my $tmpseq = $s2->seq();

    my @f = split(/\*/,$tmpseq);

    my $count = 1;

    foreach my $f (@f) {
      if (length($f) >= $len) {
        my $id = $s2->id() . "_" . $count;
        $f =~ s/(.{72})/$1\n/g;
        print ">$id\n$f\n";
        $count++;
      }
   }
 }
}


sub usage {
  my $exit = shift;

  print "\nTakes a fasta dna file and finds all ORFs over a certain length in all 6 frames\n";
  print "Output is a protein fasta file\n\n";
  print "Usage:  perl trans6.pl -infile <fastafile> [-len <minimum protein length>] [-help]\n";
  print "Default length is 10\n\n";

  if ($exit) {
     exit(0);
  }
}
