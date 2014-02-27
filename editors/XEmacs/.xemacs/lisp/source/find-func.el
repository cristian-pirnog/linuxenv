;;; find-func.el --- find the definition of the Emacs Lisp function near point

;; Copyright (C) 1997, 1999, 2001, 2002, 2003, 2004,
;;   2006 Free Software Foundation, Inc.

;; Author: Jens Petersen <petersen@kurims.kyoto-u.ac.jp>
;; Maintainer: petersen@kurims.kyoto-u.ac.jp
;; Keywords: emacs-lisp, functions, variables
;; Created: 97/07/25

;; This file is part of XEmacs.

;; XEmacs is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 2, or (at your option)
;; any later version.

;; XEmacs is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with XEmacs; see the file COPYING.  If not, write to the 
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Synched up with: FSF 22.0.50

;;; Commentary:
;;
;; The funniest thing about this is that I can't imagine why a package
;; so obviously useful as this hasn't been written before!!
;; 
;; The default keybindings are the ones protected by autoload cookies at
;; the bottom of this file.  It does pretty much what you would expect,
;; putting the cursor at the definition of the function or variable at
;; point.
;;
;; In XEmacs the source filename of every dumped or loaded Lisp symbol
;; definition is now recorded in `load-history'.  So in XEmacs all
;; non-primitive functions and variables can be found in principle.  (I
;; say "in principle" since the system is not perfect.  For example
;; although it is unusual it can happen that say a variable and function
;; of the same name are defined in different files, which may lead to
;; incorrect results.)  Unfortunately in Emacs, only symbols loaded from
;; startup can be found.  

;; The file names of primitive functions in C is available in recent GNU and
;; XEmacs beta versions; GNU since some point in 2004, XEmacs since early
;; 2005.  XEmacs returns the file name from `symbol-file' in loadhist.el, as
;; with any other symbol.  GNU has a function `help-C-file-name' in
;; help-fns.el that they call instead.

;; The code started out from `describe-function', `describe-key'
;; ("help.el") and `fff-find-loaded-emacs-lisp-function' (Noah Friedman's
;; "fff.el").

;;; Problems:
;;
;; o `find-function-other-frame' is not quite right when the
;; function is in the current buffer.
;;

;;;; Code:

(require 'loadhist)

;;; User variables:

(defgroup find-function nil
  "Finds the definition of the Emacs Lisp symbol near point."
;;   :prefix "find-function"
  :group 'lisp)

(defconst find-function-space-re "\\(?:\\s-\\|\n\\|;.*\n\\)+")

(defcustom find-function-regexp
  ;; Match things like (defun foo ...), (defmacro foo ...),
  ;; (define-skeleton foo ...), (define-generic-mode 'foo ...),
  ;;  (define-derived-mode foo ...), (define-minor-mode foo)
  (concat
   "^\\s-*(\\(def\\(ine-skeleton\\|ine-generic-mode\\|ine-derived-mode\\|\
ine\\(?:-global\\)?-minor-mode\\|ine-compilation-mode\\|un-cvs-mode\\|\
foo\\|[^cfgv]\\w+\\*?\\)\\|easy-mmode-define-[a-z-]+\\|easy-menu-define\\|\
menu-bar-make-toggle\\)"
   find-function-space-re
   "\\('\\|\(quote \\)?%s\\(\\s-\\|$\\|\(\\|\)\\)")
  "The regexp used by `find-function' to search for a function definition.
Note it must contain a `%s' at the place where `format'
should insert the function name.  The default value avoids `defconst',
`defgroup', `defvar', `defface'.

Please send improvements and fixes to the maintainer."
  :type 'regexp
  :group 'find-function)

(defcustom find-variable-regexp
  (concat
   "^\\s-*(\\(def[^fumag]\\(\\w\\|\\s_\\)+\\*?\\|\
easy-mmode-def\\(map\\|syntax\\)\\|easy-menu-define\\)"
   find-function-space-re
   "%s\\(\\s-\\|$\\)")
  "The regexp used by `find-variable' to search for a variable definition.
Note it must contain a `%s' at the place where `format'
should insert the variable name.  The default value
avoids `defun', `defmacro', `defalias', `defadvice', `defgroup', `defface'.

Please send improvements and fixes to the maintainer."
  :type 'regexp
  :group 'find-function)

(defcustom find-face-regexp
  (concat"^\\s-*(defface" find-function-space-re "%s\\(\\s-\\|$\\)")
  "The regexp used by `find-face' to search for a face definition.
Note it must contain a `%s' at the place where `format'
should insert the face name.

Please send improvements and fixes to the maintainer."
:type 'regexp
:group 'find-function
:version "22.1")

(defvar find-function-regexp-alist
  '((nil . find-function-regexp)
    (defvar . find-variable-regexp)
    (defface . find-face-regexp))
  "Alist mapping definition types into regexp variables.
Each regexp variable's value should actually be a format string
to be used to substitute the desired symbol name into the regexp.")
(put 'find-function-regexp-alist 'risky-local-variable t)

(defcustom find-function-source-path nil
  "The default list of directories where `find-function' searches.

If this variable is nil then `find-function' searches `load-path' by
default."
  :type '(repeat directory)
  :group 'find-function)

(defcustom find-function-recenter-line 1
  "The window line-number from which to start displaying a symbol definition.
A value of nil implies center the beginning of the definition.
See the function `center-to-window-line' for more information, and
`find-function' and `find-variable'."
  :type '(choice (const :tag "Center" nil)
         integer)
  :group 'find-function)

(defcustom find-function-after-hook nil
  "Hook run after finding symbol definition.

See the functions `find-function' and `find-variable'."
  :group 'find-function)

;;; Functions:

;; XEmacs omission: Emacs has find-library and supporting friends here.  We
;; have the equivalent in lib-complete.el in core. 

;; However, we don't have support for looking up C in core; that comes from
;; GNU and is here.

(defvar find-function-C-source-directory
  ;; XEmacs change ; check source-root too, which was available for a couple
  ;; of years in 21.5.
  (let (dir)
    (when (and (setq dir (or (and (boundp 'source-directory) 
                  (expand-file-name "src" source-directory))
                 (and (boundp 'source-root) 
                  (expand-file-name "src" source-root))))
           (file-directory-p dir) (file-readable-p dir))
      dir))
  "Directory where the C source files of XEmacs can be found.
If nil, do not try to find the source code of functions and variables
defined in C.")

(defun find-function-C-source (fun-or-var file type)
  "Find the source location where SUBR-OR-VAR is defined in FILE.
TYPE should be nil to find a function, or `defvar' to find a variable."
  (unless find-function-C-source-directory
    (setq find-function-C-source-directory
      (read-directory-name "XEmacs C source dir: " nil nil t)))
  (setq file (expand-file-name file find-function-C-source-directory))
  (unless (file-readable-p file)
    (error "The C source file %s is not available"
       (file-name-nondirectory file)))
  (unless type
    (setq fun-or-var (indirect-function fun-or-var)))
  ;; Versions of XEmacs without `subr-name' shouldn't return C filenames
  ;; from `symbol-file'.
  (assert (fboundp 'subr-name) 
      t
      "This code needs `subr-name', and shouldn't be called without it.")
  (with-current-buffer (find-file-noselect file)
    (goto-char (point-min))
    (unless (re-search-forward
         (if type
         (concat "DEFVAR[A-Z_]*[ \t\n]*([ \t\n]*\""
             (regexp-quote (symbol-name fun-or-var))
             "\"")
           (concat "DEFUN\\(_NORETURN\\|_MANY\\|_UNEVALLED"
               "\\|_COMMAND_LOOP\\|\\)[ \t\n]*([ \t\n]*\""
               (regexp-quote (subr-name fun-or-var))
               "\""))
         nil t)
      (error "Can't find source for %s" fun-or-var))
    (cons (current-buffer) (match-beginning 0))))

;;;###autoload
(defun find-function-search-for-symbol (symbol type library)
  "Search for SYMBOL's definition of type TYPE in LIBRARY.
If TYPE is nil, look for a function definition.
Otherwise, TYPE specifies the kind of definition,
and it is interpreted via `find-function-regexp-alist'.
The search is done in the source for library LIBRARY."
  (if (null library)
      (error "Don't know where `%s' is defined" symbol))
  ;; We deviate significantly from Emacs here, due to our distinct
  ;; find-library implementations.
  (if (string-match "^\\(.*\\.c\\)$" library)
      (find-function-C-source symbol (match-string 1 library) type)
    (if (string-match "\\.el\\(c\\)\\'" library)
    (setq library (substring library 0 (match-beginning 1))))
    (let* ((path find-function-source-path)
       (filename (if (file-exists-p library)
             library
               ;; use `file-name-sans-extension' here? (if it gets
               ;; fixed)
               (if (string-match "\\(\\.el\\)\\'" library)
               (setq library (substring library 0
                            (match-beginning 1))))
               (or (locate-library (concat library ".el") t path)
               (locate-library library t path)))))
      (if (not filename)
      (error "The library \"%s\" is not in the path." library))
      (with-current-buffer (find-file-noselect filename)
    (save-match-data
      (let ((regexp (format (if type
                    find-variable-regexp
                  find-function-regexp)
                (regexp-quote (symbol-name symbol))))
        (case-fold-search))
        (with-syntax-table emacs-lisp-mode-syntax-table
          (goto-char (point-min))
          (if (or (re-search-forward regexp nil t)
              (re-search-forward
               (concat "^([^ ]+" find-function-space-re "['(]"
                   (regexp-quote (symbol-name symbol))
                   "\\_>")
               nil t))
          (progn
            (beginning-of-line)
            (cons (current-buffer) (point)))
        (error "Cannot find definition of `%s' in library `%s'"
               symbol library)))))))))

;;;###autoload
(defun find-function-noselect (function)
  "Return a pair (BUFFER . POINT) pointing to the definition of FUNCTION.

Finds the Emacs Lisp library containing the definition of FUNCTION
in a buffer and the point of the definition.  The buffer is
not selected.

If the file where FUNCTION is defined is not known, then it is
searched for in `find-function-source-path' if non nil, otherwise
in `load-path'."
  (if (not function)
      (error "You didn't specify a function"))
  (let ((def (symbol-function function))
    aliases)
    (while (symbolp def)
      (or (eq def function)
      (if aliases
          (setq aliases (concat aliases
                    (format ", which is an alias for `%s'"
                        (symbol-name def))))
        (setq aliases (format "`%s' an alias for `%s'"
                  function (symbol-name def)))))
      (setq function (symbol-function function)
        def (symbol-function function)))
    (if aliases
    (message "%s" aliases))
    (let ((library
       (cond ((eq (car-safe def) 'autoload)
          (nth 1 def))
         ((symbol-file function))
         ;; XEmacs addition: function annotations
         ((fboundp 'compiled-function-annotation)
          (cond ((compiled-function-p def)
             (file-name-sans-extension
              (compiled-function-annotation def)))
            ((eq 'macro (car-safe def))
             (and (compiled-function-p (cdr def))
                  (file-name-sans-extension
                   (compiled-function-annotation (cdr def))))))))))
      ;; XEmacs difference: check for primitive functions a bit differently
      ;; XEmacs; move this after the symbol-file check, which can now return
      ;; the place in C where the function is.
      (and (null library) (subrp (symbol-function function))
       (if aliases
           (error "%s which is a primitive function" aliases)
         (error "%s is a primitive function" function)))
      (find-function-search-for-symbol function nil library))))

;; XEmacs change: these functions are defined in help.el
;(defalias 'function-at-point 'function-called-at-point)

(defun find-function-read (&optional type)
  "Read and return an interned symbol, defaulting to the one near point.

If TYPE is nil, insist on a symbol with a function definition.
Otherwise TYPE should be `defvar' or `defface'.
If TYPE is nil, defaults using `function-at-point',
otherwise uses `variable-at-point'."
  (let ((symb (funcall (if type
               'variable-at-point
             'function-at-point)))
    (predicate (cdr (assq type '((nil . fboundp) (defvar . boundp)
                     (defface . facep)))))
    (prompt (cdr (assq type '((nil . "function") (defvar . "variable")
                  (defface . "face")))))
    (enable-recursive-minibuffers t)
    val)
    (if (equal symb 0)
    (setq symb nil))
    (setq val (completing-read
           (concat "Find "
               prompt
               (if symb
               (format " (default %s)" symb))
               ": ")
           obarray predicate t nil))
    (list (if (equal val "")
          symb
        (intern val)))))

(defun find-function-do-it (symbol type switch-fn)
  "Find Emacs Lisp SYMBOL in a buffer and display it.
TYPE is nil to search for a function definition,
or else `defvar' or `defface'.

The variable `find-function-recenter-line' controls how
to recenter the display.  SWITCH-FN is the function to call
to display and select the buffer.
See also `find-function-after-hook'.

Set mark before moving, if the buffer already existed."
  (let* ((orig-point (point))
     (orig-buffers (buffer-list))
     (buffer-point (save-excursion
             (find-definition-noselect symbol type)))
     (new-buf (car buffer-point))
     (new-point (cdr buffer-point)))
    (when buffer-point
      (when (memq new-buf orig-buffers)
    (push-mark orig-point))
      (funcall switch-fn new-buf)
      (goto-char new-point)
      (recenter find-function-recenter-line)
      (run-hooks 'find-function-after-hook))))

;;;###autoload
(defun find-function (function)
  "Find the definition of the FUNCTION near point.

Finds the Emacs Lisp library containing the definition of the function
near point (selected by `function-at-point') in a buffer and
places point before the definition.  Point is saved in the buffer if
it is one of the current buffers.

The library where FUNCTION is defined is searched for in
`find-function-source-path', if non nil, otherwise in `load-path'.
See also `find-function-recenter-line' and `find-function-after-hook'."
  (interactive (find-function-read))
  (find-function-do-it function nil 'switch-to-buffer))

;;;###autoload
(defun find-function-other-window (function)
  "Find the definition of the function near point in another window.

See `find-function' for more details."
  (interactive (find-function-read))
  (find-function-do-it function nil 'switch-to-buffer-other-window))

;;;###autoload
(defun find-function-other-frame (function)
  "Find the definition of the function near point in another frame.

See `find-function' for more details."
  (interactive (find-function-read))
  (find-function-do-it function nil 'switch-to-buffer-other-frame))

;;;###autoload
(defun find-variable-noselect (variable &optional file)
  "Return a pair `(BUFFER . POINT)' pointing to the definition of SYMBOL.

Finds the Emacs Lisp library containing the definition of SYMBOL
in a buffer and the point of the definition.  The buffer is
not selected.

The library where VARIABLE is defined is searched for in FILE or
`find-function-source-path', if non nil, otherwise in `load-path'."
  (if (not variable)
      (error "You didn't specify a variable"))
  (let ((library (or file (symbol-file variable))))
    (unless (and (null library) (built-in-variable-type variable))
      (error "%s is a primitive variable" variable))
    (find-function-search-for-symbol variable 'variable library)))

;;;###autoload
(defun find-variable (variable)
  "Find the definition of the VARIABLE near point.

Finds the Emacs Lisp library containing the definition of the variable
near point (selected by `variable-at-point') in a buffer and
places point before the definition.

Set mark before moving, if the buffer already existed.

The library where VARIABLE is defined is searched for in
`find-function-source-path', if non nil, otherwise in `load-path'.
See also `find-function-recenter-line' and `find-function-after-hook'."
  (interactive (find-function-read 'defvar))
  (find-function-do-it variable 'defvar 'switch-to-buffer))

;;;###autoload
(defun find-variable-other-window (variable)
  "Find, in another window, the definition of VARIABLE near point.

See `find-variable' for more details."
  (interactive (find-function-read 'defvar))
  (find-function-do-it variable 'defvar 'switch-to-buffer-other-window))

;;;###autoload
(defun find-variable-other-frame (variable)
  "Find, in annother frame, the definition of VARIABLE near point.

See `find-variable' for more details."
  (interactive (find-function-read 'defvar))
  (find-function-do-it variable 'defvar 'switch-to-buffer-other-frame))

;;;###autoload
(defun find-definition-noselect (symbol type &optional file)
  "Return a pair `(BUFFER . POINT)' pointing to the definition of SYMBOL.
TYPE says what type of definition: nil for a function,
`defvar' or `defface' for a variable or face.  This functoin
does not switch to the buffer or display it.

The library where SYMBOL is defined is searched for in FILE or
`find-function-source-path', if non nil, otherwise in `load-path'."
  (if (not symbol)
      (error "You didn't specify a symbol"))
  (if (null type)
      (find-function-noselect symbol)
    (let ((library (or file (symbol-file symbol))))
      (find-function-search-for-symbol symbol type library))))

;; RMS says: 
;; For symmetry, this should be called find-face; but some programs
;; assume that, if that name is defined, it means something else.
;;;###autoload
(defun find-face-definition (face)
  "Find the definition of FACE.  FACE defaults to the name near point.

Finds the Emacs Lisp library containing the definition of the face
near point (selected by `variable-at-point') in a buffer and
places point before the definition.

Set mark before moving, if the buffer already existed.

The library where FACE is defined is searched for in
`find-function-source-path', if non nil, otherwise in `load-path'.
See also `find-function-recenter-line' and `find-function-after-hook'."
  (interactive (find-function-read 'defface))
  (find-function-do-it face 'defface 'switch-to-buffer))

;;;###autoload
(defun find-function-on-key (key)
  "Find the function that KEY invokes.  KEY is a string.
Set mark before moving, if the buffer already existed."
  (interactive "kFind function on key: ")
  ;; XEmacs change: Avoid the complex menu code with key-or-menu-binding
  (let ((defn (key-or-menu-binding key))
    (key-desc (key-description key)))
    (if (or (null defn) (integerp defn))
        (message "%s is unbound" key-desc)
      (if (consp defn)
      (message "%s runs %s" key-desc (prin1-to-string defn))
    (find-function-other-window defn)))))

;;;###autoload
(defun find-function-at-point ()
  "Find directly the function at point in the other window."
  (interactive)
  (let ((symb (function-at-point)))
    (when symb
      (find-function-other-window symb))))

;;;###autoload
(defun find-variable-at-point ()
  "Find directly the function at point in the other window."
  (interactive)
  (let ((symb (variable-at-point)))
    (when (and symb (not (equal symb 0)))
      (find-variable-other-window symb))))

;; XEmacs change: autoload instead of defining find-function-setup-keys
;; FIXME: We do not have a default keybinding for find-function
;; (define-key ctl-x-map "F" 'find-function) ; conflicts with `facemenu-keymap'
;;;###autoload(define-key ctl-x-4-map "F" 'find-function-other-window)
;;;###autoload(define-key ctl-x-5-map "F" 'find-function-other-frame)
;;;###autoload(define-key ctl-x-map "K" 'find-function-on-key)
;;;###autoload(define-key ctl-x-map "V" 'find-variable)
;;;###autoload(define-key ctl-x-4-map "V" 'find-variable-other-window)
;;;###autoload(define-key ctl-x-5-map "V" 'find-variable-other-frame)
;;;###autoload(define-key help-mode-map "F" 'find-function-at-point)
;;;###autoload(define-key help-mode-map "V" 'find-variable-at-point)

(provide 'find-func)

;; arch-tag: 43ecd81c-74dc-4d9a-8f63-a61e55670d64
;;; find-func.el ends here
