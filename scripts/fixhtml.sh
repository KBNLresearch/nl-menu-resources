#!/bin/bash

# Fix relative links in nl-menu site

rootDir=.

# Base URL (string literal!)
baseURL='"http://localhost/rubbish/"'
#baseURL='"http://www.kbresearch.nl/nl-menu/"'

# Construct base tag element
baseTag="<base href="$baseURL" />"

while IFS= read -d $'\0' -r file ; do
    # write base href tag to header 
    sed -i "s|<head>|<head>\n$baseTag|" $file
    # Rewrite relative links
    sed -i "s|/nlmenu.nl|nlmenu.nl|g" $file
    sed -i "s|/nlmenu.en|nlmenu.en|g" $file
done < <(find $rootDir -type f -regex '.*\.\(html\|shtml\)' -print0)

