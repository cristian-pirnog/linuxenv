;;; Emacs initialization file
;;;
;;; Time-stamp: "04 Nov 1996 12:30 Martin Berger"
;;;
;;; adapted:     08 Oct 1996       Major revision
;;;
;;; modified:    21 Oct 2005  by  Cristian Pirnog
;;;              05 Apr 2007  by  Cristian Pirnog


(message "Loading ~/.xemacs ...")

(setq inhibit-startup-message t)   ; suppress startup screen


;;;; Set path for personal lisp code (uncomment if necessary)
(setq load-path
      (append (list (expand-file-name "~/.xemacs") 
                    (expand-file-name "~/.xemacs/lisp/"))
              load-path))

;;; --------------------------------------------------
;;; load general definitions
;; These files must be in one of the directories specified in variable load-path
;; Adding directories to this variable is done above
(load "abbrevs")
(load "globalLisp.el")
(load "ccLisp.el")
(load "javaLisp.el")
(load "lisp.el")
(load "latexLisp.el")


; load the LaTeX mode
(setq load-path (cons "~/elisp" load-path))
(require 'tex-site)


;; Autoloading for various major modes
;; Autoload the diff-mode
(autoload 'diff-mode "diff-mode.el" "Enter diff mode." t)
(setq auto-mode-alist (cons '("\\.diff\\'" . diff-mode) auto-mode-alist))

;; Set extensions for LaTeX mode
(setq auto-mode-alist (cons '("\\.tex\\'" . latex-mode) auto-mode-alist))


;;; --------------------------------------------------
;;; personal settings
(global-set-key [button4] 'fine-scroll-down)
(global-set-key [button5] 'fine-scroll-up)
(global-set-key [(shift button4)] 'my-scroll-down-command)
(global-set-key [(shift button5)] 'my-scroll-up-command)
(global-set-key [(space)] 'smart-space) ; bind the 'smart-space' function (defined in lisp.el) to the 'space' key
;(global-set-key [return] 'smart-return) ; bind the 'smart-space' function also to the 'return' key

(defvar fine-scroll-lines 3 "*Number of lines to fine scroll")

(defun my-scroll-down-command (&optional n)
  (interactive "_P")
  (let ((mouse-window (event-window current-mouse-event)))
    (with-selected-window mouse-window
      (scroll-down-command n))))

(defun my-scroll-up-command (&optional n)
  (interactive "_P")
  (let ((mouse-window (event-window current-mouse-event)))
    (with-selected-window mouse-window
      (scroll-up-command n))))

(defun fine-scroll-down () (interactive) (my-scroll-down-command fine-scroll-lines))

(defun fine-scroll-up () (interactive) (my-scroll-up-command fine-scroll-lines))

; Never insert tabs in indentation mode
(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)


(setq minibuffer-max-depth nil)

; Saves a history of files opened previously (including other times XEmacs was used - very useful)
(require `savehist)
(setq savehist-file "~/.xemacs/history")
(setq savehist-length 1000)
(savehist-load)

; Saves the position the cursor was in a file before the file was closed.
;; to further configure this package type: M-x customize-group RET saveplace RET
;(require 'saveplace)
;(setq save-place-file "~/.xemacs/places")



;;; --------------------------------------------------
;; Options Menu Settings
;; =====================
;;;; == I don't remember what this part is supposed to do. ===
;;;; == Anyway, I don't have the file .xemacs-options anymore ===
;;(cond
;;((and (string-match "XEmacs" emacs-version)
;;       (boundp 'emacs-major-version)
;;       (or (and
;;            (= emacs-major-version 19)
;;            (>= emacs-minor-version 14))
;;           (= emacs-major-version 20))
;;       (fboundp 'load-options-file))
;; (load-options-file "~/.xemacs-options")))
;; ============================
;; End of Options Menu Settings

(message "Loading ~/.xemacs ... done")


;; Improved dynamic completion
(load-file "~/.dabbrev/dabbrev.elc")


;; ============= From MATLAB =============

; Load the package 'matlab-eei-connect'
(if (file-exists-p "/opt/linux/x86_64/matlab/7.4/java/extern/EmacsLink/lisp")
    (add-to-list 'load-path "/opt/linux/x86_64/matlab/7.4/java/extern/EmacsLink/lisp" t) ;; Add the MATLAB_INSTALL_PATH to the load path (at the end)
    (add-to-list 'load-path "/opt/linux/i386/matlab/7.4/java/extern/EmacsLink/lisp" t) ;; Add the MATLAB_INSTALL_PATH to the load path (at the end)
)

(autoload 'matlab-eei-connect "matlab-eei-extended"
  "Connects Emacs to MATLAB's external editor interface.")


(autoload 'matlab-mode "matlab-overwrites.el" "Enter Matlab mode." t)
(setq auto-mode-alist (cons '("\\.m\\'" . matlab-mode) auto-mode-alist))
(autoload 'matlab-shell "matlab-overwrites.el" "Interactive Matlab mode." t)

;; (setq matlab-indent-function t)  ; if you want function bodies indented
(setq matlab-verify-on-save-flag nil) ; turn off auto-verify on save

;; Uncomment the next four lines to enable use of the tlc mode 
;; (require 'tlc)
;; (autoload 'tlc-mode "tlc" "tlc Editing Mode" t)
;; (add-to-list 'auto-mode-alist '("\\.tlc$" . tlc-mode))
;; (setq tlc-indent-function t)

;; Uncomment the next two lines to enable use of the mlint package provided
;; with EmacsLink.

(setq-default matlab-show-mlint-warnings t)
(setq-default matlab-highlight-cross-function-variables t)

;; Note: The mlint package checks for common M-file coding
;; errors, such as omitting semicolons at the end of lines.
;; mlint requires Eric Ludlam's cedet package, which is not
;; included in the EmacsLink distribution. If you enable mlint,
;; you must download cedet from http://cedet.sourceforge.net/ and
;; install it on your system before using EmacsLink.

;; Load CEDET
(load-file "~/.xemacs/lisp/cedet-1.0pre3/common/cedet.el")

;; Enabling various SEMANTIC minor modes.  See semantic/INSTALL for more ideas.
;; Select one of the following
;; (semantic-load-enable-code-helpers)
;; (semantic-load-enable-guady-code-helpers)
;; (semantic-load-enable-excessive-code-helpers)

;; Enable this if you develop in semantic, or develop grammars
;; (semantic-load-enable-semantic-debugging-helpers)


;; ============= End from MATLAB =============



;;=================================================
;; Load various user-defined customizations (not needed anymore)
;;=================================================
; Add the path to the file
;(setq myUserenvPath (expand-file-name "~/.xemacs/userenv"))
;(setq myUserenvFile (concat "userenv_" (getenv "USER") ".el"))
;(if (file-readable-p (concat myUserenvPath "/" myUserenvFile))
;    (load-file (concat myUserenvPath "/" myUserenvFile)))

