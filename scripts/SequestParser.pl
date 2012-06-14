#!/usr/bin/perl

$| = 1;

use strict;
use FileHandle;
use Getopt::Long;

my $infile;
my $outfile;

my $infh = \*STDIN;
my $outfh = \*STDOUT;

my $help;

GetOptions("-infile:s"  => \$infile,
           "-outfile:s" => \$outfile,
           "-help"      => \$help);

if ($help) {
	help(1);
}

if ($infile) {
	$infh = new FileHandle();
	$infh->open("<$infile") || die "Can't open input file [$infile]\n";
}
if ($outfile) {
	$outfh = new FileHandle();
	$outfh->open(">$outfile") || die "Can't open output file [$outfile]\n";
}

my @spectra;

my %headers;


#S       15613   15613   2       30072   camd14_Thread-1 1099.56995      82089.30        0.2552  6554568
#M       1       2       1099.55645      0.0000  1.1641  2.766776424512354       11      18      S.RLMSSTPGGPP.R U
#L       Reverse_Reverse_sp|Q2JHP5|MURD_SYNJB    172     ASS.RLMSSTPGGPP.RIG
#L       sp|Q2JHP5|MURD_SYNJB    172     ASS.RLMSSTPGGPP.RIG
#M       2       3       1098.57627      0.0657  1.0877  2.469677711916534       10      16      V.RRSSTGLQGH.Q  U
#L       Reverse_sp|Q91ZR4|NEK8_MOUSE    93      RSV.RRSSTGLQGH.QNS
#L       Reverse_sp|Q91ZR4|NEK8_MOUSE    93      RSV.RRSSTGLQGH.QNS
#M       3       4       1098.56907      0.1484  0.9914  2.0953777972907264      9       14      S.SRRSIADFF.D   U
#L       Reverse_sp|Q8XW19|GLNE_RALSO    400     LYS.SRRSIADFF.DLF
#L       Reverse_sp|Q8XW19|GLNE_RALSO    400     LYS.SRRSIADFF.DLF
#M       4       7       1097.56979      0.1488  0.9909  2.0934223623642008      10      17      I.SRELGGAHVTA.L U
#L       Reverse_Reverse_sp|Q3K3S6|Y153_STRA1    155     IPI.SRELGGAHVTA.LAS
#L       Reverse_Reverse_sp|Q8E294|Y103_STRA5    155     IPI.SRELGGAHVTA.LAS
#L       Reverse_Reverse_sp|Q8E7Q2|Y102_STRA3    155     IPI.SRELGGAHVTA.LAS
#L       sp|Q3K3S6|Y153_STRA1    155     IPI.SRELGGAHVTA.LAS
#L       sp|Q8E294|Y103_STRA5    155     IPI.SRELGGAHVTA.LAS
#L       sp|Q8E7Q2|Y102_STRA3    155     IPI.SRELGGAHVTA.LAS
#M       5       9       1099.57822      0.1766  0.9585  1.9675771605190646      9       15      S.DKKGAYFSIA.S  U
#L       Reverse_sp|Q9PHW6|FLID_CAMJE    435     GNS.DKKGAYFSIA.SDE
#L       Reverse_sp|Q9PHW6|FLID_CAMJE    435     GNS.DKKGAYFSIA.SDE
#M       114     1       1099.59282      0.7315  0.3126  -0.5430625312177356     10      15      A.VTCPVAKPRE.I  U
#L       Reverse_Reverse_sp|P25680|TXW10_NAJNI   43      GCA.VTCPVAKPRE.IVE
#L       sp|P25680|TXW10_NAJNI   43      GCA.VTCPVAKPRE.IVE

printf $outfh "%10s\t%50s\t%30s\t%7s\t%7s\t%15s\t%15s\t","Unique","Sequence","Filename","XCorr","DeltCN","Confidence","Calculated M+H+";
printf $outfh "%15s\t%10s\t%10s\t%15s\t","Observed M+H+","Mass Diff","Prob","Total Intensity";
printf $outfh "%5s\t%10s\t%10s\t%s\n","Sp Rank","Ion Proportion","Redundancy","Proteins";

while (<$infh>) {

	chomp;

	if (/^H/) {
		my @f = split(/\t/,$_,3);

		$headers{$f[1]} = $f[2];

	} elsif (/^S/) {
		my @f = split(/\t/,$_);

		my $start_spectrum = $f[1];
		my $end_spectrum   = $f[2];
		my $charge_state   = $f[3];
		my $process_time   = $f[4];
		my $server         = $f[5];
		my $observed_mass  = $f[6];
		my $totintensity   = $f[7];
		my $lowest_sp      = $f[8];
		my $num_sequences  = $f[9];


		my $xcorr_rank;
		my $sp_rank;
		my $calculated_mass;
		my $deltcn;
		my $xcorr;
		my $sp;
		my $matching_ions;
		my $predicted_ions;
		my $sequence;
		my $status;

		my @proteins;
		my @descs;

		while ((my $line = <$infh>) ne "\n") {

			if ($line =~ /^M/) {

				if (scalar(@proteins) > 0) {
					my $filename = $headers{'SpectrumFile'};
					$filename =~ s/^\/.*\///;
	 				my $protstr = join(", ",@proteins);
                                        $protstr =~ s/^, //;
					printf $outfh "%10s\t%50s\t%30s\t%7.4f\t%7.4f\t%15s\t%15.5f\t","NA",$sequence,$filename,$xcorr,$deltcn,"NA",$calculated_mass;
					printf $outfh "%15.5f\t%10.5f\t%10s\t%15.2f\t",$observed_mass,($calculated_mass-$observed_mass),"NA",$totintensity;
					printf $outfh "%5d\t%10s\t%10s\t%s\n",$sp_rank,"NA","NA",$protstr;

					@proteins = undef;
					@descs    = undef;
				}	
				 chomp($line);
				 my @f2 = split(/\t/,$line);

				 $xcorr_rank      = $f2[1];
				 $sp_rank         = $f2[2];
				 $calculated_mass = $f2[3];
				 $deltcn          = $f2[4];
				 $xcorr           = $f2[5];
				 $sp              = $f2[6];
				 $matching_ions   = $f2[7];
				 $predicted_ions  = $f2[8];
				 $sequence        = $f2[9];
				 $status          = $f2[10];

			} elsif ($line =~ /^L/) {
				chomp($line);

				my @f3 = split(/\t/,$line,3);

				push(@proteins,$f3[1]);
				push(@descs,$f3[2]);
			}
		}


		
	}
}
$outfh->close();
$infh->close();
sub help {
	my ($exit) = @_;

	print "\nUsage:  SequestParser.pl [-infile <infile>] [-outfile <outfile>]\n";
	print "\n-infile    : input file in sqt format (default stdin)";
	print "\n-outfile   : output file (default stout\n\n";

	if ($exit) {
		exit(0);
	}
}
