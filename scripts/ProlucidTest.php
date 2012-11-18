<?php

$topdir = dirname(dirname(__FILE__));

error_reporting(E_ALL);

require_once "$topdir/GlobalConfig.php";

require_once "$topdir/plugins/HarvardSMLims/ProlucidJobCluster.php";
require_once "$topdir/datamodel/TestDB.php";
require_once "Test.php";

$tname    = 'semantic_data';
$sqlfile  = 'testdb_small.sql';
$sqlfile2  = getcwd() .'/prolucid.sql';

$test     = new Test();
$testdb   = new TestDB();

$test->result($testdb, "Created TestDB");

$testdb->load_sql($sqlfile2);
$test->result($testdb,"Loaded prolucid sql");

$table    = $testdb->getTable();
$test->result($table, "Got Table");

$plinst = new TypeInstance("Prolucid_Search","PRO00001");
$plinst->fetch($table);

print $plinst->printValues() . "\n";
$jobclus = ProlucidJobCluster::newFromProlucidSearchInstance($table,$plinst);

$jobclus->split();

$test->print_total("ProlucidJobCluster");
