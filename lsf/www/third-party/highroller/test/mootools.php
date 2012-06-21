<?php
/**
 * Author: jmac
 * Date: 9/21/11
 * Time: 8:02 PM
 * Desc: HighRoller MooTools Test Suite
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
 
  require_once('_assets/HighRoller/HighRoller.php');
  require_once('_assets/HighRoller/HighRollerSeriesData.php');
  require_once('_assets/HighRoller/HighRollerLineChart.php');
  require_once('_assets/HighRoller/HighRollerSplineChart.php');
  require_once('_assets/HighRoller/HighRollerAreaChart.php');
  require_once('_assets/HighRoller/HighRollerAreaSplineChart.php');
  require_once('_assets/HighRoller/HighRollerBarChart.php');
  require_once('_assets/HighRoller/HighRollerColumnChart.php');
  require_once('_assets/HighRoller/HighRollerPieChart.php');
  require_once('_assets/HighRoller/HighRollerScatterChart.php');

  // SIMPLE ARRAY OF DATA FOR ALL CHART TYPES
  $chartData = array(
    array(
      'name' => 'my data',
      'data' => array(5324, 7534, 6234, 7234, 8251, 10324)
    )
  );

  // HighRoller: Line chart sample data
  $chartData = array(5324, 7534, 6234, 7234, 8251, 10324);

  // HighRoller: create and set Series data
  $series1 = new HighRollerSeriesData();
  $series1->addName('myData')->addData($chartData);

  // HIGHROLLER PIE CHART
  $piechart = new HighRollerPieChart();
  $piechart->chart->renderTo = 'piechart';
  $piechart->title->text = 'Pie Chart';
  $piechart->addSeries($series1);

  // HIGHROLLER BAR CHART
  $barchart = new HighRollerBarChart();
  $barchart->chart->renderTo = 'barchart';
  $barchart->title->text = 'Bar Chart';
  $barchart->addSeries($series1);

  // HIGHROLLER COLUMN CHART
  $columnchart = new HighRollerColumnChart();
  $columnchart->chart->renderTo = 'columnchart';
  $columnchart->title->text = 'Column Chart';
  $columnchart->addSeries($series1);

  // HighRoller: create and modify Line chart
  $linechart = new HighRollerLineChart();
  $linechart->chart->renderTo = 'linechart';
  $linechart->title->text = 'Line Chart';
  $linechart->addSeries($series1);

  // HIGHROLLER SPLINE CHART
  $splinechart = new HighRollerSplineChart();
  $splinechart->chart->renderTo = 'splinechart';
  $splinechart->title->text = 'Spline Chart';
  $splinechart->addSeries($series1);

  // HIGHROLLER AREA CHART
  $areachart = new HighRollerAreaChart();
  $areachart->chart->renderTo = 'areachart';
  $areachart->title->text = 'Area Chart';
  $areachart->addSeries($series1);

  // HIGHROLLER AREA SPLINE CHART
  $areasplinechart = new HighRollerAreaSplineChart();
  $areasplinechart->chart->renderTo = 'areasplinechart';
  $areasplinechart->title->text = 'Area Spline Chart';
  $areasplinechart->addSeries($series1);

  // HIGHROLLER SCATTER CHART
  $scatterchart = new HighRollerScatterChart();
  $scatterchart->chart->renderTo = 'scatterchart';
  $scatterchart->title->text = 'Scatter Plot Chart';
  $scatterchart->addSeries($series1);

?>

<html>
<head>

  <title>HighRoller | MooTools Test Suite</title>

  <link href='http://fonts.googleapis.com/css?family=Open+Sans&v1' rel='stylesheet' type='text/css'>
  <link href='_assets/jquery.snippet.css' rel='stylesheet' type='text/css'>
  <link href='_assets/highroller.css' rel='stylesheet' type='text/css'>

  <!--  MooTools 1.3.0 -->
  <script src="https://ajax.googleapis.com/ajax/libs/mootools/1.3.0/mootools-yui-compressed.js" type="text/javascript"></script>
  <script src="_assets/highcharts/adapters/mootools-adapter.js" type="text/javascript"></script>

  <?php echo HighRoller::setHighChartsLocation("_assets/highcharts/highcharts.js");?>

</head>

<div class="main">

  <img class="logo" src="_assets/dice.png"><h1>HighRoller: Chart Gallery using MooTools</h1>

  <!--  NAVIGATION -->
  <?php require_once('nav.php');?>

  <div class="page">

    <h5>MooTools Test Suite</h5>
    <p>
      <ul>
        <li>This page renders the 8 default chart types provided by Highcharts using HighRoller and <strong>MooTools.</strong></li>
        <li>The charts are rendered using identical sample data along with the default sizes, styles and options as defined by HighRoller.</li>
      </ul>
    </p>

    <h5>Pass Criteria</h5>
    <p>
      <ul>
        <li>All 8 charts load.</li>
        <li>All 8 charts render the appropriate graphics demonstrating data was received.</li>
        <li>No javascript errors are thrown in your console.</li>
      </ul>

      <p>Once all MooTools test cases pass, move onto the <a href="/jquery.php">jQuery</a> test suite...</p>
      <p>Once all Test Suites pass, you can assume your custom build of HighRoller (.zip located the /releases folder) is stable for use/release.</p>
    </p>

    <div class="clear"></div>

    <!-- HighRoller: chart gallery -->

    <div id="piechart" style="display: block; float: left; width:90%; margin-bottom: 20px;"></div>
    <div class="clear"></div>

    <div id="barchart" style="display: block; float: left; width:90%; margin-bottom: 20px;"></div>
    <div class="clear"></div>

    <div id="columnchart" style="display: block; float: left; width:90%; margin-bottom: 20px;"></div>
    <div class="clear"></div>

    <div id="linechart" style="display: block; float: left; width:90%; margin-bottom: 20px;"></div>
    <div class="clear"></div>

    <div id="splinechart" style="display: block; float: left; width:90%; margin-bottom: 20px;"></div>
    <div class="clear"></div>

    <div id="areachart" style="display: block; float: left; width:90%; margin-bottom: 20px;"></div>
    <div class="clear"></div>

    <div id="areasplinechart" style="display: block; float: left; width:90%; margin-bottom: 20px;"></div>
    <div class="clear"></div>

    <div id="scatterchart" style="display: block; float: left; width:90%; margin-bottom: 20px;"></div>
    <div class="clear"></div>

    <script type="text/javascript">
      // highroller: simplest example of rendering each basic highcharts chart
      <?php echo $piechart->renderChart('mootools');?>
      <?php echo $barchart->renderChart('mootools');?>
      <?php echo $columnchart->renderChart('mootools');?>
      <?php echo $linechart->renderChart('mootools');?>
      <?php echo $splinechart->renderChart('mootools');?>
      <?php echo $areachart->renderChart('mootools');?>
      <?php echo $areasplinechart->renderChart('mootools');?>
      <?php echo $scatterchart->renderChart('mootools');?>
      $(document).ready(function(){
        $("pre.htmlCode").snippet("html",{style: "the", showNum: false});
        $("pre.phpCode").snippet("php",{style: "the", showNum: false});
      });
    </script>

  </div>

  <!--  FOOTER -->
  <?php require_once('footer.php');?>

</div>