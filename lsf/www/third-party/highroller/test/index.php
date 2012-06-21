<?php
/**
 * Author: jmac
 * Date: 9/21/11
 * Time: 8:02 PM
 * Desc: HighRoller Index
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

  // HighRoller: Line chart sample data
  $chartData = array(5324, 7534, 6234, 7234, 8251, 10324);

  // HighRoller: create and modify Line chart
  $linechart = new HighRollerLineChart();
  $linechart->chart->renderTo = 'linechart';
  $linechart->title->text = 'jQuery Line Chart';

  // HighRoller: create and add Series 1 data
  $series1 = new HighRollerSeriesData();
  $series1->addName('myData')->addData($chartData);

  // HighRoller: add series data to chart
  $linechart->addSeries($series1);

  // HighRoller: create and modify Line chart
  $linechart2 = new HighRollerLineChart();
  $linechart2->chart->renderTo = 'linechart2';
  $linechart2->title->text = 'MooTools Line Chart';

  // HighRoller: create and add Series 1 data
  $series1 = new HighRollerSeriesData();
  $series1->addName('myData')->addData($chartData);

  // HighRoller: add series data to chart
  $linechart2->addSeries($series1);

?>

<head>
  <title>HighRoller | Smoke Test</title>
  <link href='http://fonts.googleapis.com/css?family=Open+Sans&v1' rel='stylesheet' type='text/css'>
  <link href='_assets/jquery.snippet.css' rel='stylesheet' type='text/css'>
  <link href='_assets/highroller.css' rel='stylesheet' type='text/css'>

  <!-- jQuery 1.6.1 -->
  <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
  <script type="text/javascript" src="_assets/jquery.snippet.js"></script>

  <!--  MooTools 1.3.0 -->
  <script src="https://ajax.googleapis.com/ajax/libs/mootools/1.3.0/mootools-yui-compressed.js" type="text/javascript"></script>
  <script src="_assets/highcharts/adapters/mootools-adapter.js" type="text/javascript"></script>

  <!-- HighRoller: set Highcharts location -->
  <?php echo HighRoller::setHighChartsLocation("_assets/highcharts/highcharts.js");?>
</head>

<div class="main">

  <img class="logo" src="_assets/dice.png"><h1>HighRoller: Smoke Test</h1>

  <!--  NAVIGATION -->
  <?php require_once('nav.php');?>

  <div class="page">

    <h5>Smoke Test Case</h5>
    <p>
      <ul>
        <li>This page attempts to load 2 default Highcharts line charts using HighRoller.</li>
        <li>One is rendered using <strong>jQuery</strong> and the other using <strong>MooTools</strong>.</li>
        <li>The charts are rendered using identical sample data along with the default sizes, styles and options as defined by HighRoller.</li>
      </ul>
    </p>

    <h5>Pass Criteria</h5>
    <p>
      <ul>
        <li>Both charts load.</li>
        <li>Both charts render a line demonstrating data was received.</li>
        <li>Both charts render identical data.</li>
        <li>No javascript errors are thrown in your console.</li>
      </ul>

      <p>Once these charts are good, move onto the <a href="/jquery.php">jQuery</a> and <a href="/mootools.php">MooTools</a> test suites...</p>
      <p>Once all Test Suites pass, you can assume your custom build of HighRoller (.zip located the /releases folder) is stable for use/release.</p>
    </p>

    <div class="clear"></div>

    <div id="linechart" style="display: block; float: left; width:90%; margin-bottom: 20px;"></div>
    <div class="clear"></div>

    <div id="linechart2" style="display: block; float: left; width:90%; margin-bottom: 20px;"></div>
    <div class="clear"></div>

    <script type="text/javascript">
      // simplest example of rendering a highcharts chart using highroller
      <?php echo $linechart->renderChart();?>
      <?php echo $linechart2->renderChart('mootools');?>
      $(document).ready(function(){
        $("pre.htmlCode").snippet("html",{style: "the", showNum: false});
        $("pre.phpCode").snippet("php",{style: "the", showNum: false});
        $("pre.rawCode").snippet("php",{style: "the", showNum: true});
      })
    </script>

  </div>

  <!--  FOOTER -->
  <?php require_once('footer.php');?>

</div>
