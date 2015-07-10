#A Quick and dirty python script for nagios to monitor a single files size in MB.

Install at /usr/lib/nagios/plugins/check_file_size.py

#Make Executable
```
chmod 755 /usr/lib/nagios/plugins/check_file_size.py
```
#Test by passing arugements for WARN_VALUE CRITICAL_VALUE and PATH
Example:
```
python check_file_size.py 100 200 /path/to/file
```
#Add to your nagios-nrpe config
```
command[check_file_size]=/usr/lib/nagios/plugins/check_file_size.py 100 200 /path/to/file
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
