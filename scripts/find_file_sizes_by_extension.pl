#!/usr/bin/perl

$| = 1;

use strict;
use FileHandle;

my $dir = $ARGV[0];
my $fh  = new FileHandle();
$fh->open("find $dir -type f -exec ls -1s {} \\; |");

my %size;
my %counts;

while (<$fh>) {
   chomp;
   my ($size,$file) = split(' ',$_);

   if (-f $file) {
      my $ext = $file;

      $ext =~ s/\.tar\.gz$/targz/;
      $ext =~ s/\.gz$/gz/;
      $ext =~ s/\.bz$/bz/;
      $ext =~ s/\.bz2$/bz2/;

      $ext =~ s/.*(\..*?)/$1/;

      if ($ext =~ /\//) {
         $ext =~ s/.*\/(.*?)/$1/;
      }
     #print "$size\t$file\t$ext\n";
     $size{$ext} += $size;
     $counts{$ext}++; 
   }
}

foreach my $key (sort {$counts{$a} <=> $counts{$b}} keys(%size)) {
  my $ext = $key;
  if ($ext =~ /targz$/) {
   $ext =~ s/targz$/\.tar\.gz/;
  } else {
    $ext =~ s/gz$/\.gz/;
    $ext =~ s/bz$/\.bz/;
    $ext =~ s/bz2$/\.bz2/;
  }

  printf("%40s %20s %7d %10.3f\n",$dir,$key,$counts{$key},($size{$key}/1000000));
}


