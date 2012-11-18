#!/usr/bin/python

import os, sys, re, operator, string, time, gzip

def parse_samplesheet(samplesheet):
    if not os.path.isfile(samplesheet):
      print "Samplesheet file [%s] not found" % samplesheet
      return

    file   = open(samplesheet,'r')
    flines = file.readlines()

    flines = map(lambda x: x.strip(), flines)

    samples = {}
    count   = 0

    for line in flines:

      if count > 0:

          f = line.split(',')

          #FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject
          #C0YE9ACXX,1,BW_ITS_032312,,,Dutton,N,101+13+101,bewolfe@gmail.com,Ben
          #C0YE9ACXX,2,Input_rgef_myo,C_elegans,CGATGT,Calarco,N,101+13+101,jcalarco@fas.harvard.edu,John

          flowcell = f[0]
          lane     = f[1]
          sample   = f[2]
          ref      = f[3]
          index    = f[4]
          desc     = f[5]
          control  = f[6]
          recipe   = f[7]
          operator = f[8]
          project  = f[9]

          if samples.has_key(lane) == False:
              samples[lane] = {}

          if index != "":
              if samples[lane].has_key(index) == False:
                  samples[lane][index] = {}
           
              samples[lane][index]['sample']   = sample
              samples[lane][index]['flowcell'] = flowcell
              samples[lane][index]['ref']      = ref
              samples[lane][index]['control']  = control
              samples[lane][index]['recipe']   = recipe
              samples[lane][index]['operator'] = operator
              samples[lane][index]['project']  = project

      count = count+1

    return samples

def parse_fastq_file(samples,fastqfile):

    if not os.path.isfile(fastqfile):
      print "Fastq file [%s] not found" % fastqfile
      return

    file   = gzip.open(fastqfile,'rb')

    lines = list()
    files = {}
    reads = {}

    m_obj = re.search(r".*(R\d).*",fastqfile)

    readnum = "1"

    if m_obj:
      readnum = m_obj.group(1)
 
    print "File ",fastqfile," ",readnum

    matches = 0;
    count   = 0; 
    for line in file:
        if len(lines) == 4:
            count = count + 1
            (s,index) = parse_read(lines,samples)

            if count%100000 == 0:
               print "Count %s : matches %s"%(count,matches)

            (files,reads) = save_read(s,index,lines,files,readnum,reads)

            lines = list()

        lines.append(line)
    
    if len(lines) == 4:
        (s,index) = parse_read(lines,samples)

        if count%100000 == 0:
          print "Count %s : matches %s"%(count,matches)
        
        (files,reads) = save_read(s,index,lines,files,readnum,reads)

    print "Done\n";

def parse_read(lines,samples):
   header   = lines[0]
   sequence = lines[1]
   three    = lines[2]
   qual     = lines[3]

   index    = header
   lane     = header
   index    = re.sub('^.*:(.*?)','\1',index)
   index    = re.sub('\n','',index)

   f = header.split(':')

   lane  = f[3]
   index = index[1:]

   if samples.has_key(lane):
     s     = samples[lane]
   else:
     s     = {}

   return (s,index)

def save_read(s,index,lines,files,readnum,reads):
    # First look in the samplesheet indices for a match
    found = 0
    sample = ""
    project = ""
    realindex = ""

    for i in s.keys():
        if i == index:
           found = 1
           sample = s[i]['sample']
           project = s[i]['project']
           realindex = i

    if found == 1:
    # print "Sample is %s %s %s"%(sample,project,header)

       filename = sample + "_"+realindex+"_"+readnum+"_undetermined.fastq"
    else:
       filename = "UnknownSample_"+index+"_"+readnum+"_undetermined.fastq"


    #sys.exit()

    if reads.has_key(filename) == False:
       reads[filename] = {} 
       reads[filename]['count'] = 0
       reads[filename]['lines'] = list()

    readcount = reads[filename]['count']

    if (readcount >= 10000):
      if files.has_key(filename) == False:
         print "Opening file %s %d\n"%(filename,readcount)
         files[filename] = open(filename,"a")

      if readcount == 10000:
         for l in reads[filename]['lines']:
           files[filename].writelines(l)

         reads[filename]['count'] = 10001

      files[filename].writelines(lines)

    else:

      reads[filename]['lines'].append(lines)
      reads[filename]['count'] = reads[filename]['count']+1

    return (files,reads)
         
def help():
    print "Interrogates an Illumina fastq file and attempts to match reads to samples based on the lane and the index\n";
    print "This is useful when the Illumina demultiplexing has failed and --mismatches can't be used\n";

    print "\nUsage: python extract_reads_from_undetermined.py <fastqfile> [<samplesheet.csv>]\n";


if __name__ == '__main__':
  
  if len(sys.argv) < 2:
    help()
    sys.exit(0)

  fastqfile    = sys.argv[1]

  samples = {}
 
  if len(sys.argv) == 3:
    samplesheet  = sys.argv[2]
    str = "Parsing samplesheet [%s]" % samplesheet
    samples = parse_samplesheet(samplesheet)
  
  str = "Parsing fastq file [%s]" % fastqfile

  parse_fastq_file(samples,fastqfile)
