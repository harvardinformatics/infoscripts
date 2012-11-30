<?php





$xml = getXMLFromFile($argv[1]);

$sample = $xml->sample['name'];
$user   = $xml->user;
$date   = $xml->date;
$db     = $xml->db;
$dir    = $xml->directory;
$enzyme  = $xml->enzyme;

print "Sample $sample\n";
print "User $user\n";
print "Date $date\n";
print "Db $db\n";
print "Dir $dir\n";
print "Enzyme $enzyme\n";

//$arr = xmlObjToArr($xml);
//print_r($arr);

parseXMLObj($xml);

function parseXMLObj($xml) {
  $name = $xml->getName();
  $val  = "";

  if ($name == "reference" || $name == "sequence" || $name == "filename" || $name == "db") {
    if (sizeof($xml->children()) == 0) {
      $val = (String)$xml;
      print " - Value object : $name - $val\n";
    } else {
      print "\n - Parent object : $name - children " . $xml->count() . "\n";
    }
  }

  $attr = (array)$xml->attributes();

  if ($name == "reference") {
    if (sizeof($attr) > 0) {
      print_r($attr);
    }
  }
  
  foreach ($xml->children() as $ch) {
    parseXMLObj($ch);
  }
}

  
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

function xmlObjToArr($obj) { 
  $namespace = $obj->getDocNamespaces(true); 
  $namespace[NULL] = NULL; 
        
  print "Namespace ".print_r($namespace,true)."\n";

  $children   = array(); 
  $attributes = array(); 
  $name       = strtolower((string)$obj->getName()); 
        
  $text = trim((string)$obj); 

  if( strlen($text) <= 0 ) { 
    $text = NULL; 
  } 
        
  // get info for all namespaces 
  if (is_object($obj)) { 
    foreach( $namespace as $ns=>$nsUrl ) { 
      
      // Attributes
      $objAttributes = $obj->attributes($ns, true); 

      foreach( $objAttributes as $attributeName => $attributeValue ) { 
	$attribName = strtolower(trim((string)$attributeName)); 
	$attribVal  = trim((string)$attributeValue); 

	if (!empty($ns)) { 
	  $attribName = $ns . ':' . $attribName; 
	} 
	$attributes[$attribName] = $attribVal; 
      } 
                
      // Children 
      $objChildren = $obj->children($ns, true); 

      foreach( $objChildren as $childName=>$child ) { 
	$childName = strtolower((string)$childName); 
	if ( !empty($ns) ) { 
	  $childName = $ns.':'.$childName; 
	} 
	$children[$childName][] = xmlObjToArr($child); 
      } 
    } 
  } 
  
  return array( 
	       'name'=>$name, 
	       'text'=>$text, 
	       'attributes'=>$attributes, 
	       'children'=>$children 
		); 
}

?>