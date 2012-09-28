#!/usr/bin/perl

#@HWI-ST1233:94:C0YE6ACXX:1:1101:1176:1895 1:N:0:CGATGTATCTCG
#
#@ILLUMINA_0322:6:1101:1329:2045#GATAAGATCTCG/1

#cat new-style_.fastq | awk '{if (NR % 4 == 1) {split($1, arr, ":"); printf "%s_%s:%s:%s:%s:%s#0/%s (%s)\n", arr[1], arr[3], arr[4], arr[5], arr[6], arr[7], substr($2, 1, 1), $0} else if (NR % 4 == 3){print "+"} else {print $0} }' > old-style.fastq
#
$count = 0;
while (<>) {
   #print $_;
   chomp;

   if ($count%4 == 0) {

      #@HWI-ST1233:94:C0YE6ACXX:1:1101:1176:1895 1:N:0:CGATGTATCTCG
      my @g = split(/ +/,$_);
      my @f1 = split(/:/,$g[0]);
      my @f2 = split(/:/,$g[1]);
   
      $inst     = $f1[0];
      $runid    = $f1[1];
      $flowcell = $f1[2];
      $lane     = $f1[3];
      $tile     = $f1[4];
      $x        = $f1[5];
      $y        = $f1[6];
      $read     = $f2[0];
      $fail     = $f2[1];
      $control  = $f2[2];
      $index    = $f2[3];

      #@ILLUMINA_0322:6:1101:1329:2045#GATAAGATCTCG/1
      print "$inst:$lane:$tile:$x:$y";
    
      if ($index ne "") {
         print "#$index";
      } else {
         print "#0";
      }

      print "/$read ($_)\n";
   } else {
      print $_ . "\n";
   }
   $count++;
}
      
      

     
