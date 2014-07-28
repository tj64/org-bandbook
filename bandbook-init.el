;; * bandbook-init.el --- Emacs Init File for Org-Bandbook
;; ** MetaData
;;   :PROPERTIES:
;;   :copyright: Thorsten Jolitz
;;   :copyright-years: 2014+
;;   :version:  0.9
;;   :licence:  GPL 3 or later (free software)
;;   :licence-url: http://www.gnu.org/licenses/
;;   :part-of-emacs: no
;;   :author: Thorsten Jolitz
;;   :author_email: tjolitz AT gmail DOT com
;;   :credits: bernt_hansen fabrice_nielsen  
;;   :remark: most obb/ functions courtesy of bh or fn
;;   :keywords: emacs org-mode lilypond
;;   :git-repo: https://github.com/tj64/org-bandbook
;;   :git-clone: git://github.com/tj64/org-bandbook.git
;;   :END:

;; ** Usage

;; This Emacs init file should help the uninitiated Emacs Newbie to
;; get started with Org-Bandbook. Install Emacs and start it with

;; #+begin_src sh
;;   emacs -Q -l /path/to/org-bandbook/bandbook-init.el
;; #+end_src

;; on the command-line. This should give you many convenient and
;; decent settings and configurations for working with Emacs. It might
;; give you errors too, e.g. because some packages are missing on your
;; system or because you are on another OS than GNU/Linux - please
;; report these errors to the Org-Bandbook author.

;; If you like this bandbook init-file and want to adopt it as your
;; general init file, please copy it to your .emacs.d/ directory and
;; rename it to init.el. Then you can modify it however you want, and
;; you can start Emacs simply like this:

;; #+begin_src sh
;;   emacs
;; #+end_src

;; This file is meant for Emacs newbies and should not be customized
;; for personnal needs. It should rather be improved to work without
;; errors on all kinds of systems, and to contain all needed
;; configurations to make working with Org-Bandbook easy and
;; convenient - but not more.

;; ** Tip

;; Its much more convenient to browse and navigate this init-file when
;; you install 3 additional packages. Here is the recipe how to do it:

;;  1. M-x package-list-packages
;;  2. C-s navi-mode RET
;;  3. i
;;  4. C-s outorg RET
;;  5. i
;;  6. C-s outshine RET
;;  7. i
;;  8. x

;; This will mark the three packages for install (i) and then execute
;; the installation (x). Read
;; [[http://orgmode.org/worg/org-tutorials/org-outside-org.html][Org-mode
;; outside Org-mode]] for more information about these libraries.

;; * Begin Startup

(message "\n------ ENTERING bandbook-init.el ------")

;; uptimes
(setq emacs-load-start-time (current-time))

;; ;; turn on Common Lisp support
;; (require 'cl)  ; provides useful things like `loop' and `setf'

;; get the backtrace when uncaught errors occur
(setq debug-on-error t)  ; will be unset at the end

;; * General Configurations

(message "\n------ entering GENERAL CONFIGURATIONS ------")

;; ** Coding System

(message "\n------ entering coding system ------")

(setq locale-coding-system 'utf-8)
(set-terminal-coding-system 'utf-8)
(set-keyboard-coding-system 'utf-8)
(set-selection-coding-system 'utf-8)
(prefer-coding-system 'utf-8)

;; ** Global Settings

(message "\n------ entering global settings ------")

(menu-bar-mode -1)
(scroll-bar-mode -1)
(tool-bar-mode -1)
(global-font-lock-mode t)
(delete-selection-mode t)
(show-paren-mode t)
(setq delete-by-moving-to-trash t)

(add-hook 'text-mode-hook 'turn-on-auto-fill)
;; (setq version-control t)
(setq backup-directory-alist
      (quote
       ( (".*/org-bandbook/.*" . (expand-file-name
		  "bandbook-backups/"
		  (expand-file-name user-emacs-directory))))))

(windmove-default-keybindings)

(fset 'yes-or-no-p 'y-or-n-p)
(setq ring-bell-function
      (lambda () (message "*** BELL RINGS ***")))
;; (setq initial-scratch-message "")
;; (setq inhibit-startup-message t)
;; enable the use of the command `narrow-to-region' without
;; confirmation
;; (put 'narrow-to-region 'disabled nil)

;; enable copy&paste between X applications 
(setq x-select-enable-clipboard t)
(setq interprogram-paste-function 'x-cut-buffer-or-selection-value)

;; ** Keys

;; *** Global Keys

;; must be set before outline is loaded
(defvar outline-minor-mode-prefix "\M-#")

;; some global bindings
(global-set-key (kbd "<f8>") 'scroll-other-window)
(global-set-key (kbd "<f9>") 'scroll-other-window-down)
(global-set-key (kbd "C-c v") 'view-buffer)
;; org-bandbook
(global-set-key (kbd "C-c b f") 'org-bandbook-refresh-song-order)
(global-set-key (kbd "C-c b s") 'org-bandbook-reset-song-order)
(global-set-key (kbd "C-c b m") 'org-bandbook-make-bandbook)

;; *** Function Keys

;; ** Define Aliases

;; shortening of often used commands
(defalias 'gf 'grep-find)
(defalias 'fd 'find-dired)
(defalias 'fnd 'find-name-dired)
(defalias 'sh 'eshell)

(defalias 'qrr 'query-replace-regexp)
(defalias 'lml 'list-matching-lines)
(defalias 'dml 'delete-matching-lines)
(defalias 'rof 'recentf-open-files)

(defalias 'eb 'eval-buffer)
(defalias 'er 'eval-region)
(defalias 'ee 'eval-expression)

(defalias 'c 'comment-or-uncomment-region)

;; replace commands
(defalias 'list-buffers 'ibuffer)

;; ** Load Path

;; *** Load-Path Enhancement

(defadvice load (before debug-log activate)
  (message "Loading %s..." (locate-library (ad-get-arg 0))))

(defun obb/add-to-load-path (this-directory &optional with-subdirs
recursive)
  "Add THIS-DIRECTORY at the beginning of the load-path.
Add all its subdirectories not starting with a '.' if the
optional argument WITH-SUBDIRS is not nil. Do it recursively if
the third argument is not nil."
  (when (and this-directory
             (file-directory-p this-directory))
    (let* ((this-directory (expand-file-name this-directory))
           (files (directory-files this-directory t "^[^\\.]")))
      ;; completely canonicalize the directory name (*may not* begin
      ;; with `~')
      (while (not (string= this-directory
                           (expand-file-name this-directory)))
        (setq this-directory (expand-file-name this-directory)))

      (message "Adding `%s' to load-path..." this-directory)
      (add-to-list 'load-path this-directory)

      (when with-subdirs
        (while files
          (setq dir-or-file (car files))
          (when (file-directory-p dir-or-file)
            (if recursive
                (obb/add-to-load-path dir-or-file 'with-subdirs
                'recursive)
              (obb/add-to-load-path dir-or-file)))
          (setq files (cdr files)))))))

;; *** Library Search

(defvar distro-site-lisp-directory
  (concat (or (getenv "SHARE")
              "/usr/share") "/emacs/site-lisp/")
  "Name of directory where additional Emacs goodies Lisp
files (from the distro optional packages) reside.")

(obb/add-to-load-path distro-site-lisp-directory
                     'with-subdirs)

(defvar obb/src-directory
  (file-name-as-directory
   (expand-file-name "src" user-emacs-directory))
  "Name of directory where additional Emacs goodies Lisp
files (from the Internet) reside.")

(obb/add-to-load-path obb/src-directory
                     'with-subdirs 'recursive)

(defvar obb/git-directory
  (file-name-as-directory
   (expand-file-name "~/git"))
  "Name of directory where my personal git-repos reside.")

 (obb/add-to-load-path obb/git-directory 'with-subdirs)

(defvar obb/elpa-directory
  (file-name-as-directory
   (expand-file-name "elpa" user-emacs-directory))
  "Name of directory where elpa libraries reside.")

(obb/add-to-load-path obb/elpa-directory 'with-subdirs)

;; ** Package Manager

(setq package-archives
      '(("gnu" . "http://elpa.gnu.org/packages/")
	("marmalade" . "http://marmalade-repo.org/packages/")
	("tromey" . "http://tromey.com/elpa/")
        ("melpa"  . "http://melpa.milkbox.net/packages/")))

;; * Helper functions

(message "\n------ entering HELPER FUNCTIONS ------")

;; ** Improved Require

(defvar missing-packages-list nil
  "List of packages that `try-require' can't find.")

;; attempt to load a feature/library, failing silently
(defun try-require (feature)
  "Attempt to load a library or module. Return true if the
library given as argument is successfully loaded. If not, instead
of an error, just add the package to a list of missing packages."
  (condition-case err
      ;; protected form
      (progn
        (message "Checking for library `%s'..." feature)
        (if (stringp feature)
            (load-library feature)
          (require feature))
        (message "Checking for library `%s'... Found" feature))
    ;; error handler
    (file-error  ; condition
     (progn
       (message "Checking for library `%s'... Missing" feature)
       (add-to-list 'missing-packages-list feature 'append))
     nil)))

;; ** Idle Require

;; load elisp libraries while Emacs is idle
(if (try-require 'idle-require)
    (progn
      (setq idle-require-symbols
            '(w3m org))

      ;; loaded
      (setq idle-require-idle-delay 5)

      ;; time in seconds between automatically loaded functions
      (setq idle-require-load-break 3)

      ;; load unloaded autoload functions when Emacs becomes idle
      (idle-require-mode 1)

      (defun try-idle-require (feature)
        (when (locate-library (symbol-name feature))
          (idle-require feature))))

  (defun try-idle-require (feature)
    (when (locate-library (symbol-name feature))
      (require feature))))

;; ** Fast Temporary Buffers

(defun obb/switch-to-tmp-buffer (&optional buffer-mode)
  "Opens a temporary buffer.
Optionally put it in BUFFER-MODE."
  (interactive
   (list
    (when current-prefix-arg
      (intern (read-string "Buffer mode: ")))))
  (switch-to-buffer (generate-new-buffer-name "tmp"))
  (when (fboundp buffer-mode) (funcall buffer-mode)))

(defun obb/switch-to-org-buffer ()
  "Opens a temporary org-mode buffer."
  (interactive)
  (if (buffer-live-p (get-buffer "*org*"))
      (switch-to-buffer "*org*")
  (obb/switch-to-tmp-buffer 'org-mode)
  (rename-buffer "*org*")
  (insert "* ORG SCRATCH\n\n")))

(defun obb/switch-to-elisp-buffer ()
  "Opens a temporary emacs-lisp-mode buffer."
  (interactive)
  (if (buffer-live-p (get-buffer "*elisp*"))
      (switch-to-buffer "*elisp*")
  (obb/switch-to-tmp-buffer 'emacs-lisp-mode)
  (rename-buffer "*elisp*")
  (insert ";; \* ELISP SCRATCH\n\n")))

;; define shortcut for switching to temp-buffer
(global-set-key (kbd "C-c t t") 'obb/switch-to-tmp-buffer)
(global-set-key (kbd "C-c t o") 'obb/switch-to-org-buffer)
(global-set-key (kbd "C-c t e") 'obb/switch-to-elisp-buffer)


;; ** Files and Directories

(defun obb/make-directory-y-or-n (dir)
  "Ask user to create the DIR, if it does not already exist."
  (if dir
      (if (not (file-directory-p dir))
          (if (y-or-n-p
               (concat "The directory `" dir
                       "' does not exist currently. Create it? "))
              (make-directory dir t)
            (error
             (concat "Cannot continue without directory `"
                     dir "'"))))
    (error "obb/make-directory-y-or-n: missing operand")))

(defun obb/file-executable-p (file)
  "Make sure the file FILE exists and is executable."
  (if file
      (if (file-executable-p file)
          file
        (message "WARNING: Can't find executable `%s'" file)
        ;; sleep 1 s so that you can read the warning
        (sit-for 1))
    (error "obb/file-executable-p: missing operand")))


;; ** Window Split

(defun obb/swap-windows ()
  "If you have 2 windows, it swaps them."
  (interactive)
  (cond ((not (= (count-windows) 2))
         (message "You need exactly 2 windows to do this."))
        (t
         (let* ((w1 (first (window-list)))
                (w2 (second (window-list)))
                (b1 (window-buffer w1))
                (b2 (window-buffer w2))
                (s1 (window-start w1))
                (s2 (window-start w2)))
           (set-window-buffer w1 b2)
           (set-window-buffer w2 b1)
           (set-window-start w1 s2)
           (set-window-start w2 s1)))))


(defun obb/toggle-window-split ()
  "Vertical split shows more of each line, horizontal split shows
more lines. This code toggles between them. It only works for
frames with exactly two windows."
  (interactive)
  (if (= (count-windows) 2)
      (let* ((this-win-buffer (window-buffer))
             (next-win-buffer (window-buffer (next-window)))
             (this-win-edges (window-edges (selected-window)))
             (next-win-edges (window-edges (next-window)))
             (this-win-2nd (not (and (<= (car this-win-edges)
                                         (car next-win-edges))
                                     (<= (cadr this-win-edges)
                                         (cadr next-win-edges)))))
             (splitter
              (if (= (car this-win-edges)
                     (car (window-edges (next-window))))
                  'split-window-horizontally
                'split-window-vertically)))
        (delete-other-windows)
        (let ((first-win (selected-window)))
          (funcall splitter)
          (if this-win-2nd (other-window 1))
          (set-window-buffer (selected-window) this-win-buffer)
          (set-window-buffer (next-window) next-win-buffer)
          (select-window first-win)
          (if this-win-2nd (other-window 1))))))

(global-set-key (kbd "C-c w s") 'obb/swap-windows)
(global-set-key (kbd "C-c w t") 'obb/toggle-window-split)


;; ** Truncate Lines

(defun obb/set-truncate-lines ()
  "Toggle value of truncate-lines and refresh window display."
  (interactive)
  (setq truncate-lines (not truncate-lines))
  ;; now refresh window display (an idiom from simple.el):
  (save-excursion
    (set-window-start (selected-window)
                      (window-start (selected-window)))))

(global-set-key (kbd "C-c l l") 'obb/set-truncate-lines)

;; * Major Modes

(message "\n------ entering MAJOR MODES ------")

;; ** Org

(message "\n------ entering org-mode ------")

;; *** General

;; **** Configuration

(setq org-indent-mode-turns-on-hiding-stars nil
      org-replace-disputed-keys t
      org-use-speed-commands t)

(add-hook 'org-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c M-o") 'obb/mail-subtree))
          'append)

;; Enable abbrev-mode
(add-hook 'org-mode-hook (lambda () (abbrev-mode 1)))

(setq org-todo-keywords
      (quote
       ((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!/!)")
	(sequence
	 "WAITING(w@/!)" "HOLD(h@/!)" "|"
	 "CANCELLED(c@/!)" "PHONE"))))

(setq org-todo-keyword-faces
      (quote (("TODO" :foreground "red" :weight bold)
              ("NEXT" :foreground "blue" :weight bold)
              ("DONE" :foreground "forest green" :weight bold)
              ("WAITING" :foreground "orange" :weight bold)
              ("HOLD" :foreground "magenta" :weight bold)
              ("CANCELLED" :foreground "forest green" :weight bold)
              ("PHONE" :foreground "forest green" :weight bold))))

(setq org-use-fast-todo-selection t)

(setq org-treat-S-cursor-todo-selection-as-state-change nil)

;; (setq org-todo-state-tags-triggers
;;       (quote (("CANCELLED" ("CANCELLED" . t))
;;               ("WAITING" ("WAITING" . t))
;;               ("HOLD" ("WAITING" . t) ("HOLD" . t))
;;               (done ("WAITING") ("HOLD"))
;;               ("TODO" ("WAITING") ("CANCELLED") ("HOLD"))
;;               ("NEXT" ("WAITING") ("CANCELLED") ("HOLD"))
;;               ("DONE" ("WAITING") ("CANCELLED") ("HOLD")))))

(setq org-directory "~/git/org")
(setq org-default-notes-file "~/git/org/refile.org")


;; **** Functions

(defun obb/mail-subtree ()
  (interactive)
  (org-mark-subtree)
  (org-mime-subtree))

(defun obb/hide-other ()
  (interactive)
  (save-excursion
    (org-back-to-heading 'invisible-ok)
    (hide-other)
    (org-cycle)
    (org-cycle)
    (org-cycle)))

(defun obb/org-todo (arg)
  (interactive "p")
  (if (equal arg 4)
      (save-restriction
        (widen)
        (org-narrow-to-subtree)
        (org-show-todo-tree nil))
    (widen)
    (org-narrow-to-subtree)
    (org-show-todo-tree nil)))

(defun org-cycle-global ()
  (interactive)
  (org-cycle t))

(defun org-cycle-local ()
  (interactive)
  (save-excursion
    (move-beginning-of-line nil)
    (org-cycle)))

;; *** Hyperlinks

;; **** Configuration 

(setq org-file-apps
      (quote ((auto-mode . emacs)
              ("\\.mm\\'" . default)
              ("\\.x?html?\\'" ".x?html'" . "w3m %s")
              ("\\.pdf\\'" ".pdf::(+)'" . "evince -p %1 %s")))
     org-link-search-must-match-exact-headline nil)

;; *** Properties and Columns

;; **** Configuration 

(setq org-columns-default-format
      "%40ITEM(Task) %TODO %17Effort(Estimated Effort) {:}
      %CLOCKSUM %3PRIORITY %TAGS"
       org-global-properties
       (quote (("Effort_All" .
                "0:10 0:30 1:00 2:00 3:00 4:00 5:00 6:00 7:00
                8:00"))))

;; *** Exporting

;; **** Configuration 

(setq org-latex-to-pdf-process
      (quote ("texi2dvi -p -b -c -V %f"))
      org-edit-fixed-width-region-mode
      (quote fundamental-mode))

;; FIXME remove when lib is in contrib
(try-require 'ox-gfm)

;; FIXME remove when lib is in contrib
(try-require 'ox-taskjuggler)

;; add KOMA scrartcl class
(add-to-list 'org-latex-classes
          '("koma-article"
             "\\documentclass{scrartcl}"
             ("\\section{%s}" . "\\section*{%s}")
             ("\\subsection{%s}" . "\\subsection*{%s}")
             ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
             ("\\paragraph{%s}" . "\\paragraph*{%s}")
             ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))


;; *** Timestamps

;; **** Configuration 

(add-hook 'org-insert-heading-hook
          'obb/insert-heading-inactive-timestamp 'append)

;; **** Functions

(defvar obb/insert-inactive-timestamp t)

(defun obb/toggle-insert-inactive-timestamp ()
  (interactive)
  (setq obb/insert-inactive-timestamp
        (not obb/insert-inactive-timestamp))
  (message "Heading timestamps are %s"
           (if obb/insert-inactive-timestamp "ON" "OFF")))

(defun obb/insert-inactive-timestamp ()
  (interactive)
  (org-insert-time-stamp nil t t nil nil nil))

(defun obb/insert-heading-inactive-timestamp ()
  (save-excursion
    (when obb/insert-inactive-timestamp
      (org-return)
      (org-cycle)
      (obb/insert-inactive-timestamp))))


;; *** Tags

;; **** Configuration 

;; Tags directly after headline

(setq org-tags-column 0)

;; Tags with fast selection keys
(setq org-tag-alist (quote ((:startgroup)
                            ("@office" . ?o)
                            ("@home" . ?h)
                            (:endgroup)
                            ("PHONE" . ?p)
                            ("WAITING" . ?w)
                            ("HOLD" . ?H)
                            ("PERSONAL" . ?P)
                            ("WORK" . ?W)
                            ("ORG" . ?O)
                            ("crypt" . ?E)
                            ("MARK" . ?M)
                            ("NOTE" . ?n)
                            ("CANCELLED" . ?c)
                            ("FLAGGED" . ??))))

;; Allow setting single tags without the menu
(setq org-fast-tag-selection-single-key (quote expert))

;; For tag searches ignore tasks with scheduled and deadline dates
(setq org-agenda-tags-todo-honor-ignore-options t)


;; *** Clocking

;; **** Configuration 

;; ;; Resume clocking task when emacs is restarted
;; (org-clock-persistence-insinuate)

;; Show lot's of clocking history so it's easy to pick items off the
;; C-F11 list
(setq org-clock-history-length 36)

;; Resume clocking task on clock-in if the clock is open
(setq org-clock-in-resume t)

;; Change tasks to NEXT when clocking in
(setq org-clock-in-switch-to-state 'obb/clock-in-to-next)

;; Separate drawers for clocking and logs
(setq org-drawers (quote ("PROPERTIES" "LOGBOOK")))

;; Save clock data and state changes and notes in the LOGBOOK drawer
(setq org-clock-into-drawer t)

;; Sometimes I change tasks I'm clocking quickly - this removes
;; clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)

;; Clock out when moving task to a done state
(setq org-clock-out-when-done t)

;; Save the running clock and all clock history when exiting Emacs, load it on startup
(setq org-clock-persist t)

;; Do not prompt to resume an active clock
(setq org-clock-persist-query-resume nil)

;; Enable auto clock resolution for finding open clocks
(setq org-clock-auto-clock-resolutionn
(quote when-no-clock-is-running))

;; Include current clocking task in clock reports
(setq org-clock-report-include-clocking-task t)

(setq obb/keep-clock-running nil)

(add-hook 'org-clock-out-hook 'obb/clock-out-maybe 'append)

(setq org-time-stamp-rounding-minutes (quote (1 1)))

(setq org-agenda-clock-consistency-checks
      (quote (:max-duration "4:00"
                            :min-duration 0
                            :max-gap 0
                            :gap-ok-around ("4:00"))))

;; Sometimes I change tasks I'm clocking quickly - this removes
;; clocked tasks with 0:00 duration
(setq org-clock-out-remove-zero-time-clocks t)

;; Agenda clock report parameters
(setq org-agenda-clockreport-parameter-plist
      (quote
       (:link t :maxlevel 5 :fileskip0 t :compact t :narrow 80)))


;; **** Functions

(defun obb/clock-in-to-next (kw)
  "Switch a task from TODO to NEXT when clocking in.
Skips capture tasks, projects, and subprojects.
Switch projects and subprojects from NEXT back to TODO"
  (when (not (and (boundp 'org-capture-mode) org-capture-mode))
    (cond
     ((and (member (org-get-todo-state) (list "TODO"))
           (obb/is-task-p))
      "NEXT")
     ((and (member (org-get-todo-state) (list "NEXT"))
           (obb/is-project-p))
      "TODO"))))

(defun obb/find-project-task ()
  "Move point to the parent (project) task if any"
  (save-restriction
    (widen)
    (let ((parent-task
           (save-excursion
             (org-back-to-heading 'invisible-ok) (point))))
      (while (org-up-heading-safe)
        (when (member (nth 2 (org-heading-components))
                      org-todo-keywords-1)
          (setq parent-task (point))))
      (goto-char parent-task)
      parent-task)))

(defun obb/punch-in (arg)
  "Start continuous clocking and set the default task to the
selected task.  If no task is selected set the Organization task
as the default task."
  (interactive "p")
  (setq obb/keep-clock-running t)
  (if (equal major-mode 'org-agenda-mode)
      ;; We're in the agenda
      (let* ((marker (org-get-at-bol 'org-hd-marker))
             (tags (org-with-point-at marker (org-get-tags-at))))
        (if (and (eq arg 4) tags)
            (org-agenda-clock-in '(16))
          (obb/clock-in-organization-task-as-default)))
    ;; We are not in the agenda
    (save-restriction
      (widen)
      ;; Find the tags on the current task
      (if (and (equal major-mode 'org-mode)
               (not (org-before-first-heading-p)) (eq arg 4))
          (org-clock-in '(16))
        (obb/clock-in-organization-task-as-default)))))

(defun obb/punch-out ()
  (interactive)
  (setq obb/keep-clock-running nil)
  (when (org-clock-is-active)
    (org-clock-out))
  (org-agenda-move-restriction-lock))

(defun obb/clock-in-default-task ()
  (save-excursion
    (org-with-point-at org-clock-default-task
      (org-clock-in))))

(defun obb/clock-in-parent-task ()
  "Move point to the parent (project) task if any and clock in"
  (let ((parent-task))
    (save-excursion
      (save-restriction
        (widen)
        (while (and (not parent-task) (org-up-heading-safe))
          (when (member (nth 2 (org-heading-components))
                        org-todo-keywords-1)
            (setq parent-task (point))))
        (if parent-task
            (org-with-point-at parent-task
              (org-clock-in))
          (when obb/keep-clock-running
            (obb/clock-in-default-task)))))))

(defvar obb/organization-task-id
  "67df14d8-ea37-41a7-9aaa-1bcb4fed6eed")

(defun obb/clock-in-organization-task-as-default ()
  (interactive)
  (org-with-point-at (org-id-find obb/organization-task-id 'marker)
    (org-clock-in '(16))))

(defun obb/clock-out-maybe ()
  (when (and obb/keep-clock-running
             (not org-clock-clocking-in)
             (marker-buffer org-clock-default-task)
             (not org-clock-resolving-clocks-due-to-idleness))
    (obb/clock-in-parent-task)))

(require 'org-id)
(defun obb/clock-in-task-by-id (id)
  "Clock in a task by id"
  (org-with-point-at (org-id-find id 'marker)
    (org-clock-in nil)))

(defun obb/clock-in-last-task (arg)
  "Clock in the interrupted task if there is one
Skip the default task and get the next one.
A prefix arg forces clock in of the default task."
  (interactive "p")
  (let ((clock-in-to-task
         (cond
          ((eq arg 4) org-clock-default-task)
          ((and (org-clock-is-active)
                (equal org-clock-default-task
                       (cadr org-clock-history)))
           (caddr org-clock-history))
          ((org-clock-is-active) (cadr org-clock-history))
          ((equal org-clock-default-task (car org-clock-history))
           (cadr org-clock-history))
          (t (car org-clock-history)))))
    (org-with-point-at clock-in-to-task
      (org-clock-in nil))))

(defun obb/clock-in-bzflagt-task ()
  (interactive)
  (obb/clock-in-task-by-id "dcf55180-2a18-460e-8abb-a9f02f0893be"))

(defun obb/resume-clock ()
  (interactive)
  (if (marker-buffer org-clock-interrupted-task)
      (org-with-point-at org-clock-interrupted-task
        (org-clock-in))
    (org-clock-out)))

;; *** Capturing

;; **** Configuration

;; Capture templates for: TODO tasks, Notes, appointments, phone
;; calls, and org-protocol
(setq org-capture-templates
      (quote (("t" "todo" entry (file "~/git/org/refile.org")
               "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
              ("r" "respond" entry (file "~/git/org/refile.org")
               "* TODO Respond to %:from on %:subject\n%U\n%a\n"
               :clock-in t :clock-resume t :immediate-finish t)
              ("n" "note" entry (file "~/git/org/refile.org")
               "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
              ("j" "Journal" entry
               (file+datetree "~/git/org/diary.org")
               "* %?\n%U\n" :clock-in t :clock-resume t)
              ("w" "org-protocol" entry
               (file "~/git/org/refile.org")
               "* TODO Review %c\n%U\n" :immediate-finish t)
              ("p" "Phone call" entry (file "~/git/org/refile.org")
               "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t)
              ("h" "Habit" entry (file "~/git/org/refile.org")
               (concat "* NEXT %?\n%U\n%a\nSCHEDULED: %t "
                       ".+1d/3d\n:PROPERTIES:\n:STYLE: habit\n"
                       ":REPEAT_TO_STATE: NEXT\n:END:\n")))))


;; *** Projects

;; **** Functions

(defun obb/skip-non-stuck-projects ()
  "Skip trees that are not stuck projects"
  (obb/list-sublevels-for-projects-indented)
  (save-restriction
    (widen)
    (let ((next-headline
           (save-excursion (or (outline-next-heading)
                               (point-max)))))
      (if (obb/is-project-p)
          (let* ((subtree-end
                  (save-excursion (org-end-of-subtree t)))
                 (has-next ))
            (save-excursion
              (forward-line 1)
              (while (and (not has-next)
                          (< (point) subtree-end)
                          (re-search-forward
                           "^\\*+ NEXT " subtree-end t))
                (unless (member "WAITING" (org-get-tags-at))
                  (setq has-next t))))
            (if has-next
                next-headline
              ;; a stuck project, has subtasks but no next task
              nil)) 
        next-headline))))

(defun obb/is-project-p ()
  "Any task with a todo keyword subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components))
                             org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task has-subtask))))

(defun obb/is-project-subtree-p ()
  "Any task with a todo keyword that is in a project subtree.
Callers of this function already widen the buffer view."
  (let ((task (save-excursion
                (org-back-to-heading 'invisible-ok)
                              (point))))
    (save-excursion
      (obb/find-project-task)
      (if (equal (point) task)
          nil
        t))))
(defun obb/is-task-p ()
  "Any task with a todo keyword and no subtask"
  (save-restriction
    (widen)
    (let ((has-subtask)
          (subtree-end (save-excursion (org-end-of-subtree t)))
          (is-a-task (member (nth 2 (org-heading-components))
                             org-todo-keywords-1)))
      (save-excursion
        (forward-line 1)
        (while (and (not has-subtask)
                    (< (point) subtree-end)
                    (re-search-forward "^\*+ " subtree-end t))
          (when (member (org-get-todo-state) org-todo-keywords-1)
            (setq has-subtask t))))
      (and is-a-task (not has-subtask)))))

(defun obb/is-subproject-p ()
  "Any task which is a subtask of another project"
  (let ((is-subproject)
        (is-a-task (member (nth 2 (org-heading-components))
                           org-todo-keywords-1)))
    (save-excursion
      (while (and (not is-subproject) (org-up-heading-safe))
        (when (member (nth 2 (org-heading-components))
                      org-todo-keywords-1)
          (setq is-subproject t))))
    (and is-a-task is-subproject)))

(defun obb/list-sublevels-for-projects-indented ()
  "Set org-tags-match-list-sublevels so when restricted to a subtree we list all subtasks.
  This is normally used by skipping functions where this variable
  is already local to the agenda."
  (if (marker-buffer org-agenda-restrict-begin)
      (setq org-tags-match-list-sublevels 'indented)
    (setq org-tags-match-list-sublevels nil))
  nil)

(defun obb/list-sublevels-for-projects ()
  "Set org-tags-match-list-sublevels so when restricted to a subtree we list all subtasks.
  This is normally used by skipping functions where this variable
  is already local to the agenda."
  (if (marker-buffer org-agenda-restrict-begin)
      (setq org-tags-match-list-sublevels t)
    (setq org-tags-match-list-sublevels nil))
  nil)

(defun obb/skip-non-projects ()
  "Skip trees that are not projects"
  (obb/list-sublevels-for-projects-indented)
  (if (save-excursion (obb/skip-non-stuck-projects))
      (save-restriction
        (widen)
        (let ((subtree-end (save-excursion (org-end-of-subtree t))))
          (if (obb/is-project-p)
              nil
            subtree-end)))
    (org-end-of-subtree t)))

(defun obb/skip-project-trees-and-habits ()
  "Skip trees that are projects"
  (save-restriction
    (widen)
    (let ((subtree-end (save-excursion (org-end-of-subtree t))))
      (cond
       ((obb/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       (t
        nil)))))

(defun obb/skip-projects-and-habits-and-single-tasks ()
  "Skip trees that are projects, tasks that are habits, single
non-project tasks"
  (save-restriction
    (widen)
    (let ((next-headline
           (save-excursion
             (or (outline-next-heading)
                               (point-max)))))
      (cond
       ((org-is-habit-p)
        next-headline)
       ((obb/is-project-p)
        next-headline)
       ((and (obb/is-task-p)
             (not (obb/is-project-subtree-p)))
        next-headline)
       (t
        nil)))))

(defun obb/skip-project-tasks-maybe ()
  "Show tasks related to the current restriction.
When restricted to a project, skip project and sub project tasks,
habits, NEXT tasks, and loose tasks.  When not restricted, skip
project and sub-project tasks, habits, and project related
tasks."
  (save-restriction
    (widen)
    (let* ((subtree-end
            (save-excursion (org-end-of-subtree t)))
           (next-headline
            (save-excursion
              (or (outline-next-heading) (point-max))))
           (limit-to-project
            (marker-buffer org-agenda-restrict-begin)))
      (cond
       ((obb/is-project-p)
        next-headline)
       ((org-is-habit-p)
        subtree-end)
       ((and (not limit-to-project)
             (obb/is-project-subtree-p))
        subtree-end)
       ((and limit-to-project
             (obb/is-project-subtree-p)
             (member (org-get-todo-state) (list "NEXT")))
        subtree-end)
       (t
        nil)))))

(defun obb/skip-projects-and-habits ()
  "Skip trees that are projects and tasks that are habits"
  (save-restriction
    (widen)
    (let ((subtree-end
           (save-excursion (org-end-of-subtree t))))
      (cond
       ((obb/is-project-p)
        subtree-end)
       ((org-is-habit-p)
        subtree-end)
       (t
        nil)))))

(defun obb/skip-non-subprojects ()
  "Skip trees that are not projects"
  (let ((next-headline (save-excursion (outline-next-heading))))
    (if (obb/is-subproject-p)
        nil
      next-headline)))

;; *** Archiving

;; **** Configuration 

(setq org-archive-mark-done nil)
(setq org-archive-location "%s_archive::* Archived Tasks")

;; **** Functions

(defun obb/skip-non-archivable-tasks ()
  "Skip trees that are not available for archiving"
  (save-restriction
    (widen)
    (let ((next-headline
           (save-excursion (or (outline-next-heading)
                               (point-max)))))
      ;; Consider only tasks with done todo headings as archivable
      ;; candidates
      (if (member (org-get-todo-state) org-done-keywords)
          (let* ((subtree-end (save-excursion
                                (org-end-of-subtree t)))
                 (daynr (string-to-int
                         (format-time-string "%d" (current-time))))
                 (a-month-ago (* 60 60 24 (+ daynr 1)))
                 (last-month (format-time-string
                              "%Y-%m-"
                              (time-subtract
                               (current-time)
                               (seconds-to-time a-month-ago))))
                 (this-month (format-time-string
                              "%Y-%m-" (current-time)))
                 (subtree-is-current
                  (save-excursion
                    (forward-line 1)
                    (and (< (point) subtree-end)
                         (re-search-forward
                          (concat last-month
                                  "\\|"
                                  this-month)
                          subtree-end t)))))
            (if subtree-is-current
                ;; Has a date in this month or last month, skip it
                next-headline
              ;; available to archive
              nil))
        (or next-headline (point-max))))))

;; *** Agenda

;; **** Configuration 

;; ***** Variables

(setq org-agenda-files (quote ("~/git/org"))
      org-agenda-window-setup (quote current-window))

(setq org-agenda-archives-mode nil
      org-agenda-skip-comment-trees nil
      org-agenda-skip-function nil)

;; Custom agenda command definitions	
(setq org-agenda-custom-commands
      (quote (("N" "Notes" tags "NOTE"
               ((org-agenda-overriding-header "Notes")
                (org-tags-match-list-sublevels t)))
              ("h" "Habits" tags-todo "STYLE=\"habit\""
               ((org-agenda-overriding-header "Habits")
                (org-agenda-sorting-strategy
                 '(todo-state-down effort-up category-keep))))
              (" " "Agenda"
               ((agenda "" nil)
                (tags "REFILE"
                      ((org-agenda-overriding-header
                        "Tasks to Refile")
                       (org-tags-match-list-sublevels nil)))
                (tags-todo "-CANCELLED/!"
                           ((org-agenda-overriding-header
                             "Stuck Projects")
                            (org-agenda-skip-function
                             'obb/skip-non-stuck-projects)))
                (tags-todo "-WAITING-CANCELLED/!NEXT"
                           ((org-agenda-overriding-header
                             "Next Tasks")
                            (org-agenda-skip-function
                             'obb/skip-projects-and-habits-and-single-tasks)
                            (org-agenda-todo-ignore-scheduled t)
                            (org-agenda-todo-ignore-deadlines t)
                            (org-agenda-todo-ignore-with-date t)
                            (org-tags-match-list-sublevels t)
                            (org-agenda-sorting-strategy
                             '(todo-state-down
                               effort-up
                               category-keep))))
                (tags-todo "-REFILE-CANCELLED/!-HOLD-WAITING"
                           ((org-agenda-overriding-header "Tasks")
                            (org-agenda-skip-function
                             'obb/skip-project-tasks-maybe)
                            (org-agenda-todo-ignore-scheduled t)
                            (org-agenda-todo-ignore-deadlines t)
                            (org-agenda-todo-ignore-with-date t)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-HOLD-CANCELLED/!"
                           ((org-agenda-overriding-header
                             "Projects")
                            (org-agenda-skip-function
                             'obb/skip-non-projects)
                            (org-agenda-sorting-strategy
                             '(category-keep))))
                (tags-todo "-CANCELLED/!WAITING|HOLD"
                           ((org-agenda-overriding-header
                             "Waiting and Postponed Tasks")
                            (org-tags-match-list-sublevels nil)
                            (org-agenda-todo-ignore-scheduled
                             'future)
                            (org-agenda-todo-ignore-deadlines
                             'future)))
                (tags "-REFILE/"
                      ((org-agenda-overriding-header
                        "Tasks to Archive")
                       (org-agenda-skip-function
                        'obb/skip-non-archivable-tasks)
                       (org-tags-match-list-sublevels nil))))
               nil)
              ("r" "Tasks to Refile" tags "REFILE"
               ((org-agenda-overriding-header "Tasks to Refile")
                (org-tags-match-list-sublevels nil)))
              ("#" "Stuck Projects" tags-todo "-CANCELLED/!"
               ((org-agenda-overriding-header "Stuck Projects")
                (org-agenda-skip-function
                 'obb/skip-non-stuck-projects)))
              ("n" "Next Tasks" tags-todo "-WAITING-CANCELLED/!NEXT"
               ((org-agenda-overriding-header "Next Tasks")
                (org-agenda-skip-function
                 'obb/skip-projects-and-habits-and-single-tasks)
                (org-agenda-todo-ignore-scheduled t)
                (org-agenda-todo-ignore-deadlines t)
                (org-agenda-todo-ignore-with-date t)
                (org-tags-match-list-sublevels t)
                (org-agenda-sorting-strategy
                 '(todo-state-down effort-up category-keep))))
              ("R" "Tasks" tags-todo
               "-REFILE-CANCELLED/!-HOLD-WAITING"
               ((org-agenda-overriding-header "Tasks")
                (org-agenda-skip-function
                 'obb/skip-project-tasks-maybe)
                (org-agenda-sorting-strategy
                 '(category-keep))))
              ("p" "Projects" tags-todo "-HOLD-CANCELLED/!"
               ((org-agenda-overriding-header "Projects")
                (org-agenda-skip-function 'obb/skip-non-projects)
                (org-agenda-sorting-strategy
                 '(category-keep))))
              ("w" "Waiting Tasks" tags-todo
               "-CANCELLED/!WAITING|HOLD"
               ((org-agenda-overriding-header
                 "Waiting and Postponed tasks"))
               (org-tags-match-list-sublevels nil))
              ("A" "Tasks to Archive" tags "-REFILE/"
               ((org-agenda-overriding-header "Tasks to Archive")
                (org-agenda-skip-function
                 'obb/skip-non-archivable-tasks)
                (org-tags-match-list-sublevels nil))))))

(setq org-agenda-span 'day)

;; Do not dim blocked tasks
(setq org-agenda-dim-blocked-tasks nil)

;; Compact the block agenda view
(setq org-agenda-compact-blocks t)

;; (setq org-show-entry-below (quote ((default))))
;; Keep tasks with dates on the global todo lists
(setq org-agenda-todo-ignore-with-date nil)

;; Keep tasks with deadlines on the global todo lists
(setq org-agenda-todo-ignore-deadlines nil)

;; Keep tasks with scheduled dates on the global todo lists
(setq org-agenda-todo-ignore-scheduled nil)

;; Keep tasks with timestamps on the global todo lists
(setq org-agenda-todo-ignore-timestamp nil)

;; Remove completed deadline tasks from the agenda view
(setq org-agenda-skip-deadline-if-done t)

;; Remove completed scheduled tasks from the agenda view
(setq org-agenda-skip-scheduled-if-done t)

;; Remove completed items from search results
(setq org-agenda-skip-timestamp-if-done t)

(setq org-agenda-include-diary nil)
(setq org-agenda-diary-file "~/git/org/diary.org")

(setq org-agenda-insert-diary-extract-time t)

;; Include agenda archive files when searching for things
(setq org-agenda-text-search-extra-files (quote (agenda-archives)))

;; Show all future entries for repeating tasks
(setq org-agenda-repeating-timestamp-show-all t)

;; Show all agenda dates - even if they are empty
(setq org-agenda-show-all-dates t)

;; Sorting order for tasks on the agenda
(setq org-agenda-sorting-strategy
      (quote
       ((agenda habit-down time-up
                user-defined-up priority-down
                effort-up category-keep)
              (todo category-up priority-down effort-up)
              (tags category-up priority-down effort-up)
              (search category-up))))

;; Start the weekly agenda on Monday
(setq org-agenda-start-on-weekday 1)

;; Enable display of the time grid so we can see the marker for the
;; current time
(setq org-agenda-time-grid
      (quote
       ((daily today remove-match)
        #("----------------" 0 16 (org-heading t))
        (830 1000 1200 1300 1500 1700))))

;; Display tags farther right
(setq org-agenda-tags-column -102)

;; Agenda sorting functions
(setq org-agenda-cmp-user-defined 'obb/agenda-sort)

(setq org-agenda-auto-exclude-function
      'obb/org-auto-exclude-function)

;; ***** Hooks

;; Disable C-c [ and C-c ] in org-mode
(add-hook 'org-mode-hook
          (lambda ()
            ;; Undefine C-c [ and C-c ] since this breaks my
            ;; org-agenda files when directories are include It
            ;; expands the files in the directories individually
            (org-defkey org-mode-map "\C-c["    'undefined)
            (org-defkey org-mode-map "\C-c]"    'undefined)))

(add-hook 'org-agenda-mode-hook
          '(lambda ()
             (org-defkey org-agenda-mode-map "W" 'obb/widen))
          'append)

(add-hook 'org-agenda-mode-hook
          '(lambda ()
             (org-defkey org-agenda-mode-map "F"
                         'obb/restrict-to-file-or-follow))
          'append)

(add-hook 'org-agenda-mode-hook
          '(lambda ()
             (org-defkey org-agenda-mode-map "N"
                         'obb/narrow-to-subtree))
          'append)

(add-hook 'org-agenda-mode-hook
          '(lambda ()
             (org-defkey org-agenda-mode-map "P"
                         'obb/narrow-to-project))
          'append)

(add-hook 'org-agenda-mode-hook
          '(lambda ()
             (org-defkey org-agenda-mode-map "\C-c\C-x<"
                         'obb/set-agenda-restriction-lock))
          'append)

(add-hook 'org-agenda-mode-hook
          '(lambda ()
             (org-defkey org-agenda-mode-map "U"
                         'obb/narrow-up-one-level))
          'append)

;; Always hilight the current agenda line
(add-hook 'org-agenda-mode-hook
          '(lambda () (hl-line-mode 1))
          'append)

(add-hook 'org-agenda-mode-hook
          (lambda ()
            (define-key org-agenda-mode-map "q" 'bury-buffer))
          'append)

;; **** Functions

(defun obb/org-auto-exclude-function (tag)
  "Automatic task exclusion in the agenda with / RET"
  (and (cond
        ((string= tag "hold")
         t)
        ;; ((string= tag "farm")
        ;;  t)
        )
       (concat "-" tag)))

(defun obb/widen ()
  (interactive)
  (if (equal major-mode 'org-agenda-mode)
      (org-agenda-remove-restriction-lock)
    (widen)
    (org-agenda-remove-restriction-lock)))

(defun obb/restrict-to-file-or-follow (arg)
  "Set agenda restriction to 'file or with argument invoke follow mode.
I don't use follow mode very often but I restrict to file all the
time so change the default 'F' binding in the agenda to allow
both"
  (interactive "p")
  (if (equal arg 4)
      (org-agenda-follow-mode)
    (if (equal major-mode 'org-agenda-mode)
        (obb/set-agenda-restriction-lock 4)
      (widen))))

(defun obb/narrow-to-org-subtree ()
  (widen)
  (org-narrow-to-subtree)
  (save-restriction
    (org-agenda-set-restriction-lock)))

(defun obb/narrow-to-subtree ()
  (interactive)
  (if (equal major-mode 'org-agenda-mode)
      (org-with-point-at (org-get-at-bol 'org-hd-marker)
        (obb/narrow-to-org-subtree))
    (obb/narrow-to-org-subtree)))

(defun obb/narrow-up-one-org-level ()
  (widen)
  (save-excursion
    (outline-up-heading 1 'invisible-ok)
    (obb/narrow-to-org-subtree)))

(defun obb/narrow-up-one-level ()
  (interactive)
  (if (equal major-mode 'org-agenda-mode)
      (org-with-point-at (org-get-at-bol 'org-hd-marker)
        (obb/narrow-up-one-org-level))
    (obb/narrow-up-one-org-level)))

(defun obb/narrow-to-org-project ()
  (widen)
  (save-excursion
    (obb/find-project-task)
    (obb/narrow-to-org-subtree)))

(defun obb/narrow-to-project ()
  (interactive)
  (if (equal major-mode 'org-agenda-mode)
      (org-with-point-at (org-get-at-bol 'org-hd-marker)
        (obb/narrow-to-org-project))
    (obb/narrow-to-org-project)))

(defun obb/set-agenda-restriction-lock (arg)
  "Set restriction lock to current task subtree or file if prefix
is specified"
  (interactive "p")
  (let* ((pom (or (org-get-at-bol 'org-hd-marker)
                  org-agenda-restrict-begin))
         (tags (org-with-point-at pom (org-get-tags-at))))
    (let ((restriction-type (if (equal arg 4) 'file 'subtree)))
      (save-restriction
        (cond
         ((equal major-mode 'org-agenda-mode)
          (org-with-point-at pom
            (org-agenda-set-restriction-lock restriction-type)))
         ((and (equal major-mode 'org-mode)
               (org-before-first-heading-p))
          (org-agenda-set-restriction-lock 'file))
         (t
          (org-with-point-at pom
            (org-agenda-set-restriction-lock
             restriction-type))))))))

(defun obb/agenda-sort (a b)
  "Sorting strategy for agenda items.
Late deadlines first, then scheduled, then non-late deadlines"
  (let (result num-a num-b)
    (cond
     ;; time specific items are already sorted first by
     ;; org-agenda-sorting-strategy

     ;; non-deadline and non-scheduled items next
     ((obb/agenda-sort-test 'obb/is-not-scheduled-or-deadline a b))

     ;; deadlines for today next
     ((obb/agenda-sort-test 'obb/is-due-deadline a b))

     ;; late deadlines next
     ((obb/agenda-sort-test-num 'obb/is-late-deadline '< a b))

     ;; scheduled items for today next
     ((obb/agenda-sort-test 'obb/is-scheduled-today a b))

     ;; late scheduled items next
     ((obb/agenda-sort-test-num 'obb/is-scheduled-late '> a b))

     ;; pending deadlines last
     ((obb/agenda-sort-test-num 'obb/is-pending-deadline '< a b))

     ;; finally default to unsorted
     (t (setq result nil)))
    result))

(defmacro obb/agenda-sort-test (fn a b)
  "Test for agenda sort"
  `(cond
    ;; if both match leave them unsorted
    ((and (apply ,fn (list ,a))
          (apply ,fn (list ,b)))
     (setq result nil))
    ;; if a matches put a first
    ((apply ,fn (list ,a))
     (setq result -1))
    ;; otherwise if b matches put b first
    ((apply ,fn (list ,b))
     (setq result 1))
    ;; if none match leave them unsorted
    (t nil)))

(defmacro obb/agenda-sort-test-num (fn compfn a b)
  `(cond
    ((apply ,fn (list ,a))
     (setq num-a (string-to-number (match-string 1 ,a)))
     (if (apply ,fn (list ,b))
         (progn
           (setq num-b (string-to-number (match-string 1 ,b)))
           (setq result (if (apply ,compfn (list num-a num-b))
                            -1
                          1)))
       (setq result -1)))
    ((apply ,fn (list ,b))
     (setq result 1))
    (t nil)))

(defun obb/is-not-scheduled-or-deadline (date-str)
  (and (not (obb/is-deadline date-str))
       (not (obb/is-scheduled date-str))))

(defun obb/is-due-deadline (date-str)
  (string-match "Deadline:" date-str))

(defun obb/is-late-deadline (date-str)
  (string-match "In *\\(-.*\\)d\.:" date-str))

(defun obb/is-pending-deadline (date-str)
  (string-match "In \\([^-]*\\)d\.:" date-str))

(defun obb/is-deadline (date-str)
  (or (obb/is-due-deadline date-str)
      (obb/is-late-deadline date-str)
      (obb/is-pending-deadline date-str)))

(defun obb/is-scheduled (date-str)
  (or (obb/is-scheduled-today date-str)
      (obb/is-scheduled-late date-str)))

(defun obb/is-scheduled-today (date-str)
  (string-match "Scheduled:" date-str))

(defun obb/is-scheduled-late (date-str)
  (string-match "Sched\.\\(.*\\)x:" date-str))

(defun obb/show-org-agenda ()
  (interactive)
  (switch-to-buffer "*Org Agenda*")
  (delete-other-windows))

;; *** Refile

;; **** Configuration 

;; Targets include this file and any file contributing to the agenda
;; - up to 9 levels deep

(setq org-refile-targets
      (quote ((nil :maxlevel . 9)
              (org-agenda-files :maxlevel . 9))))

;; Use full outline paths for refile targets - we file directly with
;; IDO
(setq org-refile-use-outline-path t)

;; Targets complete directly with IDO
(setq org-outline-path-complete-in-steps nil)

;; Allow refile to create parent tasks with confirmation
(setq org-refile-allow-creating-parent-nodes (quote confirm))

(setq org-refile-target-verify-function 'obb/verify-refile-target)

;; **** Functions

;; Exclude DONE state tasks from refile targets
(defun obb/verify-refile-target ()
  "Exclude todo keywords with a done state from refile targets"
  (not (member (nth 2 (org-heading-components)) org-done-keywords)))


;; *** Org-Babel

;; **** Configuration

(setq org-ditaa-jar-path "~/java/ditaa0_9.jar")
(setq org-plantuml-jar-path "~/java/plantuml.jar")

(add-hook 'org-babel-after-execute-hook
          'obb/display-inline-images 'append)

;; Make babel results blocks lowercase
(setq org-babel-results-keyword "results")

(setq org-structure-template-alist
      (quote (("s" "#+begin_src ?\n\n#+end_src"
               "<src lang=\"?\">\n\n</src>")
              ("e" "#+begin_example\n?\n#+end_example"
               "<example>\n?\n</example>")
              ("q" "#+begin_quote\n?\n#+end_quote"
               "<quote>\n?\n</quote>")
              ("v" "#+begin_verse\n?\n#+end_verse"
               "<verse>\n?\n/verse>")
              ("c" "#+begin_center\n?\n#+end_center"
               "<center>\n?\n/center>")
              ("l" "#+begin_latex\n?\n#+end_latex"
               "<literal style=\"latex\">\n?\n</literal>")
              ("L" "#+latex:"
               "<literal style=\"latex\">?</literal>")
              ("h" "#+begin_html\n?\n#+end_html"
               "<literal style=\"html\">\n?\n</literal>")
              ("H" "#+html:"
               "<literal style=\"html\">?</literal>")
              ("a" "#+begin_ascii\n?\n#+end_ascii")
              ("A" "#+ascii:")
              ("i" "#+index:?" "#+index: ?")
              ("I" "#+include%file ?"
               "<include file=%file markup=\"?\">"))))

(org-babel-do-load-languages
 (quote org-babel-load-languages)
 (quote ((emacs-lisp . t)
         (dot . t)
         (calc . t)
         (ditaa . t)
         (gnuplot . t)
         (shell . t)
         (ledger . t)
         (org . t)
         (lilypond . t)
         (plantuml . t)
         (latex . t))))

;; Do not prompt to confirm evaluation This may be dangerous - make
;; sure you understand the consequences of setting this -- see the
;; docstring for details
(setq org-confirm-babel-evaluate nil)

;; Use fundamental mode when editing plantuml blocks with C-c '
(add-to-list 'org-src-lang-modes (quote ("plantuml" . fundamental)))

;; Don't enable this because it breaks access to emacs from my
;; Android phone
(setq org-startup-with-inline-images nil)

;; **** Functions

(defun obb/display-inline-images ()
  (condition-case nil
      (org-display-inline-images)
    (error nil)))

;; *** Skeletons

;; **** Abbreviations

(define-abbrev org-mode-abbrev-table "sblk" "" 'skel-org-block)

(define-abbrev org-mode-abbrev-table "splantuml" ""
  'skel-org-block-plantuml)

(define-abbrev org-mode-abbrev-table "sdot" ""
  'skel-org-block-dot)

(define-abbrev org-mode-abbrev-table "sditaa" ""
  'skel-org-block-ditaa)

(define-abbrev org-mode-abbrev-table "selisp" ""
  'skel-org-block-elisp)

;; **** Definitions

;; sblk - Generic block #+begin_FOO .. #+end_FOO
(define-skeleton skel-org-block
  "Insert an org block, querying for type."
  "Type: "
  "#+begin_" str "\n"
  _ - \n
  "#+end_" str "\n")

;; splantuml - PlantUML Source block
(define-skeleton skel-org-block-plantuml
  "Insert a org plantuml block, querying for filename."
  "File (no extension): "
  "#+begin_src plantuml :file " str ".png :cache yes\n"
  _ - \n
  "#+end_src\n")

;; sdot - Graphviz DOT block
(define-skeleton skel-org-block-dot
  "Insert a org graphviz dot block, querying for filename."
  "File (no extension): "
  "#+begin_src dot :file " str ".png :cache yes :cmdline -Kdot
  -Tpng\n"
  "graph G {\n"
  _ - \n
  "}\n"
  "#+end_src\n")

;; sditaa - Ditaa source block
(define-skeleton skel-org-block-ditaa
  "Insert a org ditaa block, querying for filename."
  "File (no extension): "
  "#+begin_src ditaa :file " str ".png :cache yes\n"
  _ - \n
  "#+end_src\n")

;; selisp - Emacs Lisp source block
(define-skeleton skel-org-block-elisp
  "Insert a org emacs-lisp block"
  ""
  "#+begin_src emacs-lisp\n"
  _ - \n
  "#+end_src\n")

;; *** Org Weather

;; ;; Load the org-weather library
;; (add-to-list 'load-path "~/<path-to>/org-weather")
(when (try-require 'org-weather)
;; Set your location and refresh the data
(setq org-weather-location "Berlin,DE")
(ignore-errors
  (org-weather-refresh)))


;; *** Keybindings

(setq org-use-speed-commands t)

(global-set-key (kbd "C-M-r") 'org-capture)
(global-set-key (kbd "C-c a") 'org-agenda)

;; ** LaTeX

(message "\n------ entering latex  ------")

;; *** Configuration
 
(try-require 'tex-mode)
(load "auctex.el" nil t t)
;; (load "preview-latex.el" nil t t)

    ;; will be bound to `TeX-electric-macro'
    (setq TeX-electric-escape t)

    ;; ;; leave the `tikzpicture' code unfilled when doing `M-q'
    ;; (add-to-list 'LaTeX-indent-environment-list '("tikzpicture"))

    ;; number of spaces to add to the indentation for each `\begin'
    ;; not matched by a `\end'
    (setq LaTeX-indent-level 4)

    ;; number of spaces to add to the indentation for `\item''s in
    ;; list environments
    (setq LaTeX-item-indent 0)  ; -4

    ;; number of spaces to add to the indentation for each `{' not
    ;; matched by a `}'
    (setq TeX-brace-indent-level 0)  ; 4

    ;; auto-indentation (suggested by the AUCTeX manual - instead of
    ;; adding a local key binding to `RET' in the `LaTeX-mode-hook')
    (setq TeX-newline-function 'newline-and-indent)

    ;; ;; font-lock in latex-mode
    ;; (add-to-list 'LaTeX-verbatim-environments "comment")

    ;; use PDF mode by default (instead of DVI)
    (setq-default TeX-PDF-mode t)

    ;; ;; use a saner PDF viewer (evince, SumatraPDF on win7)
    ;; (setcdr (assoc "^pdf$" TeX-output-view-style)
    ;;      '("." "evince %o"))

    ;; don't show output of TeX compilation in other window
    (setq TeX-show-compilation nil)

    ;; AUC TeX will assume the file is a master file itself
    (setq-default TeX-master t)

    ;; enable parse on load (if no style hook is found for the file)
    (setq TeX-parse-self t)

    ;; enable automatic save of parsed style information when saving
    ;; the buffer
    (setq TeX-auto-save t)

    ;; directory containing automatically generated TeX
    ;; information. Must end with a slash
    (setq TeX-auto-global
          "~/.emacs.d/auctex-auto-generated-info/")

    ;; directory containing automatically generated TeX
    ;; information. Must end with a slash
    (setq TeX-auto-local
          "~/.emacs.d/auctex-auto-generated-info/")

   ;; include 'wideverbatim' in verbatim environments (for
   ;; `PicoLisp-by-Example')
    (setq LaTeX-verbatim-environments
      (quote ("verbatim" "verbatim*" "wideverbatim")))

(when (try-require 'reftex)
  ;; with AUCTeX LaTeX mode
 (add-hook 'LaTeX-mode-hook 'turn-on-reftex)
 (setq
  ;; turn all plug-ins on
  reftex-plug-into-AUCTeX t
  ;; use a separate selection buffer for each label type -- so the
  ;; menu generally comes up faster
  reftex-use-multiple-selection-buffers t
  reftex-label-menu-flags (quote (t t nil nil nil t t nil))))

    (add-hook 'LaTeX-mode-hook 'LaTeX-preview-setup)
    (autoload 'LaTeX-preview-setup "preview")

    ;; how to call gs for conversion from EPS
    (setq preview-gs-command "/usr/bin/gs")
    (obb/file-executable-p preview-gs-command)

    ;; scale factor for included previews
    (setq preview-scale-function 1.2)


;; *** Functions

;; ** Calendar 

(message "\n------ entering calendar  ------")

(setq calendar-latitude 52.3
      calendar-longitude -13.3
      calendar-week-start-day 1)

;; ** Dired

(message "\n------ entering dired ------")

;; editable mode for dired buffers
(when (try-require 'wdired)
    (autoload 'wdired-change-to-wdired-mode "wdired")
    (add-hook 'dired-load-hook
              (lambda ()
                (define-key dired-mode-map
                  (kbd "E") 'wdired-change-to-wdired-mode))))

;; load other dired extensions

(try-require 'dired-extension)
;; (try-require 'dirtree)
(try-require 'dired+)

;; (try-require 'dired-single)
;; (try-require 'dired-sync)

;; (try-require 'dired-toggle)
;; (try-require 'dired-view)

;; find html-files with w3m in dired
(defun dired-find-w3m () (interactive)
  "In Dired, visit (with find-w3m) the file named on this line."
  (w3m-find-file (file-name-sans-versions (dired-get-filename) t)))

;; ;; add a binding "w" -> `dired-find-w3m' to Dired
;; (eval-after-load "dired"
;;   '(progn (define-key dired-mode-map "w" 'dired-find-w3m)))

;; free "M-o" binding from `dired-omit-mode' (since I use "M-o" as
;; prefix for tmux and stumpwm)
(when (try-require 'dired-x)
(eval-after-load "dired-x"
  '(progn
     ;; Add an alternative local binding for the command
     ;; bound to M-o
     (define-key dired-mode-map (kbd "C-c o")
       (lookup-key dired-mode-map (kbd "M-o")))
     ;; Unbind M-o from the local keymap
     (define-key dired-mode-map (kbd "M-o") nil))))

;; ** IRC

(message "\n------ entering irc ------")

(setq
 rcirc-log-flag t
 ;; 8001 6665 6667 6697
 rcirc-default-port 6667
 rcirc-server-alist
 (quote (("irc.freenode.net" :channels ("#org-mode")))))

(rcirc-track-minor-mode 1)
(define-key rcirc-track-minor-mode-map (kbd "C-c `") nil)

;; ** Message

(message "\n------ entering message-mode ------")

(add-hook 'message-mode-hook 'turn-on-auto-fill 'append)

;; ** Magit

(message "\n------ entering magit ------")

(when (try-require 'magit)
;; (global-set-key (kbd "C-c git") 'magit-status) 
(global-set-key (kbd "C-c m m") 'magit-status) 

(defun obb/magit-commit-add-log ()
  (interactive)
  (let* ((ol (car (overlays-at (point))))
	 (beg (overlay-start ol))
	 (end (overlay-end ol))
	 commit-buffer)
    (save-excursion
      (goto-char beg)
      (while (re-search-forward "^[+-]" end t)
	(save-window-excursion
	  (magit-commit-add-log)
	  (setq commit-buffer (current-buffer)))))
    (display-buffer commit-buffer)))3
)

;; ** W3M

(message "\n------ entering emacs-w3m ------")

;; *** Configurations

;; (for Win32, use the Cygwin version of the executable)
(setq w3m-command (executable-find "w3m"))

(setq w3m-start-url "http://orgmode.org/worg/")

(when (and w3m-command
           (file-executable-p w3m-command))
  ;; w3m slows down the startup process dramatically
  (try-idle-require 'w3m)  
  (eval-after-load 'w3m
    '(progn
       (try-require 'w3m-session)
       (try-require 'w3m-extension)
       (w3m-lnum-mode)
       ;; Tabs
       (define-key w3m-mode-map (kbd "<C-tab>") 'w3m-next-buffer)
       (define-key w3m-mode-map [(control shift iso-lefttab)]
         'w3m-previous-buffer)
       (define-key w3m-mode-map (kbd "C-t") 'w3m-new-tab)
       (define-key w3m-mode-map (kbd "C-w") 'w3m-delete-buffer)
       ))

  ;; browsing web pages
  (setq browse-url-browser-function 'w3m-browse-url)
  (autoload 'w3m-browse-url
    "w3m" "Ask a WWW browser to show a URL." t)

  ;; optional keyboard short-cut
  (setq w3m-use-cookies t)

  (setq w3m-coding-system 'utf-8
        w3m-file-coding-system 'utf-8
        w3m-file-name-coding-system 'utf-8
        w3m-input-coding-system 'utf-8
        w3m-output-coding-system 'utf-8
        w3m-terminal-coding-system 'utf-8)

  (standard-display-ascii ?\225 [?+])
  (standard-display-ascii ?\227 [?-])
  (standard-display-ascii ?\222 [?'])

  (setq w3m-use-filter t)
  ;; send all pages through one filter
  (setq w3m-filter-rules `(("\\`.+" w3m-filter-all)))

  (defun w3m-filter-all (url)
    (let ((list '(
                  ;; add more as you see fit!
                  ("&#187;" "&gt;&gt;")
                  ("&laquo;" "&lt;")
                  ("&raquo;" "&gt;")
                  ("&ouml;" "o")
                  ("&#8230;" "...")
                  ("&#8216;" "'")
                  ("&#8217;" "'")
                  ("&rsquo;" "'")
                  ("&lsquo;" "'")
                  ("\u2019" "\'")
                  ("\u2018" "\'")
                  ("\u201c" "\"")
                  ("\u201d" "\"")
                  ("&rdquo;" "\"")
                  ("&ldquo;" "\"")
                  ("&#8220;" "\"")
                  ("&#8221;" "\"")
                  ("\u2013" "-")
                  ("\u2014" "-")
                  ("&#8211;" "-")
                  ("&#8212;" "-")
                  ("&ndash;" "-")
                  ("&mdash;" "-")
                  )))
      (while list
        (let ((pat (car (car list)))
              (rep (car (cdr (car list)))))
          (goto-char (point-min))
          (while (search-forward pat nil t)
            (replace-match rep))
          (setq list (cdr list)))))) )

;; send referers only when both the current page and the target page
;; are provided by the same server
(setq w3m-add-referer 'lambda)

;; home page
(setq w3m-home-page "http://orgmode.org")

;; number of steps in columns used when scrolling a window
;; horizontally
(setq w3m-horizontal-shift-columns 1)  ; 2

;; *** Functions

(defun w3m-new-tab ()
  (interactive)
  (w3m-copy-buffer nil nil nil t))


;; ** Ediff

(message "\n------ entering ediff ------")

;; run `diff' in compilation-mode
(autoload 'diff-mode "diff-mode" "Diff major mode" t)

;; extensions to `diff-mode.el'
(try-require 'diff-mode)

;; ediff, a comprehensive visual interface to diff & patch
;; setup for Ediff's menus and autoloads
(try-require 'ediff-hook)

;; auto-refine only the regions of this size (in bytes) or less
(setq ediff-auto-refine-limit (* 2 14000))

;; do everything in one frame
(setq ediff-window-setup-function 'ediff-setup-windows-plain)

;; split the window depending on the frame width
(setq ediff-split-window-function
      (lambda (&optional arg)
        (if (> (frame-width) 160)
            (split-window-horizontally arg)
          (split-window-vertically arg))))

;; prepare org-files for ediff
(defun f-ediff-prepare-buffer-hook-setup ()
  ;; specific modes
  (cond ((eq major-mode 'org-mode)
         (f-org-vis-mod-maximum))
        ;; room for more modes
        )
  ;; all modes
  (setq truncate-lines nil))

(defun f-org-vis-mod-maximum ()
  "Visibility: Show the most possible."
  (cond
   ((eq major-mode 'org-mode)
    (visible-mode 1)  ; default 0
    (setq truncate-lines nil)  ; no `org-startup-truncated' in hook
    (setq org-hide-leading-stars nil))  ; default nil
    ;; (setq org-hide-leading-stars t))  ; default nil
   (t
    (message "ERR: not in Org mode")
    (ding))))

(add-hook 'ediff-prepare-buffer-hook
          'f-ediff-prepare-buffer-hook-setup)

(try-require 'diff-git)

;; ** Occur

;; *** Configurations
 
;; Replace global 'occur function
(global-set-key (kbd "M-s o") 'obb/occur-search-and-switch)

;; Occur mode: new/better keybindings
(define-key occur-mode-map (kbd "d") 'occur-mode-display-occurrence)
(define-key occur-mode-map (kbd "n") 'occur-next)
(define-key occur-mode-map (kbd "p") 'occur-prev)
(define-key occur-mode-map (kbd "q") 'obb/occur-quit-and-switch)
(define-key isearch-mode-map (kbd "M-s i") 'isearch-occur)

;; `M-x flush-lines' deletes each line that contains a match for
;; REGEXP

;; *** Functions

(defun isearch-occur ()
  "Invoke `occur' from within isearch."
  (interactive)
  (let ((case-fold-search isearch-case-fold-search))
    (occur (if isearch-regexp isearch-string (regexp-quote isearch-string)))))

;; Convenience function for 'M-x occur': switch immediatly to *Occur* buffer
(defun obb/occur-search-and-switch ()
  "Call `occur' and immediatley switch to *Occur* buffer"
  (interactive)
  (setq occur-search-and-switch-marker (point-marker))
  (call-interactively 'occur)
    (switch-to-buffer-other-window "*Occur*"))

;; Convenience function for 'M-x quit-window': switch immediatly back to
;; search buffer
(defun obb/occur-quit-and-switch ()
  "Quit `occur' and immediatley switch back to original buffer"
  (interactive)
  (quit-window)
  (switch-to-buffer
   (marker-buffer occur-search-and-switch-marker))
  (goto-char
   (marker-position occur-search-and-switch-marker))
  (set-marker occur-search-and-switch-marker nil))

;; ** Lilypond

(message "\n------ entering lilypond ------")

(when (try-require 'lilypond-mode)
(add-to-list 'auto-mode-alist '("\\.ly\\'" . LilyPond-mode)))

;; * Minor Modes

(message "\n------ entering MINOR MODES ------")

;; ** Outline

(message "\n------ entering outline ------")

(when (try-require 'outline)
(add-hook 'emacs-lisp-mode-hook 'outline-minor-mode)
(add-hook 'message-mode-hook 'outline-minor-mode))

;; outorg

(try-require 'outorg)

;; outshine
(try-require 'outshine)
(add-hook 'outline-minor-mode-hook 'outshine-hook-function)

(setq outshine-use-speed-commands t)

;; navi-mode
(try-require 'navi-mode)

;; poporg

(try-require 'poporg)

;; ** Ido

(message "\n------ entering ido ------")

(when (try-require 'ido)
  ;; (try-require 'idomenu)
  (ido-mode 1)
  (ido-everywhere 1)
  (ido-mode (quote both))
  (setq ido-max-directory-size 100000)
  (setq ido-confirm-unique-completion t)
  (setq ido-enable-flex-matching t)
  (setq ido-enable-prefix nil)
  (setq ido-max-prospects 10)
  (setq ido-auto-merge-delay-time 1.5)
  ;; ;; uses ffap-guesser
  ;; ido-use-filename-at-point 'guess)
  (setq org-completion-use-ido t)
  ;; (try-require 'ido-ubiquitous)
  ;; (try-require 'ido-better-flex)
  )

;; ** Company

(message "\n------ entering company ------")

;; *** Configuration

;; from (http://goo.gl/lQVUs2)
(when (try-require 'company)
  (setq company-idle-delay 0.3)
  (setq company-tooltip-limit 5)
  (setq company-minimum-prefix-length 3)
  (setq company-echo-delay 0)
  (setq company-auto-complete nil)
  (global-company-mode 1)
  (add-to-list 'company-backends 'company-dabbrev t)
  (add-to-list 'company-backends 'company-ispell t)
  (add-to-list 'company-backends 'company-files t)
  (setq company-backends
	(remove 'company-ropemacs company-backends)))

;; ** Smex

(message "\n------ entering smex ------")

(when (try-require 'smex)
(smex-initialize)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-x xx") 'smex)
(global-set-key (kbd "M-X") 'smex-major-mode-commands))


(message "\n------ entering Helm ------")

(when (try-require 'helm-config)
  ;; (helm-mode 1)
  ;; (global-set-key (kbd "M-x") 'helm-M-x)
  )

;; ** S

(message "\n------ entering S ------")

(try-require 's-buffer)

;; ** Undo Tree Mode

(message "\n------ entering undo-tree ------")

;; If the user enabled Undo Tree's diff mode
;; (undo-tree-visualizer-toggle-diff) a diff-mode buffer will show the
;; current node diffed against its parent.  Using
;; undo-tree-visualizer-selection-mode, the user can diff against
;; arbitrary nodes of the undo tree.


(when (try-require 'undo-tree)
(autoload 'global-undo-tree-mode
  "undo-tree" "Global undo tree mode" t)
(global-undo-tree-mode t)
(global-set-key (kbd "C-c u d")
		'undo-tree-visualizer-toggle-diff)
(global-set-key (kbd "C-c u s")
		'undo-tree-visualizer-selection-mode))

;; ** Boxquote

(message "\n------ entering boxquote ------")

(when (try-require 'boxquote)
;; (global-set-key (kbd "C-c rd") 'rebox-dwim)
  ;; describe
  (global-set-key (kbd "C-c x k") 'boxquote-describe-key)
  (global-set-key (kbd "C-c x f") 'boxquote-describe-function)
  (global-set-key (kbd "C-c x v") 'boxquote-describe-variable)
  ;; elems
  (global-set-key (kbd "C-c x b") 'boxquote-buffer)
  (global-set-key (kbd "C-c x r") 'boxquote-region)
  (global-set-key (kbd "C-c x x") 'boxquote-unbox-region)
  (global-set-key (kbd "C-c x d") 'boxquote-defun)
  (global-set-key (kbd "C-c x p") 'boxquote-paragraph)
  (global-set-key (kbd "C-c x q") 'boxquote-fill-paragraph)
  (global-set-key (kbd "C-c x s") 'boxquote-shell-command)
  (global-set-key (kbd "C-c x h") 'boxquote-quote-help-buffer)
  ;; misc
  (global-set-key (kbd "C-c x n") 'boxquote-narrow-to-boxquote)
  (global-set-key (kbd "C-c x u") 'boxquote-unbox)
  (global-set-key (kbd "C-c x e") 'boxquote-text)
  (global-set-key (kbd "C-c x i") 'boxquote-title))


;; ** Rainbow Delimiters

(message "\n------ entering rainbow-delimiters ------")

(when (try-require 'rainbow-delimiters)
  (global-rainbow-delimiters-mode))

;; ** Auto Pair

(message "\n------ entering auto-pair ------")

;; ** Smartparens

(message "\n------ entering smart-parens ------")

(when (try-require 'smartparens-config)
 (smartparens-global-mode t))

;; ** Eldoc

(message "\n------ entering eldoc ------")

(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
(add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
(add-hook 'ielm-mode-hook 'turn-on-eldoc-mode)

;; ** Openwith

(message "\n------ entering openwith ------")


(when (try-require 'openwith)

;; openwith-mode (disable before attaching filetypes mentioned below
;; in `message-mode' (GNUS)
(setq openwith-associations
      (quote (
              ("\\.pdf\\'" "fbgs" (file))
              ("\\.mp3\\'" "xmms" (file))
              ("\\.\\(?:mpe?g\\|avi\\|wmv\\)\\'" "mplayer"
               ("-idx" file))
              ("\\.\\(?:jp?g\\|png\\)\\'" "display" (file))))))

;; ** Workgroups

(message "\n------ entering workgroups ------")

(when (try-require 'workgroups)
  (setq wg-prefix-key (kbd "M-o"))
  (workgroups-mode 1)
  (setq wg-morph-on nil)
  (wg-load (expand-file-name "~/.emacs.d/workgroups")))

;; ** Switch Windows

(message "\n------ entering switch-windows ------")

(try-require 'switch-window)

;; ** Window Numbering

(message "\n------ entering window-numbering ------")

(when (try-require 'window-numbering)
  (window-numbering-mode 1))

;; ** Winner Mode

(message "\n------ entering winner-mode ------")

(when (try-require 'winner)
   (when (fboundp 'winner-mode)
   (winner-mode 1))

   (global-set-key (kbd "<f5>") 'winner-undo)
   (global-set-key (kbd "<f6>") 'winner-redo))

;; ** Nuke'n Eval 

(message "\n------ entering nukeneval ------")

;; nuke and reevaluate an elisp buffer
(when (try-require 'nukneval)

(add-hook 'emacs-lisp-mode-hook
         (lambda ()
           (define-key emacs-lisp-mode-map (kbd "C-c M-n")
             'nuke-and-eval))) )
;; ** Recentf

(recentf-mode 1)
(setq recentf-max-menu-items 25)

(defun recentf-ido-find-file ()
  "Find a recent file using Ido."
  (interactive)
  (let* ((file-assoc-list
          (mapcar (lambda (x)
                    (cons (file-name-nondirectory x)
                          x))
                  recentf-list))
         (filename-list
          (remove-duplicates (mapcar #'car file-assoc-list)
                             :test #'string=))
         (filename (ido-completing-read "Choose recent file: "
                                        filename-list
                                        nil
                                        t)))
    (when filename
      (find-file (cdr (assoc filename
                             file-assoc-list))))))


;; (global-set-key (kbd "C-c oi") 'recentf-open-files)
(global-set-key (kbd "C-c f f") 'recentf-ido-find-file)

;; ** Lorem ipsum

(message "\n------ entering lorem-ipsum ------")

(try-require 'lorem-ipsum)

;; * End Startup

;; warn that some packages were missing
(if missing-packages-list
    (progn (message "Packages not found: %S"
                    missing-packages-list)))

;; startup time
(message "Emacs startup time: %d seconds."
         (time-to-seconds (time-since emacs-load-start-time)))

;; was set to `t' at beginning of buffer
(setq debug-on-error nil) 

;; * Custom Set Variables/Fonts

(message "\n------ FINALLY Custom vars/fonts ------\n")

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
)
