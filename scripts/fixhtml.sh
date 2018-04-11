#!/bin/bash

# Fix relative links in nl-menu site

# Location on file system
rootDir=/var/www/www.nl-menu.nl/rubbish

# Base directory on web server 
baseDir=/rubbish

while IFS= read -d $'\0' -r file ; do
    # write base href tag to header 
    #sed -i "s|<head>|<head>\n$baseTag|" $file
    # Rewrite relative links
    sed -i "s|/nlmenu.nl|$baseDir/nlmenu.nl|g" $file
    sed -i "s|/nlmenu.en|$baseDir/nlmenu.en|g" $file
done < <(find $rootDir -type f -regex '.*\.\(html\|shtml\)' -print0)

