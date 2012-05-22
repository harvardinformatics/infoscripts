#!/usr/bin/perl

$| = 1;

use strict;
use FileHandle;

use Data::Dumper;
use Getopt::Long;
use XML::LibXML;


my $submit;
my $infile;
my $outfile;
my $bsubfile;
my $chunk = 1000;
my $splitdir;
my $clobber;

my $help; 

my $cwd  = `pwd`; chomp($cwd);

GetOptions("-infile:s"      => \$infile,
           "-outfile:s"     => \$outfile,
	   "-bsubfile:s"    => \$bsubfile,
	   "-chunk:s"       => \$chunk,
	   "-splitdir:s"    => \$splitdir,
	   "-clobber"       => \$clobber,
	   "-submit"        => \$submit,
	   "-help"          => \$help);


if ($help)  { help(1); }

if ($splitdir !~ /^\//) {
    $splitdir = $cwd . "/" . $splitdir;
}

my $stub = $infile;
$stub =~ s/^\/.*\///;
$stub =~ s/(.*)\..*/$1/;

print "Stub is $stub\n";

if (-d $splitdir && !$clobber) {  die "ERROR: Split directory exists [$splitdir].  Use -clobber option to overwrite"; }


if ($splitdir && $splitdir ne "/") {
    my $res = system("rm -rf $splitdir");
}


mkdir $splitdir || die "ERROR: Can't make output directory [$splitdir]\n";

if (! -e $bsubfile) { die "ERROR: Bsub file not specified [-bsubfile <bsub.sh>]\n"; }

my $bsubdata     = read_bsubfile($bsubfile,$infile,$outfile);
my $seqdata      = split_fasta($infile,$stub,$chunk,$splitdir);

print Dumper($seqdata);
print Dumper($bsubdata);

my $bsuberrfile  = $bsubdata->{'bsuberrfile'};
my $bsuboutfile  = $bsubdata->{'bsuboutfile'};

my @files        = @{$seqdata->{'files'}};

my $bsubstr      = $bsubdata->{'bsubstr'};
print Dumper($bsubdata);

my $jobclusterfile = "$splitdir/$stub.jobs";
my $jobclusterfh   = new FileHandle();
$jobclusterfh->open(">$jobclusterfile");


foreach my $file (@files) {
    
    # Get the split number - this should be either at the end or before the .fa or .fasta

    my $num = $file;
    $num =~ s/.*\.(\d+-\d+)\..*/$1/;

    print "Making job for file [$file] number [$num]\n";
    
    # Make the bsuboutfile and bsuberrfile names

    my $newbsuboutfile = "$splitdir/$stub.$num.bout";
    my $newbsuberrfile = "$splitdir/$stub.$num.berr";

    # Make the outputfile name
    my $newoutfile = "$splitdir/$stub.$num.out";

    # Make the new bsub filename

    my $newbsubfile = "$splitdir/$stub.$num.bsub";

    # MAke te new job name

    my $newbsubjobname = "$stub.$num";

    # Replace the various strings in the bsub string 
    
    my $newbsubstr = $bsubstr;

    $newbsubstr =~ s/\<infile\>/$file/;
    $newbsubstr =~ s/\<outfile\>/$newoutfile/;
    $newbsubstr =~ s/\<bsuboutfile\>/$newbsuboutfile/;
    $newbsubstr =~ s/\<bsuberrfile\>/$newbsuberrfile/;
    $newbsubstr =~ s/\<bsubjobname\>/$newbsubjobname/;

    print "New bsubstr\b$newbsubstr\n";


    # Write to the bsub jobfilename in the output dir

    my $newfh = new FileHandle();
    $newfh->open(">$newbsubfile");

    print $newfh $newbsubstr;

    $newfh->close();

    # If we're submitting then submit the job and get the jobid

    my $jobid;

    if ($submit) {

	my $tmpstr =  `bsub < $newbsubfile`;

	if ($tmpstr =~ /Job +<(\d+)>/) {
	    $jobid = $1;
	} else {
	    print "Error submitting job for $file\n";
	}

	print "Submitted $jobid\n";
    }

    # Write the job filename to the jobcluster filename (and the jobid if we have it)

    print $jobclusterfh "$newbsubfile\t$jobid\n";

}

$jobclusterfh->close();

sub read_bsubfile {
    my ($bsubfile,$infile,$outfile) = @_;

    if (! -e $bsubfile) { 
	print "ERROR: Input bsub file [$bsubfile] doesn't exist.  Can't split\n";
	help(1);
    }

    my $infh = new FileHandle();
    $infh->open("<$bsubfile") || die "Can't open input file [$bsubfile]\n";
    
    my %bsubdata;
    
    while (my $line = <$infh>) {
	chomp $line;

	if ($line =~ /\#BSUB +(.*)/) {

	    my @f = split(' ',$1,2);

	    if ($#f == 1) {

		my $arg = $f[0];
		my $val = $f[1];

		if ($arg eq "-o") {
		    
		    $line =~ s/$val/\<bsuboutfile\>/;
		    $bsubdata{'bsuboutfile'} = $val;

		} elsif ($arg eq "-e") {

		    $line =~ s/$val/\<bsuberrfile\>/;
		    $bsubdata{'bsuberrfile'} = $val;

		} elsif ($arg eq "-J") {

		    $line =~ s/$val/\<bsubjobname\>/;
		    $bsubdata{'bsubjobname'} = $val;

		} 
	    }
	}

	
	if ($line =~ /$infile/) {

	    $line =~ s/$infile/\<infile\>/;
	    $bsubdata{'infile'} = $infile;
	} 

	if ($line =~ /$outfile/) {
	    $bsubdata{'outfile'} = $outfile;
	    $line =~ s/$outfile/\<outfile\>/;
	}

	$bsubdata{'bsubstr'} .= $line . "\n";
    }

    my $error = 0;

    if (!$bsubdata{'infile'}) { 
	print "ERROR: No input file [$infile] found in bsub file $bsubfile\n";
	$error++;
    }
    if (!$bsubdata{'outfile'}) { 
	print "ERROR: No output file [$outfile] found in bsub file $bsubfile\n";
	$error++;
    }
    if (!$bsubdata{'bsuboutfile'}) { 
	print "ERROR: No bsub output file [$bsuboutfile] found in bsub file $bsubfile\n";
	$error++;
    }
    if (!$bsubdata{'bsuberrfile'}) { 
	print "ERROR: No bsub error file [$bsuberrfile] found in bsub file $bsubfile\n";
	$error++;
    }

    if ($error) {
	die "ERROR: There are [$error] errors in the bsub file. Can't proceed\n";
    }
    return \%bsubdata;
}
	
sub split_fasta {

    my ($infile,$stub,$chunk,$outdir) = @_;

    if (! -e $infile) { 
	print "ERROR: Input fasta file [$infile] doesn't exist.  Can't split\n";
	help(1);
    }
    
    my $infh = new FileHandle();
    $infh->open("<$infile") || die "Can't open input file [$infile]\n";


    my $count = 0;
    
    my @seqs;
    my @ids;
    my @outfiles;

    while (<$infh>) {
	chomp;
	
	if (/^>(.*)/) {
	    my $tmpid = $1;
	    
	    if (scalar(@ids) == $chunk) {
		my $newoutfile = writeSeqs(\@ids,\@seqs,$count,$chunk,$outdir,$stub);
		
		push(@outfiles,$newoutfile);

		undef @ids;
		undef @seqs;
	    }
	    
	    $count++;
	    
	    push(@ids,$tmpid);
	} else {
	    $seqs[$#ids] .= $_;
	}
    }

    my $newoutfile  = writeSeqs(\@ids,\@seqs,$count,$chunk,$outdir,$stub);
    
    push(@outfiles,$newoutfile);

    my %out;

    $out{'files'} = \@outfiles;

    return \%out;
}

sub writeSeqs {

    my ($ids,$seqs,$count,$chunk,$outdir,$stub) = @_;

    my @ids  = @$ids;
    my @seqs = @$seqs;

    my $ofh = new FileHandle();

    my $start = $count-scalar(@ids)+1;
    my $end   = $count;

    my $ofilename = $outdir . "/" . $stub . ".$start-$end.fa";

    print STDERR "Saving sequences $start - $end to $ofilename\n";


    $ofh->open(">$ofilename") || die "Couldn't open output file $ofilename\n";

    my $i = 0;
    while ($i < scalar(@ids)) {
	my $seq = $seqs[$i];
	my $id  = $ids[$i];
	
	$seq =~ s/(.{70})/$1\n/g;
	$seq =~ s/\n$//;
	
	print $ofh ">$id\n$seq\n";
	
	$i++;
    }

    $ofh->close();

    return $ofilename;
}




    



sub help {
    my ($exit) = @_;


}
