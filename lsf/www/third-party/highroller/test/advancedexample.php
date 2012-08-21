<?php
/**
 * Author: jmac
 * Date: 9/21/11
 * Time: 8:02 PM
 * Desc: HighRoller Advanced Chart Example
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

// HighRoller: sample data for customized HighRoller Multi-series Line Chart
for($i = 0; $i <= 50; $i++){
  $chartData[0][] = rand(4000,8000);
  $chartData[1][] = rand(5000,15000);
  $chartData[2][] = rand(250,4000);
  $categories[$i] = 'Label-' . $i;
}

// HighRoller: create multiple Series Data objects and add name, color and data to each
$series1 = new HighRollerSeriesData();
$series1->addName('Finance')->addColor('#ff9900')->addData($chartData[0]);
$series2 = new HighRollerSeriesData();
$series2->addName('Google')->addColor('#0099ff')->addData($chartData[1]);
$series3 = new HighRollerSeriesData();
$series3->addName('Apple')->addColor('#00cc00')->addData($chartData[2]);
$linechart = new HighRollerLineChart();
$linechart->title->text = "Most Popular Topics";
$linechart->title->align = "left";
$linechart->title->floating = true;
$linechart->title->style->font = '18px Metrophobic, Arial, sans-serif';
$linechart->title->style->color = '#0099ff';
$linechart->title->x = 20;
$linechart->title->y = 20;
$linechart->chart->renderTo = 'linechart';
$linechart->chart->width = 900;
$linechart->chart->height = 300;
$linechart->chart->marginTop = 60;
$linechart->chart->marginLeft = 90;
$linechart->chart->marginRight = 30;
$linechart->chart->marginBottom = 110;
$linechart->chart->spacingRight = 10;
$linechart->chart->spacingBottom = 15;
$linechart->chart->spacingLeft = 0;
$linechart->chart->backgroundColor->linearGradient = array(0,0,0,300);
$linechart->chart->backgroundColor->stops = array(array(0,'rgb(217, 217, 217)'),array(1,'rgb(255, 255, 255)'));
$linechart->chart->alignTicks = false;
$linechart->legend->enabled = true;
$linechart->legend->layout = 'horizontal';
$linechart->legend->align = 'center';
$linechart->legend->verticalAlign = 'bottom';
$linechart->legend->itemStyle = array('color' => '#222');
$linechart->legend->backgroundColor->linearGradient = array(0,0,0,25);
$linechart->legend->backgroundColor->stops = array(array(0,'rgb(217, 217, 217)'),array(1,'rgb(255, 255, 255)'));
$linechart->tooltip->formatter = new HighRollerFormatter(); // TOOLTIP FORMATTER
$linechart->tooltip->backgroundColor->linearGradient = array(0,0,0,50);
$linechart->tooltip->backgroundColor->stops = array(array(0,'rgb(217, 217, 217)'),array(1,'rgb(255, 255, 255)'));
$linechart->plotOptions->line->pointStart = strtotime('-30 day') * 1000;
$linechart->plotOptions->line->pointInterval = 24 * 3600 * 1000; // one day
$linechart->xAxis->type = 'datetime';
$linechart->xAxis->tickInterval = $linechart->plotOptions->line->pointInterval;
$linechart->xAxis->startOnTick = true;
$linechart->xAxis->tickmarkPlacement = 'on';
$linechart->xAxis->tickLength = 10;
$linechart->xAxis->minorTickLength = 5;
$linechart->xAxis->labels->align = 'right';
$linechart->xAxis->labels->step = 2;
$linechart->xAxis->labels->rotation = -35;
$linechart->xAxis->labels->x = 5;
$linechart->xAxis->labels->y = 20;
$linechart->xAxis->dataLabels->formatter = new HighRollerFormatter();
$linechart->yAxis->labels->formatter = new HighRollerFormatter();
$linechart->yAxis->min = 0;
$linechart->yAxis->maxPadding = 0.2;
$linechart->yAxis->endOnTick = true;
$linechart->yAxis->minorGridLineWidth = 0;
$linechart->yAxis->minorTickInterval = 'auto';
$linechart->yAxis->minorTickLength = 1;
$linechart->yAxis->tickLength = 2;
$linechart->yAxis->minorTickWidth = 1;
$linechart->yAxis->title->text = 'Pageviews';
$linechart->yAxis->title->align = 'high';
$linechart->yAxis->title->style->font = '14px Metrophobic, Arial, sans-serif';
$linechart->yAxis->title->rotation = 0;
$linechart->yAxis->title->x = 60  ;
$linechart->yAxis->title->y = -10;
$linechart->yAxis->plotLines = array( array('color' => '#808080', 'width' => 1, 'value' => 0 ));
$linechart->addSeries($series1);
$linechart->addSeries($series2);
$linechart->addSeries($series3);
$linechart->enableAutoStep();
?>

<head>
<!-- jQuery 1.6.1 -->
<script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
<!-- HighRoller: set the location of Highcharts library -->
<?php echo HighRoller::setHighChartsLocation("_assets/highcharts/highcharts.js");?>
<?php echo HighRoller::setHighChartsThemeLocation("_assets/highcharts/themes/highroller.js");?>
</head>

<body>
<!-- HighRoller: linechart div container -->
<div id="linechart"></div>
<script type="text/javascript">

  // example of how to define a tooltip formatter in a highcharts chart using using highroller
  var myChartOptions = <?php echo $linechart->getChartOptionsObject()?>

  // define your own formatter for tooltip
  myChartOptions.tooltip.formatter = function() {
    return '<b>' + this.series.name + '</b><br/>' +
        Highcharts.dateFormat('%b %e', this.x) + ': ' + Highcharts.numberFormat(this.y, 0, ',') + ' views';
  };

  // define your own formatter for xAxis.labels
  myChartOptions.xAxis.labels.formatter = function() {
    var newDate = new Date(this.value);
    return Highcharts.dateFormat('%b %e', this.value);
  };

  // define your own formatter for yAxis.labels
  myChartOptions.yAxis.labels.formatter = function() {
    return Highcharts.numberFormat(this.value, '', ',');
  };

  $(document).ready(function(){
    <?php echo $linechart->renderChartOptionsObject('myChartOptions')?>
  });

</script>

<!--  FOOTER -->
<?php require_once('footer.php');?>

</body>
