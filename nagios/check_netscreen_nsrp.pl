#!/usr/bin/perl

my $PROGNAME = "check_netscreen_nsrp.pl";
my $VERSION = '$Revision: 1.1 $';

use strict;
use vars qw($PROGNAME $VERSION %state_names $state);
use Getopt::Long qw(:config no_ignore_case);
use utils qw($TIMEOUT %ERRORS &print_revision &support);

# example ./check_netscreen_nsrp.pl -H 192.168.1.1 -C private -p 234567 -s 123456
sub help
{
        print "Usage: $PROGNAME <options>\n\n";
        print "options:\n";
        print "\t-H <host>         - hostname(you have to define a ScreenOS Device)\n";
        print "\t-C <community>    - community(default: private)\n";
        print "\t-v <snmp-version> - snmp version(default: 1)\n";
        print "\t-p <primary-isg>  - primary isg unit id, run 'get nsrp vsd-group' on netscreen cluster to get this\n";
        print "\t-s <secondary-isg> - secondary isg unit id, run 'get nsrp vsd-group' on netscreen cluster to get this\n";
        print "\t-w <warning>      - warning-level(default: Secondary ISG)\n";
        print "\t-h                - prints this help-screen\n";
}

# Nagios exit states
our %states = (
    OK       => 0,
    WARNING  => 1,
    CRITICAL => 2,
    UNKNOWN  => 3
);

# Nagios state names
%state_names = (
    0 => 'OK',
    1 => 'WARNING',
    2 => 'CRITICAL',
    3 => 'UNKNOWN'
);

$state = 'UNKNOWN';

my ($COMMUNITY, $SNMPWALK, $SNMPVERSION, $MIBFILE, $CRITICAL, $IP, $HELP, $PRIMARY_ISG, $SECONDARY_ISG, $WARNING);

GetOptions
(
"h" => \$HELP, "help" => \$HELP,
"C=s" => \$COMMUNITY, "community=s" => \$COMMUNITY,
"v=s" => \$SNMPVERSION, "snmpversion=s" => \$SNMPVERSION,
"c=s" => \$CRITICAL, "crit=i" => \$CRITICAL,
"H=s" => \$IP, "host=s" => \$IP,
"p=s" => \$PRIMARY_ISG, "primary=s" => \$PRIMARY_ISG,
"s=s" => \$SECONDARY_ISG, "secondary=s" => \$SECONDARY_ISG,
"w=s" => \$WARNING, "warning=s" => \$WARNING
) or exit $states{$state};

if( defined $HELP)
{
   help();
   exit $states{$state};
}

unless(defined $WARNING)
{
  my $WARNING = $SECONDARY_ISG;
}
unless(defined $IP)
{
   print "no host defined!\n";
   exit $states{$state};
}

$COMMUNITY = "public" if not defined $COMMUNITY;
$SNMPWALK = "/usr/bin/snmpwalk" if not defined $SNMPWALK;
$SNMPVERSION = 1 if not defined $SNMPVERSION;

unless(-e $SNMPWALK)
{
   print "snmpwalk is not installed!\n";
   exit $states{$state};
}

my $master_cluster = `$SNMPWALK -c $COMMUNITY -v $SNMPVERSION $IP 1.3.6.1.4.1.3224.6.1 | awk 'FNR==2{print \$4}'`;

if($WARNING == $master_cluster)
{
   print "WARNING: Current Master is $master_cluster (Secondary ISG); failover has occurred…\n";
    $state = 'WARNING';
   exit $states{$state};
}
elsif($PRIMARY_ISG == $master_cluster)
{
   print "OK: Current master is $master_cluster (Primary ISG).\n";
   $state = 'OK';
    exit $states{$state};
}
else
{
   print "UNKNOWN: The current HA status is unknown.\n";
   $state = 'UNKNOWN';
   exit $states{$state};
}
