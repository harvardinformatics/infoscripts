package BSearch;

use strict;

my $fsize;

sub search_file {
    my ($file,$coord,$field_no,$field_sep)  = @_;

    return search_file_pos($file,$coord,$field_no,$field_sep,0);
}

sub search_file_pos {
    my ($file,$coord,$field_no,$field_sep,$field_pos) = @_;

    $coord = substr($coord,$field_pos);

    my $fh = new FileHandle;

    $fh->open("<$file");

    sysseek($fh, 0, 2);                   # Goto end of file

    my $filesize = BSearch::systell($fh); # Read size of file

    $fsize = $filesize;

    $fh= BSearch::findpos($fh,0,$filesize,$coord,$field_no,$field_sep,$field_pos);

    return $fh;

}

sub findpos { 
    my ($fh,$startpos,$endpos,$coord,$field_no,$field_sep,$field_pos) = @_;

    my $halfpos   = int(($endpos+$startpos)/2);

    my ($fh2,$halfstart,$halfend) = find_coord($fh,$halfpos,$field_no,$field_sep,$field_pos);

    #print "Coordinates at the halfway position are $halfstart - $halfend\n";
    

    if ($endpos - $startpos <= 1 || ($fsize - $startpos) < 5) {
	return $fh;
    }

    if ($coord >= $halfstart && $coord <= $halfend) {
	#print "Found pos $fh\n";
	#Back up one line here
	$fh = backup_line($fh2);
	return $fh;
    } elsif ($halfstart > $coord) {

	#print "Recursing in lower half\n";

	findpos($fh,$startpos,$halfpos,$coord,$field_no,$field_sep,$field_pos);

	
    } elsif ($halfend < $coord) {

	#print "Recursing in upper half\n";

	findpos($fh,$halfpos,$endpos,$coord,$field_no,$field_sep,$field_pos);
    }
}


sub find_coord {
    my ($fh,$halfpos,$field_no,$field_sep,$field_pos) = @_;

    if ($field_sep eq "") {
	$field_sep = "\t";
    }
    sysseek($fh,$halfpos,0);

    $fh = backup_line($fh);

    my $startcoord;
    my $endcoord;
    my $alnpos;

    my $pos = systell($fh);
    my $prepos = $pos;

    my $c;
    my $line;

    while ($c ne "\n") {

	sysseek($fh,$pos,0);
	sysread($fh,$c,1);
	$line .= $c;
	$pos++;
    }
    #print "Found pos $pos line $line\n";

    my @f = split(/$field_sep/,$line);

    my $field = $f[$field_no];
    $field = substr($field,$field_pos);
    #print "FFF :@f:\n";
    sysseek($fh,$prepos,0);

    #return ($fh,$f[$field_no],$f[$field_no+1]);
    return ($fh,$field,$field);

}


sub systell {
    use Fcntl 'SEEK_CUR';
    sysseek($_[0], 0, SEEK_CUR);
}

sub backup_line {
    my ($fh) = @_;

    my $pos = systell($fh);

    #print "Backup pos $pos\n";

    my $c;

    #$pos--;

    #sysseek($fh,$pos,0);
    sysread($fh,$c,1);

    while ($c ne "\n" && $pos >= 0) {
	$pos--;
	sysseek($fh,$pos,0);
	sysread($fh,$c,1);
    }

    $pos++;

    sysseek($fh,$pos,0);


    return $fh;
}


sub kmerpi_gff {
    my ($chr,$start,$end,$kmer) = @_;

    my $dir = "/ahg/scr3/kmer_sweep/full_overlap/$kmer/";

    my $size = $kmer;
    $size =~ s/mer//;

    $size = $size/2;
    
    my $filestart = $start;
    my $fileend   = $end;
    
    $filestart = int($start/1000000) * 1000000;
    $fileend   = $filestart + 999999;
 
    my @gff;

    my %vals;
    while ($filestart < $end) {
	my $tmpchr = $chr;
	my $gfffile = $dir . $chr . "/" . $chr . "_$filestart-$fileend.pi.$kmer";
	
	#print "File $gfffile\n";
	
	if (! -e $gfffile) {
	    print "ERROR: No pi file $gfffile\n";
	    return;
	}
	
	my $fh = BSearch::search_file($gfffile,$start-$size,1,"\t");
	
	my $line;
	
	my $offset = $kmer*12/4;
	

	my $chunk = 1;#int(($end-$start+1)/1000);
	
	if ($chunk < 1) { $chunk = 1;}
	
	$chunk = 1;

	my $done = 0;
	my $prev;
	


	while ($line = <$fh>) {

	    chomp($line);
	    
	    my @f = split(/\t/,$line);
	    
	    my $tmp;

	    if (!($f[1] > $end    ||
		  $f[2] < $start )
		) {
		#print $line . "\n";
		#print "Start " . $f[1] . "\t" . $f[2] . "\t" . $start . "\t" . $end . "\n";		
		$tmp = $f[0];
		my $shift = 0;

		if ($shift) {
		    $f[1] = $f[1] - $start + $size + 1;
		    $f[2] = $f[2] - $start + $size + 1;
		} else {
		    $f[1] = $f[1] + $size;
		}

		my $val = $f[4];
		
		$vals{$f[1]-$start}{pi} = $val;
	    }
	    $prev = int($f[1]/$chunk);
	    
	    if ($f[1] > $end) {
		last;
	    }
	    
	}
	
	$filestart += 1000000;
	$fileend   += 1000000;
    }
    
    
    return \%vals;
}
    

sub get_pi {
    my ($chr,$start,$end) = @_;

    my $dir = "/ahg/scr4/30mammals/eutherian/pi/";

    my %vals;

    my $filestart = $start;
    my $fileend   = $end;
    
    $filestart = int($start/1000000) * 1000000;
    $fileend   = $filestart + 999999;
    
    while ($filestart < $end) {
	my $tmpchr = $chr;
	$tmpchr =~ s/chr//;
	
	my $gfffile = $dir . $tmpchr . "/" . $chr . "_$filestart-$fileend.pi";
	
	#print "File $gfffile\n";
	
	if (! -e $gfffile) {
	    print "ERROR: No pi file $gfffile\n";
	    return;
	}
	
#	print "STArt $chr $start $filestart\n";
	my $fh = BSearch::search_file($gfffile,$start,0,"\t");
    
	my $line;
	my $prev; 
	
	while ($line = <$fh>) {
	#    print $line;
	    chomp($line);
	    
	    my ($tmpstart,$a,$c,$g,$t,$score,$tree,$dum)= split(/\t/,$line);
	    
	    $tmpstart += 1;
	    	    
	    if ($tmpstart >= $start && 
		$tmpstart <= $end) {
		my $shift = 0;
		if ($shift) {
		    $tmpstart = $tmpstart -  $start;
		}
#	    print "$chr\t30mamm.pi\t30mamm.pi\t$tmpstart\t$tmpstart\t$score\t1\t.\t${a}\t${t}\t${c}\t${g}\n";
		#print "$chr\tpivals\tpivals\t$tmpstart\t$tmpstart\t$score\t1\t.pival\n";
		$vals{$tmpstart-$start}{pi} = $score;
	    }
	    if ($tmpstart > $end) {
		last;
	    }
	    
    }
	
	$filestart += 1000000;
	$fileend   += 1000000;
    }
    
    return \%vals;
}
    
sub get_coding_exons {
    my ($chr,$start,$end) = @_;

    #my $file = "/ahg/scr3/global_stats/EnsRefVeg.coding.gff.startsort";
    my $file = "/ahg/scr3/genes/genes.051509/Homo_sapiens.NCBI36.54.coding_phase.gff.startsort";
    my %vals;

	
    if (! -e $file) {
	print "ERROR: No exon  file $file\n";
	return;
    }

    my $fh = BSearch::search_file($file,$start,3,"\t");
    
    my $line;

    my @exons;
	
    while ($line = <$fh>) {

	chomp($line);
	
	my $gff = Factory::FeatureFactory::readGFFFeature($line);
	#print $gff->to_string  . "\n";
	if ($gff->chr eq $chr &&
	    !($gff->end < $start ||
	      $gff->start > $end)) {

	    push(@exons,$gff);
	}
	
	if ($gff->start > $end) {
	    last;
	}

    }

    $fh->close;

    return @exons;
}

    

    
    

sub get_fullpi {
    my ($chr,$start,$end) = @_;

    my $dir = "/ahg/scr4/30mammals/eutherian/pi/";

    my %vals;

    my $filestart = $start;
    my $fileend   = $end;
    
    $filestart = int($start/1000000) * 1000000;
    $fileend   = $filestart + 999999;

    my @pis;    

    while ($filestart < $end) {
	my $tmpchr = $chr;
	$tmpchr =~ s/chr//;
	
	my $gfffile = $dir . $tmpchr . "/" . $chr . "_$filestart-$fileend.pi";
	
#	print "File $gfffile\n";
	
	if (! -e $gfffile) {
	    print "ERROR: No pi file $gfffile\n";
	    return;
	}
	#print "Start $start\n";

	my $fh = BSearch::search_file($gfffile,$start,0,"\t");
    
	my $line;
	my $prev; 
	

	while ($line = <$fh>) {
	    
	    chomp($line);
	    
	    #print $line . "\n";
	    my ($tmpstart,$a,$c,$g,$t,$score,$tree,$dum)= split(/\t/,$line);
	    
	    $tmpstart += 1;
	    	    
	    if ($tmpstart >= $start && 
		$tmpstart <= $end) {

		my $shift = 0;
		if ($shift) {
		    $tmpstart = $tmpstart -  $start;
		}
		#print "$chr\t30mamm.pi\t30mamm.pi\t$tmpstart\t$tmpstart\t$score\t1\t.\t${a}\t${t}\t${c}\t${g}\n";
		#print "$chr\tpivals\tpivals\t$tmpstart\t$tmpstart\t$score\t1\t.pival\n";
		$vals{$tmpstart-$start}{pi} = $score;
		$vals{$tmpstart-$start}{a} = $a;
		$vals{$tmpstart-$start}{c} = $c;
		$vals{$tmpstart-$start}{g} = $g;
		$vals{$tmpstart-$start}{t} = $t;
		$vals{$tmpstart-$start}{branch} = $tree;
		push(@pis,$a);
		push(@pis,$t);
		push(@pis,$c);
		push(@pis,$g);

	    }
	    if ($tmpstart > $end) {
		last;
	    }
	    
    }
	
	$filestart += 1000000;
	$fileend   += 1000000;
    }
    
    return (\%vals,\@pis);
}
    





1;
