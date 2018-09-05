#!/usr/bin/python3
import re
import requests
import lxml.html

regexp = re.compile('([+-])(.*) (\d+_\d+)')
result_file = open('rpmfusion_all.txt')
list_line = []
for line in result_file:
    list_line.append([line[0]] + line[1:-1].split(' '))
#print (list_line)
index = 1
list_line2 = []
for lline in list_line:
    loo=lline[1]
    keep_it = True
    for lline2 in list_line[index:]:
        if lline[1] == lline2[1]:
            keep_it = False
    if keep_it :
        list_line2.append(lline)
    #else:
    #    print("discard %s" % lline)
    index += 1

hparser = lxml.html.HTMLParser(encoding="utf-8" , remove_comments=True)
strxpath = ".//a/@href|.//area/@href|@href|.//iframe/@src|.//frame/@src"
strxpath = ".//entry"
strxlink = "./link/@href"
strxtitle = "./title"
#text += lxml.html.tostring(frags, method="html", encoding="utf-8")

offline = True
for lline in list_line2:
    if lline[0] == '-':
        namespace = lline[2].split('-')
        if offline:
            print("Removed %s %s \t%s" % (lline[3], namespace[1], lline[1]))
            #print("rfpkg clone %s/%s" % (namespace[1], lline[1]))
            #print("ls -d repos/%s" % (lline[1]))
        else:
            atom = "https://pkgs.rpmfusion.org/cgit/%s/%s.git/atom" % (namespace[1], lline[1])
            html = requests.get(atom)
            html_document = lxml.html.fromstring(html.text, parser=hparser)
            elems = html_document.xpath(strxpath)
            print("Number of commits %s in %s" % (len(elems), atom))
            for frags in elems:
                link = frags.xpath(strxlink)
                text = frags.xpath(strxtitle)
                print ("Last msg: %s link: %s" % (text[0].text, link[0]))
                break

for lline in list_line2:
    if lline[0] == '+':
        namespace = lline[2].split('-')
        print("Added %s %s \t %s" % (lline[3], namespace[1], lline[1]))
