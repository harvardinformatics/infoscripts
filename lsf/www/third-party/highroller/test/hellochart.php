<?php
/**
 * Author: jmac
 * Date: 9/21/11
 * Time: 8:02 PM
 * Desc: HighRoller Hello Chart Raw
 *
 * Licensed to Gravity.com under one or more contributor license agreements.
 * See the NOTICE file distributed with this work for additional information
 * regarding copyright ownership.  Gravity.com licenses this file to you use
 * under the Apache License, Version 2.0 (the License); you may not this
 * file except in compliance with the License.  You may obtain a copy of the
 * License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an AS IS BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

// HighRoller: include class files
require_once('_assets/HighRoller/HighRoller.php');
require_once('_assets/HighRoller/HighRollerSeriesData.php');
require_once('_assets/HighRoller/HighRollerLineChart.php');

// HighRoller: sample data
$chartData = array(5324, 7534, 6234, 7234, 8251, 10324);

// HighRoller: create a new line chart object and modify some basic properties
$linechart = new HighRollerLineChart();
$linechart->chart->renderTo = 'linechart';
$linechart->title->text = 'Line Chart';
$linechart->yAxis->title->text = 'Total';

// HighRoller: create new series data object and hydrate with precious data
$series1 = new HighRollerSeriesData();
$series1->addName('myData')->addData($chartData);

// HighRoller: add series data object to chart object
$linechart->addSeries($series1);
?>

<head>

<!-- jQuery 1.6.1 -->
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>

<!-- HighRoller: set the location of Highcharts library -->
<?php echo HighRoller::setHighChartsLocation("_assets/highcharts/highcharts.js");?>
</head>

<body>
<!-- HighRoller: linechart div container -->
<div id="linechart" style="width: 64%;"></div>

<!-- HighRoller: renderChart() method generates new Highcarts object inside script tag -->
<script type="text/javascript">
  <?php echo $linechart->renderChart();?>
</script>

<!--  FOOTER -->
<?php require_once('footer.php');?>

</body>