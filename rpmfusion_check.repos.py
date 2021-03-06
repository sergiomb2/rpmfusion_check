#!/usr/bin/python3 -u
import re
import requests
import lxml.html
from lxml import etree
import datetime
from dateutil.parser import parse as parsedate

regexp = re.compile('([+-])(.*) (\d+_\d+)')
hparser = lxml.html.HTMLParser(encoding="utf-8" , remove_comments=False)
#strxpath = ".//a/@href|.//area/@href|@href|.//iframe/@src|.//frame/@src"
strxpath = ".//item"
strxlink = ".//pubDate"
strxtitle = "./title"
#text += lxml.html.tostring(frags, method="html", encoding="utf-8")

product = ['fedora', 'el']
versions = ['27', '28']
el_versions = ['6', '7']
branched = ['29']
all_versions = el_versions + versions + branched + ['rawhide']
#all_versions = branched + ['rawhide']

arches = ['SRPMS', 'i386', 'x86_64', 'armhfp']
second_arches = ['aarch64', 'ppc64', 'ppc64le']
second_archesv2 = ['aarch64', 'ppc64le']

for version in all_versions:
    product = 'fedora'
    if version >= '29':
        p_arches = arches + second_archesv2
    else:
        p_arches = arches + second_arches

    if version in el_versions:
        product = 'el'
        if version == '6':
            p_arches = ['SRPMS', 'i386', 'x86_64']
        else:
            p_arches = ['SRPMS', 'x86_64']
    if version == 'rawhide':
        configs = ['development']
    elif version in branched:
        configs = ['development', 'updates/testing']
    elif version in el_versions:
        configs = ['updates', 'updates/testing']
    else:
        configs = ['updates', 'updates/testing']
        #configs = ['releases', 'updates', 'updates/testing']

    print("\n####################")
    print("Verifying %s-%s" % (product, version))
    print("####################")
    first_line = True
    for namespace in ['free', 'nonfree']:
        for config in configs:
            if not first_line:
                print("---")
            else:
                first_line = False
            for arch in p_arches:
                diff = {}
                for mirror in ['download0', 'download1']:
                    if config in ['releases', 'development']:
                        if arch == 'SRPMS':
                            atom = "http://%s.rpmfusion.org/%s/%s/%s/%s/%s" % (mirror, namespace,
                                product, config, version + '/Everything', 'source/' + arch)
                        else:
                            atom = "http://%s.rpmfusion.org/%s/%s/%s/%s/%s" % (mirror, namespace,
                                product, config, version + '/Everything', arch + '/os')
                    else:
                        atom = "http://%s.rpmfusion.org/%s/%s/%s/%s/%s" % (mirror, namespace,
                            product, config, version, arch)
                    repoview = "%s/repoview/index.html" % atom
                    repoview = "%s/repoview/latest-feed.xml" % atom
                    repomd = "%s/repodata/repomd.xml" % atom
                    #print("check %s" % (repoview))
                    html = requests.get(repoview)
                    repoview = "%s/%s/%s/%s/%s" % (namespace, product, config, version, arch)
                    if html.status_code == 200:
                        repoview_date = parsedate(html.headers['last-modified'])
                        #print ("repoview_date %s" % repoview_date)
                        #html_document = lxml.html.fromstring(html.text, parser=hparser)
                        html_document = etree.fromstring(html.text)
                        elems = html_document.xpath(strxpath)
                        #print("Last update %s in %s" % (len(elems), repoview))
                        #for frags in elems:
                        if len(elems) > 0:
                            frags = elems[0]
                            #print( lxml.html.tostring(frags))
                            text = frags.xpath(strxtitle)
                            link = frags.xpath(strxlink)
                            if len(link) > 0 and len(text) > 0:
                                #print ("Last date: %s tilte: %s" % (link[0].text, text[0].text))
                                dl0 = parsedate(link[0].text)
                                try:
                                    dt = parsedate(link[0].text)
                                    dl0 = dt.strftime('%Y-%m-%d %H:%M:%S')
                                except e:
                                    pass
                                diff[mirror] = "%s, %s" % (dl0, text[0].text)
                            elif len(link) > 0:
                                print ("error1: %s" % (link[0].text))
                            elif len(text) > 0:
                                print ("error2: %s" % (text[0].text))
                            else:
                                print ("error3")
                    else:
                        repoview_date = None
                        print("http %s: %s" % (html.status_code, repoview))
                    html = requests.get(repomd)
                    if html.status_code != 200:
                        print("http %s: %s" % (html.status_code, repomd))
                    else:
                        #print("http %s: %s" % (html.status_code, repomd))
                        repomd_date = parsedate(html.headers['last-modified'])
                        #print ("repodata_date %s" % repomd_date)

                dl0 = diff.get('download0', "N/A")
                dl1 = diff.get('download1', "N/A")
                if dl0 != dl1:
                    print("%s download0 and download1 differ: %s and %s" % (repoview , dl0, dl1))
                else:
                    print("%-42s: %s" % (repoview, dl0))

                if repoview_date is not None and repoview_date < repomd_date:
                    print("repoview %s date:%s older than repodata:%s = %s" % (repoview, repoview_date, repomd_date,
                        repomd_date-repoview_date))
