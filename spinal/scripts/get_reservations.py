import os, sys, re, operator, string, time

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

if __name__ == '__main__':
  
  if len(sys.argv) != 2:
    help()
    sys.exit(0)

  resource = sys.argv[1]

  res      = Resource.objects.filter(name__icontains=resource)

  if len(res) > 0:
     res = res[0]
  else:
     print "ERROR: Can't find resource %s"%resource
     sys.exit(0)

  rev      = ResourceReservation.objects.filter(resource=res)

  for r in rev:
    print "%s\t%s\t%s\t%s"%(r.lab_user,r.start_time,r.end_time,r)


