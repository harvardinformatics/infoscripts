<?php
$file      = null;
$elename   = 'name';
$substring = 'metazoa';
$help      = false;

$options = getopt("f:n:s:h");

if (isset($options["f"])) { $infile          = $options["f"]; }
if (isset($options["n"])) { $elename         = $options["n"]; }
if (isset($options["s"])) { $substring       = $options["s"]; }
if (isset($options["h"])) { $help             = true;          }

if ($help) {
  help(true);
}

if (!is_file($infile)) {
  print "ERROR: No input file given\n";
  help(1);
}
if ($elename == "") {
  print "ERROR: No element name given\n";
  help(1);
}
if ($substring == "") {
  print "ERROR: No filter string given\n";
  help(1);
}

$xml = getXMLFromFile($infile);

print "<interpro_matches>\n";
foreach ($xml->interpro_matches as $match) {
  foreach ($match->protein as $prot) {
    foreach ($prot->interpro as $in) {

      $attr = $in->attributes();
      $name = $attr[$elename];
      if (preg_match("/".$substring."/",$name)) {
	print $prot->asXML();
      }
    }
  }
}
print "</interpro_matches>\n";

function getXMLFromFile($infile) {

  $xmlstr = getXMLStrFromFile($infile);
  $xmlstr = preg_replace("/<xmlns.*xsd>/", "", $xmlstr);
  $xmlstr = preg_replace("/<xmlns.*xsi>/", "", $xmlstr);

  $xml = new SimpleXMLElement($xmlstr);

  return $xml;
}

function getXMLStrFromFile($infile) {
  $xmlstr = null;

  if (preg_match("/.bz2$/", $infile)) {
    $xmlstr = shell_exec("bunzip2 -c $infile");
  } else if (preg_match("/.gz$/", $infile)) {
    $xmlstr = shell_exec("gunzip -c $infile");
  } else {
    $xmlstr = file_get_contents($infile);
  }

  return $xmlstr;
}

function help($exit) {

  print "\nUsage:  php parseInterproXML.php -f <xmlfile> -n <element name> -s <filter string>\n";
  print "\nParses an interproscan xml file and extracts all interpro match elements by filtering both on element type and content\n";
  print "\n -f  :   Interproscan xml file\n";
  print " -n  : Name of element to filter on [default = name]\n";
  print " -s  : Match only elements with substring [default= metazoa]\n";
  print "\n";
  print "Example:   php parseInterproXML.php -f myfile.xml -n name -s fungi\n";
  print "\n";

  if ($exit) {
    exit();
  }
}
?>