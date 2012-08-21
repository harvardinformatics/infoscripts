#!/usr/bin/perl

$| = 1;

use strict;

use Getopt::Long;

# The ProLuCID database search engine and the original submit_prolucid script is developed 
# in the Yates Laboratory at The Scripps Research Institute.

# It has been heavily modified to be run on the Harvard University Research Computing cluster
# using LSF.
#
# ProLuCID requires two files, the search parameter file search.xml and the MS/MS
# spectrum file (ms2 file).  The search results will be stored in a sqt file.
#
# Although ProLuCID can handle both MS2 file format and mzXML file format, this script
# can only work with MS2 file format(RAPID COMMUNICATIONS IN MASS SPECTROMETRY 18(18):2162-2168).  
#
# The fasta database and other search parameters, such as peptide and fragment mass
# tolerance, are specified in the search.xml file. Please note the fasta database file
# has to be accessible on each node of the cluster.
#
# Fragmentation method or activation type is specified in ms2 I line "I       ActivationType  ETD"
# Please send bug reports and comments to taoxu@scripps.edu and mclamp@harvard.edu

# The values of $jarfile and $redundanthlineremover
# shoud be modified according to your system condition.
#
# If the architecture of your system is different, you may need to modify 
# this script.
#

# This script will split each ms2 file into multiple jobs and will concatenate all the 
# output files to one final sqt file, and concatenate all the log files to one log file 
# for each original ms2 file.
#
# The default number of spectrum per job is 1000, however users can specify it at the command line 

# The following is an example command line to run ProLuCID
# java -Xmx1500M -jar ProLuCID.jar xxx.ms2 >> xxx.log 2>&1

my $help;
my $outdir;
my $datadir;
my $numSpectraPerFile     = 1000;
my $paramfile             = 'search.xml';
my $lsfqueue              = "ip2";
my $prolucidjarfile       = "/n/ip2/ip2sys/lib/ProLuCID1_3.jar";
my $redundanthlineremover = "/n/ip2/ip2sys/lib/redundanthlineremover";

GetOptions("jarfile:s"           => \$prolucidjarfile,
	   "lineremover:s"       => \$redundanthlineremover,
	   "numspectraperfile:s" => \$numSpectraPerFile,
	   "outdir:s"            => \$outdir,
	   "datadir:s"           => \$datadir,
	   "lsfqueue:s"          => \$lsfqueue,
	   "paramfile:s"         => \$paramfile,
	   "help"                => \$help,
	   ) || help();

if ($help) {help();}

my $cwd = `pwd`; chomp($cwd);

if ($datadir   !~ /^\//) { $datadir   = "$cwd/$datadir";}
if ($outdir    !~ /^\//) { $outdir    = "$cwd/$outdir";}
if ($paramfile !~ /^\//) { $paramfile = "$cwd/$paramfile";}

if ($datadir eq $outdir) { die "ERROR: Output directory must be different to data directory\n\n";}
    
print "\n";
print "================== Parameters ==================\n\n";
print "Prolucid jar file          = $prolucidjarfile\n";
print "Number of spectra per file = $numSpectraPerFile\n";
print "Output directory           = $outdir\n";
print "Data directory             = $datadir\n";
print "Param file                 = $paramfile\n";
print "LSF Queue                  = $lsfqueue\n";
print "\n================================================\n\n";

if (!    $outdir)    { print "No output directory specified\n";    help();}
if (!    $datadir)   { print "No data directory specified\n";      help();}
if (! -e $paramfile) { print "No param file [$paramfile]\n"; help();}


# ===============================================================================
#  Make the output directory
# ===============================================================================

print "Removing and/or making output directory $outdir\n\n";

`rm -rf  $outdir`;
`mkdir $outdir`;

chdir($outdir) or die "Can't create $outdir! Exiting...\n\n";

# ================================================================================
#   Read the spectra files
# ================================================================================

print "\nReading input spectra files from $datadir\n\n";

opendir(DIR,"$datadir");

my @temps = readdir(DIR);
my @filestub;

foreach (@temps) {
    chomp;
    if (/^(.*)\.ms2$/) {
        push(@filestub, $1);
        print "Adding spectra file $1.ms2\n";
   
    }
}

closedir(DIR);

# ================================================================================
#   Split the input ms2 files into $numSpectraPerFile line chunks
# ================================================================================

my $ms2counter = 0;
my $jobcounter = 0;

foreach my $filestub (reverse(@filestub)) {

    print "\nSplitting file $filestub\n\n";

    my $ms2file        = "$datadir/$filestub.ms2"; 
    my $hms2file       = "$datadir/H$filestub.ms2"; 

    print "File stub $filestub\n\n";
    print "MS2 file  $ms2file\n";
    print "HMS2 file $hms2file\n\n";

    open (INPUTFILE, "<$ms2file") || die "couldn't open $ms2file!";

    my $line;

    # reading header
    while ( $line = <INPUTFILE>) {
        last if($line =~ /^S/);
    }

    my $numProcessed   = 0;
    my $fileCounter    = 0;
    my @splitFiles;

    while($line) {
       if($numProcessed == 0) {

            $fileCounter++;

            my $splitfilename    = "$filestub"."_my_"."$fileCounter";
            my $filename         = "$filestub"."_my_"."$fileCounter".".ms2";
	    
            print "Split filename: $filename\n";
            open (OUTFILE, ">$filename") or die "Couldn't open $filename! Exiting...\n";

            push(@splitFiles, $splitfilename);      
       }

       # output each spectrum including header (S, Z, I lines) and peaks
        while ($line) {
            print OUTFILE $line;
            $line = <INPUTFILE>;
            last if($line =~ /^S+/);
        }

       $numProcessed++;

       if($numProcessed == $numSpectraPerFile) {
            close(OUTFILE);
            $numProcessed = 0;
       }
    }

    close(INPUTFILE);

    print "\nWriting job files ready for lsf submission\n\n";

    foreach my $splitfile (@splitFiles) {

        my $hsplitfile     = "H$splitfile";
        my $hfilestub      = "H$filestub";

	
        &outputJobFile($filestub, $splitfile, $outdir, $paramfile,$lsfqueue);

        $jobcounter++;

#       Heavy search - NOT IMPLEMENTED	
#        if($numargs > 6) {
#             output job file for heavy search
#            `cp $tempfile.ms2 $htempfile.ms2`;
#            &outputJobFile($horiginalFile, $htempfile, $directory, "Hsearch.xml"); 
#            $jobcounter++;
#        }
    }   
 
    print "\n$fileCounter jobfiles written for $filestub.ms2!\n";

    $ms2counter++;
}

# to keep track of number of spectra per file and number of spectrum files
my $prolucidstatus = "prolucid_search_stat.txt";

open (STATUSFILE, ">$prolucidstatus") or die "Couldn't open $prolucidstatus! Exiting...\n";

print STATUSFILE "$numSpectraPerFile:$jobcounter\n";
close STATUSFILE;

print "\n\n\n$jobcounter jobs submitted for $ms2counter ms2 files. Check out the queue status\n";
print "by typing \'qstat\'.\n\n";
print "The search results (sqt files and log files) will be returned to your\n";
print "directory $datadir.\n";

sub outputJobFile {
    my $filestub        = $_[0];
    my $splitfile       = $_[1];
    my $outdir          = $_[2];
    my $searchxml       = $_[3];
    my $lsfqueue        = $_[4];
    my $jobfile         = "$_[1].job";
    my $qsublogfile     = "$filestub.sub"; 
    my $lockfilename    = "$filestub.lock"; 
    
    my $qsubfinishedfile = "$filestub.fin"; 
    my $tempjobfile      = $jobfile;

    open (JOBFILE, ">$tempjobfile") or die "Couldn't open $tempjobfile! Exiting...\n";

    print "Writing $splitfile.job\n";

    print JOBFILE "#!/bin/sh\n";

    my $cwd = `pwd`; chomp($cwd);

    print JOBFILE "#BSUB -u mclamp\@harvard.edu\n";
    print JOBFILE "#BSUB -J $splitfile.job\n";
    print JOBFILE "#BSUB -o $cwd/$splitfile.out\n";
    print JOBFILE "#BSUB -e $cwd/$splitfile.err\n";
    print JOBFILE "#BSUB -q $lsfqueue\n";
#    print JOBFILE "#BSUB -E ls $cwd\n";
    print JOBFILE "#BSUB -C 0\n";

    #print JOBFILE "#BSUB -n 12\n";
    #print JOBFILE "#BSUB -M 8000000000\n";
    #print JOBFILE "#BSUB -R span[ptile=12]\n";

    print JOBFILE "/n/ip2/ip2sys/jdk1.6.0_21_64/bin/java -Xmx4144M -jar $prolucidjarfile $cwd/$splitfile.ms2 $searchxml 2 >> $cwd/$splitfile.log 2>&1\n\n";

    #print JOBFILE "rm -rf $splitfile.ms2 \n";
    
    print JOBFILE "lockfile -r-1 $lockfilename\n";
    print JOBFILE "cat $cwd/$splitfile.sqt >> $cwd/$filestub.sqt\n";
    print JOBFILE "cat $cwd/$splitfile.log >> $cwd/$filestub.log\n";
    print JOBFILE "cat $cwd/$splitfile.job >> $cwd/$filestub.job\n";
    
    #print JOBFILE "rm -rf $splittedFile.sqt\n";
    #print JOBFILE "rm -rf $splittedFile.log\n";
    #print JOBFILE "rm -rf $splittedFile.job\n";

    print JOBFILE "\n" . "echo finished $splitfile>> $qsubfinishedfile\n";

    print JOBFILE "numJobsFinished=`cat $cwd/$qsubfinishedfile | wc -l`\n";
    print JOBFILE "numJobsSubmitted=`cat $cwd/$qsublogfile | wc -l`\n";

    print JOBFILE "echo numJobsFinished \$numJobsFinished >> $cwd/$filestub.log\n";
    print JOBFILE "echo numJobsSubmitted \$numJobsSubmitted >> $cwd/$filestub.log\n";
    
    print JOBFILE "rm -rf $lockfilename\n";

    #  ========================================================================
    #   If all jobs finished then remove redundant lines
    #  ========================================================================

    print JOBFILE "\nif \[ \$numJobsSubmitted = \$numJobsFinished \]\; then\n";
    print JOBFILE "  $redundanthlineremover $cwd/$filestub.sqt\n";

    #  ========================================================================
    #   Try the copy 5 times!!! 
    #  ========================================================================
    #print JOBFILE "for i in 1 2 3 4 5\ndo\n"; 
    #print JOBFILE "cp -o StrictHostKeyChecking=no $originalFile.sqt $appuser\@$datafileserver:$datafilefolder\n";

    #print JOBFILE "\ncp $filestub.sqt $datadir\n";

    #print JOBFILE "if [ \"\$?\" -eq \"0\" ]; then\nbreak\nfi\ndone\n";

    #print JOBFILE "cp $filestub.log $appuser\@$datafileserver:$datafilefolder\n";
    #print JOBFILE "cp $filestub.job $appuser\@$datafileserver:$datafilefolder\n";

    #  ========================================================================
    #    Copy the log and job files to the data folder
    #  ========================================================================

    #print JOBFILE "cp $filestub.log $datadir\n";
    #print JOBFILE "cp $filestub.job $datadir\n";

    #  ========================================================================
    #    Remove the interim log and job files (keep for now)
    #  ========================================================================

    #print JOBFILE "rm -rf $originalFile.log\n";
    #print JOBFILE "rm -rf $originalFile.job\n";
    #print JOBFILE "rm -rf $qsubfinishedfile\n";
    #print JOBFILE "rm -rf $qsublogfile\n";

    print JOBFILE "\nfi\n";
    #print JOBFILE "cd \$PBS_O_WORKDIR\n";

    print JOBFILE "\nexit\n";
    close JOBFILE;

    `echo $splitfile.job >> $cwd/$qsublogfile`;

   # `bsub < $splittedFile.job >> $qsublogfile`;

}
sub help {
    
    print "\n\nUsage : lsf_submit_prolucid.pl -outdir <output directory> -datadir <data directory> [-paramfile <paramfile>] [-spectraperfile <n>] [-lsfqueue <queue>] [-jarfile <jarfile>] [-lineremover <lineremover>] [-help]\n";

    print "\n";
    print "  outdir:            Output directory (default .)\n";
    print "  datadir:           Data directory (contains the .ms2 files\n";
    print "  paramfile:         Parameter file (defaultis search.xml in the current directory\n";
    print "  spectraperfile:    Number of spectra per file when splitting up .ms2 input files (default 1000)\n";
    print "  jarfile:           Prolucid jar file\n";
    print "  lineremover:       Redundant line remover\n";
    print "  lsfqueue:          LSF queue (default ip2)\n";
    print "  help:              This message\n";
    print "\n\n";
    
    exit();
}
