#!/usr/bin/perl
use strict;

# This script will check number of spectra finished in the given folder
# USAGE: prolucid_progress_checker folder_name 
# this script will output three numbers, the first one is the numspectrasearched,
# the second is total number spectra submitted and the third one is always 0 to make 
# sure the first two will be always be intact even with error message

                                                                                
my $directory = shift; # remote temp directory for search

my $datafilefolder = shift;

# dir has not been created yet
chdir($directory) or die "0\t0\t0\n";

my $numunfinishedms2files = 0;
my @logfiles;

# one line in the prolucid_search_stat.txt file, numspectraperfile:numms2files
# output 0\t0 if the files has not been created yet
open (INPUTFILE, "prolucid_search_stat.txt") || die "0\t0\t0";
my $line;
my $numspectraperfile = 0;
my $numms2files = 0;  # total num ms2 files
while ( $line = <INPUTFILE>) {
    my @temparr = split(/:/, $line);
    $numspectraperfile = $temparr[0];
    $numms2files = $temparr[1];
}
close(INPUTFILE);

my @temps = `ls`;
foreach (@temps) {
    chomp;
    if (/^(.*)\.ms2$/) {
        $numunfinishedms2files++;
    }
    elsif (/^(.*)\.log$/) {
        push(@logfiles, "$1.log");
    }
}


# check log files

my $totalsearchedspectrainlog = 0;
foreach my $logfile (@logfiles) {
    my $numsearchedspectra = 0; # num spectra searched in this log file
    open (LOGFILE, $logfile) || next;
    my $line;

    my $iscombinedlog = 0;
    while ( $line = <LOGFILE>) {
        if($line =~ /^numJobsFinished/) {
            $iscombinedlog = 1;
            last;
        }
        if($line =~ /^NumSearched/) {
            my @temparr = split(/\t/, $line);
            $numsearchedspectra = $temparr[1];
        }
    }
    if($iscombinedlog) {
    } else {
        $totalsearchedspectrainlog += $numsearchedspectra;
    }
    #print "totalsearchedspectrainlog: $totalsearchedspectrainlog, numsearchedspectra: $numsearchedspectra\n";
    close(LOGFILE);
}

my $totalnumspectra = $numms2files * $numspectraperfile;
my $totalnumsearchedspectra = ($numms2files - $numunfinishedms2files)*$numspectraperfile + $totalsearchedspectrainlog ;

# in case ms2 file removed, but the log file has not been removed yet
if($totalnumsearchedspectra > $totalnumspectra) {
    $totalnumsearchedspectra = $totalnumspectra
}

print "$totalnumsearchedspectra\t$totalnumspectra\t0\n";

