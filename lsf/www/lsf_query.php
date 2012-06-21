<?php
// Examples
# $nb_affected = mysql_magic('delete from users');
# $nb = mysql_magic('select count(*) from users');
# $one_row = mysql_magic('select * from users limit 1');
# $all_rows = mysql_magic('select * from users where name = ?', 'John');
#$id = mysql_magic('insert into users(name,rank) values(?,?)', 'Vincent', 3);

require_once("third-party/MysqlMagic.php");

$sqlhost="localhost";
$sqluser="root";
$sqlpass="98lsf76";
$sqlbase="lsf2";

$user = "";
$groupby = "";
$labgroup = "";

if (isset($_REQUEST['user'])) {
  $user   = $_REQUEST['user'];
} else {
  $user = 'jab';
}

if (isset($_REQUEST['groupby'])) {
   $groupby = $_REQUEST['groupby'];
} else {
   $groupby = "month";
}
if (isset($_REQUEST['labgroup'])) {
   $labgroup = $_REQUEST['labgroup'];
} else {
  $labgroup = "";
}

error_log("Group by $groupby\n",3,"/tmp/log");

foreach ($_REQUEST as $key => $val) {
	error_log("Key $key : $val\n",3,"/tmp/log");
}

date_default_timezone_set ('America/New_York');
$userstr = "";

if (0 && $labgroup != ""  && $user == "") {

  if ($groupby == "month") {
    $qstr = "select submit_month,submit_year,
                        count(*) count
			from finish_job,user ,user_group,labgroup
 			    where user.user_internal_id = finish_job.user_internal_id
                            and   user_group.user_internal_id = user.user_internal_id
                            and   user_group.labgroup_internal_id = labgroup.labgroup_internal_id
                            and   labgroup.labgroup_name = '$labgroup'
                            group by 2,1";
    $rawdata = mysql_magic($qstr);
    
    foreach ($rawdata as $data) {
      $month = $data['submit_month']+1;
      $year  = 1900 + (int)($data['submit_year']);
      
      $date = new DateTime("$year-$month-01");
      
      print $date->format('Y-m-d H:i:s') . "\t" . (int)($data['count']) . "\n";
    }

  } else {
    $qstr = "select submit_mday,submit_month,submit_year,
                        count(*) count
			from finish_job,user ,user_group,labgroup
 			    where user.user_internal_id = finish_job.user_internal_id
                            and   user_group.user_internal_id = user.user_internal_id
                            and   user_group.labgroup_internal_id = labgroup.labgroup_internal_id
                            and   labgroup.labgroup_name = '$labgroup'
                            group by 3,2,1";
    $rawdata = mysql_magic($qstr);
    
    foreach ($rawdata as $data) {
      $day   = $data['submit_mday'];
      $month = $data['submit_month']+1;
      $year  = 1900 + (int)($data['submit_year']);

      $date = new DateTime("$year-$month-$day");
      
      print $date->format('Y-m-d H:i:s') . "\t" . (int)($data['count']) . "\n";
      
    }
  }
} else {
  
  if (isset($user) && $user != "") {
    $userstr = "and user.user_name = '$user'";
  }
  
  if ($groupby == "month") {
    
    $qstr = 'select submit_month,submit_year,
                        count(*) count
			from finish_job,user 
 			    where finish_job.user_internal_id = user.user_internal_id '.$userstr.'
                            group by 2,1';
    
    $rawdata = mysql_magic($qstr);
    
    foreach ($rawdata as $data) {
      $month = $data['submit_month']+1;
      $year  = 1900 + (int)($data['submit_year']);
      
      $date = new DateTime("$year-$month-01");
      
      print $date->format('Y-m-d H:i:s') . "\t" . (int)($data['count']) . "\n";
    }
  } else if ($groupby == "mday") {
    
    $qstr = 'select submit_mday,submit_month,submit_year,
                        count(*) count
			from finish_job,user 
 			    where finish_job.user_internal_id = user.user_internal_id '.$userstr .'
                            group by 3,2,1';
    
    
    
    $rawdata = mysql_magic($qstr);
    
    foreach ($rawdata as $data) {
      $day   = $data['submit_mday'];
      $month = $data['submit_month']+1;
      $year  = 1900 + (int)($data['submit_year']);
      
      $date = new DateTime("$year-$month-$day");
      
      print $date->format('Y-m-d H:i:s') . "\t" . (int)($data['count']) . "\n";
    }
  }
}

?>
