;;; org-bandbook.el --- Functions for Org-Bandbook

;; Author: Thorsten Jolitz <tjolitz AT gmail DOT com>
;; Version: 1.0
;; URL: https://github.com/tj64/org-bandbook

;;;; MetaData
;;   :PROPERTIES:
;;   :copyright: Thorsten Jolitz
;;   :copyright-years: 2014+
;;   :version:  1.0
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

;; Emacs Lisp functionality for Org-Bandbook.

;;; Requires

(eval-when-compile (require 'cl))
(require 'puml)

;;; Variables
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
   "\\([^ ]+?\\)\\(?:% endif\\)")
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

(defconst org-bandbook-project-properties
  '("header" "song_order")
  "List of Org Bandbook project properties.")

;; (defconst org-bandbook-project-root-src-block
;;   (concat
;;    "\n#+name: project-root\n"
;;    "#+header: :results silent\n"
;;    "#+header: :exports none\n"
;;    "#+header: :var buf-file=(buffer-file-name)\n"
;;    "#+begin_src emacs-lisp\n"
;;    " (file-name-directory\n"
;;    "  (directory-file-name\n"
;;    "   (file-name-directory\n"
;;    "    (directory-file-name\n"
;;    "     (file-name-directory buf-file)))))\n"
;;    "#+end_src\n")
;;   "Utility src_block that gets project root.")

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

;;;; Vars

(defvar org-bandbook-temp-dir
  (make-temp-file "bandbook-" 'DIR-FLAG)
  "Directory for org-bandbook temp files.")

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

;; (defcustom org-bandbook-... ""
;;   "... ."
;;   :group 'org-bandbook
;;   :type 'string)


;;; Functions
;;;; Advices

(defadvice org-taskjuggler-export (around org-taskjuggler-export-around)
  "Run taskjuggler-exporter in well defined environment.
'org-bandbook.el' must be on your load-path and current buffer's
buffer-file in the top-level of a well-structured org-bandbook
project to trigger new behaviour through this advice."
  (if (and (require 'org-bandbook nil t)
	   (org-bandbook-in-project-p 'SILENT))
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


(defun org-bandbook--get-num-prefix (file)
  "Return numeric prefix of FILE name."
  (string-to-number
   (car (org-bandbook--split-words
	 (file-name-sans-extension
	  (file-name-nondirectory file))))))


(defun org-bandbook--goto-first-heading ()
  "Move point to beginning of first heading."
  (goto-char (point-min))
  (or (org-on-heading-p)
      (outline-next-heading)))

(defun org-bandbook-set-directory ()
  "Set variable `org-bandbook-directory'".
  )
;;;;; Project Info

(defun org-bandbook--get-project-songs ()
  "Return sorted list of project songs.
Assume point is in top-level file-(buffer) of Org-Bandbook
project. Use absolute path to songs."
  ;; (message "get-project-songs: %s" (buffer-file-name))
  (if (org-bandbook-in-project-p 'SILENT)
      (directory-files
       (expand-file-name "./songs")
       'FULL "^[[:digit:]]+-.+?\\.org$")
    (error "Not in Org-Bandbook project (path: %s)"
	   (ignore-errors
	     (file-name-directory
	      (buffer-file-name (current-buffer)))))))

(defun org-bandbook--get-project-properties ()
  "Return current entry's filtered properties.
Only properties that are member of
`org-bandbook-project-properties' are considered."
  (delq nil
	(mapcar
	 (lambda (--pair)
	   (when (member (car --pair)
			 org-bandbook-project-properties)
	     --pair))
	 (org-entry-properties))))

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

 #+begin_src emacs-lisp
  ((part-name . content) ... (part-name . content))
 #+end_src

If TRANSPOSE-FROM-TO is non-nil, it should be a cons-pair of the
form:

 #+begin_src emacs-lisp
  (\"c\" . \"d\")
 #+end_src

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

 #+begin_src emacs-lisp
  (\"c\" . \"d\")
 #+end_src

with the actual key in the car and the target key in the cdr."
  (let ((old-buf (current-buffer)))
    (let* ((song-buf (find-file-noselect song))
	   (version (or (ignore-errors
			  (with-current-buffer song-buf
			    (replace-regexp-in-string
			     "\"" ""
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
		   (when (org-bandbook-in-project-p 'SILENT)
		     (with-current-buffer
			 (find-file-noselect
			  (expand-file-name "../common.ly"))
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
		  (org-bandbook-in-project-p 'SILENT)))
	   (format "\n<<%s>>\n"
		   (org-bandbook--render-song-score
		    part-names
		    (with-current-buffer old-buf
		      (expand-file-name "../score.org")))))
	  (t "")))))))

(defun org-bandbook-render-project-songs (&optional ordered-project-songs)
  "Render all songs from current project."
  (if (org-bandbook-in-project-p 'SILENT)
      (let ((ordered-song-names
	     (or ordered-project-songs
		 (org-bandbook--get-project-songs)))
	    song-lst)
	(mapc
	 (lambda (--song)
	   (let* ((from-key
		   (with-current-buffer (find-file-noselect --song)
		     (org-entry-get nil "song_key")))
		  (to-key
		   (with-current-buffer (find-file-noselect --song)
		     (org-entry-get nil "transpose_score")))
		  (song-path
		   (with-current-buffer (find-file-noselect --song)
		     (org-bandbook--extract-path-from-org-link
		      (org-entry-get nil "song_link"))))
		  (song-name (and song-path
				  (file-name-sans-extension
				   (file-name-nondirectory
				    song-path))))
		  (outfile (concat
			    (expand-file-name "./gitignore.d/")
			    song-name ".eps")))
	     (when song-name
	     (setq song-lst
		   (cons
		    (format
 		     ;; ;; not working with #+header_args?
		     ;; (concat
		     ;;  "#+name: %s\n"
		     ;;  "#+header_args: :file %s\n"
		     ;;  "#+begin_src lilypond\n%s\n#+end_src\n")
		     (concat
		      "\n#+latex: \\newpage\n"
		      "\n* %s\n"
		      ;; "  :PROPERTIES:\n"
		      ;; "  :END:\n\n")
		      "Some Text"
		      "\n#+latex: \\newpage\n"
		      "\n#+name: %s\n"
		      "#+begin_src lilypond "
		      ":exports results :file %s\n"
		      "%s\n#+end_src\n"
		      "\n#+latex: \\newpage\n")
		     (mapconcat
		      (lambda (--word) (upcase --word))
		      (org-bandbook--split-words song-name) " ")
		     song-name
		     (concat song-name ".eps")
		     (if (and to-key from-key)
			 (org-bandbook-render-song
			  song-path (cons from-key to-key) t);)
		       (org-bandbook-render-song song-path nil t)))
		    song-lst)))))
	 ;; (org-bandbook--get-project-songs))
	 ordered-song-names)
	(mapconcat 'identity song-lst "\n"))
    (error "Not in Org-Bandbook project (path: %s)"
	   (ignore-errors
	     (file-name-directory
	      (buffer-file-name (current-buffer)))))))

;;;;; Change Song Order

;; (defun org-dblock-write:org-bandbook-project-songs-dblock (params)
;;   (let ((project (plist-get params :project)))
;;     (insert
;;      (org-bandbook--format-project-song-list
;;       (org-bandbook--make-extended-project-song-list project)))))

;; (add-hook 'org-bandbook-change-song-order-hook
;; 	  'org-dblock-write:org-bandbook-project-songs-dblock)


(defun org-bandbook--make-extended-project-song-list (&optional project)
  "Create list of plists with extended info about project songs.
Keys are :name, :ID, :key, :mode
and :transp"
  (let ((proj (ignore-errors
		(or project
		    (file-name-directory (buffer-file-name))))))
    (and proj (file-exists-p proj)
	 (with-current-buffer
	     (find-file-noselect (expand-file-name "./master.org"))
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
		(setq results
		      (plist-put results :key
				 (with-current-buffer
				     (find-file-noselect --song)
				   (org-entry-get nil "song_key"))))
		(setq results
		      (plist-put results :mode
				 (with-current-buffer
				     (find-file-noselect --song)
				   (org-entry-get nil
						  "song_mode"))))
		(setq results
		      (plist-put results :transp
				 (with-current-buffer
				     (find-file-noselect --song)
				   (org-entry-get
				    nil "transpose_score"))))))
	    (org-bandbook--get-project-songs))))))

;; adapted from ob-core.el
(defun org-bandbook--format-project-song-list (project-songs &optional sep)
  "Format PROJECT-SONGS for project-songs-dblock."
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

;;;;; Create arrangement diagrams
     
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

;;;;; Check project directory structure

(defun org-bandbook-in-project-p (&optional silent)
  "Return project-name if in (top-level of) org-bandbook project.
Assumes `buffer-file-name' of `current-buffer' is master.org file
of project. With SILENT non-nil, do not message the project
name."
  (interactive "P")
  (let* ((silent-p (or silent current-prefix-arg))
	 (curr-dir (ignore-errors
		     (file-name-directory
		      (buffer-file-name
		       (current-buffer)))))
	 (parent-dir (when curr-dir
		       (file-name-directory
			(directory-file-name curr-dir))))
	 (curr-dir-name (when curr-dir
			  (file-name-nondirectory
			   (directory-file-name curr-dir))))
	 (parent-dir-name (when curr-dir
	 		    (file-name-nondirectory
	 		     (directory-file-name parent-dir))))
	 (curr-dir-file-lst
	  (list "funds.org" "instruments.org" "master.org"
		"people.org" "reports" "songs" "tasks" "tmp"))
	 (parent-dir-file-lst
	  (list "common.ly" "doc" ".git" "lib"
		"library-of-headers" "library-of-songs"
		 "project-massey-hall-1953" "score.org"
		 "src" "tmp")))
    (if (and (string= parent-dir-name "org-bandbook")
	     (= (length curr-dir-file-lst)
		(length (intersection curr-dir-file-lst
				      (directory-files curr-dir)
				      :test 'string=)))
	     (= (length parent-dir-file-lst)
		(length (intersection parent-dir-file-lst
				      (directory-files parent-dir)
				      :test 'string=))))
	(progn
	  (unless silent-p
	    (message "Org-Bandbook %s"
		     (mapconcat
		      (lambda (--word)
			(if (string= --word "project")
			    --word
			  (upcase --word)))
		      (org-bandbook--split-words
		       curr-dir-name) " ")))
	  curr-dir-name)
      (unless silent-p
	(message "Not in Org-Bandbook project (path: %s)"
		 (ignore-errors
		   (file-name-directory
		    (buffer-file-name (current-buffer))))))
      nil)))


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
'song_link' property with an Org-link (to an Org-Bandbook song in
the '/library-of-songs/' directory) as value."
  (interactive)
  (let* ((song-entry-marker
	  (org-find-exact-headline-in-buffer "song")) 
	 (path (ignore-errors
		 (org-bandbook--extract-path-from-org-link
		  (save-excursion
		    (goto-char song-entry-marker)
		    (org-entry-get nil "song_link")))))
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
      (setq structure (org-entry-get nil "structure"))
      (kill-buffer))
    (save-excursion
      (goto-char song-entry-marker)
      (org-entry-put nil "song_key" key)
      (org-entry-put nil "song_mode" mode)
      (org-entry-put nil "song_structure" structure))))


;;;;; Refresh Song Order 

(defun org-bandbook-reset-song-order ()
  "Reset song-order to default.
The default order is the order of songs in the list returned by
`org-bandbook--get-project-songs'."
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

;;;;; Refresh Arrangement Properties

(defun org-bandbook-refresh-arrangement-properties ()
  "Gather (and insert) properties from resources.org.

Assumes that point is in a song file in the <project>/songs/
directory that has a 'arrangement' entry."
  (interactive)
  (let ((arr-header-marker
	 (org-find-exact-headline-in-buffer "arrangement")))
    (when (marker-position arr-header-marker)
      (save-excursion
	(goto-char arr-header-marker)
	(mapc
	 (lambda (--pair)
	   (org-entry-put nil (car --pair) (cdr --pair)))
	 (with-current-buffer
	     (find-file-noselect
	      (expand-file-name "../resources.org"))
	   (if (org-bandbook-in-project-p)
	       (org-map-entries
		(lambda ()
		  
		  ))
	     (error "Not in Org-Bandbook project (path: %s)"
		    (ignore-errors
		      (file-name-directory
		       (buffer-file-name (current-buffer))))))))))))

;;;;; Make Bandbook

(defun org-bandbook-make-bandbook ()
  "Create bandbook for current project."
  (interactive)
  (if (org-bandbook-in-project-p 'SILENT)
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
		  (org-bandbook--get-project-properties)))
	       (header
		(org-string-nw-p
		 (cdr (assoc "header" master-props))))
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
		  (org-bandbook--get-project-songs)))
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
	  ;; insert utility src_blocks
	  (insert
	   (format
	    "\n* Utility functions :noexport:\n\n%s%s"
	    org-bandbook-project-name-src-block
	    org-bandbook-current-date-src-block))
	   (save-buffer)
	  ;; export to pdf
	  (let* ((curr-buf-file (buffer-file-name))
		 (temporary-file-directory org-bandbook-temp-dir)
		 (tmp-dir (make-temp-file "bandbook-" 'DIR-FLAG))
		 (new-file-name (expand-file-name
				 (file-name-nondirectory
				  curr-buf-file)
				 tmp-dir)))
	    (kill-buffer)
	    (rename-file curr-buf-file new-file-name)
	    (with-current-buffer (find-file-noselect
				  new-file-name)
	      (org-latex-export-to-pdf)))))
    (error "Not in Org-Bandbook project (path: %s)"
	   (ignore-errors
	     (file-name-directory
	      (buffer-file-name (current-buffer)))))))


;;;;; Create, refresh and delete project

;;;;; Add songs to project

;;; Run Hooks and Provide

(provide 'org-bandbook)

;;; org-bandbook.el ends here



