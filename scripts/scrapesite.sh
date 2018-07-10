#!/bin/bash

# Dropped -k (= --convert-links) flag
# Dropped --adjust-extension flag
# Scape all files using --input-file option
# Dropped --mirror option

# First add domain root to prevent problems in pywb
echo "http://www.nl-menu.nl/" > urls.txt

# Add root of Dutch and English language pages
echo "http://www.nl-menu.nl/nlmenu.nl/" >> urls.txt
echo "http://www.nl-menu.nl/nlmenu.en/" >> urls.txt

# Add remaining files (and rewrite file paths as URLs)
find /var/www/www.nl-menu.nl -type f | sed -e 's/\/var\/www\//http:\/\//g' >> urls.txt

# Run wget using list as input
wget --page-requisites \
    --warc-file="nl-menu" \
    --warc-cdx \
    --output-file="nl-menu.log" \
    --input-file=urls.txt
    