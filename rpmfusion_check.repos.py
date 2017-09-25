#!/usr/bin/python3
import re
import requests
import lxml.html

regexp = re.compile('([+-])(.*) (\d+_\d+)')
hparser = lxml.html.HTMLParser(encoding="utf-8" , remove_comments=True)
strxpath = ".//a/@href|.//area/@href|@href|.//iframe/@src|.//frame/@src"
strxpath = ".//entry"
strxlink = "./link/@href"
strxtitle = "./title"
#text += lxml.html.tostring(frags, method="html", encoding="utf-8")

product = ['fedora', 'el']
versions = ['25','26']
el_versions = ['6', '7']
branched = ['27']
all_versions = versions + el_versions + branched + ['rawhide']

arches = ['SRPMS', 'i386', 'x86_64', 'armhfp']
second_arches = ['aarch64', 'ppc64', 'ppc64le']
all_arches = arches + second_arches

for version in all_versions:
    product = 'fedora'
    p_arches = all_arches
    if version == '25':
        p_arches = arches
    if version in el_versions:
        product = 'el'
        if version == '6':
            p_arches = ['SRPMS', 'i386', 'x86_64']
        else:
            p_arches = ['SRPMS', 'x86_64']

    for namespace in ['free', 'nonfree']:
        if version == 'rawhide':
            configs = ['development']
        elif version in branched:
            configs = ['development', 'updates/testing']
        elif version in el_versions:
            configs = ['updates', 'updates/testing']
        else:
            configs = ['releases', 'updates', 'updates/testing']
        for config in configs:
            for arch in p_arches:
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
                    repomd = "%s/repodata/repomd.xml" % atom
                    #print("check %s" % (repoview))
                    html = requests.get(repoview)
                    if html.status_code == 200:
                        html_document = lxml.html.fromstring(html.text, parser=hparser)
                        elems = html_document.xpath(strxpath)
                        print("Last update %s in %s" % (len(elems), repoview))
                        for frags in elems:
                            link = frags.xpath(strxlink)
                            text = frags.xpath(strxtitle)
                            print ("Last msg: %s link: %s" % (text[0].text, link[0]))
                    else:
                        print("http %s: %s" % (html.status_code, repoview))
                    html = requests.get(repomd)
                    if html.status_code != 200:
                        print("http %s: %s" % (html.status_code, repomd))

