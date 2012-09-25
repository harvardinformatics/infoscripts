<?php
// Examples
# $nb_affected = mysql_magic('delete from users');
# $nb = mysql_magic('select count(*) from users');
# $one_row = mysql_magic('select * from users limit 1');
# $all_rows = mysql_magic('select * from users where name = ?', 'John');
#$id = mysql_magic('insert into users(name,rank) values(?,?)', 'Vincent', 3);

require_once("third-party/MysqlMagic.php");

$sqlhost="localhost";
$sqluser="mysql";
$sqlpass="xxxxxxx";
$sqlbase="lsf2";

if (isset($_REQUEST['str'])) {
  $str = $_REQUEST['str'];
} else {
  $str = "";
}

date_default_timezone_set ('America/New_York');


$qstr = 'select labgroup_name from labgroup';

if ($str != "") {
  $qstr .= " where labgroup_name like '%$str%'";
}
  
$qstr .= " order by labgroup_name limit 200";
  
$rawdata = mysql_magic($qstr);
  
foreach ($rawdata as $data) {
  print $data['labgroup_name'] . "\n";
}

?>
