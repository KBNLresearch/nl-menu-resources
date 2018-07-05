
We recently recovered the contents of an old (2004) website from CD-ROM. I managed to get a local instance of the site running using the Apache web server; by editing the machine's *hosts* file the site is available on that local machine from its original URL, which is `http://www.nl-menu.nl` (some more context can be found [here](http://openpreservation.org/blog/2018/04/24/resurrecting-the-first-dutch-web-index-nl-menu-revisited/)).

I'm now looking into ways to crawl the contents of the site into a WARC, so we can ingest it into our web archive. After initial experiments with Heritrix failed, I moved on to wget. After some experimentation the following wget command appeared to work reasonably well:

## Attempt 1: mirror from site root

    wget --mirror \
        --page-requisites \
        --warc-file="nl-menu" \
        --warc-cdx \
        --output-file="nl-menu.log" \
        http://www.nl-menu.nl

However, closer inspection of the result showed that about 668 files in the source directory are missing in the resulting WARC file. The majority (90%) of these files are "orphan" resources that are not used/referenced by any of the HTML files in the crawl. However, the remaining 10% of missing files are resourced that *are* referenced, in most cases through JavaScript variables. These aren't picked up by wget, and therefore they end up missing in the WARC. So I am looking for a way to force wget to include these resources anyway. 

## Attempt 2: use --input-file

At first wget's `--input-file` switch (which takes a list of URLs) looked like a good way to achieve this. I created a directory listing of all files that are part of the website, and then transformed them into corresponding URLs: 

    find /var/www/www.nl-menu.nl -type f \
        | sed -e 's/\/var\/www\//http:\/\//g' > urls.txt

Then I ran wget like this (note that I removed the `--mirror` option, as this apparently causes wget to do a recursive crawl *for each single URL* in the list, which takes forever):

    wget --page-requisites \
        --warc-file="nl-menu" \
        --warc-cdx \
        --output-file="nl-menu.log" \
        --input-file=urls.txt

This results in a WARC file that contains *all* files from the source directory: perfect! But it does introduce a different problem: when I try to access the WARC using [pywb](https://github.com/webrecorder/pywb), it turns out that the WARC is made up of 85864 individual captures (i.e. each file appears to be treated as an individual capture)! This makes rendering of the WARC impossible (loading the list of capture alone takes forever to begin with).

## Attempt 3: include list of URLs in crawl

So as a last resort I created a list of all URLs in HTML format, and put that file in the source directory. Steps:

1. Create list of URLS in Markdown format (add "\<" and "\>" pre-and suffix to each line):

    `find /var/www/www.nl-menu.nl -type f | sed -e 's/\/var\/www\//<http:\/\//; s/$/>\n/g' > urls.txt`

2. Replace any whitespace characters with *%20* to avoid malformed URLs:

    `sed -i 's/\ /%20/g' urls.txt`

3. Convert URL list to HTML which is placed at the root directory of the source dir:

    `sudo pandoc -s urls.txt -o /var/www/www.nl-menu.nl/urls.html`

Then I ran wget, using the above URL list as crawl root:

    wget --mirror \
        --page-requisites \
        --warc-file="nl-menu" \
        --warc-cdx \
        --output-file="nl-menu.log" \
        http://www.nl-menu.nl/urls.html

The resulting WARC contains all files that are in the source dir, and it can be accessed as one single capture in pywb. The obvious downside of this hack is that it compromises the integrity of the 'original' website by adding one (huge) HTML file that was not part of the original site to the WARC.

This makes me wonder if there is another, more elegant way to do this that I have overlooked here? Any suggestions welcome!

BTW I know this question is somewhat similar to [this earlier one] (http://qanda.digipres.org/337/there-web-archiving-tool-that-produces-warc-directory-tree), but option 2 as mentioned by @anjackson there looks similar to Attempt 2 in my case.



## Re-index

    cdx-indexer -j -s /home/johan/test-pywb/collections/my-web-archive/indexes/index.cdxj /home/johan/test-pywb/collections/my-web-archive/archive/nl-menu.warc.gz