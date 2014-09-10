;; * obb-article-full-page

(;; Name
  "obb-article-full-page"
  ;; Preamble
   "\\documentclass{article}
   [DEFAULT-PACKAGES]
   [PACKAGES]
   [EXTRA]
   \\usepackage[cm]{fullpage}}"
  ;; Sectioning Structure
  ("\\section{%s}" . "\\section*{%s}")
  ("\\subsection{%s}" . "\\subsection*{%s}")
  ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
  ("\\paragraph{%s}" . "\\paragraph*{%s}")
  ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
