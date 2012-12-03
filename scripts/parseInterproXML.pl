#!/usr/bin/perl

$| = 1;

use strict;
use FileHandle;

use Data::Dumper;
use Getopt::Long;
use XML::LibXML;

my $infile;
my $interprofile;
my $elename = "name";
my $substring = "metazoa";
my $help      = 0;

GetOptions("-infile:s"    => \$infile,
	   "-element:s"   => \$elename,
	   "-substring:s" => \$substring,
           "-help"        => \$help);
	   
if ($help) {
    help(1);
}

my $interpro = {};

my $parser    = XML::LibXML->new();

my $tree      = $parser->parse_file($infile);
my $root      = $tree->getDocumentElement;

my @protids = $root->getElementsByTagName('protein');

print "<interpro_matches>\n";
foreach my $id (@protids) {
    my @ipros  = $id->getElementsByTagName("interpro");
    my $found  = 0;

    foreach my $ipro (@ipros) {
	my $name = $ipro->getAttribute($elename);
	if ($name =~ /$substring/) {
	    $found = 1;
	}
    
    }
    if ($found) {
	print $id."\n";
    }
}


print "</interpro_matches>\n";


sub help {
    my ($exit) = shift;

    print "\nUsage:  php parseInterproXML.pl -infilef <xmlfile> -element <element name> -substring <filter string>\n";
    print "\nParses an interproscan xml file and extracts all interpro match elements by filtering both on element type and content\n";
    print "\n -infile    :   Interproscan xml file\n";
    print " -element    : Name of element to filter on [default = name]\n";
    print " -substring  : Match only elements with substring [default= metazoa]\n";
    print "\n";
    print "Example:   perl parseInterproXML.pl -infile myfile.xml -element name -s fungi\n";
    print "\n";
    
    if ($exit) {
	exit();
    }
}
