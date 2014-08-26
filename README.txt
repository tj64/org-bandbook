			  ___________________

			      ORG-BANDBOOK

			    Thorsten Jolitz
			   tjolitz@gmail.com
			  ___________________


Table of Contents
_________________

1 org-bandbook.el --- Professional Band Management Tool
.. 1.1 MetaData
.. 1.2 Commentary
.. 1.3 Inspiration and Credits
.. 1.4 Usage
..... 1.4.1 9 Steps to Heaven
..... 1.4.2 Song Properties
..... 1.4.3 Song Arrangements
..... 1.4.4 Project Properties
.. 1.5 Create Bandbook
.. 1.6 Contribute
..... 1.6.1 Songs
..... 1.6.2 Export Headers
..... 1.6.3 Accounting Schemes
..... 1.6.4 Title Pages
..... 1.6.5 Artwork
..... 1.6.6 Source Code





1 org-bandbook.el --- Professional Band Management Tool
=======================================================

  Author: Thorsten Jolitz <tjolitz AT gmail DOT com> Version: 0.9 URL:
  [https://github.com/tj64/org-bandbook]


1.1 MetaData
~~~~~~~~~~~~

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


1.2 Commentary
~~~~~~~~~~~~~~

  Emacs Lisp functionality for

        Org-Bandbook

        Professional Band Management
        for Computer-Literate Musicians


1.3 Inspiration and Credits
~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Org-Bandbook is inspired by Mark Veltzer's [Open-Book] project, in
  fact it started out as a port of Open-Book' to Org-mode, and it would
  not exist without this wonderful project (since thats where the more
  than hundred jazz standards in LilyPond notation in Org-Bandbook's
  'library-of-songs' come from, as well as the common LilyPond macros
  used for every score).

  However, Org-Bandbook has a different focus than Open-Book. While the
  latter tries to become a free 'Real Book' or 'Fake Book' with possibly
  hundreds of tunes, the former is meant to just contain the repertoire
  of a band-project (maybe one or two dozen tunes) with arrangements, as
  well as (rehearsal-, gig- and tour-) planning, accounting and contact
  info.


  [Open-Book] https://github.com/veltzer/openbook


1.4 Usage
~~~~~~~~~

1.4.1 9 Steps to Heaven
-----------------------

  1. Clone or fork repo on Github.

  2. Create a personnal branch for hacking the sources and producing
     patches and pull requests.

  3. Create a new branch for every band-project or yours. You should not
     touch the org-bandbook sources in these branches, only modify your
     project-xyz subdirectory.

  4. Use project-massey-hall-1953 as template, either rename it or copy
     it for your own band-project.

  5. Goto the library-of-songs, select songs and create a config file
     for each in the projects 'songs' directory (whose name starts with
     an integer, e.g. 1-all-the-things.org).

  6. Edit the config file for each song (see 'songs' subdir of massey
     hall project).

  7. Edit 'peoples.org' file (kind of org-contacts)

  8. Edit 'instruments.org' file

  9. finally edit the 'master.org' file

  The files 'journal.ledger' and 'timeline-and-tasks.org' are frequently
  edited during the band-project for planning and keeping track of band
  finances.


1.4.2 Song Properties
---------------------

  Use this command:

  ,----
  | ,----[ C-h f org-bandbook-refresh-song-info RET ]
  | | org-bandbook-refresh-song-info is an interactive Lisp function in
  | | `org-bandbook.el'.
  | | 
  | | (org-bandbook-refresh-song-info)
  | | 
  | | Get key/mode/form from song-link and update properties.
  | | 
  | | Assumes that point is in a song file in the <project>/songs/
  | | directory that has a 'song' entry, and that this entry has a
  | | 'link' property with an Org-link (to an Org-Bandbook song in
  | | the '/library-of-songs/' directory) as value.
  | `----
  `----

  Note that, thanks to amazing LilyPond, transposing a song is done by
  simply adding a property like this ':transpose: g'. Thats all.


1.4.3 Song Arrangements
-----------------------

  Use these two commands:

  ,----
  | ,----[ C-h f org-bandbook-refresh-arrangement-properties RET ]
  | | org-bandbook-refresh-arrangement-properties is an interactive Lisp
  | | function in `org-bandbook.el'.
  | | 
  | | (org-bandbook-refresh-arrangement-properties)
  | | 
  | | Gather (and insert) info about project instruments.
  | | Assumes that point is in a song file in the <project>/songs/
  | | directory that has a 'arrangement' entry.
  | `----
  `----

  ,----
  | ,----[ C-h f org-bandbook-insert-arrangement-table-skeleton RET ]
  | | org-bandbook-insert-arrangement-table-skeleton is an interactive Lisp
  | | function in `org-bandbook.el'.
  | | 
  | | (org-bandbook-insert-arrangement-table-skeleton)
  | | 
  | | Insert skeleton-table for song arrangement.
  | `----
  `----

  or simply copy&pase from existing song config files. Then create the
  arrangement as org-table, it will be exported to an PlantUML activity
  diagram.

  Here is an example arrangement:

   seq   do  melody  solo   accomp  riff 
  ---------------------------------------
   a      1  as tr          b dr p       
   aaba   3          as     b dr p       
   aaba   4          tr     b dr p       
   aaba   3          p      b dr         
   aa     1          as tr  b dr p       
   b      1          dr                  
   a      1  as tr          b dr p       


  AABA is the song structure, as tr p b dr are the instruments of the
  classical jazz quintett. This table should and must be edited by hand.


1.4.4 Project Properties
------------------------

  In file 'master.org' you specify

  - export header (org link)

  - accounting scheme (org link)

  - song order (song IDs as integers)

  - bandbook parts (songs/tasks/funds/people)

  - project people (nick-names = resource_id's)

  Note the song-order/overview table at the bottom. This table must
  *not* be edited by hand. Use command:

  ,----
  | ,----[ C-h f org-bandbook-refresh-song-order RET ]
  | | org-bandbook-refresh-song-order is an interactive Lisp function in
  | | `org-bandbook.el'. [...]
  | `----
  `----

  for inserting and refreshing the table. The song-order is simply
  changed by moving the numbers in property ':song_order: 1 3'
  around. The '1' is the song ID, the numerical prefix of its
  song-config file (e.g. 1-all-the-things.org).


1.5 Create Bandbook
~~~~~~~~~~~~~~~~~~~

  Use command:

  ,----
  | ,----[ C-h f org-bandbook-make-bandbook RET ]
  | | org-bandbook-make-bandbook is an interactive Lisp function in
  | | `org-bandbook.el'.
  | | 
  | | (org-bandbook-make-bandbook)
  | | 
  | | Create bandbook for current project.
  | `----
  `----

  to create the PDF.


1.6 Contribute
~~~~~~~~~~~~~~

1.6.1 Songs
-----------

  Add songs to the 'library-of-songs'. Use commands

  - `org-bandbook-export-org-file',

  - `org-bandbook-export-directory-org-files',

  - `org-bandbook-import-mako-file'

  - `org-bandbook-import-directory-mako-files'

  to import from and export to 'Open-Book' project. Each song you add in
  either of the two formats (org or mako) will therefore benefit both
  projects, since conversion is easy.


1.6.2 Export Headers
--------------------

  Add headers that produce beautiful (LaTeX) output to the
  'library-of-headers'.


1.6.3 Accounting Schemes
------------------------

  Add ledger accounting schemes for your country to the
  'library-of-accounting-schemes'.


1.6.4 Title Pages
-----------------

  Add beautiful (LaTeX) title pages for Org-Bandbook to the
  'library-of-title-pages'.


1.6.5 Artwork
-------------

  Add artwork for title pages and other parts of Org-Bandbook to the
  'library-of-artwork.


1.6.6 Source Code
-----------------

  Bug Reports and Patches welcome.



					 Emacs 24.3.1 (Org mode 8.3beta)
