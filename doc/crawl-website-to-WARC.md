# Crawl website to WARC

## Scope

These notes describe:

- how to crawl a website that is hosted on localhost to a WARC file
- how to test the resulting WARC

These notes only cover static HTML-based sites, and not dynamic sites that depend on a full [*LAMP stack*](https://en.wikipedia.org/wiki/LAMP_(software_bundle))).

## Earlier work

These notes build on [earlier documentation by Jeroen van Luin of the National Archives of the Netherlands](http://docplayer.nl/17762647-Ervaringen-met-website-archivering-in-het-nationaal-archief.html). This document lists two methods for crawling from localhost:

1. Crawl using [Heritrix](https://github.com/internetarchive/heritrix3)
2. Crawl using [Wget](https://www.gnu.org/software/wget/)

Initial tests with Heritrix (build heritrix-3.3.0-20180529.100446-105) resulted in several problems. Most importantly, Heritrix appeared to ignore the *hosts* file, with the effect that it would  (elements of) the "live" site at the crawl domain, instead of localhost. After disabling network access, crawl jobs would run indefinitely without ever downloading any actual data. Because of this I gave up on Heritrix, and focused mostly on Wget. I also did some limited tests with [Warcit](https://github.com/webrecorder/warcit) tool, which is a relatively new tool that is part of the [Webrecorder](https://github.com/webrecorder) suite. 

## Preparation: change machine system date, disable network connection

In most cases it will be desirable that the site snapshot will appear in the Wayback timeline around the year/date it was actually online. This can be achieved by setting the computer's system date to that date. This has to be done before running wget. Below is an example:

    sudo date --set="2004-01-23 21:03:09.000"

Also, to completely rule out anything from the "live" web leaking into the crawl, it may be prudent to disable the network connection at this point (both wired and wireless connections!).

## Wget: basic command

The basic command line for crawling the site (hosted locally at URL `http://www.nl-menu.nl/`) is[^1]: 

    wget --mirror \
        --page-requisites \
        --adjust-extension \
        --warc-file="nl-menu" \
        --warc-cdx \
        --output-file="nl-menu.log" \
        http://www.nl-menu.nl/

This results in a WARC file, a CDX index file (useful for subsequent quality checks), a log file and a mirror of the crawled directory tree (which again is useful for quality checks).

This results in a 200 MB compressed WARC file, which can be rendered in [pywb](https://github.com/webrecorder/pywb). However, a [detailed analysis shows that over 660 files from the source directory tree are missing in the crawl](./qa-archived-site.md). For most of these (90%), the explanation for their absence is that they are not referenced (by way of a hyperlink) by any of the website resources that are crawled from the site root. Of the remaining 64 missing files, 51 are only referenced through a JavaScript variable (which are understandably not recognised by wget). Other, less common reasons are:

- File is only referenced as *value* attribute of an *input* element:
- File is only referenced frame *src* attribute of a *frame* element

So, I tried adapt the basic command above to get a more complete capture.

## Wget: use --input-file switch

Wget's `--input-file` switch takes a list of URLs which are sequentially crawled. In theory this would allow one to force the inclusion of all files in the crawl. The first step here is to create a directory listing of the source directory of the website, and then transform each file entry into a corresponding URL. I did this using the command below: 

    find /var/www/www.nl-menu.nl -type f \
        | sed -e 's/\/var\/www\//http:\/\//g' > urls.txt

I then ran wget with the command below (note that I removed the `--mirror` option, as this caused wget to do a recursive crawl *for each single URL* in the list, which takes forever):

    wget --page-requisites \
        --warc-file="nl-menu" \
        --warc-cdx \
        --output-file="nl-menu.log" \
        --input-file=urls.txt

This results in a WARC file that contains *all* files from the source directory. But it does introduce a different problem: when the WARC is accessed using pywb, it shows up as 85864 individual captures (i.e. each file appears to be treated as an individual capture)! This makes rendering of the WARC impossible (loading the list of capture alone takes forever to begin with). 

After getting in touch with pywb author Ilya Kreymer about this, Ilya pointed out pywb's behaviour in this case is triggered by the fact there is no exact match for the root URL `http://www.nl-menu.nl`. This causes pywb to do a prefix query which in this case results in 80k URLs. This can be avoided by explicitly adding the domain root to the URL list:  

    echo "http://www.nl-menu.nl/" > urls.txt

Incidentally we also need to add entries for the roots of the Dutch and English language home pages:

    echo "http://www.nl-menu.nl/nlmenu.nl/" >> urls.txt
    echo "http://www.nl-menu.nl/nlmenu.en/" >> urls.txt

Then we can add the remaining files (and rewrite file paths as URLs)

    find /var/www/www.nl-menu.nl -type f | sed -e 's/\/var\/www\//http:\/\//g' >> urls.txt

Finally run wget:

    wget --page-requisites \
        --warc-file="nl-menu" \
        --warc-cdx \
        --output-file="nl-menu.log" \
        --input-file=urls.txt

This results in a WARC that is both complete *and* renders in pywb!

<!-- TODO: what happens if we include directories in the find command? Might be easier. -->

### Quality checks

Number of crawled files:

    find ./www.nl-menu.nl/ -type f | wc -l

Result:

    85647

No. of files in source tree is 85644; crawled tree adds 1 index.html at the domain root + 2 icon files. So this is OK.

From CDX:

    grep " 200 " nl-menu.cdx | wc -l

Result:

    85649

This adds 2 more entries for the roots of the Dutch and English language home pages (`http://www.nl-menu.nl/nlmenu.nl/` and `http://www.nl-menu.nl/nlmenu.en/`).

Double-check on missing files:

    diff --brief -r /var/www/www.nl-menu.nl /home/johan/NL-menu/wget-i-addindex/www.nl-menu.nl/ | grep "Only in /var/www/" > diffdir.txt

Which is empty, so all is well!

## Warcit

    warcit http://www.nl-menu.nl/ /var/www/www.nl-menu.nl/ -d 20040123200500

Result:

    [INFO] Wrote 85646 resources to www.nl-menu.nl.warc.gz

## Rendering the archived site locally

Install [pywb](https://github.com/webrecorder/pywb):

    sudo python3 -m pip install pywb

Set up test directory:

    mkdir test-pywb
    cd test-pywb

Create archive:

    wb-manager init my-web-archive

Add NL-menu WARC:

    wb-manager add my-web-archive /home/johan/NL-menu/warc-wget/nl-menu.warc.gz

Start the server:

    wayback

Archived site is now available from:

<http://localhost:8080/my-web-archive/20040123201017/http://www.nl-menu.nl/>

Result:

![](./img/nl-menu-pywb.png)

Which appears to work fine!

A more or less elaborate [Quality assessment of the archived site can be found here](./qa-archived-site.md)

## Additional resources

- Jeroen van Luin: [Ervaringen met website-archivering in het Nationaal Archief](http://docplayer.nl/17762647-Ervaringen-met-website-archivering-in-het-nationaal-archief.html)

[^1]: Compared to van Luin's example, this leaves out the *-w* switch (since we are crawling from a local machine, overloading the host server is not an issue, so we can crawl at maximum speed), the *-k* switch (converting the links is not necessary for rendering the site) and the *-E* switch (I don't think changing any extensions is really necessary or desired in this case, but I could be wrong?). It also adds the *--warc-cdx* command (which writes an index file) and the *--output-file* switch (which writes a log file)
