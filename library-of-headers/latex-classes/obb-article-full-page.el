;; * obb-article-full-page

'(;; Name
  "obb-article-full-page"
  ;; Preamble
  (concat
   "\\documentclass{article}\n"
   "[DEFAULT-PACKAGES]\n"
   "[PACKAGES]\n"
   "[EXTRA]\n"
   "\\usepackage[cm]{fullpage}}\n")
  ;; Sectioning Structure
  ("\\part{%s}" . "\\part*{%s}")
  ("\\chapter{%s}" . "\\chapter*{%s}")
  ("\\section{%s}" . "\\section*{%s}")
  ("\\subsection{%s}" . "\\subsection*{%s}")
  ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
  ("\\paragraph{%s}" . "\\paragraph*{%s}")
  ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))
