#!/bin/bash

# Lookup references to missing items

dirISO=/var/www/www.nl-menu.nl/
dirWget=/home/johan/NL-menu/warc-wget-noextensionadjust/www.nl-menu.nl/
filterString="Only in "$dirISO
difFile="diffdir.txt"

# Do difff on both dirs and filter files that are only in /var/www/
diff --brief -r $dirISO $dirWget | grep "$filterString" > $difFile

# Iterate over difFile

echo "fileName","count"

while read line; do
    fName="$(cut -d':' -f2 <<<"$line")"
    grepCount=$(grep -r $fName $dirISO | wc -l)
    echo $fName,$grepCount
done <$difFile
