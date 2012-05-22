#!/usr/bin/perl

$| = 1;

use strict;
use FileHandle;

use Data::Dumper;
use Getopt::Long;
use XML::LibXML;


my $infile;
my $outfile;
my $interpro2gofile;

my $help;

GetOptions("-infile:s"      => \$infile,
           "-outfile:s"     => \$outfile,
           "-interpro2go:s" => \$interpro2gofile,
	   "-help"          => \$help);


if ($help)  { help(1); }

my $interpro2go = {};

if ($interpro2gofile) {
  $interpro2go = read_interpro2go($interpro2gofile);
} 

my @infiles = parse_infiles($infile);

foreach my $file (@infiles) {

    eval {
	my $parser    = XML::LibXML->new();
	
	my $tree      = $parser->parse_file($file);
	my $root      = $tree->getDocumentElement;
	my @proteins  = $root->getElementsByTagName('protein');
	
	my $outfh = \*STDOUT;
	
	if ($outfile) {
	    $outfh = new FileHandle();
	    $outfh->open(">$outfile") || die "Can't open output file [$outfile] for writing";
	}
	
	foreach my $id (@proteins) {
	    
	    my $seqname = $id->getAttribute('id'); 
	    
	    my $frame   = $seqname; $frame  =~ s/.*_(\d)_(ORF\d+)$/$1/;
	    my $orf     = $seqname; $orf    =~ s/.*_(\d)_(ORF\d+)$/$2/;
	    
	    $seqname =~ s/_\d_ORF\d+$//;
	    
	    my @matches  = $id->getElementsByTagName('match');
	    
	    foreach my $match (@matches) {
		
		my $matchid   = $match->getAttribute('id');
		my $matchname = $match->getAttribute('name');
		my $matchdb   = $match->getAttribute('dbname');

		foreach my $loc ($match->getElementsByTagName('location')) {

		    my $start    = $loc->getAttribute('start');
		    my $end      = $loc->getAttribute('end');
		    my $score    = $loc->getAttribute('score');  
		    my $status   = $loc->getAttribute('status');  
		    my $evidence = $loc->getAttribute('evidence');  

		    print $outfh $seqname . "\t" . $matchdb . "\tinterpro\t$start\t$end\t$orf\t$score\t$frame\t$matchid\tTYPE:\tNAME:\tPARENT_ID:\tMATCHID:$matchid\tMATCHDB:$matchdb\tMATCHNAME:$matchname\tSTATUS:$status\tEVIDENCE:$evidence\t\n";

		}
	    }

	    my @interpro = $id->getElementsByTagName('interpro');

	    foreach my $interpro (@interpro) {

		my $id   = $interpro->getAttribute('id');
		my $type = $interpro->getAttribute('type');
		my $name = $interpro->getAttribute('name');

		my $parent_id = $interpro->getAttribute('parent_id');

		my @match = $interpro->getElementsByTagName('match');

		my $gostr = "";

		foreach my $goid (keys %{$interpro2go->{$id}}) {
		    $gostr .= $goid . " > ".$interpro2go->{$id}{$goid} . "; ";
		}

		$gostr =~ s/\; $//;

		foreach my $match (@match) {

		    my $matchid   = $match->getAttribute('id');
		    my $matchname = $match->getAttribute('name');
		    my $matchdb   = $match->getAttribute('dbname');

		    foreach my $loc ($match->getElementsByTagName('location')) {

			my $start    = $loc->getAttribute('start');
			my $end      = $loc->getAttribute('end');
			my $score    = $loc->getAttribute('score');  
			my $status   = $loc->getAttribute('status');  
			my $evidence = $loc->getAttribute('evidence');  

			print $outfh $seqname . "\t" . $matchdb . "\tinterpro\t$start\t$end\t$orf\t$score\t$frame\t$id\tTYPE:$type\tNAME:$name\tPARENT_ID:$parent_id\tMATCHID:$matchid\tMATCHDB:$matchdb\tMATCHNAME:$matchname\tSTATUS:$status\tEVIDENCE:$evidence\t$gostr\n";
		    }
		}

		my @children = $interpro->getElementsByTagName('child_list');

		foreach my $child (@children) {
		    foreach my $item ($child->getElementsByTagName('rel_ref')) {
			#   print "\tChild " . $item->getAttribute('ipr_ref') . "\n";
		    }
		}
		
		my @found_in = $interpro->getElementsByTagName('found_in');
		
		foreach my $found_in (@found_in) {
		    foreach my $item ($found_in->getElementsByTagName('rel_ref')) {
			#   print "\tFound in\t" . $item->getAttribute('ipr_ref') . "\n";
		    }
		}
	    }
	}
    };
    if ($@) {
	warn("WARNING: File $file not parsable");
    }
}

sub read_interpro2go {
   my ($file) = @_;

   #InterPro:IPR000003 Retinoid X receptor/HNF4 > GO:DNA binding ; GO:0003677
   #InterPro:IPR000003 Retinoid X receptor/HNF4 > GO:steroid hormone receptor activity ; GO:0003707
   #InterPro:IPR000003 Retinoid X receptor/HNF4 > GO:zinc ion binding ; GO:0008270
   #InterPro:IPR000003 Retinoid X receptor/HNF4 > GO:regulation of transcription, DNA-dependent ; GO:0006355


   my $interpro2go = {};

   my $fh = new FileHandle();

   $fh->open("<$file") || die "Can't read interpro2go file [$file]\n";

   while (<$fh>) {
      chomp;

      if (/^\!/) {
         next;
      }

      if (/InterPro:(\S+) (.*) > (GO:.*) ; (.*)/) {

        my $interproid   = $1;
        my $interprodesc = $2;
        my $godesc       = $3;
        my $goid         = $4;

        $interpro2go->{$interproid}{$goid}  = $godesc;
       
     }
  }
  $fh->close();
  return $interpro2go;
}

sub help {
    my ($exit) = @_;

    print "\nUsage:  Iprscan.pl -infile <infile or regexp> -outfile <outfile> [-interpro2go <interpro2gofile>] [-help]\n";
    print "\n";
    print "Takes the xml output from iprscan (using -format xml) and converts it into a tab delimited output.\n";
    print "If the interpro2go file is specified it will map all interpro ids into go terms (use -iprlookup -goterms\n";
    print "\n";
    print "Iprscan should be run with the following parameters:\n\n";
    print "iprscan -cli -i <myfile.fa> -o <myfile.xml> -format xml -iprlookup -goterms\n";
    print "\n";
    print "-infile      :   Either a single filename or a set of filenames \"myfile1, myfile2\" or a set of files \"myfile.*.iprscan\"\n";
    print "-outfile     :   The output file (default is stdout)\n";
    print "-interpro2go :   A file containing the interpro to go mapping (Obtained from www.geneontology.org/external2go/interpro2go\n";
    print "-help        :   This message\n\n";

    if ($exit) {
	exit(0);
    }
}
sub parse_infiles {
    my ($filestr) = @_;

    my $indir        =  `pwd`; chomp($indir);

    my @tmpfiles = split(/\,/,$filestr);
    my @infiles;


    foreach my $infile (@tmpfiles) {
	$infile       =~ s/ +$//;           # Trim whitespace
	$infile       =~ s/^ +//;           # Trim whitespace

	$infile       =~ s#\*#\.\*#;                 # Change wildcard * to .* 
	
	if ($infile =~ /^\/.*/) {
	    $indir   = $infile;
	    $indir   =~ s/^.*\///;
	}

	my $dh;

	opendir($dh, $indir) || die "Couldn't open directory [$indir]\n";
	
	while(my $file = readdir $dh) {
	    if ($file =~ /$infile/) {
		push(@infiles,$indir."/".$file);
	    }
	}
    
	closedir $dh;
    }

    return @infiles;
}
