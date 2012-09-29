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

    for line in file:
        if len(lines) == 4:
            header   = lines[0]
            sequence = lines[1]
            three    = lines[2]
            qual     = lines[3]

            index    = header
            lane     = header
            index    = re.sub('^.*:(.*?)','\1',index)
            index    = re.sub('\n','',index)
            f = header.split(':')

            lane = f[3]

            index = index[1:]
            print "Index :%s: lane %s : %s" % (index,lane,header)

            s = samples[lane]

            start1 = index[:2]
            end1   = index[3:]

            found   = 0
            sample  = ""
            project = ""

            for i in s.keys():
                start2 = i[:2]
                end2   = i[3:]


                if start1 == start2 and end1 == end2:
                    print "Found %s %s"%(index,i)
                    found = found+1
                    sample = s[i]['sample']
                    project = s[i]['project']


            if found == 1:
                print "Sample is %s %s %s"%(sample,project,header)

                filename = sample + "_undetermined.fastq"

                if files.has_key(filename) == False:
                    files[filename] = open(filename,"w")

                files[filename].writelines(lines)

            elif found > 1:
                print "Two matches"
            else:
                print "No matches"
                filename = "Undetermined_"+index+".fastq";

                if files.has_key(filename) == False:
                    files[filename] = open(filename,"w")

                files[filename].writelines(lines)

            lines = list()

        lines.append(line)
    
    if len(lines) == 4:
        header   = lines[0]
        sequence = lines[1]
        three    = lines[2]
        qual     = lines[3]
        
        index    = re.sub("^.*:(.*?)\n","\1",header)
        lane     = re.sub("^.*?:.*?:.*?:(.*?):.*\n",'\1',header)
        
        print "Index %s lane %s : %s" % (index,lane,header)

            
    

def help():
    print "Interrogates an Illumina fastq file and attempts to match reads to samples based on the lane and the index\n";
    print "This is useful when the Illumina demultiplexing has failed and --mismatches can't be used\n";

    print "\nUsage: python extract_reads_from_undetermined.py <samplesheet.csv> <fastqfile>\n";


if __name__ == '__main__':
  
  if len(sys.argv) != 3:
    help()
    sys.exit(0)

  samplesheet  = sys.argv[1]
  fastqfile    = sys.argv[2]


  str = "Parsing samplesheet [%s]" % samplesheet

  samples = parse_samplesheet(samplesheet)

  str = "Parsing fastq file [%s]" % fastqfile

  parse_fastq_file(samples,fastqfile)
