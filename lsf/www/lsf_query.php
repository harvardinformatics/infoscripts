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
$sqlpass="xxxxxx";
$sqlbase="lsf2";

$user = "";
$groupby = "";
$labgroup = "";

if (isset($_REQUEST['user'])) {
  $user   = $_REQUEST['user'];
} else {
  $user = '';
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
//error_log("Group by $groupby\n",3,"/tmp/log");
foreach ($_REQUEST as $key => $val) {
	error_log("Key $key : $val\n",3,"/tmp/log");
}
date_default_timezone_set ('America/New_York');
//$groupby = 'wday';
//$labgroup = 'Giribet_Lab';
//$user = "";
$userstr = "";

if ($labgroup == "" && $user == "") {

  if ($groupby == "month") {
    $qstr = "select submit_month,submit_year,count(*) count from finish_job group by 2,1";

    $rawdata = mysql_magic($qstr);
    
    foreach ($rawdata as $data) {
      $month = $data['submit_month']+1;
      $year  = 1900 + (int)($data['submit_year']);
      
      $date = new DateTime("$year-$month-01");
      
      print $date->format('Y-m-d H:i:s') . "\t" . (int)($data['count']) . "\n";
    }
 } else if ($groupby == "mday") {
    $qstr = "select submit_mday,submit_month,submit_year,count(*) count from finish_job group by 3,2,1";

    $rawdata = mysql_magic($qstr);
    
    foreach ($rawdata as $data) {
    
      $day   = $data['submit_mday'];
      $month = $data['submit_month']+1;
      $year  = 1900 + (int)($data['submit_year']);
      
      $date = new DateTime("$year-$month-$day");
      
      print $date->format('Y-m-d H:i:s') . "\t" . (int)($data['count']) . "\n";
    }
 } else if ($groupby == "wday") {
    $qstr = "select submit_wday,count(*) count from finish_job group by submit_wday";

    $rawdata = mysql_magic($qstr);
    
    foreach ($rawdata as $data) {
    
      $day   = $data['submit_wday']+1;
      
      print "$day\t" . (int)($data['count']) . "\n";
    }
} else if ($groupby == "hour") {

    $qstr = "select submit_hour,count(*) count from finish_job group by submit_hour";

    $rawdata = mysql_magic($qstr);
    
    foreach ($rawdata as $data) {
    
      $day   = $data['submit_hour']+1;
      
      print "$day\t" . (int)($data['count']) . "\n";
    }
 }
} else if ($labgroup != ""  && $user == "") {

  $users = get_users_by_labgroup($labgroup);

  $userstr = join(",",$users);

  $userstr = "(".$userstr.")";

  if ($groupby == "month") {
    $qstr = "select submit_month,submit_year,
                        count(*) count
			from finish_job
 			    where user_internal_id in $userstr 
                            group by 2,1";
    $rawdata = mysql_magic($qstr);
    
    foreach ($rawdata as $data) {
      $month = $data['submit_month']+1;
      $year  = 1900 + (int)($data['submit_year']);
      
      $date = new DateTime("$year-$month-01");
      
      print $date->format('Y-m-d H:i:s') . "\t" . (int)($data['count']) . "\n";
    }

  } else if ($groupby == "mday"){
    $qstr = "select submit_mday,submit_month,submit_year,
                        count(*) count
			from finish_job
 			    where user_internal_id in $userstr 
                            group by 3,2,1";
    $rawdata = mysql_magic($qstr);
    
    foreach ($rawdata as $data) {
      $day   = $data['submit_mday'];
      $month = $data['submit_month']+1;
      $year  = 1900 + (int)($data['submit_year']);

      $date = new DateTime("$year-$month-$day");
      
      print $date->format('Y-m-d H:i:s') . "\t" . (int)($data['count']) . "\n";
      
    }
  } else if ($groupby == "wday") {
    $qstr = "select submit_wday,
                        count(*) count
                        from finish_job
                            where user_internal_id in $userstr group by submit_wday ";
    $rawdata = mysql_magic($qstr);
    
    foreach ($rawdata as $data) {
      $day   = $data['submit_wday']+1;
      
      print $day . "\t" . (int)($data['count']) . "\n";
    }     
   } else if ($groupby == "hour") {
    $qstr = "select submit_hour,
                        count(*) count
                        from finish_job
                            where user_internal_id in $userstr group by submit_hour ";
    $rawdata = mysql_magic($qstr);
    
    foreach ($rawdata as $data) {
      $hour   = $data['submit_hour']+1;
      
      print $hour . "\t" . (int)($data['count']) . "\n";
      
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
   } else if ($groupby == "wday") {
    $qstr = "select submit_wday,
                        count(*) count
                        from finish_job,user
 			    where finish_job.user_internal_id = user.user_internal_id $userstr group by submit_wday";
    $rawdata = mysql_magic($qstr);
    
    foreach ($rawdata as $data) {
      $day   = $data['submit_wday']+1;
      
      print $day . "\t" . (int)($data['count']) . "\n";
    }     
   } else if ($groupby == "hour") {
    $qstr = "select submit_hour,
                        count(*) count
                        from finish_job,user
 			where finish_job.user_internal_id = user.user_internal_id $userstr group by submit_hour";
    $rawdata = mysql_magic($qstr);
    
    foreach ($rawdata as $data) {
      $hour   = $data['submit_hour'];
      
      print $hour . "\t" . (int)($data['count']) . "\n";
      
    }
  }
}

function get_users_by_labgroup($group) {

  $qstr = "select user_internal_id from labgroup,user_group where labgroup.labgroup_name = '$group' and labgroup.labgroup_internal_id = user_group.labgroup_internal_id";
  $rows = mysql_magic($qstr);

  $groups = array();

  foreach ($rows as $row) {
    $groups[] = $row['user_internal_id'];
  }

  return $groups;
}


?>
