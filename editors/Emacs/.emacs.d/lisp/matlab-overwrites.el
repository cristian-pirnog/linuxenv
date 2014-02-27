;; Special things for matlab mode
(require 'executable)
(require 'tempo)

;; (load "/opt/Software/matlab/7.4/java/extern/EmacsLink/lisp/matlab.el" nil t t)

;; This variable is used for setting the length of a line before wrapping is done
(setq default-fill-column 83)
(setq matlab-mode-map
  (let ((km (make-sparse-keymap)))
    (define-key km [return] 'matlab-return)
    (define-key km "%" 'matlab-electric-comment)
    (define-key km "\C-c;" 'matlab-comment-region)
    (define-key km "\C-c:" 'matlab-uncomment-region)
    (define-key km [(control c) return] 'matlab-comment-return)
    (define-key km [(control c) (control c)] matlab-insert-map)
    (define-key km [(control c) (control f)] 'matlab-fill-comment-line)
    (define-key km [(control c) (control j)] 'matlab-justify-line)
    (define-key km [(control c) (control q)] 'matlab-fill-region)
    (define-key km [(control c) (control s)] 'matlab-shell-save-and-go)
    (define-key km [(control c) (control r)] 'matlab-shell-run-region)
    (define-key km [(control c) (control t)] 'matlab-show-line-info)
    (define-key km [(control c) ?. ] 'matlab-find-file-on-path)
    (define-key km "\C-ch" 'matlab-shell-show-help)
    (define-key km [(control h) (control m)] matlab-help-map)
    (define-key km [(control j)] 'matlab-linefeed)
    (define-key km "\M-\r" 'newline)
    (define-key km [(meta \;)] 'matlab-comment)
    (define-key km [(meta q)] 'matlab-fill-paragraph)
    (define-key km [(meta a)] 'matlab-beginning-of-command)
    (define-key km [(meta e)] 'matlab-end-of-command)
    (define-key km [(meta j)] 'matlab-comment-line-break-function)
    (define-key km [(meta s)] 'matlab-show-matlab-shell-buffer)
    (define-key km "\M-\t" 'matlab-complete-symbol)
    (define-key km [(meta control f)] 'matlab-forward-sexp)
    (define-key km [(meta control b)] 'matlab-backward-sexp)
    (define-key km [(meta control q)] 'matlab-indent-sexp)
    (define-key km [(meta control a)] 'matlab-beginning-of-defun)
    (define-key km [(meta control e)] 'matlab-end-of-defun)
    (if (string-match "XEmacs" emacs-version)
	(define-key km [(control meta button1)] 'matlab-find-file-click)
      (define-key km [(control meta mouse-2)] 'matlab-find-file-click))
    (substitute-key-definition 'comment-region 'matlab-comment-region
			       km) ; global-map ;torkel
    km))



;;; helper functions for matlab-mode  =======================================
;;;  Written by Cristian Pirnog (crpi)
;;;
(defun matlab-shell-show-help (functionName)
  (interactive
   (list
    (let ((default (matlab-read-word-at-point)))
      (if default
      (setq s default))
   )))
  (setq command (concat "help " functionName))
  (message command)

  (if (matlab-with-emacs-link)
     ; Run the region w/ Emacs Link
     (matlab-eei-eval-m-expr command)
  (message "This command requires the emacs-link"))
)


(defun matlab-insert-help-end ()
  "Inserts some text (normally, at the end of the help)."
  (interactive)
  (insert "\n% $LastChangedBy$\n")
  (insert "% $LastChangedDate$\n")
  (insert "% $LastChangedRevision$\n")
)

(defun matlab-insert-function-hyperlink ()
  "Inserts a function hyperlink (should be use in the help section)."
  (interactive)
  (defvar myFunctionName (read-from-minibuffer  "FunctionName: "))
  (insert (concat "<a href=\"matlab: help " myFunctionName "\">" myFunctionName "</a>"))
)

(defun matlab-insert-for-loop ()
  "Inserts the base text corresponding to a 'for' loop."
  (interactive)
  (setq begin (point))
  (setq index  (read-from-minibuffer "Index: " "i"))
  (insert (concat "for " index "=1:numel()\n"))
  (insert "\n")
  (insert "end\n")
  (setq end (point))
  (previous-line 3)
  (back-to-indentation)
  (forward-char 14)
  (indent-region begin end nil)
)

(defun matlab-insert-if-isequal-condition ()
  "Inserts the base text corresponding to a 'if empty(x)' condition."
  (interactive)
  (setq begin (point))
  (insert "if isequal()\n")
  (insert "\n")
  (insert "end\n")
  (indent-region begin (point) nil)
  (previous-line 3)
  (back-to-indentation)
  (forward-char 11)
)

(defun matlab-insert-if-notisequal-condition ()
  "Inserts the base text corresponding to a 'if empty(x)' condition."
  (interactive)
  (setq begin (point))
  (insert "if ~isequal()\n")
  (insert "\n")
  (insert "end\n")
  (indent-region begin (point) nil)
  (previous-line 3)
  (back-to-indentation)
  (forward-char 12)
)

(defun matlab-insert-if-empty-condition ()
  "Inserts the base text corresponding to a 'if empty(x)' condition."
  (interactive)
  (setq begin (point))
  (insert "if isempty()\n")
  (insert "\n")
  (insert "end\n")
  (indent-region begin (point) nil)
  (previous-line 3)
  (back-to-indentation)
  (forward-char 11)
)

(defun matlab-insert-if-notempty-condition ()
  "Inserts the base text corresponding to a 'if empty(x)' condition."
  (interactive)
  (setq begin (point))
  (insert "if ~isempty()\n")
  (insert "\n")
  (insert "end\n")
  (indent-region begin (point) nil)
  (previous-line 3)
  (back-to-indentation)
  (forward-char 12)
)

(defun matlab-insert-if-exist-condition ()
  "Inserts the base text corresponding to a 'if exist(x)' condition."
  (interactive)
  (setq begin (point))
  (insert "if exist('', 'var')\n")
  (insert "\n")
  (insert "end\n")
  (indent-region begin (point) nil)
  (previous-line 3)
  (back-to-indentation)
  (forward-char 10)
)

(defun matlab-insert-if-notexist-condition ()
  "Inserts the base text corresponding to a 'if exist(x)' condition."
  (interactive)
  (setq begin (point))
  (insert "if ~exist('', 'var')\n")
  (insert "\n")
  (insert "end\n")
  (indent-region begin (point) nil)
  (previous-line 3)
  (back-to-indentation)
  (forward-char 11)
)

(defun matlab-insert-error ()
  "Inserts the base text corresponding to an error message"
  (interactive)
  (insert "error(GenerateErrorID(), '');")
  (backward-char 3)
)

(defun matlab-insert-warning ()
  "Inserts the base text corresponding to an error message"
  (interactive)
  (insert "warning(GenerateErrorID(), '');")
  (backward-char 3)
)

(defun matlab-insert-fprintf ()
  "Inserts the base text corresponding to a fprintf statement message"
  (interactive)
  (insert "fprintf('\\n');")
  (backward-char 5)
)

(defun matlab-insert-fopen ()
"Inserts a standard fopen statement"
  (interactive)
  (insert "FileID = fopen('")
  (insert (concat (read-from-minibuffer "FileName: " "output.txt") "', '"))
  (insert (concat (read-from-minibuffer "Access rights (r/w/a[+]): " "r") "'"))
  (insert ");")
)

(defun matlab-insert-file-fprintf ()
  "Inserts the base text corresponding to a fprintf statement message with FileID"
  (interactive)
  (insert "fprintf(FileID, '\\n');")
  (backward-char 5)
)

(defun matlab-insert-productinfo ()
  "Inserts the standard product info call"
  (interactive)
  (insert "ProdInfo = ProductInformation(NameA, NameB);\n")
)


(defun matlab-insert-add-statement ()
  "Inserts an increment statement"
  (interactive)
  
  ;; Move 2 characters backwards (i.e. two '+')
  (backward-char 1)
  (setq myVariable (matlab-read-word-at-point))

  (forward-char 1)
  (insert " = " myVariable " + ")
)


(defun matlab-insert-increment-statement ()
  "Inserts an increment statement"

  ;; Move 2 characters backwards (i.e. two '+')
  (backward-char 1)
  (setq myVariable (matlab-read-word-at-point))

  (forward-char 1)
  (insert " = " myVariable " + 1;")
)


(defun matlab-insert-default-inputs-code ()
  (interactive)
  "Inserts a piece of code for setting default input values"
 
  (insert "%% Set default values for the optional input variables that are not specified\n")
  (insert "DEFAULT_INPUTS = {'', ;\n")
  (insert "                  '', ;\n")
  (insert "                  '', };\n")
  (insert "\n")
  (insert "for i=1:size(DEFAULT_INPUTS, 1)\n")
  (insert "    if ~exist(DEFAULT_INPUTS{i, 1}, 'var')\n")
  (insert "        eval([DEFAULT_INPUTS{i, 1} ' = DEFAULT_INPUTS{i, 2};']);\n")
  (insert "    end\n")
  (insert "end\n")

  (previous-line 9)
  (forward-char 19)
)

;;;-----------------------------------------------------------
;; Function 'matlab-backward-word': should stop at upper-case caracters
;;;-----------------------------------------------------------
;(defun matlab-backward-word ()
;  
;  ;; The position of the first upper-case character
;  (setq upperCasePosition (re-search-backward "[A-Z]" nil t))
;  
;  ;; The position of the first white space character
;  (setq whiteSpacePosition (re-search-backward "[A-Z]" nil t))
;  
;  ;; If the whiteSpacePosition comes before (backwards) upperCasePosition
;  (if (< upperCasePosition whiteSpacePosition)
;      ;; execute the normal backward-word function
;      (backward-word)
;    ;; otherwise, go to that position
;    (goto-char upperCasePosition)
;    )
;  message("Pisu misu")
;)
;
;(define-key global-map [(control left-arrow)] 'matlab-backward-word)



;;-----------------------------------------------------------
; Advice for template 'tempo-template-matlab-function'
;;-----------------------------------------------------------
(defadvice tempo-template-matlab-function (around sag-function (arg))
  (if (and (matlab-with-emacs-link) (eobp))
      (message "Running this function on the last line of the buffer makes Emacs freeze")

    ;; Remember where we started from
    (defvar startingLine (line-number-at-pos))

    ;; Insert SUBFUNCTION comment, if this appears to be a subfunction (i.e. not on the first line)
    (if (not (= 1 (line-number-at-pos)))
	(insert "%%=============================\n% SUBFUNCTION\n%%=============================\n"))

    ;; This is where the original function will be executed
    ad-do-it

    ;; Insert the standard SVN stamp if this is the first line of the file
    (if (= 3 (line-number-at-pos))
	(progn
	  (insert "\n")
	  (matlab-insert-help-end)))
    
    (insert "\n\n\n\n%% End-of-Function\n")
    (defvar endingLine (line-number-at-pos))
    

    ;; Hack: since we know that the function name is the third last in the 
    ;; minibuffer history, we can retrieve (guess)  it from there
    (defvar myFunctionName (nth 2 minibuffer-history))

    (goto-line startingLine)
    (message (upcase myFunctionName))
    (perform-replace (upcase myFunctionName) myFunctionName nil nil t)
    (goto-line (- endingLine 3)))
)

;; Activate the advice
(ad-activate 'tempo-template-matlab-function)


;;-----------------------------------------------------------
;; Override for 'matlab-mode-determine-mfile-path'
;;-----------------------------------------------------------
(defun matlab-mode-determine-mfile-path ()
  "Create the path in `matlab-mode-install-path'."
  (let ((path (file-name-directory matlab-shell-command)))

    ;; if we don't have a path, find the MATLAB executable on our path.
    (if (not path)
	(let ((pl exec-path))
	  (while (and pl (not path))
	    (if (and (file-exists-p (concat (car pl) "/" matlab-shell-command))
		     (not (car (file-attributes (concat (car pl) "/"
							matlab-shell-command)))))
		(setq path (car pl)))
	    (setq pl (cdr pl)))))
    (if (not path)
	nil
      ;; When we find the path, we need to massage it to identify where
      ;; the M files are that we need for our completion lists.
      (if (string-match "/bin/*$" path)    ;; Modified by crpi: added '/*', in case the path ends with '/'
	  (setq path (substring path 0 (match-beginning 0))))
      ;; Everything stems from toolbox (I think)
      (setq path (concat path "/toolbox/")))
    path))


;;-----------------------------------------------------------
; Advice for function 'matlab-mode-determine-mfile-path'
;;-----------------------------------------------------------
(defadvice matlab-mode-determine-mfile-path (after sag-determine-mfile-path ())
  (if (not ad-return-value)
      (setq ad-return-value (getenv (concat "MATLAB_HOME" "/toolbox"))))
  )

;; Activate the advice
(ad-activate 'matlab-mode-determine-mfile-path)


;;-----------------------------------------------------------
; Advice for function 'matlab-semicolon-on-return'
;;-----------------------------------------------------------
(defadvice matlab-semicolon-on-return (before sag-matlab-semicolon-on-return ())
  (expand-abbrev)
  )

;; Activate the advice
(ad-activate 'matlab-semicolon-on-return)



;;-----------------------------------------------------------
;; Override for 'matlab-find-file-under-path'
;;-----------------------------------------------------------
(defun matlab-find-file-under-path (path filename)
  "Return the pathname or nil of PATH under FILENAME."
  (if (file-exists-p (concat path filename))
      (concat path filename)
    (let ((dirs (if (file-directory-p path)
		    ;; Not checking as a directory first fails on XEmacs
		    ;; Stelios Kyriacou <kyriacou@cbmv.jhu.edu>
		    (directory-files path t nil t)))
	  (found nil))
      (while (and dirs (not found))
	(if (and (car (file-attributes (car dirs)))
		 ;; don't redo our path names
		 (not (string-match "/\\.\\.?$" (car dirs)))
		 ;; don't find files in object directories. (outcommented by crpi)
		 ;; (not (string-match "@" (car dirs)))
         )
	    (setq found
		  (matlab-find-file-under-path (concat (car dirs) "/")
					       filename)))
	(setq dirs (cdr dirs)))
      found)))



;;-----------------------------------------------------------
;; Override for 'matlab-find-file-on-path'
;;-----------------------------------------------------------
;; Written by Cristian Pirnog (crpi)
(defun matlab-find-file-on-path (filename)
  "Find FILENAME on the current Matlab path.
The Matlab path is determined by `matlab-mode-install-path' and the
current directory.  You must add user-installed paths into
`matlab-mode-install-path' if you would like to have them included."
  (interactive
   (list
    (let ((default (matlab-read-word-at-point)))
      (if default
      (setq s default))
)))
  ; Error message, if no word is selected - this does not work
  (if (null (boundp 'filename)) (error "You must specify an M file"))

  ;; Constant value tag
  (setq THIS_FILE "thisfile")

  ;; The ".m" extension must come first
  (setq extensions_orig (list  ".m" ".cpp" ".c" ".java"))

  ;; If the file is called exactly as the function that we're looking for,
  ;; than don't search for the ".m" extension
  (if (string= (concat filename (car extensions_orig)) (buffer-name))
      (setq extensions_orig (cdr extensions_orig)))

  ;;(setq filename_orig filename)
  (setq filename_orig filename)
  (setq extensions extensions_orig)

  (let ((fname nil)
	(dirs_orig (list (getenv "PWD") matlab-mode-install-path)))

    ;; First search for a local function (in the current buffer)...
    (setq original_cursor_position (point))
    (if (string= ".m" (car extensions_orig))
        (progn
         (goto-char (point-min))
         ;; The simple regexp handles the case when the function has no output arguments
         (setq mySimpleFunctionRegexp (concat "^ *function  *" filename_orig "("))
         ;; The normal regexp handles the case when the function has some output arguments
         (setq myFunctionRegexp (concat "^ *function .* " filename_orig "("))
         ;(error myFunctionRegexp)
         (if (or (re-search-forward mySimpleFunctionRegexp nil t)
                  (re-search-forward myFunctionRegexp nil t))
             (progn
              (setq fname THIS_FILE)
              (center-to-window-line)
              (beginning-of-line))
           (goto-char original_cursor_position))))


    ; ...then search in the currently opened buffers...
    (while (and (not fname) extensions)
      (if (null (get-buffer (concat filename_orig (car extensions))))
          (setq extensions (cdr extensions))
        (setq fname (buffer-file-name (get-buffer (concat filename_orig (car extensions)))))))

    ; ...then search in the current directory...
    (setq extensions extensions_orig)
    (while (and (not fname) extensions)
      (if (file-exists-p (concat default-directory filename_orig (car extensions)))
          (setq fname (concat default-directory filename (car extensions))))
      (setq extensions (cdr extensions)))

    ; ... then in all other directories on the path
    (setq extensions extensions_orig)
    (while (and (not fname) extensions)
      (setq filename (concat filename_orig (car extensions)))
      (setq dirs dirs_orig)
      (message "Searching for %s" filename)
      (while (and (not fname) dirs)
        (if (stringp (car dirs))
              (setq fname (matlab-find-file-under-path (car dirs) filename)))
        (setq dirs (cdr dirs)))
      (setq extensions (cdr extensions))
      )

    ;; If file was not found generate error message
    (if (not fname)
      (error "File %s not found on any known paths.  \
Check `matlab-mode-install-path'" filename_orig)
      ;; Otherwise open the file in a new buffer...
      (if (not (string= fname THIS_FILE))
          (progn
            (find-file fname)

            ;; Construct the file name with path
            (setq home_dir (concat (getenv "HOME") "/"))
            (setq fname_new fname)
            ;; Replace HOME_DIR by '~/'
            (if (string-match home_dir fname)
                (setq fname_new (concat "~/" (substring fname (length home_dir)))))
            
            ;; ... then add the file name (with path) to the file-name-history of the minibuffer
            ;; but only if the file is not already on the first position of the history list
            ;; better would be to remove duplicates, but there is no function available for it
            ;; will have to write one myself
            (cond ((not (string= fname_new (car file-name-history)))
                   (if (< 100 (length file-name-history)) ;; History no longer than 100 elements
                       (setq file-name-history (nreverse (cdr (nreverse file-name-history)))))
                   (setq file-name-history (cons fname_new file-name-history)))
                  (t (message "File is already first in the history"))))))
))
