#!/usr/bin/python
import os, sys
from stat import *

#################
#Set variables
file = '/path/to/file'
#In bytes ~200MB
critical = 200
#In bytes ~100MB
warning = 100
#################

try:
    st = os.stat(file)
except IOError:
    print "failed to get information about", file

size = st[ST_SIZE]/1000000

#Determine state to pass to Nagios
#CRITICAL = 2
#WARNING = 1
#OK = 0

if size >= critical:
    print "File Size CRITICAL: %s is %s MB" % (file, size)
    sys.exit(2)
elif size >= warning:
    print "File Size WARNING: %s is %s MB" % (file, size)
    sys.exit(1)
else:
    print "File SizeE OK: %s is %s MB" % (file, size)
    sys.exit(0)
