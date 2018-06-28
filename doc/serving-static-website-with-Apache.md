# Serving a static website with the Apache web server

## Scope

These notes cover the very basics of:

- how to set up the Apache web server
- how to restrict access to localhost
- how to install a site (for example from a static CD-ROM dump)
- how to crawl the site so it can be ingested into a web archive
- how to test the resulting WARC

These notes are based on Apache/2.4.18 on a Linux-based system. They only cover static HTML-based sites. Serving dynamic sites also requires an additional application server and a database (i.e. a full [*LAMP stack*](https://en.wikipedia.org/wiki/LAMP_(software_bundle))).

**!!Important!!** use these notes at your own risk! I'm not an expert on neither web server nor Apache, and these are primarily for my own reference!

## Installation of Apache web server

First update the package index:

    sudo apt-get update

Then install Apache:

    sudo apt-get install apache2

Configuration directory is `/etc/apache2`. Note that the server starts running directly after installation.

## Restrict access to localhost

Running a web server can expose your machine to a number of security threats, so it's a good idea to restrict access to localhost only (this means that only the machine on which the server is running can access it). To do this, locate the file *ports.conf* in the *Apache* configuration directory (`/etc/apache2`), open it in a text editor (as sudo), and then change this line:

    Listen 80

into this:

    Listen 127.0.0.1:80

Save the *ports.conf* file, and restart the web server using:

    sudo systemctl restart apache2

## Check if the server is running

Type the following command:

    sudo systemctl status apache2

Output should be something like this:

    ● apache2.service - LSB: Apache2 web server
       Loaded: loaded (/etc/init.d/apache2; bad; vendor preset: enabled)
      Drop-In: /lib/systemd/system/apache2.service.d
               └─apache2-systemd.conf
       Active: active (running) since Tue 2018-04-10 12:40:29 CEST; 3min 21s ago
         Docs: man:systemd-sysv-generator(8)
      Process: 7756 ExecStop=/etc/init.d/apache2 stop (code=exited, status=0/SUCCESS)
      Process: 5731 ExecReload=/etc/init.d/apache2 reload (code=exited, status=0/SUCCESS)
      Process: 7779 ExecStart=/etc/init.d/apache2 start (code=exited, status=0/SUCCESS)
       CGroup: /system.slice/apache2.service
               ├─7796 /usr/sbin/apache2 -k start
               ├─7799 /usr/sbin/apache2 -k start
               └─7800 /usr/sbin/apache2 -k start

    Apr 10 12:40:28 johan-HP-ProBook-640-G1 systemd[1]: Starting LSB: Apache2 web server...
    Apr 10 12:40:28 johan-HP-ProBook-640-G1 apache2[7779]:  * Starting Apache httpd web server apache2
    Apr 10 12:40:28 johan-HP-ProBook-640-G1 apache2[7779]: AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 127.0.1.1. Set the 'ServerName' directive globally to suppress this message
    Apr 10 12:40:29 johan-HP-ProBook-640-G1 apache2[7779]:  *
    Apr 10 12:40:29 johan-HP-ProBook-640-G1 systemd[1]: Started LSB: Apache2 web server.

Finally open below URL in your web browser:

<http://127.0.0.1/>

If all goes well this should load the Apache default page:

![](./img/apache-default.png)


## Adding a site

Adding a site involves the following steps:

1. Put the site contents somewhere on the file system (by default in a subdirectory of folder `/var/www`, although any directory can be used).
2. Create a configuration file under `/etc/apache2/sites-available`
3. Activate the configuration file
4. Add original domain to hosts file
5. Restart the server.

### 1. Put site contents on the file system

Create a root directory for your site under `/var/www` (you need sudo rights for this). For example, in below screenshot `var/www` contains 4 different sites:

![](./img/varwwwroot.png)

Next copy the contents of your site into this directory. Make sure to check the file permissions for the top-level folders; for all users (Others), *Folder Access*  must be set to *Access Files*. Apply these permissions to all underlying (enclosed) files as well. In the Caja file manager (Ubuntu / Linux Mint MATE desktop) this looks as follows:

![](./img/caja-permissions.png)

You can also set the permissions from the terminal, using the following commands:

    sudo find www.nl-menu.nl -type d -exec chmod 755 {} \;
    sudo find www.nl-menu.nl -type f -exec chmod 644 {} \;

### 2. Create a configuration file

Next you need to create a configuration file for the site `/etc/apache2/sites-available`. The easiest way to do this is to copy an existing file (typically the default *000-default.conf*), and save it under a new name (e.g. *nl-menu.conf*). Note that you need sudo priviliges for this. Then open the newly created file in a text editor (again as sudo), and edit the value of the *DocumentRoot* variable, which must point to the root directory of your site. For example, if our site is located at `/var/www/www.nl-menu.nl` use this:

    DocumentRoot /var/www/www.nl-menu.nl

Then save the file.

### 3. Activate the configuration file

First disable the current configuration (in this case 8000-default.conf*):

    sudo a2dissite 000-default.conf

Now enable the new one:

    sudo a2ensite nl-menu.conf

### 4. Add original domain to hosts file

Open (with sudo priviliges) file `/etc/hosts` in a text editor, and add a line that associates the IP address at which the site is locally available to its original URL. For example:

    127.0.0.1	www.nl-menu.nl

Then save the file.

### 5. Restart the server

Type this:

    sudo systemctl restart apache2

All done! The newly installed site is now available at the original URL in your web browser:

<http://www.nl-menu.nl> (which should redirect to <http://127.0.0.1/>)

## Crawl the site for use in web archive

### Preparation: change machine system date to approximate date of snapshot

    sudo date --set="2004-01-23 21:03:09.000"

Two methods listed in [van Luin](http://docplayer.nl/17762647-Ervaringen-met-website-archivering-in-het-nationaal-archief.html):

1. Heritrix
2. Wget

### Heritrix

Installed Heritrix 3.3. 0 (build heritrix-3.3.0-20180529.100446-105). For some reason Heritrix appears to ignore the domain to hosts file, crawling (some elements of) the "live" site instead. If I disable network acesss, the crawl job runs indefinitely without ever downloading any actual data. Tried this for several seed URLs, such as:

    http://www.nl-menu.nl/nlmenu.nl/

and

    http://www.nl-menu.nl/nlmenu.nl/nlmenu.shtml

These all give the same result. So I gave up on this and moved to the wget method below.

## Wget

To completely rule out anything from the "live" site leaking into the crawl, I disabled the network connection before starting the crawl. I then ran Wget following a modified version of the example in van Luin[^1]:

    wget --mirror \
        --page-requisites \
        --warc-file="nl-menu" \
        --warc-cdx \
        --output-file="nl-menu.log" \
        http://www.nl-menu.nl/nlmenu.nl/nlmenu.shtml

This results in a 200 MB compressed WARC file. Throwing WARC at [warctools](https://github.com/internetarchive/warctools)' *warcvalid* doesn't result in any errors.

## Testing the archived site

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

## Comparison with files extracted from ISO image

Number of files in (extracted) ISO image:

    find /var/www/www.nl-menu.nl -type f | wc -l

Result:

    85644

Number of files scraped by wget (from dir tree created by wget):

    find /home/johan/NL-menu/warc-wget-noextensionadjust/www.nl-menu.nl -type f | wc -l

Result:

    84976

Number of files scraped by wget (from cdx file, counting lines with substring " 200 ", which should identify all sucessfully scraped files):

    grep " 200 " nl-menu.cdx | wc -l

Result:

    84976

Which is identical to the count from the fs. Difference: 668 files. These files are part of the ISO, but they weren't scraped by wget.

Detailed comparison:

    diff --brief -r /var/www/www.nl-menu.nl /home/johan/NL-menu/warc-wget-noextensionadjust/www.nl-menu.nl/ | grep "Only in /var/www/" > diffdir.txt

Result [here](./diffdir.txt). In particular, the following items are missing in the wget crawled version[^2]:

- 499 .gif files
- 83 .html files
- 36 .txt files

Not entirely clear why this happens, could be orphaned resources that are not referenced by the site.

## Search for references to missing files in html

One possible explanation for the missing files is that they are not referenced by any of the html files (or, to be more precise, the html parts that are crawled).

We can test this by searching for the names of the missing files inside the html. For instance, using the *grep* tool:

    grep -r "1580.html" /var/www/www.nl-menu.nl/ | wc -l

This returns 110 references, whereas:

    grep -r "frameset_zoekresultaten.html" /var/www/www.nl-menu.nl/ | wc -l

returns 0.

The following script does this for the names of *all* miising files: 

[checkmissingitems.sh](../scripts/checkmissingitems.sh)


TODO: use grep to check if missing files are referenced from any of the HTML.

## Pages/resources that are not available in Pywb

All of the following pages don't work, and give error "The url http://www.nl-menu.nl/nlmenu.nl/fset/ could not be found in this collection": 

### "aanmelden" / "wijzigen" from home page, right-hand menu:

<http://localhost:8080/my-web-archive/20040123200406/http://www.nl-menu.nl/nlmenu.nl/fset/zoekenplus.html?http://www.nl-menu.nl/nlmenu.nl/admin/aanmeldform.html>

Having arrived on this page, the other links at the right hand menu (FAQ, colofon, etc) don't work either! But behaviour seems to depend on previous page we arrived from. Very strange.

On "live" site, going here:

<http://www.nl-menu.nl/nlmenu.nl/admin/aanmeldform.html>

Redirects to:

<http://www.nl-menu.nl/nlmenu.nl/fset/zoekenplus.html?http://www.nl-menu.nl/nlmenu.nl/admin/aanmeldform.html>

This doesn't happen in the archived site! The resource is present in the WARC though:

    warcdump NL-menu.warc.gz > NL-menu-dump.txt
    grep "http://www.nl-menu.nl/nlmenu.nl/admin/aanmeldform.html" NL-menu-dump.txt

Result:

    WARC-Target-URI:<http://www.nl-menu.nl/nlmenu.nl/admin/aanmeldform.html>
    WARC-Target-URI:http://www.nl-menu.nl/nlmenu.nl/admin/aanmeldform.html

Looking at the source of the page, there's this:

    <SCRIPT LANGUAGE="JavaScript">
    <!--
            var navPrinting = false;
            if ((navigator.appName + navigator.appVersion.substring(0, 1)) == "Netscape4") {
                navPrinting = (self.innerHeight == 0) && (self.innerWidth == 0);}
            if ((self.name != 'text') && (self.location.protocol != "file:") && !navPrinting)
            if (top.location.href == location.href) {
                    // deze pagina opnieuw openen, maar dan binnen frameset
                    top.location.href = "http://www.nl-menu.nl/nlmenu.nl/fset/zoekenplus.html?" + unescape(document.URL);
            }
    // -->
    </SCRIPT>

So, the JavaScript re-opens the page within a frame set. So perhaps the problem occurs because the JavaScript fails to run in the archived version? Possibly related to this: pywb actually uses JavaScript to render each archived page inside an iframe. For example, "view source" on the archived homepage produces this (which is *not* the NL-menu source!) :

    <!DOCTYPE html>
    <html>
    <head>
    <style>
    html, body
    {
    height: 100%;
    margin: 0px;
    padding: 0px;
    border: 0px;
    overflow: hidden;
    }

    </style>
    <script src='http://localhost:8080/static/wb_frame.js'> </script>

    <!-- default banner, create through js -->
    <script src='http://localhost:8080/static/default_banner.js'> </script>
    <link rel='stylesheet' href='http://localhost:8080/static/default_banner.css'/>


    </head>
    <body style="margin: 0px; padding: 0px;">
    <div id="wb_iframe_div">
    <iframe id="replay_iframe" frameborder="0" seamless="seamless" scrolling="yes" class="wb_iframe"></iframe>
    </div>
    <script>
    var cframe = new ContentFrame({"url": "http://www.nl-menu.nl/nlmenu.nl/nlmenu.shtml" + window.location.hash,
                                    "prefix": "http://localhost:8080/my-web-archive/",
                                    "request_ts": "20040123200406",
                                    "iframe": "#replay_iframe"});

    </script>
    </body>
    </html>

Also tried: disable JavaScript in browser on "live" site: page is still displayed!

BUT: if I am on one of the category pages, e.g.:

<http://localhost:8080/my-web-archive/20040123200406/http://www.nl-menu.nl/nlmenu.nl/fset/bedrijven.html>

and then click on "aanmelden" (right-hand menu), the page loads normaly, *even though the URL is identical*!! Again, opening the URL in a new tab still produces the error.


Open <http://www.nl-menu.nl/nlmenu.nl/fset/zoekenplus.html>: works on "live" site, fails on archived site. 


### "digitalisering" (NL homepage, bottom-left under "Nieuwe rubrieken"):

<http://localhost:8080/my-web-archive/20040123200406/http://www.nl-menu.nl/nlmenu.nl/fset/zoekenplus.html?http://www.nl-menu.nl/nlmenu.nl/sections/236/1868.html>

Same as above (JavaScript).


<!-- Below only happens if wget is called with --convert-links switch
## changed resources

Command:

    diff --brief -r /home/johan/NL-menu/cd1-intact/NL-menu/ /home/johan/NL-menu/warc-wget/www.nl-menu.nl/ | grep " differ" > diff.txt

Produces > 84000 entries like this :

    Files /home/johan/NL-menu/cd1-intact/NL-menu/nlmenu.en/admin/aanmeldform.html and /home/johan/NL-menu/warc-wget/www.nl-menu.nl/nlmenu.en/admin/aanmeldform.html differ
    Files /home/johan/NL-menu/cd1-intact/NL-menu/nlmenu.en/admin/colofon.html and /home/johan/NL-menu/warc-wget/www.nl-menu.nl/nlmenu.en/admin/colofon.html differ

So how do these files differ?

    diff /home/johan/NL-menu/cd1-intact/NL-menu/nlmenu.en/admin/aanmeldform.html /home/johan/NL-menu/warc-wget/www.nl-menu.nl/nlmenu.en/admin/aanmeldform.html

Result:

    17c17
    < <link rel="stylesheet" href="/nlmenu.nl/styles_nlmenu.css">
    ---
    > <link rel="stylesheet" href="../../nlmenu.nl/styles_nlmenu.css">
    19c19
    < <body bgcolor="#FFFFFF" background="/nlmenu.nl/images/achtergrond_tekst.gif">
    ---
    > <body bgcolor="#FFFFFF" background="../../nlmenu.nl/images/achtergrond_tekst.gif">
    22c22
    < <td bgcolor="#FF9933" align="right" valign="top"><img src="/nlmenu.nl/images/kop_aanmelden.eng.gif" align="right" border=0 alt=""></td>
    ---
    > <td bgcolor="#FF9933" align="right" valign="top"><img src="../../nlmenu.nl/images/kop_aanmelden.eng.gif" align="right" border=0 alt=""></td>
    29c29
    < <img src="/nlmenu.nl/images/aanmelden1.gif" width="80" height="70" align="right"
    ---
    > <img src="../../nlmenu.nl/images/aanmelden1.gif" width="80" height="70" align="right"
    77,80c77,80
    < <A HREF="/nlmenu.nl/admin/aanmeldform.html">NL-menu Registration Form</A> (in Dutch) |
    < <a href="/nlmenu.en/nlinfo.html">NL-menu Mission Statement</a></p>
    < <p><img src="/nlmenu.nl/images/lijntje.gif" alt="" width="10" height="19"><br>
    < <span class="klein">&copy; <a target="_top" href="http://www.nl-menu.nl/">NL-menu: de webindex voor Nederland</a>, sinds 1992</span></p></td>
    ---
    > <A HREF="../../nlmenu.nl/admin/aanmeldform.html">NL-menu Registration Form</A> (in Dutch) |
    > <a href="../nlinfo.html">NL-menu Mission Statement</a></p>
    > <p><img src="../../nlmenu.nl/images/lijntje.gif" alt="" width="10" height="19"><br>
    > <span class="klein">&copy; <a target="_top" href="../../index.html">NL-menu: de webindex voor Nederland</a>, sinds 1992</span></p></td>

So differences are all links that were re-written by wget. If we run wget without the -k (= --convert-links) switch, all files remain unchanged.

**Question**: so why use this switch in the first place?
-->

## Info on origin of files in WARC in metadata

The WARC was crawled from a locally reconstructed version of the site and not from the live web. This is something that should somehow be recorded in metadata. Using the *warcdump* tool from [warctools](https://github.com/internetarchive/warctools):

    warcdump NL-menu.warc.gz > NL-menu-dump.txt

Example record:

    archive record at NL-menu.warc.gz:778658
    Headers:
        WARC-Type:request
        WARC-Target-URI:<http://www.nl-menu.nl/nlmenu.nl/new/home.html>
        Content-Type:application/http;msgtype=request
        WARC-Date:2004-01-23T20:04:06Z
        WARC-Record-ID:<urn:uuid:a733b6c2-f31f-4bb1-822c-63fa08cdb2e2>
        WARC-IP-Address:127.0.0.1
        WARC-Warcinfo-ID:<urn:uuid:8a56cc17-3a38-4146-8594-3f0f39d31d51>
        WARC-Block-Digest:sha1:23FDBRG7W5PPQHPA7TZOJCFNFEV76X55
        Content-Length:230
    Content Headers:
        Content-Type : application/http;msgtype=request
        Content-Length : 230
    Content:
        GET /nlmenu\x2Enl/new/home\x2Ehtml HTTP/1\x2E1\xD\xAReferer\x3A http\x3A//www\x2Enl\x2Dmenu\x2Enl/nlmenu\x2Enl/resources/linkermenu\x2Ehtml\xD\xAUser\x2DAgent\x3A Wget/1\x2E19 \x28linux\x2Dgnu\x29\xD\xAAccept\x3A \x2A/\x2A\xD\xAAccept\x2DEncoding\x3A identity\xD\xAHost\x3A www\x2Enl\x2Dmenu\x2Enl\xD\xAConnection\x3A Keep\x2DAlive\xD\xA\xD\xA
        ...
Note this line:

    WARC-IP-Address:127.0.0.1

The field *WARC-IP-Address* is defined in the [WARC specification](https://iipc.github.io/warc-specifications/specifications/warc-format/warc-1.1/#warc-ip-address) as:

> The WARC-IP-Address is the numeric Internet address contacted to retrieve any included content. An IPv4 address shall be written as a “dotted quad”; an IPv6 address shall be written as specified in [RFC4291]. For a HTTP retrieval, this will be the IP address used at retrieval time corresponding to the hostname in the record’s target-Uri.

In this case, from the value 127.0.0.1 (=localhost) we can see that the files inside the warc originate from a local copy.

## Additional resources

* [Apache HTTP Server Documentation](https://httpd.apache.org/docs/)
* [How To Install the Apache Web Server on Ubuntu 16.04](https://www.digitalocean.com/community/tutorials/how-to-install-the-apache-web-server-on-ubuntu-16-04)
* [Make apache only accessible via 127.0.0.1](https://serverfault.com/questions/276963/make-apache-only-accessible-via-127-0-0-1-is-this-possible/276968#276968)
* Jeroen van Luin: [Ervaringen met website-archivering in het Nationaal Archief](http://docplayer.nl/17762647-Ervaringen-met-website-archivering-in-het-nationaal-archief.html)

[^1]: Compared to van Luin's example, this leaves out the *-w* switch (since we are crawling from a local machine), the *-k* switch (since converting the links is not necessary for rendering the site) and the *-E* switch (don't think changing any extensions is really necessary or desired in this case, but I could be wrong?). It also adds the *--warc-cdx* command (which writes an index file) and the *--output-file* switch (which writes a log file)

[^2]: The total number of items in the diff file is 637; expected number is 668! No idea why.