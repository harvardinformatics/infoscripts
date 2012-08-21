package JobFactory;

use strict;

use Data::Dumper;
use FileHandle;
use AnalysisJob;

sub newFromMultiJobFile {
    my ($file) = @_;


    my $fh = new FileHandle();

    $fh->open("<$file") || die "Can't read jobs from file [$file]";

    my @jobs;
    
    while (my $line = <$fh>) {
	chomp($line);

	my @f = split(/\t/,$line);

	if ($f[0]) {
	    my $job = JobFactory::newFromJobFile($f[0]);
	    
	    if ($f[1]) {
		$job->{jobid} = $f[1];
	    }
	    
	    push(@jobs,$job);
	}
    }

    $fh->close();

    my $job = new AnalysisJob();
    $job->{jobfile} = $file;
    $job->{subjobs} = \@jobs;

    return $job;
}

sub newFromJobFile {
    my ($file) = @_;

    my $fh = new FileHandle();
    
    $fh->open("<$file") || die "Can't read job from file [$file]";

    my $job = new AnalysisJob();

    LINE: while (my $line = <$fh>) {
	chomp($line);

	if ($line =~ /^\#BSUB +(\S+) +(.*)/) {
	    my $option = $1;
	    my $value  = $2;

	    print "Option $option $value\n";

	    if ($option eq "-o") {
		$job->{'bsubout'} = $value;
	    } elsif ($option eq "-e") {
		$job->{'bsuberr'} = $value;		
	    } elsif ($option eq "-u") {
		$job->{'user'} = $value;
	    } elsif ($option eq "-J") {
		$job->{'name'} = $value;
	    } elsif ($option eq "-q") {
		$job->{'queue'} = $value;
	    }
	}
    }
    JobFactory::fillFromLSFQueue($job);

    if ($job->{bsubout} && -e $job->{bsubout}) {
	JobFactory::fillFromBsubout($job);
      }
    
    return $job;
}
sub fillFromLSFQueue {
    my ($job) = @_;

    my $jobid = $job->{jobid};

    my $fh = new FileHandle();
    $fh->open("bjobs -w $jobid|");

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
	    
	    $job->{'jobid'}    = $jobid;
	    $job->{'user'}     = $user;
	    $job->{'status'}   = $status;
	    $job->{'queue'}    = $queue;
	    $job->{'subhost'}  = $subhost;
	    $job->{'exechost'} = $exechost;
	    $job->{'name'}     = $jobname;
	    $job->{'subtime'}  = $subtime;

	    return $job;
	}
    }
}

sub fillFromBsubout {
    my ($job) = @_;

    my $bsubfile  = $job->{bsubfile};
    my $bjobid    = $job->{jobid};
    my $outfile  = $job->{bsubout};

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
    return $job;
}

1;
