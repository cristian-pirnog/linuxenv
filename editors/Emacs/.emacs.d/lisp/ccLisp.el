;; Function for inserting FOR statement with unsigned integer i
(defun cc-insert-for-loop( argumentType )
  (interactive)

  (setq DEFAULT_INDEX "i")

  ; Ask the user for the name of the index variable (i.e. i, j, k, myIndex)
  (setq indexName (read-from-minibuffer (concat "Index variable name (" DEFAULT_INDEX "): ") ""))

  (if (= 0 (length indexName)) (setq indexName DEFAULT_INDEX))
  (if (= 0 (length argumentType))
      (setq extraSpace "")
    (setq extraSpace " "))
    

  (setq begin (point))
  (insert (concat "for(" argumentType extraSpace "int " indexName "=0; " indexName "<; " indexName) "++)\n")
  (insert "{\n")
  (insert "\n}\n")
  (indent-region begin (point) nil)
  (c-indent-line)
  (previous-line 4)
  (forward-char (+ 13 (length argumentType) (length extraSpace) (* 2 (length indexName))))
  (message (concat"Length of your input is "  (number-to-string (length indexName))))
)


;; Function for inserting FOR statement with unsigned integer i (wrapper function)
(defun cc-insert-for-unsigned-loop()
  (interactive)
  (cc-insert-for-loop "unsigned")
)


;; Function for inserting FOR statement with signed integer i (wrapper function)
(defun cc-insert-for-signed-loop()
  (interactive)
  (cc-insert-for-loop "")
)

;; Function for inserting a 'cout' statement
(defun cc-insert-cout()
  (interactive)

  (insert "cout << << endl;")
  (backward-char 9)
)


;; Function for inserting a DOXYGEN comment
(defun cc-insert-doxygen-comment()
  (interactive)

  (setq begin (point))

  (insert "/*! \\brief .\n")
  (insert "*\n*\n**/")
  (indent-region begin (point) nil)

  (previous-line 3)
  (end-of-line)
  (backward-char 1)
)


;; Function for inserting IF-ELSE statement
(defun cc-insert-if-else-statement()
  (interactive)
  (setq begin (point))
  (insert "if()\n")
  (insert "{\n\n}\n")
  (insert "else\n")
  (insert "{\n\n}\n")
  (indent-region begin (point) nil)
  (c-indent-line)
  (previous-line 8)
  (forward-char 3)
  ;; (message "Comment delimiter inserted at lines %i to %i" (line-number) (+ (line-number) 3))
)


;; Function for inserting IF-ELSE-IF statement
(defun cc-insert-if-else-if-statement()
  (interactive)
  (setq begin (point))
  (insert "if()\n")
  (insert "{\n\n}\n")
  (insert "else if()\n")
  (insert "{\n\n}\n")
  (insert "// else\n")
  (insert "// {\n// \n// }\n")
  (indent-region begin (point) nil)
  (c-indent-line)
  (previous-line 12)
  (forward-char 3)
)

;; Function for inserting header comment
(defun cc-insert-header-svn()
  (interactive)
  (setq begin (point))
  (insert "/***\n*\n")
  (insert "* $LastChangedBy$\n")
  (insert "* $LastChangedDate$\n")
  (insert "* $LastChangedRevision$\n")
  (insert "*\n***/\n")
  (indent-region begin (point) nil)
)

;; Function for inserting a DEBUG ifdef
(defun cc-insert-debug-ifded()
  (interactive)
  (setq begin (point))
  (insert "#ifdef DEBUG\n")
  (insert "\n")
  (insert "#endif //DEBUG\n")
  (indent-region begin (point) nil)
  (previous-line 2)
  (c-indent-line)
)

(defun cc-insert-main-skeleton()
  (interactive)
  (cc-insert-iostream)
  (insert "int main()\n")
  (insert "{\n")
  (insert "\n")
  (insert "\n")
  (insert "return 0;\n")
  (insert "}\n")
  (previous-line 4)
)

(defun cc-insert-iostream()
(interactive)
(insert "#include <iostream>\n")
(insert "using namespace std;\n\n")
)

(defun cc-insert-class-skeleton()
(interactive)

(setq myExtension (file-name-extension (buffer-name)))
(setq myFileNameWithoutExt (file-name-sans-extension (buffer-name)))
(setq myIsHeaderFile (string-match myExtension "hpp"))

(setq myClassName (read-from-minibuffer "Class name: " myFileNameWithoutExt))

(setq myNeedsIfndef (and myIsHeaderFile (= (buffer-size) 0)))
(setq myIfndefTag (concat "__" myFileNameWithoutExt "__"))

;; Insert the start of the ifndef construct
(if myNeedsIfndef
    (insert "#ifndef " myIfndefTag "\n#define " myIfndefTag "\n\n\n"))

;; Insert the class declaration
(insert "namespace gj\n{\n")
(insert "class " myClassName "\n")
(insert "{\n")
(insert "public:\n")
(insert myClassName "();\n")
(insert "virtual ~" myClassName "();\n\n\n")
(insert "protected:\n\n\n")
(insert "private:\n\n\n")
(insert "// Members\n")
(insert "private:\n\n\n")
(insert "};\n\n//Inline methods\n\n}; //namespace gj\n\n")

;; Insert the rest of the ifndef construct
(if myNeedsIfndef
    (insert "#endif //" myIfndefTag "\n"))


;; If we're in a header file, open the .C file
(if (and myIsHeaderFile (string-match myFileNameWithoutExt myClassName))
    (progn
     (find-file (concat myFileNameWithoutExt ".C"))
     (insert "#include <iostream>\n\n")
     (insert "#include <" myFileNameWithoutExt ".h>\n\n")
     (insert "using namespace std;\n\n\n")
     ))

;; Insert the defs of the constructor and destructor
(insert "namespace gj\n{\n\n")
(insert myClassName "::" myClassName "()\n")
(insert "{\n/*Do nothing*/\n}\n\n")

(insert myClassName "::~" myClassName "()\n")
(insert "{\n/*Do nothing*/\n}\n")
(insert "}; // namespace gj\n")
)

(defun cc-insert-brackets()
(interactive)
(insert "{\n\n}\n")
(previous-line 2)
)


;;=====================================================
;;   These functions should be used only when writing
;;                 Matlab MEX files.
;;=====================================================
;; Function for inserting mexPrintf statement
(defun cc-insert-mexPrintf()
  (interactive)
  (insert "mexPrintf(\"\\n\");")
  (backward-char 5)
  (c-indent-line)
)

;; Function for inserting mexPrintf statement
(defun cc-insert-mexErrMsgTxt()
  (interactive)
  (insert "mexErrMsgIdAndTxt(\"SAGZUG:")
  ;; Matlab 7.1 does not alow dots in the message indentifier ==> replace it with '_'
  (if (string-match  "\\.cpp$" (file-name-nondirectory (buffer-file-name)))
      (setq file_extension "_cpp")
    (if (string-match  "\\.cxx$" (file-name-nondirectory (buffer-file-name)))
        (setq file_extension "_cxx")
      (setq file_extension "_c")))
  (insert (concat (file-name-nondirectory (file-name-sans-extension (buffer-file-name))) file_extension))
  (insert "\", \"\");")
  (backward-char 3)
  (c-indent-line)
)
