;; * obb-koma-book-1

(;; Name
 "obb-koma-book-1" 
 ;; Preamble
 "\\documentclass{scrbook}
  [DEFAULT-PACKAGES]
  [PACKAGES]
  [EXTRA]   
  \\usepackage{palatino}
  \\usepackage[cm]{fullpage}
  \\bibliographystyle{alpha}
  \\bibliography{../bandbook.bib}
  \\setcounter{tocdepth}{1}
  \\setcounter{secnumdepth}{1}
  [TITLEPAGE]"
 ;; Sectioning Structure
 ("\\part{%s}" . "\\part*{%s}")
 ("\\chapter{%s}" . "\\chapter*{%s}")
 ("\\section{%s}" . "\\section*{%s}")
 ("\\subsection{%s}" . "\\subsection*{%s}")
 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
 ("\\paragraph{%s}" . "\\paragraph*{%s}")
 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
