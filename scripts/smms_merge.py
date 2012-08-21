import os, sys, re, operator, xlrd, string, time

import settings
from django.core             import management 
from django.db               import models
from django.db.models        import *

from django.contrib.auth.models import User

from spinal_website.apps.reservations.models import ResourceReservation
from spinal_website.apps.resources.models    import *

from spinal_website.apps.auth_active_directory.helper_classes  import *
from spinal_website.apps.auth_active_directory.ldap_connection import *
from spinal_website.apps.auth_active_directory.models          import ActiveDirectoryDomainInfo

from datetime import datetime

def email_to_user(email):

    ldap_filter_str = '(&(objectClass=person)(mail=%s*))' % (email)

    conn  = LdapConnection(RC_DOMAIN)        #  from apps.auth_active_directory.ldap_connection.py
    #conn = LdapConnection(NUCLEUS_DOMAIN)   #  from apps.auth_active_directory.ldap_connection.py

    result = conn.search(filter=ldap_filter_str, search_fields_to_retrieve=MEMBER_ATTRIBUTE_LIST)
    conn.unbind()
   
    if result==None or len(result) == 0:
        return
   
    for user_entry in result:
        if len(user_entry) < 2:
            msgx('user entry missing member info data')
            continue
        mi = MemberInfo(user_entry[1])
        if mi.sAMAccountName:
            return mi.sAMAccountName

        
def parse_user_file(filename):
    if not os.path.isfile(filename):
      print "User file [%s] not found" % filename
      return

    file   = open(filename,'r')
    flines = file.readlines()

    flines = map(lambda x: x.strip(), flines)

    users = {}
    count = 0

    for line in flines:
      f = line.split('\t');

      if (len(f) > 3):

        if len(f) > 1:
          login   = f[1].lower()
          users[login] = {}
          users[login]['login']   = login


        else:
          print "No login name - skipping line %s" % line

        if len(f) > 0:
          group   = f[0]
          users[login]['group']   = group
          
        if len(f) > 2:
          name    = f[2]
          users[login]['name']    = name
          
        if len(f) > 3:
          email   = f[3]
          users[login]['email']   = email

        if len(f) > 4:
          groupid = f[4]
          users[login]['groupid'] = groupid
          
        if len(f) > 5:
          pi      = f[5]
          users[login]['pi']      = pi


      else:
        print "Wrong number of fields %d in line[%s]" % (len(f),line)
        
      count = count+1

    return users

def parse_file(filename,start_time,end_time,users):
    if not os.path.isfile(filename):
      print "ESI-TOF usage file [%s] not found" % filename
      return

    log = {}

    file  = xlrd.open_workbook(filename)

    sh = file.sheet_by_index(0)

    print sh.name, sh.nrows, sh.ncols

    for rx in range(sh.nrows):

      login   = sh.cell_value(rx,2).lower()
      group   = sh.cell_value(rx,3)
      sample  = sh.cell_value(rx,4)
      runtype = sh.cell_value(rx,5)
      file1   = sh.cell_value(rx,6)
      file2   = sh.cell_value(rx,8)
      wiff    = sh.cell_value(rx,9)
      tmp1    = sh.cell_value(rx,10)
      time1   = sh.cell_value(rx,11)
      time2   = sh.cell_value(rx,12)
      time3   = sh.cell_value(rx,13)
      runstart= sh.cell_value(rx,14)
      runend  = sh.cell_value(rx,15)
      tmp2    = sh.cell_value(rx,16)
      tmp3    = sh.cell_value(rx,17)
      tmp4    = sh.cell_value(rx,18)
      notes   = sh.cell_value(rx,20)
      email   = ""
      user    = ""

      if users.has_key(login) and  users[login].has_key('email'):

          email = users[login]['email']
          tmp   = email_to_user(email)

          if tmp != None:
              user = tmp

      if log.has_key(runtype) == False:

        log[runtype] = list()

      tmp = {}

      tmp['login']      = login
      tmp['group']      = group
      tmp['sample']     = sample
      tmp['runtype']    = runtype
      tmp['file1']      = file1
      tmp['file2']      = file2
      tmp['wiff']       = wiff
      tmp['time1']      = time1
      tmp['time2']      = time2
      tmp['time3']      = time3
      tmp['email']      = email
      tmp['user']       = user
      
      p = re.compile("\d+/\d+/\d+ \d+:\d+:\d+")

      if p.search(runstart):
        tmp['start_time']   = datetime.strptime(runstart,"%m/%d/%y %H:%M:%S")
      else:
        tmp['start_time'] = None

      if p.search(runend):
        tmp['end_time']     = datetime.strptime(runend,"%m/%d/%y %H:%M:%S")
      else:
        tmp['end_time'] = None

      tmp['notes']      = notes
      
      log[runtype].append(tmp)

    return log

def get_reservations(start_time,end_time):

    res = Resource.objects.filter(name__icontains="ESI-TOF")

    reserv = list()

    for r in res:
        tmpreserv = ResourceReservation.objects.filter(resource=r,start_time__gte=start_time,end_time__lt=end_time)

        for t in tmpreserv:
            tmp = {}
            tmp['start_time'] = t.start_time
            tmp['end_time']   = t.end_time
            tmp['reservation'] = t

            reserv.append(tmp)

    return reserv

def cluster_log_and_reservations(log,res):

    clus         = list()
    current_clus = None

    print ""

    #############################################################################
    # 1 ) These are the log entries without a timestamp - we can't cluster these
    #############################################################################

    for l in log:
        for i in range(len(log[l])):
            if log[l][i]['start_time'] == None:
                print "no_timestamp\t" + "%s"%log[l][i]['login'] + "\t" + "%s"%log[l][i]['runtype'] + "\t" + "%s"%log[l][i]['sample']
            else:
                res.append(log[l][i])
    print ""

    #############################################################################
    # 2 ) Now we sort the log entries and reservations by start time and cluster
    #############################################################################

    res = sorted(res, key = lambda tmp: tmp['start_time'])

    for r in res:
        if current_clus == None:
            current_clus = {}
            current_clus['entries'] = list()
            current_clus['start_time']   = r['start_time']
            current_clus['end_time']     = r['end_time']
            current_clus['entries'].append(r)
            clus.append(current_clus)
        else:
            if r['start_time'] < current_clus['end_time']:
                current_clus['entries'].append(r)
                
                if (r['start_time'] < current_clus['start_time']):
                    current_clus['start_time'] = r['start_time']

                if (r['end_time'] > current_clus['end_time']):
                    current_clus['end_time'] = r['end_time']
            else:
                current_clus = {}
                current_clus['entries'] = list()
                current_clus['start_time']   = r['start_time']
                current_clus['end_time']     = r['end_time']
                current_clus['entries'].append(r)
                clus.append(current_clus)
    
    count = 1

    ######################################################
    # 3 )We loop over the clusters and print to the screen
    ######################################################

    for c in clus:
        cluslen         = c['end_time']-c['start_time']

        s  = "%d" % len(c['entries'])
        s += '\t'
        s += "%s" % (c['start_time'])
        s += '\t'
        s += "%s" % (c['end_time']) + "\t"
        s += "Length " +  "%s" % (cluslen) + "\n"


        has_reservation = False
        has_log         = False
        log_user        = None
        res_user        = None
        user            = None
        email           = None
        clus_type       = "None"        
        cstr  = ""

        c['entries'] = sorted(c['entries'], key = lambda tmp: tmp['start_time'])

                    
        head_str   = "{0:15s}".format("Entry type")
        head_str  += "\t" + "{0:15s}".format("Length")
        head_str  += "\t" + "{0:19s}".format("Start")
        head_str  += "\t" + "{0:19s}".format("End")
        head_str  += "\t" + "{0:20s}".format("User")
        head_str  += "\t" + "Resource"

        string_val = "=" * 132
        
        for c in c['entries']:
            user       = "-"
            entry_type = "-"
            resource   = ""
            start_time = "%s" % (c['start_time'])
            end_time   = "%s" % (c['end_time'])
            cluslen    = "{0:15s}".format(c['end_time'] - c['start_time'])

            if c.has_key('reservation'):

                entry_type       = 'reserv'
                has_reservation  = True
                user             = c['reservation'].lab_user.user.username
                user             = re.sub("^rc_","",user)
                user             = "{0:20s}".format(user)
                resource         = "%s" % (c['reservation'].resource)

            elif c.has_key('runtype'):

                entry_type       = 'log'
                has_log          = True
                resource         = c['runtype']

                if c.has_key('user') and c['user'] != None and c['user'] != "":
                    user        = "{0:20s}".format(c['user'])
                elif c.has_key('email'):
                    user        = "{0:20s}".format(c['email'])
                elif c.has_key('login'):
                    user        = "{0:20s}".format(c['login'])

            entry_type = "{0:15s}".format(entry_type)
            cstr += entry_type + "\t" + cluslen + "\t" + start_time + "\t" + end_time + "\t" + user + "\t" + "%s"%(resource) + "\n"

        if has_reservation and has_log:
            clus_type = "both"

        elif has_reservation:
            clus_type = "reserv"

        elif has_log:
            clus_type = "log"


        print "\n"+string_val+ "\nCluster number " + "%s"%(count) + "\tType: " + clus_type + "\tNumber of Entries " + s  + string_val


        print head_str + "\n" + cstr
        count = count+1


def get_first_day_of_next_month(year,month):

  tmpmonth = month+1
  tmpyear  = year

  if tmpmonth == 13:
    tmpmonth = 1
    tmpyear  = year+1

  return datetime(tmpyear, tmpmonth, 1) 


def help():
    print "This script takes the usage log from the ESI-TOF machine and compares it to the reservations in SPINAL."
    print "Both the log entries and the reservations are clustered by time and displayed."
    print "Each log file is expected to contain one month's usage and the year and month need to be input on the command line"

    print "\nUsage: python smms_merge.py <userfile> <logfile.xls> <year> <month>"
    print "\nThe userfile contains the mapping from ESI-TOF username to email. It is tab-delimited and of the format :\n"
    print "Group   Login Name      Full Name       Email   Group ID        PI"
    print "AEC     AECohen Adam E Cohen    cohen@chemistry.harvard.edu     AEC     Adam E Cohen"
    print "AEC     APFields        Alexander P Fields      fields@fas.harvard.edu  AGM     Andrew Myers"

    print "\nThe logfile is the output logfile from the ESI-TOF machine"
    print "The year is the full year e.g. 2012"
    print "The month is the number i.e. 1-12\n"


if __name__ == '__main__':
  
  if len(sys.argv) != 5:
    help()
    sys.exit(0)

  userfile  = sys.argv[1]
  filename  = sys.argv[2]

  year      = int(sys.argv[3])
  month     = int(sys.argv[4])

  start_time = datetime(year,month,1)
  end_time   = get_first_day_of_next_month(year,month)

  str = "Parsing user file [%s]" % userfile

  users = parse_user_file(userfile)

  str += " - found %s users" % len(users)

  print str

  str = "Parsing log file [%s] from %s - %s" % (filename,start_time,end_time)

  log   = parse_file(filename,start_time,end_time,users)

  numlog = 0;
  for l in log:
      numlog += len(l)

  str  += " - found %d log entries" % numlog

  print str;

  str = "Fetching reservations"

  res   = get_reservations(start_time,end_time)
  
  str  += " - found %d reservations" % len(res)

  print str

  clus  = cluster_log_and_reservations(log,res)

