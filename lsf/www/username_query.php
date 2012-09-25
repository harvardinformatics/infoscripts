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
if (isset($_REQUEST['labgroup'])) {
  $group = $_REQUEST['labgroup'];
} else {
  $group = "";
}

date_default_timezone_set ('America/New_York');


if ($group == "") {
  $qstr = 'select user_name from user';
  
  if ($str != "") {
    $qstr .= " where user_name like '%$str%'";
  }
  
  $qstr .= " order by user_name limit 200";
  
} else {
  $qstr = 'select user_name from user, labgroup, user_group where ';

  if ($str != "") {
    $qstr .= " user_name like '%$str%' and";
  }

  $qstr .= " user.user_internal_id = user_group.user_internal_id and user_group.labgroup_internal_id = labgroup.labgroup_internal_id and labgroup.labgroup_name = '$group' ";

  $qstr .= " order by user_name limit 200";
  
}

  error_log($qstr . "\n",3,"/tmp/log"); 
  
  $rawdata =  mysql_magic($qstr);
  
  foreach ($rawdata as $data) {
    print $data['user_name'] . "\n";
  }

?>
