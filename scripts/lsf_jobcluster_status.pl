#!/usr/bin/perl

use strict;
use Getopt::Long;
use FileHandle;
use Data::Dumper;

# When an analysis job is split up into smaller lsf jobs (using ??) this script 
# can check on the status of all the individual jobs.
#
# Input is either a directory when it will :
#
#   - Look for the job cluster file .jobclusterfiles
# 
#  or the input is the job cluster filename itself.
#
# This file contains a row for each job listing the job submission file and the lsf job id
#
# For each job it will 
#
#      - check the status of the job via lsf (if the job id exists)
#      - get the job output and error filename
#      - check whether the output file exists
#      - check the output status from the output file 
#      - extract the CPU time/memory used etc from the output file
#
#    If the job has failed it will
#      - print the contents of the error file (or the last x lines if the file is big)
#
#    Optionally it will cycle the output and error files and resubmit the job.
#
# If all jobs have passed then it will report the job as successful
  

my $help;
my $jobdir;
my $jobclusterfile = ".jobclusterfiles";

GetOptions("jobclusterfile:s"    => \$jobclusterfile,
	   "help"                => \$help,
	   ) || help();

if ($help) {help();}

my $date = `date`;
my $cwd  = `pwd`; chomp($cwd);


if ($jobclusterfile !~ /^\//) {
    $jobclusterfile = $cwd . "/" . $jobclusterfile;
}
    
print "\n";
print "================== Parameters ==================\n\n";
print "Job cluster file              = $jobclusterfile\n";
print "\n================================================\n\n";
                                                                                
my @jobs = read_jobs($jobclusterfile);

my %status;

foreach my $job (@jobs) {


    get_outfiles($job);
    read_outfiles($job);

    my $jobstatus = $job->{'status'};
    
    print_status($job);
    
    #print Dumper($job);

    if ($jobstatus == "FAILED") {
	#print_error($job);
    }

    $status{$jobstatus}++;
}

print "\n";

print "Job status for $jobclusterfile at $date\n\n";

print "Total jobs " . scalar(@jobs) . "\n";

foreach my $status (sort keys %status) {
    print "Jobs with status $status " . $status{$status} . "\n";
}

sub read_jobs {
    my ($file) = @_;

    my @jobs;

    my %queued_jobs = check_status();
    
    if (! -e $file) { die "Can't read jobfile [$file]\n";}

    my $fh = new FileHandle();

    $fh->open("<$file");

    LINE: while (<$fh>) {

	chomp;
	
	my @f = split(/\t/,$_);

	if (scalar(@f) == 0) {
	    next LINE;
	}
	
	my $bsubfile = $f[0];
	my $bjobid;

	if (! -e $bsubfile) { die "Bsubfile [$bsubfile] listed in jobcluster file [$file] doesn't exist";}

	if (scalar(@f) > 1) {
	    $bjobid = $f[1];
	}

	my %tmpjob;

	if ($queued_jobs{$file}) {
	    $tmpjob{'bjobid'} = $queued_jobs{$file}{'bjobid'};
	    $tmpjob{'status'} = $queued_jobs{$file}{'status'};
	    print "FOUND JOB!!!!\n";
	}
	$tmpjob{'bsubfile'} = $bsubfile;
	$tmpjob{'bjobid'}   = $bjobid;

	push(@jobs,\%tmpjob);
    }

    $fh->close();

    return @jobs;

}

sub check_status {

    my %queued_jobs;

    my $fh = new FileHandle();
    $fh->open("bjobs -w |");

    while (<$fh>) {

	chomp;

	my @f   = split(/ +/,$_,8);

	if (scalar(@f) == 8 && $f[0] ne "JOBID") {

	    my $jobid    = $f[0];
	    my $user     = $f[1];
	    my $status   = $f[2];
	    my $queue    = $f[3];
	    my $subhost  = $f[4];
	    my $exechost = $f[5];
	    my $jobname  = $f[6];
	    my $subtime  = $f[7];
	    
	    my $job = {};
	    
	    $job->{'jobid'}    = $jobid;
	    $job->{'user'}     = $user;
	    $job->{'status'}   = $status;
	    $job->{'queue'}    = $queue;
	    $job->{'subhost'}  = $subhost;
	    $job->{'exechost'} = $exechost;
	    $job->{'jobname'}  = $jobname;
	    $job->{'subtime'}  = $subtime;

	    $queued_jobs{$jobname} = $job;
	    
	    print Dumper($job) . "\n";
	}
    }
    return \%queued_jobs;

}

sub get_outfiles {
    my ($job) = @_;

    my $bsubfile = $job->{'bsubfile'};
    my $bjobid   = $job->{'bjobid'};

    if (! -e $bsubfile) { die "ERROR: Can't read bsubfile [$bsubfile] for job [$bjobid]\n";}

    my $fh = new FileHandle();

    $fh->open("<$bsubfile") || die "ERROR: Can't open bsubfile [$bsubfile] for reading\n";

    LINE: while (<$fh>) {
	chomp;

	if (! /^\#BSUB/) {
	    next LINE;
	}

	if (/^\#BSUB +(\S+) +(.*)/) {
	    my $option = $1;
	    my $value  = $2;

	    if ($option eq "-o") {

		$job->{'outfile'} = $value;

	    } elsif ($option eq "-e") {

		$job->{'errfile'} = $value;		

	    }
	}
    }

    $fh->close();
    
}

sub read_outfiles {
    my ($job) = @_;

    my $bsubfile = $job->{'bsubfile'};
    my $bjobid   = $job->{'bjobid'};
    my $outfile  = $job->{'outfile'};

    if (!$outfile)     { print "ERROR: No output file defined for bsubfile [$bsubfile] with jobid [$bjobid]"; return;}

    if (! -e $outfile) { print "ERROR: Output file [$outfile] doesn't exist for bsubfile [$bsubfile] with jobid [$bjobid]";return;} 

    my $fh = new FileHandle();
    
    $fh->open("<$outfile") || die "ERROR: Can't read output file [$outfile] doesn't exist for bsubfile [$bsubfile] with jobid [$bjobid]"; 


    my $jobsender;
    my $jobsubject;
    my $jobid;
    my $jobname;
    my $jobhost;
    my $jobuser;
    my $jobqueue;
    my $jobcluster;
    my $jobexechost;
    my $jobexecqueue;
    my $jobexecuser;
    my $jobexeccluster;
    
    my $jobhomedir;
    my $jobworkdir;
    my $jobstarted;
    my $jobfinished;
    
    my $exitstatus;
    my $exitcode = 1;
    my $cputime;
    my $maxmem;
    my $maxswap;
    my $maxproc;
    my $maxthread;
    
    my $found_dashedlines = 0;   #  

    while (<$fh>) {
	chomp;

	#print "Line $_\n";
	
	if (/^Sender: (.*)/) {
	    $jobsender      = $1;
	} elsif (/^Subject: Job (\d+): +<(.*)>/) {
	    $jobid          =  $1;
	    $jobsubject     =  $2;
	} elsif (/^Job was executed on host\(s\) <(.*?>).*?<(.*?)>.*?<(.*?)>.*?<(.*?)>/) {
	    $jobexechost    = $1;
	    $jobexecqueue   = $2;
	    $jobexecuser    = $3;
	    $jobexeccluster = $4;

	} elsif (/^Job .*?<(.*?>).*?<(.*?)>.*?<(.*?)>.*?<(.*?)>/) {
	    $jobhost        = $1;
	    $jobqueue       = $2;
	    $jobuser        = $3;
	    $jobcluster     = $4;
	} elsif (/<(.*?)> was used as the home directory/) {
	    $jobhomedir     = $1;
	} elsif (/<(.*?)> was used as the working directory/) {
	    $jobworkdir     = $1;
	} elsif (/^Started at (.*)/) {
	    $jobstarted     = $1;
	} elsif (/^Started at (.*)/) {
	    $jobstarted     = $1;
	} elsif (/^Results reported at (.*)/) {
	    $jobfinished     = $1;
	} elsif (/^-+$/) {
	    $found_dashedlines++;
	} elsif (/^Successfully completed\./) {
	    $exitstatus = "SUCCESS";
	} elsif (/^Exited with exit code (\d+)\./) {
	    $exitstatus = "FAILED";
	    $exitcode   = $1;
	} elsif (/CPU time +: +(\S+)/) {
	    $cputime = $1;
	} elsif (/Max Memory +: +(\S+) +(\S+)/) {
	    $maxmem = $1 . " " . $2;
	} elsif (/Max Swap +: +(\S+) +(\S+)/) {
	    $maxswap = $1 . " " . $2;
	} elsif (/Max Processes +: +(\d+)/) {
	    $maxproc = $1;
	} elsif (/Max Threads +: +(\d+)/) {
	    $maxthread = $1;
	} elsif (/^PS:/) {

	    $job->{'jobsender'}      = $jobsender;
	    $job->{'jobsubject'}     = $jobsubject;
	    $job->{'jobid'}          = $jobid;
	    $job->{'jobname'}        = $jobname;
	    $job->{'jobhost'}        = $jobhost;
	    $job->{'jobuser'}        = $jobuser;
	    $job->{'jobcluster'}     = $jobcluster;
	    $job->{'jobexechost'}    = $jobexechost;
	    $job->{'jobexecqueue'}   = $jobexecqueue;
	    $job->{'jobexecuser'}    = $jobexecuser;
	    $job->{'jobexeccluster'} = $jobexeccluster;
	    
	    $job->{'jobhomedir'}     = $jobhomedir;
	    $job->{'jobworkdir'}     = $jobworkdir;
	    $job->{'jobstarted'}     = $jobstarted;
	    $job->{'jobfinished'}    = $jobfinished;
	    $job->{'status'}         = $exitstatus;
	    $job->{'exitcode'}       = $exitcode;
	    $job->{'cputime'}        = $cputime;
	    $job->{'maxmem'}         = $maxmem;
	    $job->{'maxswap'}        = $maxswap;
	    $job->{'maxproc'}        = $maxproc;
	    $job->{'maxthread'}      = $maxthread;

	    last;
	}

    }
    $fh->close();

}

sub print_status {
    my ($job) = @_;

    my $bjobid       = $job->{'bjobid'};
    my $exitstatus   = $job->{'exitstatus'};
    my $exitcode     = $job->{'exitcode'};
    my $outfile      = $job->{'outfile'};
    my $errfile      = $job->{'errfile'};
    my $bjobfile     = $job->{'bjobfile'};

    print $bjobid . "\t" . $exitstatus . "\t" . $exitcode . "\t" . $bjobfile . "\t" . $outfile. "\t" . $errfile . "\n";

}

# This file contains a row for each job listing the job submission file and the lsf job id
#
# For each job it will 
#
#      - check the status of the job via lsf (if the job id exists)
#      - get the job output and error filename
#      - check whether the output file exists
#      - check the output status from the output file 
#      - extract the CPU time/memory used etc from the output file
#
#    If the job has failed it will
#      - print the contents of the error file (or the last x lines if the file is big)
#
#    Optionally it will cycle the output and error files and resubmit the job.
#
# If all jobs have passed then it will report the job as successful


sub help {
    
 my $str = << 'END_STR';
 When an analysis job is split up into smaller lsf jobs (using ??) this script 
 can check on the status of all the individual jobs.

 The input is the job cluster filename (-jobclusterfile myjobs.list).  The default is .jobclusterfiles

 This file contains a row for each job listing the job submission file and (optionally) the lsf job id

 For each job it will 

      - check the status of the job via lsf (if the job id exists)
      - get the job output and error filename
      - check whether the output file exists
      - check the output status from the output file 
      - extract the CPU time/memory used etc from the output file

    If the job has failed it will
      - print the contents of the error file (or the last x lines if the file is big)

    Optionally it will cycle the output and error files and resubmit the job.

 If all jobs have passed then it will report the job as successful
END_STR

print "\n";
 print "Usage : lsf_jobcluster_status.pl [-jobclusterfile <jobclusterfiles.dat>] [-h]\n\n";
 print $str;
 print "\n";

 exit();
}
