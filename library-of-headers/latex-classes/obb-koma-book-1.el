;; * obb-koma-book-1

(;; Name
 "obb-koma-book-1" 
 ;; Preamble
 "\\documentclass{scrbook}
  [NO-DEFAULT-PACKAGES]
  [NO-PACKAGES]
  \\usepackage[utf8]{inputenc}
  \\usepackage[T1]{fontenc}
  \\usepackage{palatino}
  \\bibliographystyle{alpha}
  \\bibliography{../bandbook.bib}
  \\usepackage{fixltx2e}
  \\usepackage{graphicx}
  \\setcounter{tocdepth}{1}
  \\setcounter{secnumdepth}{1}
  \\usepackage{float}
  \\usepackage[cm]{fullpage}
  [EXTRA]   
  [TITLEPAGE]"
 ;; Sectioning Structure
 ("\\part{%s}" . "\\part*{%s}")
 ("\\chapter{%s}" . "\\chapter*{%s}")
 ("\\section{%s}" . "\\section*{%s}")
 ("\\subsection{%s}" . "\\subsection*{%s}")
 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
 ("\\paragraph{%s}" . "\\paragraph*{%s}")
 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
