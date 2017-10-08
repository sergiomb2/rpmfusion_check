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
#strxpath = ".//entry"
strxlink = "./@href"
strxtitle = "./@title"
#text += lxml.html.tostring(frags, method="html", encoding="utf-8")

for lline in range(0,11):
    atom = "https://pkgs.rpmfusion.org/cgit/?ofs=%s" % (lline*50)
    html = requests.get(atom)
    html_document = lxml.html.fromstring(html.text, parser=hparser)
    elems = html_document.xpath(strxpath)
    #print("Number of commits %s in %s" % (len(elems), atom))
    print("Number in %s" % (atom))
    for frags in elems:
        #link = frags.xpath(strxlink)
        #text = frags.xpath(strxtitle)
        #print ("Last msg: %s link: %s" % (text[0].text, link[0]))
        print ("Frags %s" % frags)
        #break

#for lline in list_line2:
#    if lline[0] == '+':
#        print("%s" % ' '.join(lline[1:]))
