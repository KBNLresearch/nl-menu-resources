#!/bin/bash

# This script modifies all HTML files that are part of the nl-menu site
# to make it work when hosted on a new location. The script:
#
# 1. Sets the permissions of the whole tree to 644
# 2. Fixes relative links
# 3. Fixes Javascript redirects

# Location on file system
rootDir=/var/www/www.nl-menu.nl/rubbish

# Base directory on web server 
baseDir=/rubbish

# Old and new root domain (used for updating redirects)
rootDomainOld=http://www.nl-menu.nl
rootDomainNew=http://127.0.0.1

# Set permissions to 644 (root has read/write permissions; everyone else read-only)
chmod -R 644 $rootDir

while IFS= read -d $'\0' -r file ; do
    # Rewrite relative links
    sed -i "s|/nlmenu.nl|$baseDir/nlmenu.nl|g" $file
    sed -i "s|/nlmenu.en|$baseDir/nlmenu.en|g" $file

    # Update references to original nl-menu domain (fixes JavaScript redirects to old domain)
    sed -i "s|$rootDomainOld|$rootDomainNew|g" $file
done < <(find $rootDir -type f -regex '.*\.\(html\|shtml\)' -print0)

# Copy index.html from nlmenu.nl dir to root dir
cp $rootDir/nlmenu.nl/index.html $rootDir/index.html

