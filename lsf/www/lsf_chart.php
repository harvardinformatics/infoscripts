<?php

$str = '
<html>
<head>
<script src="third-party/jquery-1.6.2.js" type="text/javascript"></script>
<script src="third-party/jquery-ui-1.8.15.custom.js" type="text/javascript"></script>
<script src="third-party/highcharts/js/highcharts.js" type="text/javascript"></script>
<script src="js/lsf_chart.js" type="text/javascript"></script>
<link rel="stylesheet" href="third-party/jquery-ui-1.8.15.custom.css" type="text/css"/>
</head>
<body>';

date_default_timezone_set ('America/New_York');

$str .="<div id=\"container\" user=\"jab\" class=\"lsf_chart ui-widget\" style=\"width: 100%; height: 400px\"></div>";
print $str;
print "</body></html>";

?>



