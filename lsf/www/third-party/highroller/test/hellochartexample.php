<?php
/**
 * Author: jmac
 * Date: 9/21/11
 * Time: 8:02 PM
 * Desc: HighRoller Hello Chart Example
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
  <title>HighRoller | Hello!</title>
  <link href='http://fonts.googleapis.com/css?family=Open+Sans&v1' rel='stylesheet' type='text/css'>
  <link href='_assets/jquery.snippet.css' rel='stylesheet' type='text/css'>
  <link href='_assets/highroller.css' rel='stylesheet' type='text/css'>

  <!-- jQuery 1.6.1 -->
  <script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"></script>
  <script type="text/javascript" src="_assets/jquery.snippet.js"></script>

  <!-- HighRoller: set Highcharts location -->
  <?php echo HighRoller::setHighChartsLocation("_assets/highcharts/highcharts.js");?>
</head>

<div class="main">

  <img class="logo" src="_assets/dice.png"><h1>HighRoller: Hello!</h1>

  <!--  NAVIGATION -->
  <?php require_once('nav.php');?>

  <div class="clear"></div>

  <div class="page">

    <h2>Hello HighRoller!</h2>

    <div style="display: block; float: left; width:100%">

      <div style="display: inline-block; position: relative; float: left;width: 45%;">
        <div id="linechart" style="display: block;"></div>
      </div>

      <div style="display: inline-block; position: relative; float: left; width: 40%; margin-left:10px">
        <h4>Description</h4>
        <p>This is the "Hello World!" example for implementing a Highcharts line chart using HighRoller.</p>
        <p>In this example, PHP, HTML and JavaScript markup are contained in a single file.</p>
        <p>The only chart properties that are specifically set are the <em>title</em> and the div ID for the chart to <em>renderTo</em>.</p>
        <p>The source code for this chart is below.  Following that is a step-by-step breakdown.</p>
        <p><a href ="/hellochart.php" target="_blank">Click here</a> to see a <em><a href ="/hellochart.php" target="_blank">standalone example</a></em>.</p>
        <p><a href="/advancedexample.php" target="_blank">Click here</a> to see an <em><a href="/advancedexample.php" target="_blank">advanced example</a></em>.</p>
        <p><a href ="/jquery.php">Click here</a> to see an entire gallery of default HighRoller chart examples using <a href ="/jquery.php">jQuery</a>.</p>
      </div>

    <div style="display: block; float: left; width:100%">


      <div style="display: inline-block; position: relative; float: left;width: 85%;">

        <h3>The Source Code</h3>

        <pre class="rawCode">&lt;?php
      // HighRoller: include class files
      require_once('../HighRoller/HighRoller.php');
      require_once('../HighRoller/HighRollerLineChart.php');

      // HighRoller: Line chart sample data
      $chartData = array(5324, 7534, 6234, 7234, 8251, 10324);

      // HighRoller: create and modify Line chart
      $linechart = new HighRollerLineChart();
      $linechart->chart->renderTo = 'linechart';
      $linechart->title->text = 'Line Chart';
      $linechart->yAxis->title->text = 'Total';

      // HighRoller: create and set Series data
      $series1 = new HighRollerSeriesData();
      $series1->addName('myData')->addData($chartData);

      // HighRoller: add series data to chart
      $linechart->addSeries($series1);

      // HighRoller: start HTML markup
      ?&gt;

      &lt;head&gt;
      &lt;!-- jQuery 1.6.1 --&gt;
      &lt;script type="text/javascript" src="https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js"&gt;&lt;/script&gt;

      &lt;!-- HighRoller: set the location of Highcharts library --&gt;
      &lt;?php echo HighRoller::setHighChartsLocation("../highcharts/highcharts.js");?&gt;
      &lt;/head&gt;

      &lt;body&gt;
      &lt;!-- HighRoller: linechart div container --&gt;
      &lt;div id="linechart"&gt;&lt;/div&gt;

      &lt;!-- HighRoller: renderChart() method generates new Highcarts object inside script tag --&gt;
      &lt;script type="text/javascript"&gt;
        &lt;?php echo $linechart->renderChart();?&gt;
      &lt;/script&gt;
      &lt;/body&gt;</pre>

      </div>

    </div>

    <div class="clear"></div>

    <div style="display: block; float: left; width:65%">

      <h2>The Step by Step Break Down</h2>

      <p>I've always grokked things faster with examples that spoon feed me.  Here ya go!</p>
      
      <div class="section">

        <h4>1. Getting Started</h4>

        <div class="subsection">

          <h5>Install HighRoller</h5>
          <p>
            <ul>
              <li>Copy the latest .zip version of HighRoller from the /releases project folder to a temp work area and decompress.</li>
              <li>Drop the entire "HighRoller" folder created by the .zip into your project.</li>
              <li>Done!</li>
            </ul>
          </p>

        </div>

        <div class="subsection">

          <h5>Include HighRoller</h5>
          <p>To get rolling, include the HighRoller, HighRollerSeriesData and HighRoller Line Chart classes</p>

          <pre class="phpCode" style="display:block;">// HighRoller: include class files
    require_once('../HighRoller/HighRoller.php');
    require_once('../HighRoller/HighRollerSeriesData.php');
    require_once('../HighRoller/HighRollerLineChart.php');</pre>

        </div>

        <div class="subsection">
          <h5>Format the chart data</h5>
          <p>Use an array to format your data for use in a HighRoller line chart...</p>
          <pre class="phpCode" style="width:100%;">// HighRoller: Line chart sample data
    $chartData = array(5324, 7534, 6234, 7234, 8251, 10324);</pre>
        </div>
        
      </div>

      <div class="clear"></div>

      <div class="section">

        <h4>2. Create a Chart</h4>

        <div class="subsection">
          <h5>Create a New Chart Object</h5>
          <p>Simplest example of a chart...create a new Chart object and assign some custom properties.</p>
          <pre class="phpCode" style="display:block;">// HighRoller: create and modify Line chart
    $linechart = new HighRollerLineChart();
    $linechart->chart->renderTo = 'linechart';
    $linechart->title->text = 'Line Chart';
    $linechart->yAxis->title->text = 'Total';</pre>
        </div>
        <div class="subsection">
          <h5>Create a Series Data Object</h5>
          <p>A Series Data object allows manipulation outside of the Chart object.</p>
          <pre class="phpCode" style="display:block;">// HighRoller: create Series Data object, add Name and Data to Series
    $series1 = new HighRollerSeriesData();
    $series1->addName('myData')->addData($chartData);</pre>
        </div>
          
        <div class="subsection">
          <h5>Add Data Object to Chart Object</h5>
          <p>Just add the Series Data object is added to the Chart object</p>
          <pre class="phpCode" style="display:block;">// HighRoller: add series data to chart
    $linechart->addSeries($series1);</pre>
        </div>

      </div>

      <div class="clear"></div>

      <div class="section">

        <h4>3. Render the Chart</h4>

        <p>This section explains the HTML and JavaScript markup.</p>
        
        <div class="subsection">
          <h5>Set your Highcharts location</h5>
          <p>HighRoller provides a static helper method to set the location of Highcharts in your environment.</p>
          <pre class="htmlCode" style="display: block;">&lt;!-- HighRoller: set the location of Highcharts --&gt;
  &lt;?php echo HighRoller::setHighChartsLocation("../highcharts/highcharts.js");?&gt;</pre>
        </div>

        <div class="subsection">
          <h5>Placeholder for your chart</h5>
          <p>This is pure Highcharts, you must provide a div with an id for the chart to render to.</p>
          <pre class="htmlCode" style="display: block;">&lt;!-- HighRoller: div container for Highcharts--&gt;
  &lt;div id="linechart"&gt;&lt;/div&gt;</pre>
        </div>

        <div class="subsection">
          <h5>Render the chart</h5>
          <p>Echo the Highcharts object into a script tag using HighRoller's renderChart() method</p>
          <pre class="htmlCode" style="display: block;">&lt;!-- HighRoller: renderChart() method generates new Highcarts object inside script tag --&gt;
  &lt;script type="text/javascript"&gt;
    &lt;?php echo $linechart->renderChart();?&gt;
  &lt;/script&gt;</pre>
        </div>


      </div>

  <script type="text/javascript">
    // simplest example of rendering a highcharts chart using highroller
    <?php echo $linechart->renderChart();?>
    $(document).ready(function(){
      $("pre.htmlCode").snippet("html",{style: "the", showNum: false});
      $("pre.phpCode").snippet("php",{style: "the", showNum: false});
      $("pre.rawCode").snippet("php",{style: "the", showNum: false});
    })
  </script>

  </div>

</div>


    <!--  FOOTER -->
    <?php require_once('footer.php');?>

