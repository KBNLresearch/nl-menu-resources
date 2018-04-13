#!/bin/bash

# This script modifies all HTML files that are part of the nl-menu site
# to make it work when hosted on a new location. The script:
#
# 1. Sets the permissions of the whole tree to 644
# 2. Fixes relative links
# 3. Fixes Javascript redirects

# Location on file system
rootDir=/home/johan/NL-menu/nl-menu-kbresearch

# Base directory on web server 
baseDir=/nl-menu

# Old and new root domain (used for updating redirects)
rootDomainOld=http://www.nl-menu.nl
rootDomainNew=http://www.kbresearch.nl

while IFS= read -d $'\0' -r file ; do
    # Rewrite relative links
    sed -i "s|/nlmenu.nl|$baseDir/nlmenu.nl|g" $file
    sed -i "s|/nlmenu.en|$baseDir/nlmenu.en|g" $file

    # Update references to original nl-menu domain (fixes JavaScript redirects to old domain)
    sed -i "s|$rootDomainOld|$rootDomainNew|g" $file
done < <(find $rootDir -type f -regex '.*\.\(html\|shtml\)' -print0)

# Copy index.html from nlmenu.nl dir to root dir
cp $rootDir/nlmenu.nl/index.html $rootDir/index.html

# Set permissions on directories to 755; files to 644
find $rootDir -type d -exec chmod 755 {} \;
find $rootDir -type f -exec chmod 644 {} \;
