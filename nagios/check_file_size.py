#!/usr/bin/python
import os, sys
from stat import *
from optparse import OptionParser, OptionGroup


usage = "Usage: %prog -f path-to-file [-w] [-c]"
parser = OptionParser(usage, version="%prog 1.0")
parser.add_option( "-f",
                   "--file",
		   type="string",
		   dest="file",
		   help="You must define a file with the -f option.")
parser.add_option( "-w",
                  "--warning",
		  type="int",
		  dest="warning",
		  default=-5,
		  help="Use this option to set a warning threshold\
		        Make sure to set a critical value as well.\
                        Default is: 5MB.")
parser.add_option( "-c",
                  "--critical",
		  type="int",
		  dest="critical",
		  default=-10,
		  help="Use this option to set a critical threshold. \
		        Make sure to set a warning value as well \
                        Default is: 10MB.")

(options, args) = parser.parse_args()

file = options.file
warning = options.warning
critical = options.critical

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
