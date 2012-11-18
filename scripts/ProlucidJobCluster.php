<?php

global $realdir;

require_once "$realdir/GlobalConfig.php";
require_once "$realdir/datamodel/FileHandler.php";

class ProlucidJobCluster {
  var $numSpectraPerFile = 1000;
  var $lsfqueue          = "ip2";

  public function __construct() {
    $this->jarfile               = "/n/ip2/ip2sys/lib/ProLuCID1_3.jar";
    $this->redundanthlineremover = "/n/ip2/ip2sys/lib/redundanthlineremover";
    
  }
  public function submit() {
  }
  public function track() {
  }
  public function join() {
  }

  public function split() {
    
    $ms2counter = 0;
    $jobcounter = 0;

    foreach ($this->spfiles as $spfile) {

      print "\nSplitting file $spfile\n\n";

      $filename = preg_replace("/(.*)\/(.*?)/",'$2',$spfile);
      $filestub = preg_replace("/(.*)\.(.*?)/",'$1',$filename);

      $fp = fopen("$spfile","r");
      
      if ($fp) {

	// Read the header

	while (!feof($fp)) {
	  $line = fgets($fp);
	  
	  if (preg_match("/^S/",$line)) {
	    break;
	  }
	}

	// Now the bulk of the file

	$splitfiles = array();
	$of;
	$linecount = 0;

	$numProcessed   = 0;
	$fileCounter    = 0;

	while (!feof($fp)) {
	  $linecount++;
	  $line           = fgets($fp);
	  
	  if ($numProcessed == 0) {

            $fileCounter++;

            $splitfilename  = $this->outdir . "/$filestub"."_my_"."$fileCounter";
	    print "File $linecount $splitfilename\n";

            $of = fopen($splitfilename,"w");

	    $splitfiles[] = $splitfilename;
	  }

	  //output each spectrum including header (S, Z, I lines) and peaks
	  while ($line) {
            fwrite($of,$line);
            $line = fgets($fp);

            if (preg_match("/^S+/",$line)) {
	      break;
	    }
	  }

	  $numProcessed++;
	  print "Num $numProcessed\t".$this->numSpectraPerFile."\n";
	  if ($numProcessed == $this->numSpectraPerFile) {
	    fclose($of);
            $numProcessed = 0;
	    $fileCounter++;
	    print "Heren\n";
	  }
	  
	}

	fclose($of);
	fclose($fp);

	print "\nWriting job files ready for lsf submission\n\n";

	foreach ($splitfiles as $splitfile) {

	  $hsplitfile     = "H$splitfile";
	  $hfilestub      = "H$filestub";
		
	  $this->outputJobFile($filestub, $splitfile);

	  $jobcounter++;

	}   
 
	print "\n$fileCounter jobfiles written for $filestub.ms2!\n";

	$ms2counter++;
      }
    }
  }

  public function outputJobFile($filestub,$splitfile) {
    $outdir          = $this->outdir;
    $searchxml       = $this->createProlucidParameterXML();
    $lsfqueue        = $this->lsfqueue;

    $jobfile         = "$outdir/$filestub.job";
    $qsublogfile     = "$outdir/$filestub.sub"; 
    $lockfilename    = "$outdir/$filestub.lock"; 
    $qsubfinfile     = "$outdir/$filestub.fin"; 
    $tempjobfile     = $jobfile;
    $searchxmlfile   = "$outdir/$filestub.xml";

    $fp = fopen($searchxmlfile,"w");
    fwrite($fp,$searchxml);
    fclose($fp);

    print "Jobfile $tempjobfile\n";
    $fp = fopen($tempjobfile,"w");

    fwrite($fp,"#!/bin/sh\n");


    fwrite($fp,"#BSUB -u ". $this->email . "\n");
    fwrite($fp,"#BSUB -J $filestub\n");
    fwrite($fp,"#BSUB -o $splitfile.out\n");
    fwrite($fp,"#BSUB -e $splitfile.err\n");
    fwrite($fp,"#BSUB -q ".$this->lsfqueue. "\n");
    fwrite($fp,"#BSUB -C 0\n");
    
    fwrite($fp,"/n/ip2/ip2sys/jdk1.6.0_21_64/bin/java -Xmx4144M -jar ".$this->jarfile." $splitfile  $searchxmlfile 2 >> $splitfile.log 2>&1\n\n");
	   
    fclose($fp);

  }

  public function setEmail($mail) {
    $this->email = $mail;
  }
  public function setExperiment($expt) {
    $this->expt = $expt;

    $spectra = $expt->getPropertyValues("Spectra_File");
    $spfiles = array();
    $fh      = new FileHandler();

    foreach ($spectra as $sp) {
      $spfile = preg_replace("#http://DUMMYHOST.ROOTDIR/misc/MiniFileView.php/#","",$sp);
      $spfile = $fh->getFilePath($spfile);
      $spfiles[] = $spfile;
    }

    $this->spfiles = $spfiles;
  }
  public function setDatabaseFile($dbfile) {
    $this->dbfile = $dbfile;
  }
  public function setSourceInstance($inst) {
    $this->sourceinst = $inst;
  }
  public function setSourceType($type) {
    $this->sourcetype = $type;
  }
  public function setRunDir($dir) {
    $this->rundir = $dir;
  }
  public function setOutDir($dir) {
    $this->outdir = $dir;

    if (!is_dir($dir)) {
      mkdir($dir,0755,true);
    }
  }

  public function setJobName($name) {
    $this->jobname = $name;
  }

  public static function newFromProlucidSearchInstance($table,$inst) {
    global $toprundir;

    $toprundir = "/tmp/";

    $jobclus = new ProlucidJobCluster();
    $jobclus->setEmail("mclamp@fas.harvard.edu");

    $fh    = new FileHandler();

    print "\nGenerating input files for [".$inst->getName() . "]\n";
    
    $exname = $inst->getPropertyValue("Experiment");             
    $ex     = new TypeInstance("Experiment",$exname);
    $ex->fetch($table);

    $jobclus->setExperiment($ex);                                // Set the experiment

    $dbname = $inst->getPropertyValue("Protein_Database");       
    $db     = new TypeInstance("Protein_Database",$dbname);
    $db->fetch($table);

    $dbfile = preg_replace("#http://DUMMYHOST.ROOTDIR/misc/MiniFileView.php/#","",$db->getPropertyValue("File"));
    $dbfile = $fh->getFilePath($dbfile);

    $jobclus->setDatabaseFile($dbfile);                         // Set the database
    $jobclus->setSourceInstance($inst);                         // Set the source instance 
    $jobclus->setSourceType("Prolucid_Search");                 // Set the source type

    $count   = 1;
    $jobname = $inst->getName() . "_LSF_Job_".$count;
    $jobinst = new TypeInstance("LSF_Job",$jobname);

    while ($jobinst->exists($table)) {
      $count++;
      $jobname = $inst->getName() . "_LSF_Job_".$count;
      $jobinst    = new TypeInstance("LSF_Job",$jobname);
    }

    $jobdir  = $toprundir . $jobname . "/";
    $outdir  = $jobdir . "out";

    $jobclus->setJobName($jobname);                            // Set the job name 
    $jobclus->setRunDir($jobdir);                              // Set the job directory
    $jobclus->setOutDir($outdir);                              // Set the output directory
    
    return $jobclus;
  }

  public function createProlucidParameterXML() {

    $pls = $this->sourceinst;
    $db  = $this->dbfile;

    $doc = new DOMDocument();
    $doc->formatOutput = true;
    
    $r = $doc->createElement( "parameters" );
    $doc->appendChild( $r );
    
    // The database
    $dbn = $doc->createElement("database");
    
    $dbn->appendChild($this->getXMLTextElement($doc,"database_name",$db));
    $dbn->appendChild($this->getXMLTextElement($doc,"is_indexed","false"));
    
    $r->appendChild($dbn);
    
    // Search mode
    $sm = $doc->createElement("search_mode"); 
    
    $sm->appendChild($this->getXMLTextElement($doc,"primary_score_type",1));
    $sm->appendChild($this->getXMLTextElement($doc,"secondary_score_type",2));
    $sm->appendChild($this->getXMLTextElement($doc,"locus_type",1));
    $sm->appendChild($this->getXMLTextElement($doc,"charge_disambiguation",0));
    $sm->appendChild($this->getXMLTextElement($doc,"atomic_enrichment",0));
    $sm->appendChild($this->getXMLTextElement($doc,"min_match",0));
    $sm->appendChild($this->getXMLTextElement($doc,"peak_rank_threshold",200));
    $sm->appendChild($this->getXMLTextElement($doc,"candidate_peptide_threshold",500));
    $sm->appendChild($this->getXMLTextElement($doc,"num_output",5));
    $sm->appendChild($this->getXMLTextElement($doc,"id_decharged",0));
    $sm->appendChild($this->getXMLTextElement($doc,"fragmentation_method",$pls->getPropertyValue("Fragmentation/activation_method")));
    $sm->appendChild($this->getXMLTextElement($doc,"multistage_activation_mode",0));
    $sm->appendChild($this->getXMLTextElement($doc,"preprocess",1));
    
    $r->appendChild($sm);
    
    // Isotopes
    
    $it = $doc->createElement("isotopes");  
    $it->appendChild($this->getXMLTextElement($doc,"precursor","mono"));
    $it->appendChild($this->getXMLTextElement($doc,"fragment","mono"));
    $it->appendChild($this->getXMLTextElement($doc,"num_peaks",0));
    
    $r->appendChild($it);

    // Tolerance
    
    $tl = $doc->createElement("tolerance");
    $tl->appendChild($this->getXMLTextElement($doc,"precursor_high",$pls->getPropertyValue("Milli-amu_precursor_tolerance")));
    $tl->appendChild($this->getXMLTextElement($doc,"precursor_low", $pls->getPropertyValue ("Milli-amu_precursor_tolerance")));
    $tl->appendChild($this->getXMLTextElement($doc,"precursor",     $pls->getPropertyValue("ppm_precursor_tolerance")));
    $tl->appendChild($this->getXMLTextElement($doc,"fragment",      $pls->getPropertyValue("Fragment_mass_tolerance_in_ppm")));
    
    $r->appendChild($tl);
    
    $pml = $doc->createElement("precursor_mass_limits");
    $pml->appendChild($this->getXMLTextElement($doc,"minimum",600));
    $pml->appendChild($this->getXMLTextElement($doc,"maximum",6000));
    
    $r->appendChild($pml);
    
    $pcl = $doc->createElement("precursor_charge_limits");
    $pcl->appendChild($this->getXMLTextElement($doc,"minimum",0));
    $pcl->appendChild($this->getXMLTextElement($doc,"maximum",100));
    
    $r->appendChild($pcl);
    
    $pll = $doc->createElement("protein_length_limits");
    $pll->appendChild($this->getXMLTextElement($doc,"minimum",6));
    
    $r->appendChild($pll);
    
    $npl = $doc->createElement("num_peak_limits");
    $npl->appendChild($this->getXMLTextElement($doc,"minimum",25));
    $npl->appendChild($this->getXMLTextElement($doc,"maximum",5000));
    
    $r->appendChild($npl);
    
    $r->appendChild($this->getXMLTextElement($doc,"max_num_diffmod",$pls->getPropertyValue("Maximum_number_of_internal_diff_mods")));
    
    $mods = $doc->createElement("modifications");
    $mods->appendChild($this->getXMLTextElement($doc,"display_mod",0));
    $r->appendChild($mods);
    
    $nterm = $doc->createElement("n_term");
    $cterm = $doc->createElement("c_term");
    
    $mods->appendChild($nterm);
    $mods->appendChild($cterm);
    
    $nsm = $doc->createElement("static_mod");
    $nsm->appendChild($this->getXMLTextElement($doc,"symbol","*"));
    $nsm->appendChild($this->getXMLTextElement($doc,"mass_shift","0.0"));
    $nterm->appendChild($nsm);
    
    $ndms = $doc->createElement("diff_mods");
    $ndm  = $doc->createElement("diff_mod");
    $ndm->appendChild($this->getXMLTextElement($doc,"symbol","*"));
    $ndm->appendChild($this->getXMLTextElement($doc,"mass_shift","0.0"));
    $ndms->appendChild($ndm);
    $nterm->appendChild($ndms);
    
    $csm = $doc->createElement("static_mod");
    $csm->appendChild($this->getXMLTextElement($doc,"symbol","*"));
    $csm->appendChild($this->getXMLTextElement($doc,"mass_shift","0.0"));
    $cterm->appendChild($csm);
    
    $cdms = $doc->createElement("diff_mods");
    $cdm  = $doc->createElement("diff_mod");
    $cdm->appendChild($this->getXMLTextElement($doc,"symbol","*"));
    $cdm->appendChild($this->getXMLTextElement($doc,"mass_shift","0.0"));
    $cdms->appendChild($cdm);
    $cterm->appendChild($cdms);
    
    $ei = $doc->createElement("enzyme_info");
    $ei->appendChild($this->getXMLTextElement($doc,"name",$pls->getPropertyValue("Protease_name_(e_g__trypsin)")));
    $ei->appendChild($this->getXMLTextElement($doc,"specificity",$pls->getPropertyValue("Enzyme_specificity")));
    $ei->appendChild($this->getXMLTextElement($doc,"type","true"));
    
    $res = $doc->createElement("residues");
    $resstr = $pls->getPropertyValue("Residues_(e_g__KR_for_trypsin)");
    
    $resarr = preg_split("//",$resstr);
    
    foreach ($resarr as $tmpr) {
      if ($tmpr != "") {
	$res->appendChild($this->getXMLTextElement($doc,"Residue",$tmpr));
      }
    }
    $ei->appendChild($res);
    
    $r->appendChild($ei);
    
    return $doc->saveXML();
  }
  
  public function getXMLTextElement($doc,$name,$value) {
    $ele = $doc->createElement($name);
    $ele->appendChild($doc->createTextNode($value));
    
    return $ele;
  }
  
}




