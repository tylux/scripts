Use python to generate url rewrites for Nginx from a .csv file

Assuming that you have an A and B column with rewrite data:

Column A:
/some/subfolder/path.html

Column B:
http://yournewsite.com/some/subfolder

Python Code:

import csv
file = open('yourrewrites.csv', 'rU')
urls = csv.reader(file)
for line in urls:
    print "location =%s {"'\n' '\t'"rewrite ^ %s permanent;"'\n' "}" % (line[0], line[1])
This uses the csv module loops through the csv file and prints off columns A and B.

Output will format it like this.

location = /some/subfolder/path.html {
    rewrite ^ http://yournewsite.com/some/subfolder permanent;
}
Redirect output to a file

'python rewrite.py > customrewrites.conf

Take that file and add it to /etc/nginx/includes/customrewrites.conf

Now we need to include them. In our sites-enabled/example.com.conf, inside the corresponding server directive(s) we include the redirects:

server {
    listen 80;
    server_name example.com;
    […]
    include includes/customrewrites.conf;
}
Test Nginx config and reload if looks good

nginx -t
service nginx reload
