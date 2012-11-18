#!/usr/bin/perl
$| = 1;

use strict;


my $seqlen  = shift;
my $mutprob = shift;
my $errprob = shift;
my $numseqs = shift;


# loop over number of transcripts

# choose a read start position 1 - tlen-rlen

# find read end position

# does it overlap an exon boundary?

my $i = 0;
my %seqs;

my $origseq;
my @bases;

$bases[0] = 'a';
$bases[1] = 'c';
$bases[2] = 'g';
$bases[3] = 't';

my $j = 0;
while ($j < $seqlen) {
    my $basenum = int(rand(4));

    $origseq .= $bases[$basenum];
    $j++;
}

print "Original sequence is $origseq\n";

while ($i < $numseqs) {

    my $j = 0;

    my $newseq = $origseq;
    my $mutcount = 0;
    my @mutpos;
    my @errpos;
    my $mutbase;
    my $errbase;
    while ($j < $seqlen) {

	($mutbase,$newseq) = mutate_base($newseq,$j,$mutprob,0);
	($errbase,$newseq) = mutate_base($newseq,$j,$errprob,1);
	
	if ($mutbase ne "") {
	    push(@mutpos,$j);
	}
	if ($errbase ne "") {
	    push(@errpos,$j);
	}
	$j++;
    }
#    print "New seq $i $newseq ". scalar(@mutpos) . "\t" . join(",",@mutpos) . "\t" .scalar(@errpos) . "\t" . join(",",@errpos) ."\n";

    my $lcseq = $newseq;
    $lcseq =~ tr/A-Z/a-z/;

    push(@{$seqs{$lcseq}},$newseq);
    $i++;
}


#    print "Seq ". scalar(@{$seqs{$seq}}) . " " . $seq . "\n";

my $j = 0;

while ($j < $seqlen) {
    my %diffs;

    $diffs{'a'} = 0;
    $diffs{'c'} = 0;

    $diffs{'g'} = 0;
    $diffs{'t'} = 0;




    foreach my $seq (keys %seqs) {
	my $k = 0;
	
	while ($k < scalar(@{$seqs{$seq}})) {
	    my $str1 = substr($seqs{$seq}[$k],$j,1);
	    my $str2 = substr($origseq,$j,1);

	    if ($str1 ne $str2) {
#		print "STring $str1 $str2\n";
		$diffs{$str1}++;
	    }
	    $k++;
	}
    }
    print "Pos $j diffs\t" .$diffs{'a'} . "\t" . $diffs{'c'} . "\t" .$diffs{'g'} . "\t" . $diffs{'t'} . "\n";
    
    $j++;
}

sub mutate_base {
    my ($seq,$pos,$prob,$ucase) = @_;

    my @bases;
    
    $bases[0] = 'a';
    $bases[1] = 'c';
    $bases[2] = 'g';
    $bases[3] = 't';
    
    my $mutate = int(rand(100));

    my $mutbase;

    if ($mutate < $prob) {

	my $origbase = substr($seq,$pos,1);
	my $mutnum  = int(rand(4));
	$mutbase = $bases[$mutnum];
	
	while ($mutbase eq substr($seq,$pos,1)) {
	    $mutnum = int(rand(4));
	    $mutbase = $bases[$mutnum];
	}

	if ($ucase == 1) {
	    $mutbase =~ tr/a-z/A-Z/;
	}
	my $nseq= $seq;
	$seq =~ s/(.{$pos})(.)/$1$mutbase/; 
#	print "N $seq\n";
    }
    #print "P $seq\n";
    return ($mutbase,$seq);
}
