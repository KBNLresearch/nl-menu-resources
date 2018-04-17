% Eerste Nederlandse webindex gered van CD-ROM


De website *NL-menu* was de eerste Nederlandse webindex. De site is in 1992 opgericht op initiatief van [SURFnet](https://en.wikipedia.org/wiki/SURFnet), de Nederlandse universiteiten en de KB. Vanaf midden jaren '90 werd de site volledig door de KB beheerd. In 2004 [stopte de KB met *NL-menu*](https://www.robcoers.nl/nl-menu-is-straks-niet-meer-leve-nl-menu/), waarna de site offline is gehaald. In 2006 is de domeinnaam *nl-menu.nl* verkocht aan een bedrijf dat de naam gebruikte voor een eigen webindex, die deels was gebaseerd op de oorspronkelijke *NL-menu* site.

Het oorspronkelijke *NL-menu* is intussen in de vergetelheid geraakt. In het webarchief van het [Internet Archive](https://archive.org/) zijn nog wel behoorlijk wat [snapshots van *NL-menu* terug te vinden](https://web.archive.org/web/*/www.nl-menu.nl), maar deze zijn onvolledig, en bovendien niet representatief voor hoe de site er in werkelijkheid uitzag. Zo is [deze pagina](https://web.archive.org/web/20020603232609/http://www.nl-menu.nl:80/nlmenu.nl/fset/gz.html) een snapshot uit juni 2002:

![](wayback1.png)

Linksboven is een [*Bing*](https://en.wikipedia.org/wiki/Bing_(search_engine)) zoekvenster te zien, maar omdat *Bing* pas in 2009 is opgericht kan de site er in 2002 onmogelijk zo uitgezien hebben. Deze discrepantie is het gevolg van de manier waarop Internet Archive websites binnenhaalt en weergeeft. In dit geval is de pagina in 2002 niet volledig binnengehaald. Enkele ontbrekende elementen (o.a. de linker en rechter menuframes) zijn vervolgens pas in een snapshot van 10 jaar later binnengehaald. De weergave van in Internet Archive is hierdoor een soort amalgaam van de pagina op verschillende tijdstippen, die nog maar weinig zegt over hoe de pagina er in werkelijkheid uitzag.

Omdat de KB pas in 2007 is begonnen met webarchivering, is *NL-menu* ook niet te vinden in het [KB Webarchief](https://www.kb.nl/bronnen-zoekwijzers/databanken-mede-gemaakt-door-de-kb/webarchief-kb). Wel zijn er, kort voordat *NL-menu* in 2004 offline werd gehaald, drie CD-ROMs gebrand met daarop de inhoud van de site.

*NL-menu* is van historisch belang, omdat het een unieke bron van informatie is over de (relatief) vroege geschiedenis van het Nederlandse web. We hebben daarom geprobeerd een reconstructie te maken van de site zoals deze er in het begin van 2004 bij lag. This involved the following steps:

1. Recover the data from the remaining CD-ROMs
2. Set up a local copy of the site by serving the recovered data om a webserver
3. Crawl the recovered site for inclusion in our web archiv



Van de oorspronkelijke inhoud resteren alleen nog enkele CD-ROMs die kort voor het einde van de site zijn  gebrand.

## Leesfouten bij uitlezen CD-ROMs

Omdat *NL-menu* unieke informatie bevat over de vroege geschiedenis van de Nederlandse webosfeer, hebben we een poging gedaan om de data op de CD-ROMs veilig te stellen. Een probleem hierbij is dat (zelfgebrande) CD-ROMs bijzonder vergankelijk zijn. Het was dan ook geen verrassing dat bij een eerste poging om de inhoud uit te lezen *alle* schijfjes leesfouten opleverden!

## Reddingspoging met ddrescue

Hierop hebben we een geprobeerd de schijfjes uit te lezen met [*ddrescue*](https://www.gnu.org/software/ddrescue/), een gespecialiseerde data-recovery tool. Eén van de sterke punten van *ddrescue* is dat je de tool meerdere opeenvolgende keren kunt draaien voor dezelfde drager. Voor elke run houdt *ddrescue* dan in een logbestand bij welke delen (sectoren) van de CD met succes gered zijn, en welke niet. De geredde data worden weggeschreven naar een image file (ISO image). Dit maakt het mogelijk om de tool achtereenvolgens met verschillende CD-drives te draaien, waarbij *ddrescue* het bestaande ISO image bijwerkt voor de nog niet geredde sectoren (en de rest intact laat). Handig, want sectoren waar de ene drive geen chocola van kan maken zijn soms voor een andere drive wél leesbaar (en vice versa)!

![](imaging-action-shot-small.png)

*Ddrescue in actie*

## Visualisatie van recoveryproces

Om te laten zien hoe dit werkt, heb ik voor één van de *NL-menu* CD-ROMs twee visualisaties gemaakt[^1]. De eerste visualisatie laat het resultaat zien van de eerste recovery-ronde met *ddrescue*. Hierbij ik de tool gedraaid met de interne CD-drive van mijn PC:  

![](nl-menu-round1.png)

In de figuur stelt elk blokje één sector (blok van 2048 bytes) van de CD-ROM voor. Alle groene blokjes zijn sectoren die met succes gered zijn; de rode blokjes zijn onleesbare sectoren. 

Vervolgens heb ik *ddrescue* opnieuw gedraaid, maar nu met een externe USB CD-drive. Na deze tweede ronde ziet de visualisatie er als volgt uit:

![](nl-menu-round2.png)

Hoewel het ISO image nog steeds onleesbare sectoren bevat, zijn het er beduidend minder dan na de eerste ronde.

## Resultaat voor de drie CD-ROMs

Van de drie nog aanwezige *NL-menu* CD-ROMs lukte het voor één exemplaar om de volledige inhoud zonder onleesbare sectoren te redden. Voor deze reddingspoging hebben we uiteindelijk vier verschillende CD-drives gebruikt op twee PCs (twee interne CD-drives, en twee extrne USB-drives).   

Van een tweede exemplaar bleek na 16 uur imagen met *ddrescue* niet meer dan de helft nog leesbaar. Een nadere analyse van het resulterende ISO image liet zien, dat de inhoud van deze CD-ROM (voor zover deze gered kon worden) identiek was aan het eerste (in zijn totaliteit geredde) schijfje. Het is dus gewoon een kopie, waardoor er uiteindelijk geen sprake is van dataverlies. 

Na diverse opeenvolgende *ddrescue* rondes met vier verschillende CD-drives bleek het derde exemplaar nog voor 99.8 % leesbaar te zijn. Dit exemplaar bevatte in totaal 468 over het hele schijfje verspreide onleesbare sectoren. Het resulterende ISO image is wel leesbaar, maar bestanden die binnen de beschadigde sectoren vallen zullen niet (correct) weergegeven worden. Verder is de top-level directory *nlmenu.en* niet leesbaar (deze bevat de Engelstalige versie van de site). Jammer genoeg bleek deze CD-ROM *geen* kopie te zijn van het al geredde schijfje.

## Vervolgstappen

De reddingspoging met *ddrescue* leverde uiteindelijk één intacte momentopname op van de inhoud van de *NL-menu* website van vlak voor het moment dat de site offline ging. Uiteindelijk willen we de site opnemen en beschikbaarstellen in ons webarchief. Hiervoor is nog een vervolgstap nodig, waarbij de geredde file-directory op een lokale webserver geïnstalleerd wordt. Dit levert een lokaal werkende versie van de site op, die vervolgens het webarchief in kan worden getrokken.  

## Bonusmateriaal: filmpje

Hieronder een link naar een kort filmpje dat een impressie geeft van hoe het redden van een CD-ROM met *ddrescue* in z'n werk gaat:

<https://vimeo.com/245041453>

[^1]: Gebruikte tool: [*ddrescueview*](https://sourceforge.net/projects/ddrescueview/)