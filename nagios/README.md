#A Quick and dirty python script for nagios to monitor a single files size in MB.

Install at /usr/lib/nagios/plugins/check_file_size.py

#Make Executable
```
chmod 755 /usr/lib/nagios/plugins/check_file_size.py
```

#Test by passing arugements for WARN_VALUE CRITICAL_VALUE in MB  and PATH
```
python check_file_size.py --help

Usage: check_file_size.py -f path-to-file [-w] [-c]

Options:
  --version             show program's version number and exit
  -h, --help            show this help message and exit
  -f FILE, --file=FILE  You must define a file with the -f option.
  -w WARNING, --warning=WARNING
                        Use this option to set a warning threshold
                        Make sure to set a critical value as well.
                        Default is: 5MB.
  -c CRITICAL, --critical=CRITICAL
                        Use this option to set a critical threshold.
                        Make sure to set a warning value as well
                        Default is: 10MB.

```
#Example
```
python check_file_size.py -w 10 -c 20 -f /path/to/file
```
#Add to your nagios-nrpe config
```
command[check_file_size]=/usr/lib/nagios/plugins/check_file_size.py -w 100 -c 200 -f /path/to/file
```
#Add to services.cfg
```
define service{
        use                             important-service
        hostgroup_name                  your_group
        service_description             check file size
        check_command                   check_nrpe_arg!check_file_size
}
```
