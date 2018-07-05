# Wget tries

## Attempt 1: mirror from Dutch homepage

    wget --mirror \
        --page-requisites \
        --warc-file="nl-menu" \
        --warc-cdx \
        --output-file="nl-menu.log" \
        http://www.nl-menu.nl/nlmenu.nl/nlmenu.shtml

Result: various files missing.

## Attempt 2: mirror from site root

    wget --mirror \
        --page-requisites \
        --warc-file="nl-menu" \
        --warc-cdx \
        --output-file="nl-menu.log" \
        http://www.nl-menu.nl

Result: same as attempt 1.

## Attempt 3: use --input-file with list of all URLs

    find /var/www/www.nl-menu.nl -type f | sed -e 's/\/var\/www\//http:\/\//g' > urls.txt

    wget --mirror \
        --page-requisites \
        --warc-file="nl-menu" \
        --warc-cdx \
        --output-file="nl-menu.log" \
        --input-file=urls.txt

Result: wget still busy after 45 minutes; looks like it is doing a recursive crawl for each single URL in the list. Terminated.

## Attempt 4: use --input-file with list of all URLs, but don't use --mirror

    find /var/www/www.nl-menu.nl -type f | sed -e 's/\/var\/www\//http:\/\//g' > urls.txt

    wget --page-requisites \
        --warc-file="nl-menu" \
        --warc-cdx \
        --output-file="nl-menu.log" \
        --input-file=urls.txt

Result: all files that are part of ISO \are crawled, but when WARC is accessed in pywb is made up of 85864 individual captures.

## Attempt 5: create HTML file with hyperlinks to all URLS and use that as crawl root

Create list of URLS; add "\<" and "\>" pre-and suffix to each line: 

    find /var/www/www.nl-menu.nl -type f | sed -e 's/\/var\/www\//<http:\/\//; s/$/>\n/g' > urls.txt

Replace any whitespace characters with *%20* to avoid malformed URLs:

    sed -i 's/\ /%20/g' urls.txt

Convert URL list to HTML which is placed at the root directory of the site:

    sudo pandoc -s urls.txt -o /var/www/www.nl-menu.nl/urls.html

Run wget, using the above URL list as crawl root:

    wget --mirror \
        --page-requisites \
        --warc-file="nl-menu" \
        --warc-cdx \
        --output-file="nl-menu.log" \
        http://www.nl-menu.nl/urls.html

Result:

Number of files scraped by wget (from dir tree created by wget):

    find /home/johan/NL-menu/warc-wget-fakecrawlroot/www.nl-menu.nl -type f | wc -l

Result:

    85655

Number of files scraped by wget (from cdx file, counting lines with substring " 200 ", which should identify all sucessfully scraped files):

    grep " 200 " nl-menu.cdx | wc -l

Result:

    85657

File count ISO image: 85644. 

Diff between directories:

    diff --brief -r /var/www/www.nl-menu.nl /home/johan/NL-menu/warc-wget-fakecrawlroot/www.nl-menu.nl/ | grep "Only in /var/www/" > diffdir.txt

Result:

    Only in /var/www/www.nl-menu.nl/nlmenu.en/images: Copy of kbsurfnet_logo.gif
    Only in /var/www/www.nl-menu.nl/nlmenu.nl/images: Copy of kbsurfnet_logo.gif

