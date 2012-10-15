#!/usr/bin/perl

use strict;

$| = 1;

use Bio::SeqUtils;
use Bio::SeqIO;
use Getopt::Long;

my $len = 10;
my $infile;
my $strand = "both";
my $max    = 0;
my $help;

&GetOptions("infile:s"   => \$infile,
           "len:s"      => \$len,
           "strand:s"   => \$strand,
           "max"        => \$max,
           "help"       => \$help);

if ($help) {
   usage(1);
} 
print "Max $max\n";
my $in  = Bio::SeqIO->new(-file => $infile, '-format' => 'Fasta');

while (my $seq = $in->next_seq()) {
 print STDERR $seq->id() . "\n";
 my @seqs;
 if ($strand eq "both") {
    @seqs = Bio::SeqUtils->translate_6frames($seq);
 } elsif ($strand eq "forward") {
    @seqs = Bio::SeqUtils->translate_3frames($seq);
 } else {
    print "ERROR: Only both or forward strands recognised\n";
    exit;
 }

 my $maxseq = "";
 my $maxid;

 foreach my $s2 (@seqs) {
    my $tmpseq = $s2->seq();

    my @f = split(/\*/,$tmpseq);

    my $count = 1;

    foreach my $f (@f) {
      if (length($f) >= $len) {

        if ($max) {
           if (length($f) > length($maxseq)) {
              $maxseq = $f;
              $maxid  = $s2->id();
           }
        } else {
          my $id = $s2->id() . "_" . $count;
          $f =~ s/(.{72})/$1\n/g;
          print ">$id\n$f\n";
          $count++;
       }
      }
   }
 }
 if ($max) {
    $maxseq =~ s/(.{72})/$1\n/g;
    print ">$maxid\n$maxseq\n";
 }
}


sub usage {
  my $exit = shift;

  print "\nTakes a fasta dna file and finds all ORFs over a certain length in all 6 frames\n";
  print "Output is a protein fasta file\n\n";
  print "Usage  :  perl translast_fasta.pl -infile <fastafile> [-max] [-len <minimum protein length>] [-help]\n";
  print "len    :  Minimum length of peptide to return (default 10)\n";
  print "max    :  Only output the longest peptide\n";
  print "strand :  forward|both (default both)\n";
  print "help   :  This message\n\n";

  if ($exit) {
     exit(0);
  }
}
