#!/usr/bin/python3
import re
import requests
import lxml.html

hparser = lxml.html.HTMLParser(encoding="utf-8" , remove_comments=True)
strxpath = ".//a/@href|.//area/@href|@href|.//iframe/@src|.//frame/@src"

for lline in range(0,12):
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
