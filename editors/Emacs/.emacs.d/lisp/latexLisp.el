;; Function for inserting the LATEX "inline equation" tags
(defun latex-insert-inline-equation-tags()
  (interactive)
  (insert "\\(\\)")
  (backward-char 2)
)

;; Function for inserting the LATEX "equation" tags
(defun latex-insert-equation-tags()
  (interactive)
  (insert "% equation\n")
  (insert "\\begin{equation}\n\t\n")
  (insert "\\end{equation}")
  (previous-line 1)
)

;; Function for inserting the LATEX "enumerate" tags
(defun latex-insert-enumerate-tags()
  (interactive)
  (insert "\\begin{enumerate}\n")
  (insert "\t% item\n\t\\item\n\n")
  (insert "\t% item\n\t\\item\n")
  (insert "\\end{enumerate}")
  (previous-line 4)
)

;; Function for inserting the LATEX "itemize" tags
(defun latex-insert-itemize-tags()
  (interactive)
  (insert "\\begin{itemize}\n")
  (insert "\t% item\n\t\\item\n\n")
  (insert "\t% item\n\t\\item\n")
  (insert "\\end{itemize}")
  (previous-line 4)
)

;; Function for inserting the LATEX "figure" tags
(defun latex-insert-figure-tags()
  (interactive)
  (insert "% figure\n")
  (insert "\\begin{figure}\n\\\centering{\n")
  (insert "\\includegraphics[width=0.9\\textwidth]{}\n")
  (insert "\\caption{}\n")
  (insert "\\label{fig:}\n")
  (insert "}\n\\end{figure}")
  (previous-line 4)
  (forward-char 26)
)

;; Function for inserting the LATEX "table" tags
(defun latex-insert-table-tags()
  (interactive)

  ; Ask the user for the table's details
  (setq centering (read-from-minibuffer "Centering(l,c,r): " "c"))
  (setq nrColumns (read-from-minibuffer "Number of columns: " "3"))
  (setq nrRows (read-from-minibuffer "Number of rows: " "2"))
  (setq tableLabel (read-from-minibuffer "Table label: " ""))

  ;; Construct the table formatter
  (setq tableFormatter (concat "| " centering " | "))
  (setq rowFormatter "\t")
  (setq iterator 1)
  (while (< iterator (string-to-number nrColumns))
    (setq tableFormatter (concat tableFormatter centering "| "))
    (setq rowFormatter (concat rowFormatter "& "))
    (setq iterator (+ iterator 1))
    )
  (setq rowFormatter (concat rowFormatter "\\\\\n\t\\hline\n"))

  ;; Insert the table
  (insert "% table\n")
  (insert "\\begin{table}[htb]\n")
  (insert "\\centering{\n")
  (insert (concat "\\begin{tabular}{" tableFormatter "}\n"))
  (insert "\t\\hline\n")
  (setq iterator 0)
  (while (< iterator (string-to-number nrRows))
    (insert rowFormatter)
    (setq iterator (+ iterator 1))
    )
  (insert "\\end{tabular}\n")
  (insert "\\caption{}\n")
  (insert (concat "\\label{table:" tableLabel "}\n"))
  (insert "}\n")
  (insert "\\end{table}\n")

  (previous-line (+ (* (string-to-number nrRows) 2) 5))
  (forward-char 1)
)
