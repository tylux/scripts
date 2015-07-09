import csv
file = open('yourrewrites.csv', 'rU')
urls = csv.reader(file)
for line in urls:
    print "location =%s {"'\n' '\t'"rewrite ^ %s permanent;"'\n' "}" % (line[0], line[1])

