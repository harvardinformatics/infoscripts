package SAMFeature;

use vars qw(@ISA);
use strict;

sub new {
    my $class = shift;
    my $self  = {};

    bless $self, $class;
    return $self;
}

sub newFromString {
    my ($str) = @_;

    chomp($str);

    my $samf = new SAMFeature();

    my @f = split(/\t/,$str);

    $samf->{qname}  = $f[0];
    $samf->{bflag}  = $f[1];
    $samf->{rname}  = $f[2];
    $samf->{rstart} = $f[3];
    $samf->{qual}   = $f[4];
    $samf->{cigar}  = $f[5];
    $samf->{seq}    = $f[9];
    
    $samf->{line}   = $str;

    my %cigdata    = $samf->parseCigar($samf->{cigar});

    $samf->{cigdata} = \%cigdata;

    return $samf;
}

sub getLength {
    my ($self) = @_;

    my $match = $self->{cigdata}{match};
    my $insert = $self->{cigdata}{insert};
    my $delete = $self->{cigdata}{delete};
}

#For example:
#RefPos:     1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19
#Reference:  C  C  A  T  A  C  T  G  A  A  C  T  G  A  C  T  A  A  C
#Read: ACTAGAATGGCT
#Aligning these two:
#RefPos:     1  2  3  4  5  6  7     8  9 10 11 12 13 14 15 16 17 18 19
#Reference:  C  C  A  T  A  C  T     G  A  A  C  T  G  A  C  T  A  A  C
#Read:                   A  C  T  A  G  A  A     T  G  G  C  T
#With the alignment above, you get:
#POS: 5
#CIGAR: 3M1I3M1D5M


# 1I means insert in the reference
# 1D means insert in the query.

sub getAlignment {
    my ($self,$rff,$qff) = @_;


    my $rid    = $self->{rname}.":".$self->{rstart}."-".$self->{rend};
    my $qid    = $self->{qname}.":".$self->{qstart}."-".$self->{qend};

    print "Getting region $rid : $qid\n";

    my $rseq   = $qff->getRegion($self->{rname}, {
	'start' => $self->{rstart},
	'end'   => $self->{rend}
				 });

    my $qseq   = $qff->getRegion($self->{qname},{
	'start' => $self->{qstart},
	'end'   => $self->{qend}
				 });


    print substr($qseq,0,100);
    print substr($rseq,0,100);

}
sub parseCigar {
    my ($self,$str) = @_;

    my @c = split(//,$str);
    
    my $i = 0;
    
    my $start;
    my $end;
    my $match  = 0;
    my $insert = 0;
    my $delete = 0;

    my $rend   = $self->{rstart};
    my $qend;

    my $num    = "";

    while ($i <= $#c) {
	my $ch = $c[$i];
	if ($ch =~ /\d/) {
	    $num .= $ch;

	} else {
	    #print "ENd num $num\n";
	    if ($ch eq "S") {
		if ($i == $#c) {
		    $end = $num;
		} else {
		    $start = $num;
		    $qend  = $num;
		}
	    } elsif ($ch eq "M") {
		$match += $num;
		$qend  += $num;
	    } elsif ($ch eq "I") {
		$insert += $num;
		$qend   += $num;
	    } elsif ($ch eq "D") {
		$delete += $num;
		$rend   += $num;
	    } else {
		print "ERROR: Unknown cigar char [$ch]\n";
	    }
	    $num = "";
	}
	$i++;

    }
    $self->{qstart} = $start;
    $self->{qend} = $qend;
    $self->{rend} = $rend;

    my %out;

    $out{'start'}  = $start;
    $out{'qend'}   = $qend;
    $out{'end'}    = $end;
    $out{'match'}  = $match;
    $out{'insert'} = $insert;
    $out{'delete'} = $delete;

    return %out;
}

1;
