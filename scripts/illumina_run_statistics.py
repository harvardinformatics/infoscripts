#!/usr/bin/python

import os, sys, re, operator, string, time, gzip, pprint

def find_pos_files(dir):
    listing = os.listdir(dir)

    posfiles = {}
    p = re.compile('s_(\d)_(\d+)_pos.txt');

    for infile in listing:
        if m = p.match(infile):
            print m.group(1)
            print m.group(2)
            if posfiles.has_key(m.group(1)) == False:
                posfiles[m.group(1)] = {}

            posfiles[m.group(1)][m.group(2)] = infile
    return posfiles

def find_clocs_filter_control_files(dir,files):
    listing = os.listdir(dir)

    p    = re.compile('s_(\d)_(\d+)\.(\S+)');

    exts = {}

    exts['clocs']   = 1;
    exts['filter']  = 1;
    exts['control'] = 1;

    for infile in listing:
        if m = p.match(infile):

            lane = m.group(1)
            tile = m.group(2)
            ext  = m.group(3)

            if exts.has_key(ext) == False:
                continue

            if files.has_key(ext) == False:
                files[ext] = {}

            if files[ext].has_key(lane) == False:
                files[ext][lane] = {}

            files[ext][lane][tile] = infile

    return files
    

def find_stats_cif_bcl_files(dir,files):
    listing = os.listdir(dir)

    p = re.compile('s_(\d)_(\d+)\.(\S+)');

    exts = {}

    exts['stats'] = 1;
    exts['bcl']   = 1;
    exts['cif']   = 1;

    for infile in listing:
        if m = p.match(infile):

            lane = m.group(1)
            tile = m.group(2)
            ext  = m.group(3)

            if exts.has_key(ext) == False:
                continue

            if files.has_key(ext) == False:
                files[ext] = {}

            if files[ext].has_key(lane) == False:
                files[ext][lane] = {}

            files[ext][lane][tile] = infile

    return files

def find_lane_files(dir,files):

    i = 1

    while i <= 8:

        ldir = dir + "/L00"+i
        files = find_clocs_filter_control_files(ldir,files)

        listing = os.listdir(ldir)

        p = re.compile('C(\d+\.\d+)')

        for infile in listing:
            if m = p.match(infile):

                files = find_stats_cif_bcl_files(infile,files)


        i = i + 1

    return files


def help():
    print "\nFinds pos, cif, clocs, filter, control, stats and bcl files in an Illumina run directory\n"
    print "and reports the output statistics\n";

    print "\nUsage: python illumina_run_statistics.py <rundir>\n\n"


if __name__ == '__main__':
  
  if len(sys.argv) != 2:
    help()
    sys.exit(0)

  rundir = sys.argv[1]

  print "Finding files in %s" % rundir

  files = {}

  files = find_lane_files(rundir,files)

  pprint.pprint(files)

  
