;; * obb-koma-book-1

(add-to-list
 'org-latex-classes
 '(
   ;; Name
   "obb-koma-book-1" 

   ;; Preamble
   (concat
    "\\documentclass{scrbook}\n"
    "[NO-DEFAULT-PACKAGES]\n"
    "[NO-PACKAGES]\n"
    "[NO-EXTRA]\n"   
    "\\usepackage[utf8]{inputenc}\n"
    "\\usepackage[T1]{fontenc}\n"
    "\\usepackage{palatino}\n"
    "\\bibliographystyle{alpha}\n"
    "\\bibliography{../bandbook.bib}\n"
    "\\usepackage{fixltx2e}\n"
    "\\usepackage{graphicx}\n"
    "\\setcounter{tocdepth}{1}\n"
    "\\setcounter{secnumdepth}{1}\n"
    "\\usepackage{microtype}\n"
    "\\usepackage{url}\n"
    "\\usepackage{longtable}\n"
    "\\usepackage{float}\n"
    "\\usepackage{wrapfig}\n"
    "\\usepackage{rotating}\n"
    "\\usepackage[normalem]{ulem}\n"
    "\\usepackage{amsmath}\n"
    "\\usepackage{marvosym}\n"
    "\\usepackage{wasysym}\n"
    "\\usepackage{amssymb}\n"
    "\\tolerance=1000\n"
    "\\usepackage[cm]{fullpage}\n"
    "\\usepackage{paralist}\n"
    "\\let\\enumerate\\compactenum\n"
    "\\let\\description\\compactdesc\n"
    "\\let\\itemize\\compactitem\n"
    "\\let\\latin\\textit\n"
    "\\usepackage{textcomp}\n"
    "\\usepackage{tabularx}\n"
    "\\usepackage[x11names]{xcolor}\n")

   ;; Sectioning Structure

   ("\\part{%s}" . "\\part*{%s}")
   ("\\chapter{%s}" . "\\chapter*{%s}")
   ("\\section{%s}" . "\\section*{%s}")
   ("\\subsection{%s}" . "\\subsection*{%s}")
   ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
   ("\\paragraph{%s}" . "\\paragraph*{%s}")
   ("\\subparagraph{%s}" . "\\subparagraph*{%s}")

   ))
