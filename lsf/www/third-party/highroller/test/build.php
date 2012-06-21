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
  <title>HighRoller | Build How To</title>
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

  <img class="logo" src="_assets/dice.png" height="100px"><h1>HighRoller: Build and Test</h1>

  <!--  NAVIGATION -->
  <?php require_once('nav.php');?>

  <div class="page">

    <h4>How To Roll Your Own</h4>
    <p>HighRoller has a few handy developer features to help you create custom builds of HighRoller.  
      <h5>Developer Features:</h5>
      <ul>
        <li>Build Script - script for creating new releases.</li>
        <li>Test Area - mini-site for verifying your latest build is stable.</li>
        <li>Release Packaging - a .zip file is created for you.</li>
      </ul>
    </p>

    <h4>How To Build</h4>
    <p>This guide assumes you have bash and already modified the contents of the /src directory to your needs and are ready to roll your own HighRoller.
      <ul>
        <li>In a bash shell, 'cd' over to the /tools dir</li>
        <li>Execute the build script using a version argument (i.e. './build.sh 1.0.1').</li>
        <li>Done. You just created a new .zip in the /releases folder and moved a copy of this build into the /test/_assets folder for use by this Test Suite</li>
      </ul>
      <p><em>IMPORTANT NOTE:</em> Using the same build version ('1.0.1') when you execute the build.sh script will overwrite all existing files in the /build and /releases folders.</p>
    </p>

    <h4>How To Test</h4>
    <p>This guide assumes you have a web server running locally on your HighRoller build machine and that you already know how to setup a virtual host.
      <ul>
        <li>Name your web server vhost something simple like 'highroller' (or whatever you like).</li>
        <li>Point your web server vhost DocumentRoot to HighRoller's /test folder.</li>
        <li>Open up a browser and point it to 'highroller'.</li>
        <li>Done. You can now use HighRoller's Test Suite to verify your custom build.</li>
      </ul>
    </p>

    <h4>Caveats and Assumptions</h4>
    <p>
      <ul>
        <li>You have an adventurous attitude about technology and are curious about how the world works.</li>
        <li>Your environment is unix-based, has bash and you know at least some basic commands.</li>
        <li>You have previously setup virtual hosts in your web server.</li>
        <li>You are fluent in the PHP scripting language.</li>
        <li>You have previously used jQuery and/or MooTools in web applications.</li>
        <li>You have read Highcharts instructions for setting up HighCharts.</li>
        <li>You have read Highcharts or are familiar with the Highcharts API.</li>
        <li>You know how to test and debug web based applications.</li>
        <li>You know how to ask for help if you need it (just ask!).</li>
        <li>You do not have a gambling problem or intend to use HighRoller for wagering.</li>
      </ul>
    </p>

  </div>

  <!--  FOOTER -->
  <?php require_once('footer.php');?>

</div>
