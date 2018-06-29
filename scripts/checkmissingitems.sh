#!/bin/bash

# Lookup references to missing items

dirISO=/var/www/www.nl-menu.nl/
dirWget=/home/johan/NL-menu/warc-wget-fromrootdir/www.nl-menu.nl/
filterString="Only in "$dirISO
difFile="diffdir.txt"
cdxFile="nl-menu.cdx"

# Do difff on both dirs and filter files that are only in /var/www/
diff --brief -r $dirISO $dirWget | grep "$filterString" > $difFile

# Iterate over difFile

echo "fileName","countRef","countCdx"

while read line; do
    # dir name
    tmp1="$(cut -d':' -f1 <<<"$line")"
    tmp2="$(cut -d' ' -f3 <<<"$tmp1")"
    dirName=${tmp2#$dirISO}
    # File name
    tmp3="$(cut -d':' -f2 <<<"$line")"
    fName=${tmp3#" "}
    # File name with file path
    fNamePath=$dirName/$fName
    #echo $fNamePath
    # Count number of references to file name + path
    refCount=$(grep -r -F $fNamePath $dirISO | wc -l)
    # Count number of references to file name + path in CDX
    cdxCount=$(grep -F $fNamePath $cdxFile | wc -l)
    echo $fNamePath,$refCount,$cdxCount
done <$difFile
