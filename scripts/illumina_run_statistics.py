#!/usr/bin/python

import os, sys, re, operator, string, time, gzip, pprint

def find_pos_files(dir):
    listing = os.listdir(dir)

    posfiles = {}
    p = re.compile('s_(\d)_(\d+)_pos.txt');

    for infile in listing:
        m = p.match(infile)

        pprint.pprint(m)

        if m.group().has_key(2) = True:
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
         m = p.match(infile)

         if m:
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
    if os.path.isdir(dir) == False:
       return files

    listing = os.listdir(dir)

    p = re.compile('s_(\d)_(\d+)\.(\S+)');

    exts = {}

    exts['stats'] = 1;
    exts['bcl']   = 1;
    exts['cif']   = 1;

    for infile in listing:
        m = p.match(infile)

        if m:
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

    if files.has_key('clocs') == False:
       files['clocs'] = {}

    if files.has_key('filter') == False:
       files['filter'] = {}

    if files.has_key('control') == False:
       files['control'] = {}

    if files.has_key('cif') == False:
       files['cif'] = {}

    if files.has_key('bcl') == False:
       files['bcl'] = {}

    if files.has_key('stats') == False:
       files['stats'] = {}

    while i <= 8:
        if files['control'].has_key(i) == False:
          files['control'][str(i)] = {}

        if files['clocs'].has_key(i) == False:
          files['clocs'][str(i)] = {}

        if files['filter'].has_key(i) == False:
          files['filter'][str(i)] = {}

        if files['cif'].has_key(i) == False:
          files['cif'][str(i)] = {}

        if files['bcl'].has_key(i) == False:
          files['bcl'][str(i)] = {}

        if files['stats'].has_key(i) == False:
          files['stats'][str(i)] = {}

        print "Looking in lane %d"%i

        ldir = dir + "/L00"+str(i)

        if os.path.isdir(ldir) == False:
           print "Can't find %s"%ldir
           continue

        files = find_clocs_filter_control_files(ldir,files)

        print "Num clocs   %d  %d"%(i,len(files['clocs'][str(i)]))
        print "Num filter  %d  %d"%(i,len(files['filter'][str(i)]))
        print "Num control %d  %d"%(i,len(files['control'][str(i)]))

        listing = os.listdir(ldir)

        p = re.compile('C(\d+\.\d+)')

        for infile in listing:
            m = p.match(infile)
            if m:
                files = find_stats_cif_bcl_files(ldir + "/" + infile,files)
                print "Lane %d Cycle %7s cif %5d bcl %5d stats %5d"%(i,infile,len(files['cif'][str(i)]),len(files['bcl'][str(i)]),len(files['stats'][str(i)]))

        i = i + 1

    return files


def help():
    print "\nFinds pos, cif, clocs, filter, control, stats and bcl files in an Illumina run directory\n"
    print "and reports the output statistics\n";

    print "\nUsage: python illumina_run_statistics.py <rundir>\n\n"


if __name__ == '__main__':
  
  if len(sys.argv) != 4:
    help()
    sys.exit(0)

  rundir = sys.argv[1]
  tiles  = sys.argv[2]
  cycles = sys.argv[3]

  print "Finding files in %s" % rundir

  files = {}

  files = find_lane_files(rundir,files)
  
  print files.keys()

  
