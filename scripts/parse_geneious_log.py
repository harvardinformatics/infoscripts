#!/usr/bin/python

import os, sys, re, operator, string, time, gzip, pprint

from datetime import datetime

def parse_geneious_log(filename):

    if not os.path.isfile(filename):
        print "User file [%s] not found" % filename
        return

    
    file   = open(filename,'r')
    flines = file.readlines()

    ts = re.compile('TIMESTAMP +(\d+)/(\d+)/(\d+)');
    us = re.compile('^(\d+):(\d+):(\d+).*IN.*license\" +(\S+)\@(.*?)\.(\S+)');

    mon  = "";
    day  = "";
    year = "";

    users     = {}
    usertimes = {}

    for line in flines:

        m1 = ts.search(line)
        m2 = us.search(line)

        if m1 and m1.group(3):
            mon  = m1.group(1)
            day  = m1.group(2)
            year = m1.group(3)
        
        if m2 and m2.group(6):

            user = m2.group(4)
            add  = m2.group(6)
            hrs  = m2.group(1)
            mns  = m2.group(2)
            sec  = m2.group(3)

            if users.has_key(user) == False:
                users[user] = {}

            if users[user].has_key(add) == False:
                users[user][add] = 0

            users[user][add] = users[user][add] + 1

            if mon != "":
                time    = datetime(int(year),int(mon),int(day),int(hrs),int(mns),int(sec))
                if usertimes.has_key(user) == False:
                    usertimes[user] = {}

                usertimes[user][len(usertimes[user])] = time
                
                #print "%s\t%s\t%s"%(time,user,add)


    for u in users.keys():
        astr = "";
        count = 0;
        for add in users[u].keys():
            astr = astr + add + " " + str(users[u][add]) + " "
            count = count + users[u][add]

            #print "%25s\t%5d\t%s"%(u,count,astr)

    for u in usertimes.keys():
        first = usertimes[u][0].strftime("%m/%d/%y")
        last  = usertimes[u][len(usertimes[u])-1].strftime("%m/%d/%Y")
        print "%25s\t%25s\t%25s"%(u,first,last)

def help():
    print "\nParses geneious logs (/n/RC_Team/iliadlic1/license_logs/geneious.log) and reformats by time and user"

    print "\nUsage: python parse_geneious_log.py <logfile>\n\n"

if __name__ == '__main__':

    if len(sys.argv) != 2:
        help()
        sys.exit(0)

    filename = sys.argv[1]

    parse_geneious_log(filename)
  
