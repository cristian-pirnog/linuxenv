(defun smart-symbol (symbol) ; make a given key behave in a smarter way
  (interactive)

  (if (not (expand-abbrev)) ; Test if the current word is an abbrev. If yes, expand it.
      (insert symbol)       ; If not, insert a plain symbol
    )                       ; Now you know how to use 'if' in emacs lisp
  )


(defun smart-space () ; make the space key behave in a smarter way
  (interactive)
  (smart-symbol " ")
  )


(defun smart-return () ; make the return key behave in a smarter way
  (interactive)
  ;(smart-symbol "")
  )


