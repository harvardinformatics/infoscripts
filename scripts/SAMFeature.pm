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

    my %cigdata    = SAMFeature::parseCigar($samf->{cigar});

    $samf->{cigdata} = \%cigdata;

    return $samf;
}

sub getLength {
    my ($self) = @_;

    my $match = $self->{cigdata}{match};
    my $insert = $self->{cigdata}{insert};
    my $delete = $self->{cigdata}{delete};
}

sub parseCigar {
    my ($str) = @_;

    my @c = split(//,$str);
    
    my $i = 0;
    
    my $start;
    my $end;
    my $match  = 0;
    my $insert = 0;
    my $delete = 0;

    my $num = "";
    my $qend;

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
	    } elsif ($ch eq "D") {
		$delete += $num;
		$qend   += $num;
	    } else {
		print "ERROR: Unknown cigar char [$ch]\n";
	    }
	    $num = "";
	}
	$i++;

    }

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
