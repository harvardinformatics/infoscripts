#!/usr/bin/perl

use strict;
use FileHandle;

$| = 1;

my $cmd = 'ldapsearch -w \'p$e9e!A2\' -x -h dc2-rc -D "clusterldap@rc.domain" -b "dc=rc,dc=domain" "uid=*"|egrep "cn:|uid:|memberOf"';
#cn: Michele Clamp
#memberOf: CN=GM_HMS_Agilent_6520_QTOF,OU=Lab_Instruments,OU=Domain Groups,OU=C
#memberOf: CN=G_HMS_Agilent_6520_QTOF,OU=Lab_Instruments,OU=Domain Groups,OU=CG
#memberOf: CN=GM_Apollo324,OU=Lab_Instruments,OU=Domain Groups,OU=CGR,DC=rc,DC=
#uid: mclamp

my $fh  = new FileHandle();

$fh->open("$cmd |");

my $uid;
my $cn;
my $groupstr;

while (<$fh>) {
   chomp;

   if (/cn: (.*)/) {
      my $tmpcn = $1;

      print "$uid\t$cn\t$groupstr\n";
      $cn = $tmpcn;
      $uid = "";
      $groupstr = "";
   } elsif (/uid: (.*)/) {
      $uid = $1;
   } elsif (/memberOf: (.*)/) {
      my @f = split(/,/,$1);


      foreach my $f (@f) {

         if ($f =~ /(.*)=(.*)/) {
             my $type  = $1;
             my $group = $2;
             if ($type eq "CN") {
                if ($groupstr ne "") {
                   $groupstr .= "\t";
                }
                $groupstr .= $group;
             }
         }
      }
   }
}
     
print "$uid\t$cn\t$groupstr\n";

