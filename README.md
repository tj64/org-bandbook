- [org-bandbook.el &#x2014; Functions for Org-Bandbook](#org-bandbook.el-&#x2014;-functions-for-org-bandbook)
  - [MetaData](#metadata)
  - [Commentary](#commentary)
  - [Inspiration and Credits](#inspiration-and-credits)
  - [Usage](#usage)
    - [9 Steps to Heaven](#9-steps-to-heaven)
    - [Song Properties](#song-properties)
    - [Song Arrangements](#song-arrangements)
    - [Project Properties](#project-properties)
  - [Create Bandbook](#create-bandbook)
  - [Contribute](#contribute)
    - [Songs](#songs)
    - [Export Headers](#export-headers)
    - [Accounting Schemes](#accounting-schemes)
    - [Title Pages](#title-pages)
    - [Artwork](#artwork)
    - [Source Code](#source-code)



# org-bandbook.el &#x2014; Functions for Org-Bandbook<a id="sec-1"></a>

Author: Thorsten Jolitz <tjolitz AT gmail DOT com>
Version: 0.9
URL: <https://github.com/tj64/org-bandbook>

## MetaData<a id="sec-1-1"></a>

    copyright: Thorsten Jolitz
    
    copyright-years: 2014+
    
    version: 0.9
    
    licence: GPL 3 or later (free software)
    
    licence-url: http://www.gnu.org/licenses/
    
    part-of-emacs: no
    
    author: Thorsten Jolitz
    
    author_email: tjolitz AT gmail DOT com
    
    inspiration: https://github.com/veltzer/openbook
    
    keywords: emacs org-mode taskjuggler lilypond
    
    git-repo: https://github.com/tj64/org-bandbook
    
    git-clone: git://github.com/tj64/org-bandbook.git

## Commentary<a id="sec-1-2"></a>

Emacs Lisp functionality for "Org-Bandbook - Professional
Band Management for Computer-Literate Musicians".

## Inspiration and Credits<a id="sec-1-3"></a>

Org-Bandbook is inspired by Mark Veltzer's [Open-Book](https://github.com/veltzer/openbook) project, in fact
it started out as a port of Open-Book' to Org-mode, and it would not
exist without this wonderfull project. 

However, Org-Bandbook has a different focus than Open-Book. While the
latter tries to become a free 'Real Book' or 'Fake Book' with possibly
hundreds of tunes, the former is meant to just contain the repertoire
of a band-project (may one or two dozen tunes) with arrangements, as
well as planning, accounting and contact info. 

## Usage<a id="sec-1-4"></a>

### 9 Steps to Heaven<a id="sec-1-4-1"></a>

1.  Clone or fork repo on Github.

2.  Create a personnal branch for hacking the sources and producing
    patches and pull requests.

3.  Create a new branch for every band-project or yours. You should
    not touch the org-bandbook sources in these branches, only modify
    your project-xyz subdirectory.

4.  Use project-massey-hall-1953 as template, either rename it or copy
    it for your own band-project.

5.  Goto the library-of-songs, select songs and create a config file
    for each in the projects 'songs' directory (whose name starts with
    an integer, e.g. 1-all-the-things.org).

6.  Edit the config file for each song (see 'songs' subdir of massey
    hall project).

7.  Edit 'peoples.org' file (kind of org-contacts)

8.  Edit 'instruments.org' file

9.  finally edit the 'master.org' file

The files 'journal.ledger' and 'timeline-and-tasks.org' are frequently
edited during the band-project for planning and keeping track of band
finances. 

### Song Properties<a id="sec-1-4-2"></a>

Use this command:

    ,----[ C-h f org-bandbook-insert-arrangement-table-skeleton RET ]
    | org-bandbook-refresh-song-info is an interactive Lisp function in
    | `org-bandbook.el'.
    | 
    | (org-bandbook-refresh-song-info)
    | 
    | Get key/mode/form from song-link and update properties.
    | 
    | Assumes that point is in a song file in the <project>/songs/
    | directory that has a 'song' entry, and that this entry has a
    | 'link' property with an Org-link (to an Org-Bandbook song in
    | the '/library-of-songs/' directory) as value.
    `----

Note that, thanks to amazing LilyPond, transposing a song is done by
simply adding a property like this ':transpose: g'. Thats all. 

### Song Arrangements<a id="sec-1-4-3"></a>

Use these two commands: 

    ,----[ C-h f org-bandbook-refresh-arrangement-properties RET ]
    | org-bandbook-refresh-arrangement-properties is an interactive Lisp
    | function in `org-bandbook.el'.
    | 
    | (org-bandbook-refresh-arrangement-properties)
    | 
    | Gather (and insert) info about project instruments.
    | Assumes that point is in a song file in the <project>/songs/
    | directory that has a 'arrangement' entry.
    `----

    ,----[ C-h f org-bandbook-insert-arrangement-table-skeleton RET ]
    | org-bandbook-insert-arrangement-table-skeleton is an interactive Lisp
    | function in `org-bandbook.el'.
    | 
    | (org-bandbook-insert-arrangement-table-skeleton)
    | 
    | Insert skeleton-table for song arrangement.
    `----

or simply copy&pase from existing song config files. Then create the
arrangement as org-table, it will be exported to an PlantUML activity
diagram. 

Here is an example arrangement:

<table border="2" cellspacing="0" cellpadding="6" rules="groups" frame="hsides">


<colgroup>
<col  class="left" />

<col  class="right" />

<col  class="left" />

<col  class="left" />

<col  class="left" />

<col  class="left" />
</colgroup>
<thead>
<tr>
<th scope="col" class="left">seq</th>
<th scope="col" class="right">do</th>
<th scope="col" class="left">melody</th>
<th scope="col" class="left">solo</th>
<th scope="col" class="left">accomp</th>
<th scope="col" class="left">riff</th>
</tr>
</thead>

<tbody>
<tr>
<td class="left">a</td>
<td class="right">1</td>
<td class="left">as tr</td>
<td class="left">&#xa0;</td>
<td class="left">b dr p</td>
<td class="left">&#xa0;</td>
</tr>


<tr>
<td class="left">aaba</td>
<td class="right">3</td>
<td class="left">&#xa0;</td>
<td class="left">as</td>
<td class="left">b dr p</td>
<td class="left">&#xa0;</td>
</tr>


<tr>
<td class="left">aaba</td>
<td class="right">4</td>
<td class="left">&#xa0;</td>
<td class="left">tr</td>
<td class="left">b dr p</td>
<td class="left">&#xa0;</td>
</tr>


<tr>
<td class="left">aaba</td>
<td class="right">3</td>
<td class="left">&#xa0;</td>
<td class="left">p</td>
<td class="left">b dr</td>
<td class="left">&#xa0;</td>
</tr>


<tr>
<td class="left">aa</td>
<td class="right">1</td>
<td class="left">&#xa0;</td>
<td class="left">as tr</td>
<td class="left">b dr p</td>
<td class="left">&#xa0;</td>
</tr>


<tr>
<td class="left">b</td>
<td class="right">1</td>
<td class="left">&#xa0;</td>
<td class="left">dr</td>
<td class="left">&#xa0;</td>
<td class="left">&#xa0;</td>
</tr>


<tr>
<td class="left">a</td>
<td class="right">1</td>
<td class="left">as tr</td>
<td class="left">&#xa0;</td>
<td class="left">b dr p</td>
<td class="left">&#xa0;</td>
</tr>
</tbody>
</table>

AABA is the song structure, as tr p b dr are the instruments of the
classical jazz quintett. This table should and must be edited by
hand. 

### Project Properties<a id="sec-1-4-4"></a>

In file 'master.org' you specify 

-   export header (org link)

-   accounting scheme (org link)

-   song order (integers)

-   bandbook parts (songs tasks funds people)

-   project people (musicians nick-names = resource\_id's)

Note the song-order/overview table at the bottom. This table should
and must **not** be edited by hand. Use command:

    ,----[ C-h f org-bandbook-refresh-song-order RET ]
    | org-bandbook-refresh-song-order is an interactive Lisp function in
    | `org-bandbook.el'. [...]
    `----

for inserting and refreshing the table. The song-order is simply
changed by moving the number in property ':song\_order: 1 3'
around. The '1' is the song ID, the numerical prefix of its
song-config file (e.g. 1-all-the-things.org). 

## Create Bandbook<a id="sec-1-5"></a>

Use command:

    ,----[ C-h f org-bandbook-make-bandbook RET ]
    | org-bandbook-make-bandbook is an interactive Lisp function in
    | `org-bandbook.el'.
    | 
    | (org-bandbook-make-bandbook)
    | 
    | Create bandbook for current project.
    `----

to create the PDF. 

## Contribute<a id="sec-1-6"></a>

### Songs<a id="sec-1-6-1"></a>

Add songs to the 'library-of-songs'. Use commands
\`org-bandbook-export-org-file',
\`org-bandbook-export-directory-org-files',
\`org-bandbook-import-mako-file', and
\`org-bandbook-import-directory-mako-files' to import from and export
to 'Open-Book' project. Each song you add in either of the two formats
(org or mako) will therefore benefit both projects, since conversion
is simple. 

### Export Headers<a id="sec-1-6-2"></a>

Add headers that produce beautiful (LaTeX) output to the
'library-of-headers'. 

### Accounting Schemes<a id="sec-1-6-3"></a>

Add ledger accounting schemes for your country to the
'library-of-accounting-schemes'. 

### Title Pages<a id="sec-1-6-4"></a>

Add beautiful (LaTeX) title pages for Org-Bandbook to the
'library-of-title-pages'.

### Artwork<a id="sec-1-6-5"></a>

Add artwork for title pages and other parts of Org-Bandbook to the
'library-of-artwork.

### Source Code<a id="sec-1-6-6"></a>

Bug Reports and Patches welcome. 
