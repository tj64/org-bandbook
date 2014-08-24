;;; org-bandbook.el --- Functions for Org-Bandbook

;; Author: Thorsten Jolitz <tjolitz AT gmail DOT com>
;; Version: 0.9
;; URL: https://github.com/tj64/org-bandbook

;;;; MetaData
;;   :PROPERTIES:
;;   :copyright: Thorsten Jolitz
;;   :copyright-years: 2014+
;;   :version:  0.9
;;   :licence:  GPL 3 or later (free software)
;;   :licence-url: http://www.gnu.org/licenses/
;;   :part-of-emacs: no
;;   :author: Thorsten Jolitz
;;   :author_email: tjolitz AT gmail DOT com
;;   :inspiration:  https://github.com/veltzer/openbook
;;   :keywords: emacs org-mode taskjuggler lilypond
;;   :git-repo: https://github.com/tj64/org-bandbook
;;   :git-clone: git://github.com/tj64/org-bandbook.git
;;   :END:

;;;; Commentary

;; Emacs Lisp functionality for "Org-Bandbook - Professional
;; Band Management for Computer-Literate Musicians".

;;; Requires

(eval-when-compile (require 'cl))
(require 'puml)
(require 'org-dp-lib)

;;; Variables

;; ;; Reset leftover global vars
;; (setq org-bandbook-temp-dir nil
;;       org-bandbook-current-temp-subdir nil
;;       org-bandbook-current-project-dir nil
;;       org-bandbook-directory nil)

;;;; Consts

(defconst org-bandbook-mako-attribute-regexp
  (concat
   "\\(?:[[:space:]]*\\)\\(?:attributes\\['\\)\\([[:word:]]+\\)"
   "\\(?:'\\]=\\)\\([^\n]+\\)")
  "Match attributes in mako file. Subgroup 1 has the attribute
  name, subgroup 2 the corresponding value.")

(defconst org-bandbook-mako-part-regexp
  (concat
   "\\(?:% if part=='\\)\\([[:word:]]+\\)\\(?:':\\)"
   "\\([^\\000]+?\\)\\(?:% endif\\)")
   ;; "\\([^^@]+?\\)\\(?:% endif\\)") ; replace with NUL byte
  "Match parts in mako file. Subgroup 1 has the part name,
  subgroup 2 the part content.")

(defconst org-bandbook-song-key-regexp
  (concat
   "\\(?:^[[:space:]]*\\\\key[[:space:]]+\\)\\([a-z]+\\)"
   "\\(?:[[:space:]\\]+\\)\\(minor\\|major\\)")
  "Match key definition in song file. Subgroup 1 has the key,
  subgroup 2 the mode (major or minor).")

(defconst org-bandbook-link-regexp
  (concat
   "\\(?:\\[\\[[^:]+:\\)\\([^]]+\\)\\(?:\\]\\[[^]]+\\]\\]\\)")
  "Match Org link. Subgroup 1 has the path.")

(defconst org-bandbook-mako-music-parts
  '("Chords" "Voice" "Lyrics" "Lyricsmore" "Lyricsmoremore")
  "List of mako part names that contain music.")

(defconst org-bandbook-mako-sheet-music-references
 '("Real" "Fake" "Aebersold" "Unknown" "Wikifonia" "Epdf0" "My")
  "List of referenced sheet-music books.")

(defconst org-bandbook-mako-non-music-parts
  '("Vars" "Doc")
  "List of mako part names that do not contain music.")

(defconst org-bandbook-people-properties
  (list "resource_id" "phone" "address" "instrument")
  "List of Org-Bandbook people properties.")

(defconst org-bandbook-instrument-properties
  (list "name" "abbrev" "pitch")
  "List of Org-Bandbook instrument properties.")

(defconst org-bandbook-song-properties
  (list "file_link" "key" "mode" "structure" "transpose")
  "List of Org-Bandbook song properties.
These properties are used for song-config-files in a project's
'song' directory.")

;; derived/imported from .mako files of 'open-book' project
(defconst org-bandbook-library-of-songs-props
  (list "lyricsurl" "idyoutube" "idyoutuberemark" "structure"
	"structureremark" "completion" "copyright" "copyrightextra"
	"remark" "poet" "piece" "composer" "style" "title"
	"subtitle" "render" "doLyrics" "doLyricsmore"
	"doLyricsmoremore" "doVoice" "doChords" "uuid")
  "List of Org-Bandbook song properties.
These properties are used for song-score-files in Org-Bandbook's
'library-of-songs'.")

(defconst org-bandbook-master-properties
  (list "export_header" "song_order" "book_parts" "project_people")
  "List of Org-Bandbook master properties.")

(defconst org-bandbook-project-properties
  (append org-bandbook-master-properties
	  org-bandbook-song-properties
	  org-bandbook-instrument-properties
	  org-bandbook-people-properties)
  "List of Org-Bandbook project properties.")

(defconst org-bandbook-org-properties
 (append org-custom-properties org-default-properties org-global-properties org-special-properties org-file-properties)
  "List of Org system properties.")

(defconst org-bandbook-arrangement-column-labels
  (list (cons "seq" "%s")
	(cons "do" "%sx")
	(cons "mel" "Melody")
	(cons "solo" "Solo")
	(cons "comp" "Comping")
	(cons "riff" "Riffing"))	
  "Column labels of song arrangement table.
Given as cons pairs with the label in the car and a (format) string
in the cdr, to be used in PlantUML activity diagrams.")

(defconst org-bandbook-project-name-src-block
  (concat
   "\n#+name: project-name\n"
   "#+header: :results silent\n"
   "#+header: :exports none\n"
   "#+begin_src emacs-lisp\n"
   "  (mapconcat\n"
   "   'capitalize\n"
   "   (cdr\n"
   "    (split-string\n"
   "     (file-name-nondirectory\n"
   "      (directory-file-name\n"
   "        org-bandbook-current-project-dir))\n"
   "     \"-\" 'OMIT-NULLS))\n"
   "    \" \")\n"
   "#+end_src\n")
  "Utility src_block that gets project name.")

(defconst org-bandbook-current-date-src-block
   (concat
    "\n#+name: curr-date\n"
    "#+header: :results silent\n"
    "#+header: :exports none\n"
    "#+begin_src emacs-lisp\n"
    " (format-time-string \"<%Y-%m-%d %T>\")\n"  
    "#+end_src\n")
  "Utility src_block that gets current date and time.")

(defconst org-bandbook-project-dir-files
  (list
   "journal.ledger" "instruments.org" "master.org" "people.org"
   "reports" "songs" "timeline-and-tasks.org" "tmp")
  "List of expected files in Org-Bandbook project directory.")

(defconst org-bandbook-dir-files
  (list
   "common.ly" "doc" ".git" "lib" "library-of-accounting-schemes"
   "library-of-artwork" "library-of-headers" "library-of-songs"
   "library-of-title-pages" "project-massey-hall-1953" "score.org"
   "src" "tmp")
  "List of expected files in Org-Bandbook directory.")

(defconst org-bandbook-config-files
  (list "instruments.org" "master.org" "people.org")
  "List of Org-Bandbook configuration files.")

(defconst org-bandbook-arrangement-diagram-page-break-limits
  (list '(small . 14) '(medium . 7))
  "Alist of diagram-styles and page-break-limits.")

;;;; Vars

(defvar org-bandbook-temp-dir
  (make-temp-file "bandbook-" 'DIR-FLAG)
  "Main directory for org-bandbook temp files.")

(defvar org-bandbook-current-temp-subdir nil
  "Current sub-directory for org-bandbook temp files.")

(defvar org-bandbook-current-project-dir nil
  "Storage for current project's directory name.")

(defvar org-bandbook-directory (expand-file-name "../")
  "Path to org-bandbook repo.")

;;;; Customs
;;;;; Custom Groups

(defgroup org-bandbook nil
  "Professional band-management for computer-literate musicians."
  :prefix "org-bandbook-"
  :group 'lisp
  :link '(url-link "https://github.com/tj64/org-bandbook"))

;;;;; Custom Vars

;; FIXME
(defcustom org-bandbook-arrangement-diagram-type 'notes
  "Possible types for arrangement diagrams.
Type is based on the backend-constructs used for creating the
diagram, e.g. PlantUML (activities with) notes, sequence-bars or
partitions."
  :group 'org-bandbook
  :type '(choice (const :tag "Notes" notes)
		 ;; (const :tag "Sync-bars" 'sync-bars)
		 ;; (const :tag "Partitions" 'partitions)
		 ))

(defcustom org-bandbook-arrangement-diagram-size 'small
  "Size of arrangement diagrams.
Size 'small' minimizes all diagram elements and thus allows to
present more arrangement-table rows on one page. Style 'medium'
creates bigger and thus more readable diagram elements, suitable
for arrangement-tables with no more rows than specified in
`org-bandbook-arrangement-diagram-page-break-limits'."
  :group 'org-bandbook
  :type '(choice (const :tag "Small" small)
		 (const :tag "Medium" medium)))

(defcustom org-bandbook-arrangement-diagram-title "Arrangement"
  "Arrangement diagram title."
  :group 'org-bandbook
  :type 'string)

(defcustom org-bandbook-arrangement-diagram-with-title-p nil
  "Add title to arrangement diagram if non-nil.
The title can be customized with
`org-bandbook-arrangement-diagram-title'"
  :group 'org-bandbook
  :type 'boolean)

(defcustom org-bandbook-with-abstract-p nil
  "Add abstract to bandbook if non-nil."
  :group 'org-bandbook
  :type 'boolean)

(defcustom org-bandbook-arr-diag-scale-factor 0.74
  "Default scale for arrangement diagrams."
  :group 'org-bandbook
  :type 'number)


;;; Functions
;;;; Advices

(defadvice org-taskjuggler-export (around org-taskjuggler-export-around)
  "Run taskjuggler-exporter in well defined environment.
'org-bandbook.el' must be on your load-path and current buffer's
buffer-file in the top-level of a well-structured org-bandbook
project to trigger new behaviour through this advice."
  (if (and (require 'org-bandbook nil t)
	   (org-bandbook-current-project))
      (let ((org-taskjuggler-extension ".tjp")
	    (org-taskjuggler-project-tag "taskjuggler_project")
	    (org-taskjuggler-resource-tag "taskjuggler_resource")
	    (org-taskjuggler-report-tag "taskjuggler_report")
	    (org-taskjuggler-target-version 3.0)
	    (org-taskjuggler-default-project-version "1.0")
	    (org-taskjuggler-default-project-duration 1)
	    (org-taskjuggler-default-global-header "")
	    (org-taskjuggler-default-global-properties "")
	    (org-taskjuggler-valid-task-attributes
	     '(account start
		       note duration endbuffer endcredit end flags
		       journalentry length limits maxend maxstart minend
		       minstart period reference responsible scheduling
		       startbuffer startcredit statusnote chargeset charge))
	    (org-taskjuggler-valid-project-attributes
	     '(timingresolution timezone alertlevels currency
				currencyformat dailyworkinghours extend
				includejournalentry now numberformat outputdir scenario
				shorttimeformat timeformat trackingscenario
				weekstartsmonday weekstartssunday workinghours
				yearlyworkingdays))
	    (org-taskjuggler-valid-resource-attributes
	     '(limits vacation shift booking efficiency journalentry rate
		      workinghours flags))
	    (org-taskjuggler-valid-report-attributes
	     '(headline columns definitions timeformat hideresource hidetask
			loadunit sorttasks formats period))
	    (org-taskjuggler-process-command
	     "tj3 --silent --no-color --output-dir %o %f")
	    (org-taskjuggler-reports-directory "reports")
	    (org-taskjuggler-keep-project-as-task t)
	    (org-taskjuggler-default-reports
	     '("textreport report \"Plan\" {
  formats html
  header '== %title =='

  center -8<-
    [#Plan Plan] | [#Resource_Allocation Resource Allocation]
    ----
    === Plan ===
    <[report id=\"plan\"]>
    ----
    === Resource Allocation ===
    <[report id=\"resourceGraph\"]>
  ->8-
}

# A traditional Gantt chart with a project overview.
taskreport plan \"\" {
  headline \"Project Plan\"
  columns bsi, name, start, end, effort, chart
  loadunit shortauto
  hideresource 1
}

# A graph showing resource allocation. It identifies whether each
# resource is under- or over-allocated for.
resourcereport resourceGraph \"\" {
  headline \"Resource Allocation Graph\"
  columns no, name, effort, weekly
  loadunit shortauto
  hidetask ~(isleaf() & isleaf_())
  sorttasks plan.start.up
}"))))
    ad-do-it)
  ad-do-it)

(ad-activate 'org-taskjuggler-export)

;;;; Non-interactive Functions

;;;;; Utility Functions

;;;;;; General

;; copied from s.el
(defun org-bandbook--split-words (s)
  "Split S into list of words."
  (s-split
   "[^[:word:]0-9]+"
   (let ((case-fold-search nil))
     (replace-regexp-in-string
      "\\([[:lower:]]\\)\\([[:upper:]]\\)" "\\1 \\2"
      (replace-regexp-in-string
       "\\([[:upper:]]\\)\\([[:upper:]][0-9[:lower:]]\\)"
       "\\1 \\2" s)))
   t))

(defun org-bandbook--extract-path-from-org-link (link)
  "Extract absolute path from org LINK."
  (ignore-errors
      (expand-file-name
       (replace-regexp-in-string
	org-bandbook-link-regexp "\\1" link))))

;; copied from kv.el
(defun org-bandbook--plist-to-alist (plist &optional keys-are-keywords)
  "Convert PLIST to an alist.

The keys are expected to be :prefixed and the colons are removed
unless KEYS-ARE-KEYWORDS is `t'.

The keys in the resulting alist are always symbols."
  (when plist
    (loop for (key value . rest) on plist by 'cddr
       collect
         (cons (if keys-are-keywords
                   key
		 (org-bandbook--keyword-to-symbol key))
               value))))

;; copied from kv.el
(defun org-bandbook--alist-keys (alist)
  "Get just the keys from the alist."
  (mapcar (lambda (pair) (car pair)) alist))

;; copied from kv.el
(defun org-bandbook--alist-values (alist)
  "Get just the values from the alist."
  (mapcar (lambda (pair) (cdr pair)) alist))

(defun org-bandbook--plist-keys  (plist &optional as-keywords-p)
  "Get just the keys from the plist.
The keys are expected to be :prefixed and the colons are removed
unless AS-KEYWORDS-P is non-nil."
  (org-bandbook--alist-keys
   (org-bandbook--plist-to-alist plist as-keywords-p)))

(defun org-bandbook--plist-values (plist)
  "Get just the values from the plist."
  (org-bandbook--alist-values
   (org-bandbook--plist-to-alist plist)))

;; copied from kv.el
(defun org-bandbook--keyword-to-symbol (keyword)
  "A keyword is a symbol leading with a :.

Converting to a symbol means dropping the :."
  (if (keywordp keyword)
      (intern (substring (symbol-name keyword) 1))
    keyword))

;; copied from outorg.el
(defun org-bandbook--remove-trailing-blank-lines ()
  "Remove all trailing blank lines from buffer.
Finally add one newline."
  (save-excursion
    (let ((inhibit-read-only t))
      (goto-char (point-max))
      (delete-region
       (point)
       (progn
	 (while (and (not (bobp))
		     (looking-at "^[ \t]*$"))
	   (forward-line -1))
	 (forward-line 1)
	 (point))))))

(defun org-bandbook--goto-first-heading ()
  "Move point to beginning of first heading."
  (goto-char (point-min))
  (or (org-on-heading-p)
      (outline-next-heading)))

(defun org-bandbook--clean-string (strg)
  "Convert STRG \"\"foo\"\" into \"foo\"."
  (when (org-string-nw-p strg)
    (car (split-string strg "\"" 'OMIT-NULLS))))

(defun org-bandbook--get-parent-dir-name (&optional file-name)
  "Return parent-dir name of bandbook file FILE-NAME or nil."
  (ignore-errors
    (file-name-sans-extension
     (file-name-nondirectory
      (directory-file-name
       (file-name-directory
	(org-bandbook--get-path
	 (or file-name (buffer-file-name)))))))))

;;;;;; Bandbook Specific

(defun org-bandbook--combine-music-parts-and-references ()
  "Return list of lists with all possible combinations.
For each member in `org-bandbook-mako-music-parts' a list with
all combinations with members of
`org-bandbook-mako-sheet-music-references' is created. All
created lists are then enclosed in another list."
   (mapcar
    (lambda (--part)
       (mapcar
	(lambda (--ref)
	  (concat --part --ref))
	org-bandbook-mako-sheet-music-references))
    org-bandbook-mako-music-parts))

(defun org-bandbook--get-num-prefix (file)
  "Return numeric prefix of FILE name."
  (string-to-number
   (car (org-bandbook--split-words
	 (file-name-sans-extension
	  (file-name-nondirectory file))))))

(defun org-bandbook--expand-instr-abbrevs (strg)
  "Return human-readable version of abbrev STRG."
  (when (org-string-nw-p strg)
    (let ((abbrev-lst (split-string strg " " 'OMIT-NULLS))
	  (instr (org-bandbook--get-peoples-instruments)))
	 (mapconcat
	  (lambda (--abbrev)
	    (car (rassoc --abbrev instr)))
	  abbrev-lst " & "))))

(defun org-bandbook--get-props (&optional fallback)
  "Return current entry's filtered properties.
Only properties that are member of the relevant
`org-bandbook-XYZ-properties' for current buffer are considered,
except for song buffers from the 'library-of-songs'. If optional
argument FALLBACK is non-nil, it can be 'all (-> all unfiltered
properties are returned) or any other value (-> all non-org
properties are returned). Otherwise `nil' is returned as
default."
  (let* ((buf (car-safe (member (buffer-name)
				org-bandbook-config-files)))
	 (parent-dir (unless buf
		       (org-bandbook--get-parent-dir-name)))
	 (songs-dir-p (and parent-dir
			   (string= parent-dir "songs")))
	 (grandparent-dir (and parent-dir
			       (not songs-dir-p)
			       (string=
				(ignore-errors
				  (org-bandbook--get-parent-dir-name
				   (directory-file-name
				    (file-name-directory
				     (buffer-file-name)))))
				"library-of-songs"))))
  (cond
   (buf (org-dp-filter-node-props
	 (eval
	  (intern
	   (format "org-bandbook-%s-properties"
		   (car (split-string buf "\\.")))))))
   (songs-dir-p (org-dp-filter-node-props
		 org-bandbook-song-properties))
   (grandparent-dir (org-dp-filter-node-props
		     org-bandbook-library-of-songs-props))
   (t (cond 
	((eq fallback 'all) (org-entry-properties))
	(fallback (org-dp-filter-node-props 'org t))
	(t nil))))))

;;;;; Project Info

(defun org-bandbook--get-project-name ()
  "Return capitalized project name."
  (mapconcat
   'capitalize
   (cdr
    (split-string
     (file-name-nondirectory
      (directory-file-name
       org-bandbook-current-project-dir))
     "-" 'OMIT-NULLS))
   " "))

(defun org-bandbook--get-path (file &optional project)
  "Return absolute path to FILE in PROJECT."
  (let* ((proj (or project (org-bandbook-current-project)))
	 (path (expand-file-name file proj))
	 (exists-p (file-exists-p path)))
    ;; (if (and proj exists-p)
    (if exists-p
    	path
      (error "Not in Org-Bandbook project (path: %s)" path))))

(defun org-bandbook--get-resource-ids (&optional project)
  "Return list of resource_ids from PROJECTs master.org file."
  (let ((live-buf (get-buffer "master.org"))
	(buf (ignore-errors
	       (find-file-noselect
		(org-bandbook--get-path "master.org" project))))
	resource_ids)
    (when buf
      (with-current-buffer buf
	(goto-char
	 (org-find-exact-headline-in-buffer
	  "Master"))
	(setq resource_ids (org-entry-get nil "project_people"))
	(unless (eq live-buf (current-buffer))
	  (kill-buffer)))
      (split-string resource_ids nil 'OMIT-NULLS))))

(defun org-bandbook--get-all-project-people-as-list (&optional project)
  "Return alist of PROJECT people."
  (let ((live-buf (get-buffer "people.org"))
	(buf (ignore-errors
	       (find-file-noselect
		(org-bandbook--get-path
		 "people.org" project))))
	people)
    (when buf
      (with-current-buffer buf
	(org-map-entries
	 (lambda ()
	   (let ((filtered-props
		  (org-bandbook--get-props)))
	     (when filtered-props
	       (setq people
		     (cons
		      (cons
		       (org-no-properties
			(org-get-heading t t))
		       filtered-props)
		      people))))))
	(unless (eq live-buf (current-buffer))
	  (kill-buffer)))
      people)))
      ;; (car (read-from-string people)))))

(defun org-bandbook--get-active-project-people-as-strg ()
  "Get filtered buffer-string of project's people.org."
  (when (org-bandbook-current-project)
    (let ((ids (org-bandbook--get-resource-ids))
	  (people ""))
      (with-temp-buffer
	(insert-file-contents
	 (org-bandbook--get-path "people.org") nil nil nil t)
	(org-mode)
	(org-element-map
	    (org-element-parse-buffer 'headline)
	    'headline	    
	  (lambda (--elem)
	    (let ((id (org-element-property :RESOURCE_ID --elem)))
	      (and id (org-string-nw-p id)
		   (member-ignore-case id ids)
		   (setq people
			 (concat
			  (org-trim
			   (buffer-substring-no-properties
			    (org-element-property :begin --elem)
			    (org-element-property :end --elem)))
			  "\n"
			  people)))))))
      people)))
		   
(defun org-bandbook--get-project-instruments (&optional project)
  "Return alist of PROJECT instruments."
  (let ((live-buf (get-buffer "instruments.org"))
	(buf (ignore-errors
	       (find-file-noselect
		(org-bandbook--get-path
		 "instruments.org" project))))
	instruments)
    (when buf
      (with-current-buffer buf
	(org-map-entries
	 (lambda ()
	   (let ((proj-props
		  (org-bandbook--get-props)))
	     (and proj-props 
		  (setq instruments
			(cons
			 (cons
			  (org-no-properties
			   (org-get-heading t t))
			  proj-props)
			 instruments))))))
	(unless (eq live-buf (current-buffer))
	  (kill-buffer)))
      instruments)))
      ;; (car (read-from-string instruments)))))

(defun org-bandbook--get-peoples-instruments ()
  "Get project instrument names and abbrevs."
  (interactive)
  (let* ((instr (org-bandbook--get-project-instruments))
  	 (people (org-bandbook--get-all-project-people-as-list))
  	 (resource_ids (org-bandbook--get-resource-ids))
	 arr-props)
    (mapc
     (lambda (--instr)
       (mapc
	(lambda (--person)
	  (mapc
	   (lambda (--resource_id)
	     (let ((person-resource_id
		     (cdr (assoc "resource_id" (cdr --person))))
		    (person-instr
		     (cdr (assoc "instrument" (cdr --person))))
		    (instr-name
		     (cdr (assoc "name" (cdr --instr)))))
	       (when (and (string= --resource_id person-resource_id)
			  (string= instr-name person-instr))
		 (setq arr-props
		       (cons
			(cons
			 (cdr (assoc "resource_id"
				     (cdr --instr)))
			 (cdr (assoc "abbrev"
				     (cdr --instr))))
			arr-props)))))
	   resource_ids))
	people))
     instr)
    arr-props))

(defun org-bandbook--check-project-structure (proj-dir)
  "Return PROJ-DIR if its structure is correct, nil otherwise."
  (when (file-directory-p proj-dir)
    (let ((bb-dir (file-name-directory
		   (directory-file-name proj-dir))))
      (when (and (= (length org-bandbook-project-dir-files)
		    (length (intersection
			     org-bandbook-project-dir-files
			     (directory-files proj-dir)
			     :test 'string=)))
		 (= (length org-bandbook-dir-files)
		    (length (intersection
			     org-bandbook-dir-files
			     (directory-files bb-dir)
			     :test 'string=))))
	proj-dir))))


(defun org-bandbook--get-abstract (&optional project)
  "Return content of project's abstract.org file."
  (when org-bandbook-with-abstract-p
    (let ((proj (or project org-bandbook-current-project-dir)))
      (with-current-buffer
	  (find-file-noselect
	   (org-bandbook--get-path "abstract.org" proj))
	(save-restriction
	  (widen)
	  (let ((buf-cont
		 (org-element-map (org-element-parse-buffer)
		     'headline
		   (lambda (--hl)
		     (and (string=
			   (org-element-property :raw-value --hl)
			   "Abstract")
			  (org-element-interpret-data
			   (org-element-contents --hl))))
		   nil 'FIRST-MATCH 'NO-RECURSION)))
	    (kill-buffer)
	    ;; (message "%s" buf-cont)
	    buf-cont))))))

(defun org-bandbook-current-project ()
  "Return project-name if in (top-level of) org-bandbook project.
Assumes `buffer-file-name' of `current-buffer' is master.org file
of project. With SILENT non-nil, do not message the project
name."
  (let* ((curr-dir (if (derived-mode-p 'dired-mode)
		       (dired-current-directory)
		     (ignore-errors
		       (file-name-directory
			(buffer-file-name
			 (current-buffer))))))
	 (parent-dir (when curr-dir
		       (file-name-directory
			(directory-file-name curr-dir))))
	 (grandparent-dir (when parent-dir
			    (file-name-directory
			     (directory-file-name parent-dir))))
	 (parent-dir-name (when parent-dir
	 		    (file-name-nondirectory
	 		     (directory-file-name parent-dir))))
	 (grandparent-dir-name (when grandparent-dir
				 (file-name-nondirectory
				  (directory-file-name
				   grandparent-dir)))))
    (cond
     ((string= parent-dir-name "org-bandbook")
      (org-bandbook--check-project-structure curr-dir))
     ((string= grandparent-dir-name "org-bandbook")
      (org-bandbook--check-project-structure parent-dir))
     (t nil))))

;;;;; Song Info


(defun org-bandbook--get-song-arrangement ()
  "Return list of song arrangement properties.

Doing (car returnLst) gives an alist with info about project
instruments, i.e. with cons pairs like 

  (\"instr\" . \"abbrev\")

Doing (nthcdr 2 (cadr returnLst)) gives an alist of song
activities, each sublist with 6 (possibly empty) string members:

 - nth 0 :: song part played
 - nth 1 :: times the part is repeated
 - nth 2 :: instrument(s) playing melody
 - nth 3 :: instrument(s) soloing
 - nth 4 :: instrument(s) comping
 - nth 5 :: instrument(s) riffing

see `org-bandbook-arrangement-column-labels'."
  (and (org-bandbook-current-project)
       (eq (derived-mode-p 'org-mode) major-mode)
       (save-excursion
	 (condition-case err
	     (goto-char
	      (org-find-exact-headline-in-buffer "arrangement"))
	   (error "No exact headline 'arrangement' in buffer %s"
		  (current-buffer)))
	 (let ((props (org-dp-filter-node-props 'org t))
	       tbl)
	   (save-restriction
	     (org-narrow-to-subtree)
	     (org-table-map-tables
	      (lambda ()
		(setq tbl (list (org-table-to-lisp))))))
	   (cons props tbl)))))


(defun org-bandbook--get-song-properties ()
  "Return alist of song properties."
  (when (org-bandbook-current-project)
    (let ((song (org-find-exact-headline-in-buffer
		 "song" nil 'POS-ONLY)))
      (when song
	(save-excursion
	  (goto-char song)
	  (org-bandbook--get-props))))))

(defun org-bandbook--get-song-link ()
  "Return song link or nil."
  (let ((link (cdr-safe
	       (assoc "file_link"
		      (org-bandbook--get-song-properties)))))
    (if (string-match org-bandbook-link-regexp link)
	(org-bandbook--extract-path-from-org-link link)
      link)))

(defun org-bandbook--get-song-key ()
  "Return song key or nil."
  (cdr-safe (assoc "key"
	      (org-bandbook--get-song-properties))))

(defun org-bandbook--get-song-mode ()
  "Return song mode or nil."
  (cdr-safe (assoc "mode"
	      (org-bandbook--get-song-properties))))

(defun org-bandbook--get-song-structure ()
  "Return song structure or nil."
  (cdr-safe (assoc "structure"
	      (org-bandbook--get-song-properties))))

(defun org-bandbook--get-song-transpose-pitch ()
  "Return song transpose-score info or nil."
  (cdr-safe (assoc "transpose_score"
	      (org-bandbook--get-song-properties))))

(defun org-bandbook-get-songs (&optional project)
  "Return sorted list of project songs.
Assume point is in top-level file-(buffer) of Org-Bandbook
project. Use absolute path to songs. If PROJECT is given it
should be a project-name without the 'project' prefix,
e.g. 'guitar-duo'."
  (let* ((live-buf (get-buffer "master.org"))
	 (buf (ignore-errors
		(find-file-noselect
		 (org-bandbook--get-path
		  "master.org" project)))))
    (when buf
      (with-current-buffer buf
	(let ((songlst (directory-files
			(expand-file-name
			 "songs" (org-bandbook-current-project))
			'FULL "^[[:digit:]]+-.+?\\.org$")))
	  (unless (eq live-buf (current-buffer))
	    (kill-buffer))
	  songlst)))))

;;;;; Music Functions

(defun org-bandbook-wrap-in-displayMusic (cont outfile)
  "Wrap CONTent in \displayMusic block and write to OUTFILE."
  (format
   (concat "{\n"
	   "  #(with-output-to-file\n"
	   "    %S\n"
	   "    (lambda () #{ \\displayMusic {\n"
	   "        %s\n"
	   "     } #}))\n"
	   "}")
   outfile cont))

(defun org-bandbook-wrap-in-transpose (cont from to)
  "Wrap CONTent in \transpose block (FROM -> TO)."
  (format "{\n \\transpose %s %s {\n %s\n }\n}" from to cont))


(defun org-bandbook-get-internal-representation (cont outfile)
  "Write internal representation of CONT to OUTFILE."
  (let* ((temporary-file-directory org-bandbook-temp-dir)
	(tmp-file (make-temp-file "display-music-" nil ".ly")))
    (with-current-buffer (find-file-noselect tmp-file)
      (insert (org-bandbook-wrap-in-displayMusic cont outfile))
      (save-buffer)
      (kill-buffer))
    (when (require 'ob-lilypond nil t)
      (ly-compile-lilyfile tmp-file))))

;; (defun org-bandbook-transpose-song ())

;;;;; Render Songs

(defun org-bandbook--render-song-parts (parts &optional transpose-from-to)
  "Return processed and concatenated PARTS.

PARTS is an alist of the form

  ((part-name . content) ... (part-name . content))

If TRANSPOSE-FROM-TO is non-nil, it should be a cons-pair of the
form:

  (\"c\" . \"d\")

with the actual key in the car and the target key in the cdr."
  (mapconcat
   (lambda (--part)
     (format "%s =\n%s\n"
	     (car --part)
	     (if (and transpose-from-to
		      (member (car --part) (list "Chords" "Voice")))
		 (org-bandbook-wrap-in-transpose
		  (cdr --part)
		  (car transpose-from-to)
		  (cdr transpose-from-to))
	       (cdr --part))))
   parts ""))

(defun org-bandbook--render-song-score (parts score-template)
  "Return score with PARTS, using SCORE-TEMPLATE."
  (let (score-components)
    (with-current-buffer (find-file-noselect score-template)
      (org-element-map
	  (org-element-parse-buffer 'element) 'src-block
	(lambda (--elem)
	  (let ((part-name
		 (cadr
		  (org-bandbook--split-words
		   (org-element-property :name --elem)))))
	    ;; (when (or (member part-name parts)
	    ;; 	      (string= part-name "Volta"))
	    (when (member part-name parts)
	      (setq score-components
		    (cons
		     (org-element-property :value --elem)
		     score-components))))))
      (mapconcat
       (lambda (--comp)
	 (format "\n%s\n" --comp))
       (reverse score-components) ""))))
  
(defun org-bandbook-render-song (song &optional transpose-from-to score-template)
  "Return SONG with relevant parts.
A SONG, which is an absolute path to an Org file containing a
song description, might have multiple versions of some parts and
might lack other parts alltogether. The score is created by
concatenating a selection of the SONG's parts obeying 'doX' and
'render' properties. A SONG with e.g. the following properties

  :PROPERTIES:
  :render:   \"Aebersold\"
  :doVoice:  True
  :doChords: True
  :END:

would be rendered with the Aebersold versions of the Voice and
Chords parts, no matter if there are other versions (Real, Fake
...) or additional parts (Lyrics, Lyricsmore ...) available.

If SCORE-TEMPLATE is 

 - nil :: just return the concatenated and processed song parts

 - a path to an existing org file :: use this file as a template
      to construct the score

 - any other non-nil value :: check if inside Org-Bandbook
      project and use contained score.org file as template

If TRANSPOSE-FROM-TO is non-nil it should be a cons-pair of the
form:

  (\"c\" . \"d\")

with the actual key in the car and the target key in the cdr."
  (let ((old-buf (current-buffer)))
    (let* ((song-buf (find-file-noselect song))
	   (version (or (ignore-errors
			  (with-current-buffer song-buf
			    ;; (replace-regexp-in-string
			    ;;  "\"" ""
			    (org-bandbook--clean-string
			     (org-entry-get nil "render"))))
			(error
			 "Song without 'render' attribute!")))
	   (part-names (delq nil
			     (mapcar
			      (lambda (--prop)
				(let ((split-prop-name
				       (org-bandbook--split-words
					(car --prop))))
				  (and
				   (= (length split-prop-name) 2)
				   (string=
				    (car split-prop-name) "do")
				   (member
				    (cadr split-prop-name)
				    org-bandbook-mako-music-parts)
				   (cadr split-prop-name))))
			      (with-current-buffer song-buf
				(org-entry-properties)))))
	   parts)
      (unless (member version
		      org-bandbook-mako-sheet-music-references)
	(message "%s not recognized as sheet-music reference!"
		 version))
      (with-current-buffer song-buf
	(org-element-map
	    (org-element-parse-buffer 'element) 'src-block
	  (lambda (--elem)
	    (let ((split-part-name
		   (org-bandbook--split-words
		    (org-element-property :name --elem))))
	      (unless (= (length split-part-name) 2)
		(error "%s has more than 2 components!"
		       split-part-name))
	      (and (member (car split-part-name) part-names)
		   (string= (cadr split-part-name) version)
		   (setq parts
			 (cons
			  (cons
			   (car split-part-name)
			   (org-element-property :value --elem))
			  parts))))))
	(concat
	 ;; common stuff
	 (format "\n%s\n"
		 (with-current-buffer old-buf
		   (when (org-bandbook-current-project)
		     (with-current-buffer
			 (find-file-noselect
			  (expand-file-name
			   "common.ly" org-bandbook-directory))
		       (buffer-substring-no-properties
			(point-min) (point-max))))))
	 ;; song parts
	 (org-bandbook--render-song-parts parts transpose-from-to)
	 ;; score
	 (cond
	  ((and (org-string-nw-p score-template)
		(file-exists-p score-template)
		(string= (file-name-extension score-template)
			 "org"))
	   (format "\n<<%s>>\n"
		   (org-bandbook--render-song-score
		    part-names score-template)))
	  ((and score-template
		(with-current-buffer old-buf
		  (org-bandbook-current-project)))
	   (format "\n<<%s>>\n"
		   (org-bandbook--render-song-score
		    part-names
		    (with-current-buffer old-buf
		      (expand-file-name
		       "score.org" org-bandbook-directory)))))
	  (t "")))))))

(defun org-bandbook-render-project-songs (&optional ordered-project-songs)
  "Render all songs from current project."
  (if (org-bandbook-current-project)
      (progn
	(let ((ordered-song-names
	       (or ordered-project-songs
		   (org-bandbook-get-songs)))
	      song-lst)
	  ;; process songs and create song pages list
	  (mapc
	   ;; get song info
	   (lambda (--song)
	     (let* ((from-key
		     (with-current-buffer
			 (find-file-noselect --song)
		       (org-bandbook--get-song-key)))
		    (to-key
		     (with-current-buffer
			 (find-file-noselect --song)
		       (org-bandbook--get-song-transpose-pitch)))
		    (arrangement
		     (with-current-buffer
			 (find-file-noselect --song)
		       (let ((temporary-file-directory
			      org-bandbook-current-temp-subdir))
			 (puml-wrap
			  :scale org-bandbook-arr-diag-scale-factor
			  :file (file-name-nondirectory
				 (make-temp-file "arrangement"))
			  :ext "eps"
			  :cont (org-bandbook-arrangement-to-diagram)
			  :pproc t))))
		    (song-path
		     (with-current-buffer
			 (find-file-noselect --song)
		       (org-bandbook--extract-path-from-org-link
			(org-bandbook--get-song-link))))
		    (song-name (and song-path
				    (file-name-sans-extension
				     (file-name-nondirectory
				      song-path)))))
	       ;; create content for song
	       (when song-name
		 (setq song-lst
		       (cons
			(concat
			 ;; newpage
			 (org-dp-create
			  'keyword nil nil nil
			  :key 'latex
			  :value "\\newpage")
			 "\n"
			 ;; headline
			 (org-dp-create
			  'headline nil nil nil
			  :level 1
			  :title (mapconcat
				  (lambda (--word) (upcase --word))
				  (org-bandbook--split-words
				   song-name) " "))
			 "\n"
			 ;; src-block
			 (org-dp-create
			  'src-block
			  ;; contents
			  (if (and to-key from-key)
			      (org-bandbook-render-song
			       song-path (cons from-key to-key) t)
			    (org-bandbook-render-song
			     song-path nil t))
			  ;; insert-p
			  nil
			  ;; affiliated
			  (list :name song-name
				:header `(":exports results"
					  ,(format ":file %s"
						   (concat
						    song-name
						    ".eps"))))
			  ;; args
			  :languate 'lilypond)
			 "\n"
			 ;; newpage
			 (org-dp-create 'keyword nil nil nil
					:key 'latex
					:value "\\newpage")
			 "\n"
			 ;; arrangement
			 (format "%s" arrangement)
			 ;; newpage
			 (org-dp-create 'keyword nil nil nil
					:key 'latex
					:value "\\newpage")
			 "\n")
			song-lst)))))
	   ;; (org-bandbook-get-songs))
	   ordered-song-names)
	  ;; Return song pages as concatenated string
	  (mapconcat 'identity song-lst "\n")))
    (error "Not in Org-Bandbook project (path: %s)"
	   (ignore-errors
	     (file-name-directory
	      (buffer-file-name (current-buffer)))))))


			;; (format
			;;  (concat
			;;   "\n#+latex: \\newpage\n"
			;;   "\n* %s\n"
			;;   ;; "  :PROPERTIES:\n"
			;;   ;; "  :END:\n\n")
			;;   "\n#+name: %s\n"
			;;   "#+header: :exports results\n"
			;;   "#+header: :file %s\n"
			;;   "#+begin_src lilypond\n"
			;;   ;; ":exports results :file %s\n"
			;;   "%s\n#+end_src\n"
			;;   "\n#+latex: \\newpage\n"
			;;   "%s"
			;;   "\n#+latex: \\newpage\n")
			;;  (mapconcat
			;;   (lambda (--word) (upcase --word))
			;;   (org-bandbook--split-words song-name) " ")
			;;  song-name
			;;  (concat song-name ".eps")
			;;  (if (and to-key from-key)
			;;      (org-bandbook-render-song
			;;       song-path (cons from-key to-key) t);)
			;;    (org-bandbook-render-song
			;;     song-path nil t))
			;;  arrangement)


;;;;; Change Song Order

(defun org-bandbook--make-extended-project-song-list (&optional project)
  "Create list of plists with extended info about project songs.
Keys are :name, :ID, :key, :mode, :transp and :struct. 

If given, PROJECT should be a project-name without the 'project-'
prefix, e.g. 'guitar-duo'."
  (let* ((live-buf (get-buffer "master.org"))
	 (buf (ignore-errors
		(find-file-noselect
		 (org-bandbook--get-path
		  "master.org" project)))))
    (when buf
      (with-current-buffer buf
	(let ((ext-songlst
	       (mapcar
		(lambda (--song)
		  (let* ((song-name
			  (file-name-sans-extension
			   (file-name-nondirectory --song)))
			 (split-name
			  (org-bandbook--split-words song-name))
			 results)
		    (setq results
			  (plist-put results :name
				     (mapconcat
				      'identity
				      (cdr split-name) "-")))
		    (setq results
			  (plist-put results :ID
				     (string-to-number
				      (car split-name))))
		    (with-current-buffer
			(find-file-noselect --song)
		      (org-bandbook--goto-first-heading)
		      (setq results
			    (plist-put
			     results :key
			     (org-entry-get nil "key")))
		      (setq results
			    (plist-put
			     results :mode
			     (org-entry-get nil "mode")))
		      (setq results
			    (plist-put
			     results :transp
			     (org-entry-get
			      nil "transpose_score")))
		      (setq results
			    (plist-put
			     results :struct
			     (org-entry-get
			      nil "structure"))))))
		(org-bandbook-get-songs))))
	  (unless (eq live-buf (current-buffer))
	    (kill-buffer))
	  ext-songlst)))))

;; adapted from ob-core.el
(defun org-bandbook--format-project-song-list (project-songs &optional sep)
  "Format PROJECT-SONGS for song overview table."
  (let ((echo-res (lambda (r) (if (stringp r) r (format "%S" r))))
	(processed-song-list
	 (when (listp project-songs)
	   (append
	    ;; column labels
	    (list (org-bandbook--plist-keys (car project-songs)))
	    ;; hline
	    (list 'hline)
	    ;; songs
	    (mapcar
	     (lambda (--song)
	       (org-bandbook--plist-values --song))
	     project-songs)))))
    (if processed-song-list
	;; table project-songs
	(orgtbl-to-orgtbl
	 processed-song-list
	 (list :sep (or sep "\t") :fmt echo-res))
      ;; scalar project-songs
      (funcall echo-res project-songs)))) 

(defun org-bandbook--update-song-order-overview (ordered-song-lst)
  "Update table showing human readable ORDERED-SONG-LST."
  (save-excursion
    (ignore-errors
      (org-table-map-tables
       (lambda ()
	 (org-mark-element)
	 (when (region-active-p)
	   (delete-region
	    (region-beginning)
	    (region-end)))) 'QUIETLY))
    (org-bandbook--remove-trailing-blank-lines)
    (save-excursion
      (goto-char (point-max))
      (newline)
      (insert
       (org-bandbook--format-project-song-list
	ordered-song-lst "|")))))

;;;;; Create arrangement diagram

;;;;;; Dispatcher Function
 
(defun org-bandbook-arrangement-to-diagram (&optional buf-or-name)
  "Return diagram for song arrangement.
Song is either current song or BUF-OR-NAME"
  (let ((buf (or buf-or-name
		 (and (org-bandbook-current-project)
		      (ignore-errors
			(string=
			 (file-name-nondirectory
			  (directory-file-name
			   (file-name-directory
			    (buffer-file-name
			     (current-buffer)))))
			 "songs"))
		      (current-buffer)))))
    (when buf
      (with-current-buffer buf
	(let* ((arrangement (org-bandbook--get-song-arrangement))
	       (instr (and arrangement (car arrangement)))
	       (activities (and arrangement
				(nthcdr 2 (cadr arrangement))))
	       (cnt-seq (and activities
			     (number-sequence
			      1 (length activities))))
	       ;; (lbls org-bandbook-arrangement-column-labels)
	       ;; (lbl-fmt-strgs (list (cdr (nth 0 lbls))
	       ;; 			    (cdr (nth 1 lbls))
	       ;; 			    (cdr (nth 2 lbls))
	       ;; 			    (cdr (nth 3 lbls))
	       ;; 			    (cdr (nth 4 lbls))
	       ;; 			    (cdr (nth 5 lbls))))
	       )
	  ;; call diagram constructor
	  (org-bandbook--create-plantuml-diagram
	   org-bandbook-arrangement-diagram-type
	   instr activities))))))

;;;;;; Diagram Constructor

(defun org-bandbook--create-plantuml-diagram (diagram-type instr activities)
  "Constructor for PlantUML arrangement diagrams.
Uses DIAGRAM-TYPE, INSTRuments and ACTIVITIES."
  (let* ((first-activity-p t)
	 (parts-counter 1)
	 diagram)
    ;; maybe set diagram title
    (and org-bandbook-arrangement-diagram-with-title-p
	 (org-string-nw-p org-bandbook-arrangement-diagram-title)
	 (setq diagram
	       (puml-title
		(puml-emph
		 (puml-size
		  (puml-sym-or-strg
		   org-bandbook-arrangement-diagram-title)
		  :pt 30)))))
    ;; loop over activities
    (while activities
      (let* ((--act (pop activities))
	     (--seq (nth 0 --act))
	     (--times (string-to-number (nth 1 --act)))
	     ;; (last-activity-p (= (length activities) 0))
	     (act-type (cond
			(first-activity-p 'start)
			;; (last-activity-p 'end)
			(t nil))))
	;; mark first activity as done
	(when (eq act-type 'start) (setq first-activity-p nil))
	;; create node and add it to diagram	   
	(setq diagram
	      (concat diagram
		      (funcall
		       (intern
			(format "org-bandbook--node-with-%s"
				diagram-type))
		       instr --act parts-counter act-type)))
	;; increase parts counter
	(setq parts-counter (1+ parts-counter))))
    ;; finally return diagram
    (puml-pack diagram
	       (puml-end-activity ; :arr (puml-arrow :len 1))
	       ))))

;;;;;; Node Constructor

(defun org-bandbook--node-with-notes (instr activity parts-counter &optional act-type)
  "Create node for PlantUML diagram with notes."
  (let* ((arr-col-lbls org-bandbook-arrangement-column-labels)
	 (notes (cddr arr-col-lbls))
	 (elem-cnt 2)
	 node)
    (while notes
      (let ((lbl (pop notes))
	    (activity-elem (nth elem-cnt activity)))
	(setq node
	      (concat
	       node
	       (if (org-string-nw-p activity-elem)
		   (case org-bandbook-arrangement-diagram-size
		     ('medium
		      (org-bandbook--medium-note
		       activity-elem (cdr lbl) elem-cnt instr))
		     ('small
		      (org-bandbook--small-note
		       activity-elem (car lbl) elem-cnt))
		     (t ""))
		 "")))
	(setq elem-cnt (1+ elem-cnt))))
    (puml-pack
     ;; activity
     (case act-type
       ('start
	(funcall 'puml-start-activity
		 :nm (case org-bandbook-arrangement-diagram-size
		       ('medium
			(org-bandbook--medium-activity-name
			 activity arr-col-lbls parts-counter))
		       ('small
			(org-bandbook--small-activity-name
			 activity arr-col-lbls parts-counter))
		       (t ""))))
		 ;; :arr (puml-arrow :len 1)))
       ;; ('end (funcall 'puml-end-activity :nm foo))
       (t (funcall 'puml-activity
		   :nm (case org-bandbook-arrangement-diagram-size
			 ('medium
			  (org-bandbook--medium-activity-name
			   activity arr-col-lbls parts-counter))
			 ('small
			  (org-bandbook--small-activity-name
			   activity arr-col-lbls parts-counter))
			 (t "")))))
     node)))

(defun org-bandbook--medium-activity-name (act col-lbls parts-cnt)
  "Create 'medium' PlantUML activity name."
  (puml-pack
   (puml-size
    (format (cdr (nth 1 col-lbls)) (nth 1 act))
    :pt 18 :crlf "\n")
   (puml-size
    (format (cdr (nth 0 col-lbls)) (upcase (nth 0 act)))
    :pt 26 :crlf "\n")
   (puml-size (format "(part %s)" parts-cnt) :pt 12)))

(defun org-bandbook--small-activity-name (act col-lbls parts-cnt)
  "Create 'small' PlantUML activity name."
  (puml-pack
   (puml-space
    (puml-size
     (format (cdr (nth 1 col-lbls)) (nth 1 act))
     :pt 16)
    :trail 1)
   (puml-space
    (puml-size
     (format (cdr (nth 0 col-lbls)) (upcase (nth 0 act)))
     :pt 16)
    :trail 1)
   (puml-size (format "(part %s)" parts-cnt) :pt 10)))

(defun org-bandbook--medium-note (act-elem lbl elem-cnt instr)
  "Create 'medium' PlantUML note."
  (puml-note
   (concat
    (puml-emph
     (mapconcat
      (lambda (--abbrev)
	(car (rassoc --abbrev instr)))
      (split-string activity-elem " " t)
      " & ")
     :crlf "\n")
    (puml-newline)
    (puml-emph lbl :type 'b))
   :ml t
   :dir (case elem-cnt
	  ((2 3) 'left)
	  ((4 5) 'right))))

(defun org-bandbook--small-note (act-elem lbl elem-cnt)
  "Create 'small' PlantUML note."
  (puml-note
   (concat
    (puml-emph lbl :type 'b)
    ": "
    (puml-emph act-elem))
   :ml t
   :dir (case elem-cnt
	  ((2 3) 'left)
	  ((4 5) 'right))))

;;;; Commands
;;;;; Import songs from mako

(defun org-bandbook-import-directory-mako-files  (dir)
  "Parse all mako files in DIR and convert them to org files."
  (interactive "DDirectory: ")
  (mapc
   (lambda (--file)
     (org-bandbook-import-mako-file
      --file))
   (directory-files dir 'FULL "\.mako$")))

(defun org-bandbook-import-mako-file (infile)
  "Parse mako file INFILE and convert it to org.

This works for the well and uniformly formatted .mako files in
the '/openbook/src/jazz/' directory. No attempts have been made
to deal with other types of file structuring/formatting. When
import does not work correctly, I suggest to adapt the .mako file
to the conventions of the Openbook jazz tunes."
  (interactive "fInput File (.mako): ")
  (with-temp-buffer
    (insert-file-contents infile)
    (let ((outfile-name (concat
			 (file-name-sans-extension infile)
			 ".org"))
	  (infile-name-nondirectory
	   (file-name-sans-extension
	    (file-name-nondirectory infile)))
	  ;; get properties
	  (attribute-alist
	   (save-excursion
	   (let (--attr)
	     (while (re-search-forward
		     org-bandbook-mako-attribute-regexp
		     nil 'NOERROR)
	       (setq --attr
		     (cons (cons (match-string 1)
				 (list
				  (match-string 2)))
			   --attr)))
	   --attr)))
	  ;; get parts
	  (part-alist 
	   (save-excursion
	   (let (--parts)
	     (while (re-search-forward
		     org-bandbook-mako-part-regexp
		     nil 'NOERROR)
	       (unless (member (match-string 1)
			       org-bandbook-mako-non-music-parts)
		 (setq --parts
		       (cons (cons (match-string 1)
				   (list (match-string 2)))
			     --parts))))
	     --parts))))
      (with-current-buffer (find-file-noselect outfile-name)
	(erase-buffer)
	;; 1st level headline
	(insert
	 (format "* %s" (upcase infile-name-nondirectory)))
	;; add properties
	(mapc
	 (lambda (--attr)
	   (org-set-property (car --attr) (cadr --attr)))
	 attribute-alist)
	;; insert parts
	(goto-char (point-max))
	(newline 3)		 
	(while part-alist
	  (let ((part (pop part-alist)))
	    (insert (format "#+name: %s\n" (car part)))
	    (insert (format "#+header: :file %s.eps\n"
			    (concat infile-name-nondirectory "_"
				    (car part))))
	    (insert (format (concat "#+begin_src lilypond \n%s\n"
				    "#+end_src\n\n")
			    (cadr part)))))
	(save-buffer)
	(kill-buffer)))))
	 

;;;;; Export songs to mako

(defun org-bandbook-export-directory-org-files  (dir)
  "Parse all org files in DIR and convert them to mako files."
  (interactive "DDirectory: ")
  (mapc
   (lambda (--file)
     (org-bandbook-export-org-file
      --file))
   (directory-files dir 'FULL "\.org$")))

(defun org-bandbook-export-org-file (infile)
  "Parse org file INFILE and convert it to mako.

This works for org files with one 1st level headline, many
headline properties, and otherwise only lilypond code-blocks,
i.e. for files that look like those imported from the well and
uniformly formatted .mako files in the '/openbook/src/jazz/'
directory.

No attempts have been made to deal with other types of org file
structuring. When export does not work correctly, I suggest to
adapt the .org file to the conventions of the
'/library-of-songs/jazz/' tunes."
  (interactive "fInput File (.org): ")
  (with-temp-buffer
    (insert-file-contents infile)
    (org-mode)
    (let ((outfile-name (concat
			 (file-name-sans-extension infile)
			 ".mako"))
	  (infile-name-nondirectory
	   (file-name-sans-extension
	    (file-name-nondirectory infile)))
	  ;; get properties
	  (node-props (org-entry-properties))
	  ;; get src-block names
	  (src-block-names (org-babel-src-block-names))
	  ;; get src-block bodies
	  (src-block-contents
	   (let (--parts)
	     (org-babel-map-src-blocks nil
	       (setq --parts (cons body --parts)))
	     --parts)))
      (with-current-buffer (find-file-noselect outfile-name)
	(erase-buffer)
	;; insert vars
	(insert
	 (concat
	  "<%page args=\"part\"/>\n"
	  "% if part=='Vars':\n"
	  "<%\n"
	  (mapconcat
	   (lambda (--prop)
	     (format "\tattributes['%s']=%S\n"
		     (car --prop)
		     (cdr --prop)))
	   (delq nil
		 (mapcar
		  (lambda (--cons)
		    (unless (or (member (car --cons)
					org-default-properties)
				(member (car --cons)
					org-special-properties))
		      --cons))
		  node-props)) "")
	  "\n%>\n% endif\n\n"))
	;; doc omitted
	;; insert parts
	(goto-char (point-max))
	(newline 2)		 
	(while src-block-names
	  (insert
	   (format
	    "%% if part=='%s':\n%s\n%% endif\n\n"
	    (pop src-block-names)
	    (pop src-block-contents))))
	(save-buffer)
	(kill-buffer)))))

    
;;;;; Parse Lilypond Syntax

(defun org-bandbook-parse-buffer (&optional in-file-or-buf verbose-p) 
  "Parse IN-FILE-OR-BUF and return parse-tree as list.
If IN-FILE-OR-BUF is nil, use `current-buffer'. When called
interactively, the user is prompted for IN-FILE-OR-BUF if
`current-prefix-arg' is non-nil."
  (interactive
   (when current-prefix-arg
     (if (y-or-n-p "Use buffer ")
	 (list (ido-read-buffer "Input Buffer: ")
	       (y-or-n-p "Write messages "))
       (list (ido-read-file-name "Input File: ")
	     (y-or-n-p "Write messages ")))))
  (let* ((buf (cond
	       ((bufferp in-file-or-buf)
		in-file-or-buf)
	       ((and in-file-or-buf
		     (file-exists-p in-file-or-buf))
		(find-file-noselect in-file-or-buf))
	       (t (current-buffer))))
	 (temporary-file-directory org-bandbook-temp-dir)
	 (tmp-out-file (make-temp-file "intern-repr-" nil ".scm")))
    (if (with-current-buffer buf
	  (or (eq major-mode 'LilyPond-mode)
	      (and (buffer-file-name buf)
		   (string= (file-name-extension
			     (buffer-file-name buf)) "ly"))))
	(let ((code (org-bandbook-get-internal-representation
		     (with-current-buffer buf
		       (buffer-substring-no-properties
			(point-min) (point-max)))
		     tmp-out-file)))
	  (if (not (= code 0))
	      (error
	       "Error compiling LilyPond (return code: %s)" code)
	    (when verbose-p
	      (message "Internal representation written to: %s"
		       tmp-out-file))
	    (with-current-buffer (find-file-noselect tmp-out-file)
	      (car
	       (read-from-string
		(buffer-substring-no-properties
		 (point-min) (point-max)))))))
      (user-error "Buffer %S not a LilyPond buffer?" buf))))
     
;;;;; Refresh Song Info

(defun org-bandbook-refresh-song-info ()
  "Get key/mode/form from song-link and update properties.

Assumes that point is in a song file in the <project>/songs/
directory that has a 'song' entry, and that this entry has a
'link' property with an Org-link (to an Org-Bandbook song in
the '/library-of-songs/' directory) as value."
  (interactive)
  (let* ((song-entry-marker
	  (org-find-exact-headline-in-buffer "song")) 
	 (path (ignore-errors
		 (org-bandbook--extract-path-from-org-link
		  (save-excursion
		    (goto-char song-entry-marker)
		    (org-entry-get nil "file_link")))))
	 (buf (if (and path (file-exists-p path))
		  (find-file-noselect path)
		(error "Could not get song link: %s" path)))
	 key mode structure)
    (with-current-buffer buf
      (re-search-forward
       org-bandbook-song-key-regexp nil 'NOERROR 1)
      (setq key (match-string 1))
      (setq mode (match-string 2))
      (org-bandbook--goto-first-heading)
      (setq structure (org-bandbook--clean-string
		       (org-entry-get nil "structure")))
      (kill-buffer))
    (save-excursion
      (goto-char song-entry-marker)
      (org-entry-put nil "key" key)
      (org-entry-put nil "mode" mode)
      (org-entry-put nil "structure" structure))))


;;;;; Refresh Song Order 

(defun org-bandbook-reset-song-order ()
  "Reset song-order to default.
The default order is the order of songs in the list returned by
`org-bandbook-get-songs'."
  (interactive)
  (let* ((song-lst (org-bandbook--make-extended-project-song-list))
	 (prefix-lst (mapconcat
		      (lambda (--song)
			(number-to-string
			 (plist-get --song :ID)))
		      song-lst " ")))
    (save-excursion
      (goto-char (org-find-exact-headline-in-buffer "Master" nil t))
      (org-entry-put nil "song_order" prefix-lst))
    (org-bandbook-refresh-song-order)))

(defun org-bandbook-refresh-song-order ()
  "Get key/mode from song-link and put them in properties.

Assumes that point is in a project's master.org file that
contains one the 1st-level 'Master' entry.

If this entry does not have property 'song_order', call
`org-bandbook-reset-song-order' to get all project songs in their
natural order, put their file-name's numerical prefix values into
this property, and update the entry's dynamic-block (for showing
the song-order in human-readable format).

Otherwise read the (possibly user modified) value of property
'song_order' and update the entry's dynamic-block to reflect the
any changes."
  (interactive)
  (save-excursion
    (goto-char (org-find-exact-headline-in-buffer "Master" nil t))
    (let ((order (ignore-errors (org-entry-get nil "song_order"))))
      (if (not (org-string-nw-p order))
	  (org-bandbook-reset-song-order)
	(let ((song-lst
	       (org-bandbook--make-extended-project-song-list))
	      (order-to-number
	       (mapcar 'string-to-number (split-string order)))
	      result-lst)
	  (mapc
	   (lambda (--num-prefix)
	     (mapc
	      (lambda (--song)
		(when (= (plist-get --song :ID)
			 --num-prefix)
		  (setq result-lst (cons --song result-lst))))
	      song-lst))
	   order-to-number)
	  (let ((reverse-res-lst (reverse result-lst)))
	    (org-bandbook--update-song-order-overview
	     reverse-res-lst)
	    reverse-res-lst))))))

;;;;; Refresh and Print Arrangement

(defun org-bandbook-refresh-arrangement-properties ()
  "Gather (and insert) info about project instruments.
Assumes that point is in a song file in the <project>/songs/
directory that has a 'arrangement' entry."
  (interactive)
  (when (org-bandbook-current-project)
    (save-excursion
      (goto-char
       (org-find-exact-headline-in-buffer "arrangement"))
      (mapc
       (lambda (--pair)
	 (org-entry-put nil (car --pair) (cdr --pair)))
       (org-bandbook--get-peoples-instruments)))))

;;;;; Make Bandbook

(defun org-bandbook-make-bandbook ()
  "Create bandbook for current project."
  (interactive)
  (if (org-bandbook-current-project)
      (progn
	;; set current tmp-subdir
	(let ((temporary-file-directory org-bandbook-temp-dir))
	  (setq org-bandbook-current-temp-subdir
		(make-temp-file "bandbook-" 'DIR-FLAG)))
	;; find tmp file
	(with-current-buffer
	    (find-file-noselect
	     (let ((temporary-file-directory
		    (expand-file-name "./")))
	       (make-temp-file "bandbook-" nil ".org")))
	  (setq org-bandbook-current-project-dir
		(expand-file-name "./"))
	  (let* ((master-buf (find-file-noselect
			      (expand-file-name "./master.org")))
		 (master-props
		  (with-current-buffer master-buf
		    (org-bandbook--get-props)))
		 (header
		  (org-string-nw-p
		   (cdr (assoc "export_header" master-props))))
		 (header-path
		  (and header
		       (org-bandbook--extract-path-from-org-link
			header)))
		 (song-order
		  (mapcar
		   'string-to-number
		   (org-bandbook--split-words
		    (org-string-nw-p
		     (cdr (assoc "song_order" master-props))))))
		 (song-lst
		  (with-current-buffer master-buf
		    (org-bandbook-get-songs)))
		 (book-parts
		  (org-string-nw-p
		   (cdr (assoc "book_parts" master-props))))
		 ;; (people
		 ;;  (org-string-nw-p
		 ;;   (cdr (assoc "project_people" master-props))))
		 ordered-song-lst)
	    ;; insert header
	    (if (and header-path
		     (file-exists-p header-path))
		(insert-file-contents header-path)
	      (insert-file-contents
	       (expand-file-name
		"default-header.org"
		(expand-file-name
		 "../library-of-headers/"))))
	    (goto-char (point-max))
	    (newline)
	    (save-buffer)
	    ;; insert songs
	    (mapc
	     (lambda (--num-prefix)
	       (mapc
		(lambda (--song)
		  (when (= (org-bandbook--get-num-prefix --song)
			   --num-prefix)
		    (setq ordered-song-lst
			  (cons --song ordered-song-lst))))
		song-lst))
	     song-order)
	    (insert
	     (org-bandbook-render-project-songs
	      ordered-song-lst))
	    (save-buffer)
	    ;; insert tasks
	    (when (member "tasks" (split-string book-parts " " t))
	      (newline)
	      (let* ((task-buf (find-file-noselect
				(expand-file-name
				 "timeline-and-tasks.org"
				 (org-bandbook-current-project))))
		     (org-use-tag-inheritance nil)
		     (timeline-buf (when (require 'org-agenda nil t)
				     (with-current-buffer task-buf
				       (org-timeline))
				     (get-buffer "*Org Agenda*"))))
		(insert-buffer-substring
		 task-buf
		 (org-find-exact-headline-in-buffer
		  "Timeline and Tasks" task-buf 'POS-ONLY)
		 (with-current-buffer task-buf
		   (point-max)))
		(insert
		 (format
		  (concat
		   "\n#+latex: \\newpage\n"
		   "** Timeline Overview %s\n%s")
		  (org-bandbook--get-project-name)
		  (insert-buffer-substring
		   timeline-buf
		   (with-current-buffer timeline-buf
		     (goto-char (point-min))
		     (forward-line)
		     (point))
		   (with-current-buffer timeline-buf
		     (goto-char (point-max))
		     (re-search-backward
		      "^\\[\\.\\.\\. [[:digit:]]+ "
		      nil t 1)
		     (match-beginning 0)))))
		(kill-buffer task-buf)
		(kill-buffer timeline-buf)))
	    ;; ;; insert funds
	    ;; (when (member "funds" (split-string book-parts " " t))
	    ;;   (newline)
	    ;;   (let ((task-buf (find-file-noselect
	    ;; 		       (expand-file-name
	    ;; 			"timeline-and-tasks.org"
	    ;; 			(org-bandbook-current-project)))))
	    ;; 	(insert-buffer-substring
	    ;; 	 task-buf
	    ;; 	 (org-find-exact-headline-in-buffer
	    ;; 	  "Timeline and Tasks" task-buf 'POS-ONLY)
	    ;; 	 (point-max))))
	    ;; insert people
	    (when (member "project_people" (split-string book-parts " " t))
	      (newline)
	      (insert
	       (format
		(concat "* Project People\n"
			"** Active Participants\n"
			"%s\n")
		(org-bandbook--get-active-project-people-as-strg))))
	    ;; insert utility src_blocks
	    (insert
	     (format
	      "\n* Utility functions :noexport:\n\n%s%s"
	      org-bandbook-project-name-src-block
	      org-bandbook-current-date-src-block))
	    (save-buffer)
	    ;; export to pdf
	    (let* ((curr-buf-file (buffer-file-name))
		   ;; (temporary-file-directory org-bandbook-temp-dir)
		   ;; (tmp-dir (make-temp-file "bandbook-" 'DIR-FLAG))
		   (new-file-name (expand-file-name
				   (file-name-nondirectory
				    curr-buf-file)
				   org-bandbook-current-temp-subdir)))
	      ;; tmp-dir)))
	      (kill-buffer)
	      (rename-file curr-buf-file new-file-name)
	      (with-current-buffer (find-file-noselect
				    new-file-name)
		(org-latex-export-to-pdf))))))
    (error "Not in Org-Bandbook project (path: %s)"
	   (ignore-errors
	     (file-name-directory
	      (buffer-file-name (current-buffer)))))))


;;;;; Create, refresh and delete project

;;;;; Add songs to project

;;; Run Hooks and Provide

(provide 'org-bandbook)

;;; org-bandbook.el ends here
