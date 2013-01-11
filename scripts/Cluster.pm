package Cluster;

use strict;

sub cluster_sorted_SAMFeatures {
    my ($f,$gap) = @_;

    my @clus;
    
    my $tmpend = 0;
    my $currclus;
    
    my @f = @$f;
    
  LINE: foreach my $fp (@f) {
      my $found = 0;

      #             -------------------
      #             ------

      #if (defined($currclus) && $fp->strand == $currclus->strand && !(($fp->start - $gap)> $currclus->end ||

      if (defined($currclus) &&  
	  !(($fp->{rstart} - $gap)  > $currclus->{end} ||
            ($fp->{rend}   + $gap)  < $currclus->{start})) {

	  push(@{$currclus->{features}},$fp);
    
	  $found = 1;
	  
	  if ($fp->{rend} > $tmpend) {
	      $tmpend = $fp->{rend};
	      $currclus->{end} = $tmpend;
	  }

	  next LINE;
	  
      }
      
      if ($found == 0) {
	  
	  my %newclus;
	  $newclus{features} = [];

	  push(@{$newclus{features}},$fp);
	  
	  push(@clus,\%newclus);

	  $tmpend   = $fp->{rend};
	  $newclus{start} = $fp->{rstart};
	  $newclus{end}   = $fp->{rend};
	  $newclus{rname} = $fp->{rname};

	  $currclus = \%newclus;
      }
  }
  return @clus;
}


1;
