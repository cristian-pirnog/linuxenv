;; Function for inserting a Jalopy comment delimiter
(defun java-insert-comment-delimiter()
  (interactive)
  (setq begin (point))
  (insert "//-----------------------------------------\n")
  (insert "//                                        -\n")
  (insert "//-----------------------------------------\n")
  (indent-region begin (point) nil)
  (c-indent-line)
  ;; (message "Comment delimiter inserted at lines %i to %i" (line-number) (+ (line-number) 3))
)


;; Function for inserting a Jalopy comment delimiter
(defun java-insert-class-skeleton()
  (interactive)
  (setq begin (point))

  (setq myClassName (read-from-minibuffer "Enter class name: "))
  (insert (concat "public class " myClassName "\n{\n"))
  (insert "public static void main(String[] anArgs)\n{\n")
  (insert "\n")
  (insert "}\n")
  (insert "}\n")
  (indent-region begin (point) nil)
  (c-indent-line)
  (forward-line -3)
)

;; Function for inserting a normal comment
(defun java-insert-comment()
  (interactive)
  (c-indent-line)
  (insert "//----------------------------------------------------------------------\n")
  (c-indent-line)
  ;; (message "Comment inserted at line %i" (line-number))
)


;; Function for inserting a trace definition
(defun java-insert-trace-definition()
  (interactive)
  (c-indent-line)
  (insert "static final private Trace theTrace = new Trace(.class.getName());\n")
  (forward-line -1)
  (forward-char 52)
  ;; (message "Trace definition inserted at line %i" (line-number))
)


;; Function for inserting a trace statement
(defun java-insert-trace-statement()
  (interactive)
  (insert "if (theTrace.ACTIVE) theTrace.println(\"(\" + \")\");\n")
  (forward-line -1)
  (forward-char 39)
  (c-indent-line)
  ;; (message "Trace statement inserted at line %i" (line-number))
)


;; Function for inserting an assert statement
(defun java-insert-assert-statement()
  (interactive)
  (insert "if (Assert.ON) Assert.on(, \"\");\n")
  (forward-line -1)
  (forward-char 25)
  (c-indent-line)
)

;; Function for inserting an assert statement
(defun java-insert-assert-null-statement()
  (interactive)
  (insert "if (Assert.ON) Assert.on(!=null, \"\");\n")
  (forward-line -1)
  (forward-char 25)
  (c-indent-line)
)


;; Function for inserting a message statement
(defun java-insert-message-statement()
  (interactive)
  (insert "new Message(.class, \"\").log();\n")
  (forward-line -1)
  (forward-char 12)
  (c-indent-line)
)

;; Function for inserting a complete function skeleton
(defun java-insert-full-function()
  (interactive)

  ;; Input values
  (setq access (format "%s" (read-minibuffer "Access: ")))
  (setq returnType (format "%s" (read-minibuffer "Return type: ")))
  (setq funcName (format "%s" (read-minibuffer "Method name: ")))

  ;; Insert the function body
  (setq begin (point))
  (java-insert-comment)
  (insert access " " returnType "\n")
  (insert funcName "()\n")
  (insert "{\n\n")
  (insert "}\n")
  (indent-region begin (point) nil)
  (forward-line -2)
  (java-insert-trace-statement)
  (insert funcName)
  (forward-line 1)
  (c-indent-line)
  ;; (message "Function body inserted at line %i" (line-number))
)
