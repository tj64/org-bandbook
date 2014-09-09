;; * obb-koma-book-1

(;; Name
 "obb-koma-book-1" 
 ;; Preamble
 "\\documentclass{scrbook}
  [NO-DEFAULT-PACKAGES]
  [NO-PACKAGES]
  [NO-EXTRA]   
  \\usepackage[utf8]{inputenc}
  \\usepackage[T1]{fontenc}
  \\usepackage{palatino}
  \\bibliographystyle{alpha}
  \\bibliography{../bandbook.bib}
  \\usepackage{fixltx2e}
  \\usepackage{graphicx}
  \\setcounter{tocdepth}{1}
  \\setcounter{secnumdepth}{1}
  \\usepackage{microtype}
  \\usepackage{url}
  \\usepackage{longtable}
  \\usepackage{float}
  \\usepackage{wrapfig}
  \\usepackage{rotating}
  \\usepackage[normalem]{ulem}
  \\usepackage{amsmath}
  \\usepackage{marvosym}
  \\usepackage{wasysym}
  \\usepackage{amssymb}
  \\tolerance=1000
  \\usepackage[cm]{fullpage}
  \\usepackage{paralist}
  \\let\\enumerate\\compactenum
  \\let\\description\\compactdesc
  \\let\\itemize\\compactitem
  \\let\\latin\\textit
  \\usepackage{textcomp}
  \\usepackage{tabularx}
  \\usepackage[x11names]{xcolor}
  [TITLEPAGE]
  \\maketitle
  \\tableofcontents"
 ;; Sectioning Structure
 ("\\part{%s}" . "\\part*{%s}")
 ("\\chapter{%s}" . "\\chapter*{%s}")
 ("\\section{%s}" . "\\section*{%s}")
 ("\\subsection{%s}" . "\\subsection*{%s}")
 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
 ("\\paragraph{%s}" . "\\paragraph*{%s}")
 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
