<?php


//@HD     VN:1.0  SO:unsorted
//@SQ     SN:scaffold_6   LN:8822787
//Au_s32705       16      scaffold_6      524     255     7638H13M122M3D56M2I9M2D13M11I63M167H   *       0       0       TGGTACAATGCTTAACTAGAA


// SAM fields    queryname  

//Col Field Type Regexp/Range Brief description
//1 QNAME String [!-?A-~]f1,255g                Query template NAME                     ok
//2 FLAG  Int [0,2^16-1]                        bitwise FLAG
//3 RNAME String \*|[!-()+-<>-~][!-~]*          Reference sequence NAME                 ok
//4 POS Int [0,2^29-1]                          1-based leftmost mapping POSition       ok - ref mapping pos
//5 MAPQ Int [0,2^8-1]                          MAPping Quality                            
//6 CIGAR String \*|([0-9]+[MIDNSHPX=])+        CIGAR string                            ~ok
//7 RNEXT String \*|=|[!-()+-<>-~][!-~]*        Ref. name of the mate/next segment      ok
//8 PNEXT Int [0,2^29-1]                        Position of the mate/next segment       ok
//9 TLEN Int [-2^29+1,2^29-1]                   observed Template LENgth
//10 SEQ String \*|[A-Za-z=.]+                  segment SEQuence
//11 QUAL String [!-~]+                         ASCII of Phred-scaled base QUALity+33


// Flags

// 0x1 template having multiple segments in sequencing         +1
// 0x2 each segment properly aligned according to the aligner  +2
// 0x4 segment unmapped                                        +4
// 0x8 next segment in the template unmapped                   +8
// 0x10 SEQ being reverse complemented                         +16
// 0x20 SEQ of the next segment in the template being reversed +32
// 0x40 the rst segment in the template                      +64
// 0x80 the last segment in the template                       +128
// 0x100 secondary alignment                                   +256
// 0x200 not passing quality controls                          +512
// 0x400 PCR or optical duplicate                              +1024

// Most common 0/16  forward/reversed.


$reffile   = null;
$samfile   = null;

$options = getopt("q:t:h");

if (isset($options["q"])) { $samfile          = $options["q"]; }
if (isset($options["t"])) { $reffile          = $options["t"]; }
if (isset($options["h"])) { $help             = true;          }

if (!is_file($samfile)) {
  print "No samfile input [-q <samfile>]\n";
  exit();
}
if (!is_file($reffile)) {
  print "No reffile input\n";
  exit();
}

$tmpref = file_get_contents($reffile);

$f = preg_split("/\n/",$tmpref);
$header = array_shift($f);

print "Reference header $header\n";
$refstr = "";

foreach ($f as $line) {
  $refstr .= $line;
}
print "Length of refstr " . strlen($refstr) . "\n";

$queries = array();

$fh = fopen($samfile,"r");
while ($line = trim(fgets($fh))) {

  if (preg_match("/^@/",$line)) {
    continue;
  }
  $f = preg_split("/\t/",$line);

  $qname  = $f[0];
  $bflag  = $f[1];
  $rname  = $f[2];
  $mpos   = $f[3];
  $mqual  = $f[4];
  $cigar  = $f[5];
  $seq    = $f[9];

  if (preg_match("/^(\d+)H/",$cigar,$match)) {
    $qpos = $match[1];

  }

  $mats = array();

  $mats['H'] = 0;
  $mats['M'] = 0;
  $mats['I'] = 0;
  $mats['D'] = 0;

  if (preg_match_all("/(\d+)(\S)/",$cigar,$match)) {
        $i = 0;
        while($i < sizeof($match[1])) {
          $mats[$match[2][$i]] += $match[1][$i];
          $i++;
        } 
  }
  
  if (!isset($queries[$qname])) {
    $queries[$qname] = array();
  }
    
  $hit = array();
  
  $hit['qstart'] = $qpos;
  $hit['len']    = strlen($seq);
  $hit['qend']   = $qpos+strlen($seq)-1;
  $hit['tname']  = $rname;
  $hit['tstart'] = $mpos;
  $hit['tend']   = $mpos+strlen($seq)-1;
  $hit['seq']    = $seq;
  $hit['sam']    = $line;
 
  $hit['match']  = $mats['M']; 
  $hit['indel']  = $mats['I'] + $mats['D'];
  $hit['indelfrac'] = intval(100*$hit['indel']/$hit['match']);

  if ($bflag == 16) {
    $hit['strand'] = -1;
  } else if ($bflag == 0) {
    $hit['strand'] = 1;
  } else {
    print "ERROR: Unparsed flag [$bflag]\n";
    exit();
  }
  
  $queries[$qname][] = $hit;
}

foreach ($queries as $qname => $hits) {
  
  $fhits = array();
  $rhits = array();

  foreach ($hits as $hit) {
    if ($hit['strand'] == 1) {
      $fhits[] = $hit;
    } else {
      $rhits[] = $hit;
    }
  }

  $newfhits = array_sort($fhits,"tstart","ASC");
  $newrhits = array_sort($rhits,"tstart","ASC");

  $fclus = array();
  $rclus = array();

  foreach ($newfhits as $hit) {

    $found = 0;

    foreach ($fclus as $k => $fc) {
      $cstart = $fc['clus_start'];
      $cend   = $fc['clus_end'];

      $qstart = $fc['query_start'];
      $qend   = $fc['query_end'];

      if ($hit['tstart'] > $cend &&  $hit['qstart'] > $qend) {
	$fclus[$k]['hits'][] = $hit;
	
	$fclus[$k]['clus_end'] = $hit['tend'];
	$fclus[$k]['query_end'] = $hit['qend'];

        $fclus[$k]['tlen']      = $fclus[$k]['clus_end'] - $fclus[$k]['clus_start']+1;
        $fclus[$k]['hitlen']    += strlen($hit['seq']);
	$found = 1;
      }
    }
    if ($found == 0) {
      $newclus = array();
      $newclus['hits']        = array();
      $newclus['hits'][]      = $hit;
      $newclus['clus_start']  = $hit['tstart'];
      $newclus['clus_end']    = $hit['tend'];
      $newclus['query_start'] = $hit['qstart'];
      $newclus['query_end']   = $hit['qend'];
      $newclus['tlen']        = $newclus['clus_end'] - $newclus['clus_start']+1;
      $newclus['hitlen']      = strlen($hit['seq']);
      $newclus['strand']      = 1; 
      $fclus[] = $newclus;
    }
  }

  foreach ($newrhits as $hit) {

    $found = 0;

    foreach ($rclus as $k=>$rc) {
      $cstart = $rc['clus_start'];
      $cend   = $rc['clus_end'];

      $qstart = $rc['query_start'];
      $qend   = $rc['query_end'];

      if ($hit['tstart'] > $cend &&  $qstart > $hit['qend']) {
        print "Adding\n";
	$rclus[$k]['hits'][] = $hit;
	
	$rclus[$k]['clus_end']  = $hit['tend'];
	$rclus[$k]['query_end'] = $hit['qend'];
        $rclus[$k]['tlen']      = $rclus[$k]['clus_end'] - $rclus[$k]['clus_start']+1;
        $rclus[$k]['hitlen']   += strlen($hit['seq']);
	$found = 1;
      }
    }
    if ($found == 0) {
      $newclus = array();
      $newclus['hits']        = array();
      $newclus['hits'][]      = $hit;
      $newclus['clus_start']  = $hit['tstart'];
      $newclus['clus_end']    = $hit['tend'];
      $newclus['query_start'] = $hit['qstart'];
      $newclus['query_end']   = $hit['qend'];
      
      $newclus['tlen']        = $newclus['clus_end'] - $newclus['clus_start']+1;
      $newclus['hitlen']      = strlen($hit['seq']);
      $newclus['strand']      = -1;
      $rclus[] = $newclus;

    }
  }


  $allclus = array_merge($fclus,$rclus);
  $allclus = array_sort($allclus,'hitlen','DESC');

  $i = 0;
  foreach ($allclus as $clus) {

    print "Cluster\t$i\t$qname\t". $clus['strand'] . "\t" . $clus['hitlen']."\t".sizeof($clus['hits']) . "\t" . $clus['clus_start'] . "\t" . $clus['clus_end'] . "\t" . $clus['query_start'] . "\t" . $clus['query_end'] . "\n";

    foreach ($clus['hits'] as $hit) {
      print "$i\t" .strlen($hit['seq']) . "\t" . $hit['indelfrac'] . "\t".$hit['sam']."\n";
    }
    $i++;
  }
}

function array_sort($arr, $sortkey, $order="ASC") {

  $out     = array();
  $sortarr = array();

  // Input array

  //  $arr[0] = array [ 'id'    => "pog",
  //                    'start' => 823,
  //                    'end'   => 456]
  //  $arr[1] = array [ 'id'    => "pog2",
  //                    'start' => 848,
  //                    'end'   => 999]
  //  $arr[2] = array [ 'id'    => "pog3",
  //                    'start' => 483,
  //                    'end'   => 564]
  //  $arr[3] = array [ 'id'    => "pog4",
  //                    'start' => 23,
  //                    'end'   => 99]


  // This will sort the array by the start value
  // $sortarr = array_sort($arr,"start","ASC")

  foreach ($arr as $key => $val) {

    if (is_array($val)) {

      foreach ($val as $key2 => $val2) {
        if ($key2 == $sortkey) {      // e.g. key2 == 'start'
          $sortarr[$key] = $val2;     //  $sortarr[0] == 823
        }
      }
    } else {
      $sortarr[$key] = $val;
    }
  }

  if ($order == "ASC") {
    asort($sortarr);                  // sort the array containing the start values
  } else if ($order == "DESC") {
      arsort($sortarr);
    }

  foreach ($sortarr as $key => $val) {
    $out[$key] = $arr[$key];
  }

  return $out;
}

  
?>

