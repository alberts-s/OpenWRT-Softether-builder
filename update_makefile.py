from bs4 import BeautifulSoup
import re
import hashlib
import requests as req
import sys

PathToMakefile = sys.argv[1]
#PathToMakefile = "/home/alberts00/projects/OpenWRT-package-softether/softethervpn/Makefile"


def getSource(buildnum, cycle ,vernum, datenum):
    linktosource = 'http://jp.softether-download.com/files/softether/v' + vernum + '-' + buildnum + '-' + cycle + '-' + datenum + '-tree/Source_Code/softether-src-v' + vernum + '-' + buildnum + '-' + cycle + '.tar.gz'
    hash = hashlib.md5()

    archive = req.get(linktosource, stream=True)
    progress = 0
    filesize = int(archive.headers['content-length'])
    for block in archive.iter_content(4096):
        progress += 4096
        print(int(progress/filesize*100))
        hash.update(block)

    md5 = hash.hexdigest()
    editMakefile(buildnum, cycle, vernum, datenum, md5)


def editMakefile(buildnum, cycle ,vernum, datenum, md5):
    # Makefile = open(PathToMakefile, 'r+').read()
    # print(Makefile)
    versionre = re.compile('PKG_VERSION:=[\d\.]+')
    buildre = re.compile('PKG_RELEASE:=[\d]+')
    datere = re.compile('PKG_DATE:=[\d\.]+')
    md5re = re.compile('PKG_MD5SUM:=[a-z\d]+')
    newfile = ""
    with open(PathToMakefile, 'r+') as f:
        for line in f:
            line = versionre.sub("PKG_VERSION:="+vernum, line)
            line = buildre.sub("PKG_RELEASE:="+buildnum, line)
            line = datere.sub("PKG_DATE:=" + datenum, line)
            line = md5re.sub("PKG_MD5SUM:=" + md5, line)
            newfile += line
        f.truncate()
        f.seek(0)
        f.write(newfile)




extract = re.compile('/files/softether/v([\d\.]+)-(\d+)-([a-z\d]+)-([\d\.]+)-tree/')

softetherpage = req.get("http://jp.softether-download.com/files/softether/")
soup = BeautifulSoup(softetherpage.text, 'html5lib')
highest_buildnum = 0
global highest_vernum
global highest_cycle
global highest_datenu

for link in soup.find_all('a'):
    curlink = link.get('href')

    try:
        vernum = extract.match(curlink).group(1)
        buildnum = int(extract.match(curlink).group(2))
        cycle = extract.match(curlink).group(3)
        datenum = extract.match(curlink).group(4)
        if buildnum > highest_buildnum:
            # print(vernum, buildnum, cycle, datenum)
            highest_buildnum = buildnum
            highest_vernum = vernum
            highest_cycle = cycle
            highest_datenum = datenum
    except (AttributeError):
        pass

getSource(str(highest_buildnum), highest_cycle, highest_vernum, highest_datenum)
#editMakefile("9578", "beta", "1.01", "2015.09.32", "sssssssssssss")
