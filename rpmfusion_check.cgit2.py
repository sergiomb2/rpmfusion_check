#!/usr/bin/python3
import re
import requests
import lxml.html

print("./rpmfusion_check.cgit2.py")
regexp = re.compile('([+-])(.*) (\d+_\d+)')
result_file = open('rpmfusion_all_all.txt')
all_packages = open('rpmfusion_link_list.txt')
list_line = []
packages = []
for package in all_packages:
    packages.append(package.strip())

for line in result_file:
    list_line.append(line.split(' '))

for package in packages:
    found = False
    for lline in list_line:
        #print("package %s , lline %s " % (package , lline[0]))
        if package == lline[0]:
            found = True
            break
    if not found:
        print("Package not found %s" % package)
        #for lline in list_line:
        #    print("package (%s), lline (%s)" % (package , lline[0]))
