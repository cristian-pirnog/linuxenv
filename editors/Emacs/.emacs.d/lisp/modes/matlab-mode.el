;; ============= For MATLAB Mode =============

(custom-set-variables
;; custom-set-variables was added by Custom.
;; If you edit it by hand, you could mess it up, so be careful.
;; Your init file should contain only one such instance.
;; If there is more than one, they won't work right.
 '(matlab-block-verify-max-buffer-size 2000)
 '(matlab-case-level (quote (0 . 4)))
 '(matlab-comment-column 120)
 '(matlab-comment-region-s "%%% ")
 '(matlab-eei-breakpoint-marker-colors (quote ("black" . "orange")))
 '(matlab-eei-key-bindings (quote (("[f10]" . matlab-eei-step) ("[f11]" . matlab-eei-step-in) ("[(shift f11)]" . matlab-eei-step-out) ("[f5]" . matlab-eei-run-continue) ("[f12]" . matlab-eei-breakpoint-set-clear) ("[f3]" . matlab-eei-eval-region))))
 '(matlab-eei-provisional-breakpoint-marker-colors (quote ("red" . "orange red")))
 '(matlab-fill-count-ellipsis-flag nil)
 '(matlab-fill-fudge-hard-maximum 129)
 '(matlab-handle-simulink nil)
 '(matlab-highlight-block-match-flag t)
 '(matlab-highlight-cross-function-variables t t)
 '(matlab-indent-function-body nil)
 '(matlab-keyword-list (quote ("global" "persistent" "for" "while" "if" "elseif" "else" "endfunction" "return" "break" "continue" "switch" "case" "otherwise" "try" "catch" "tic" "toc" "import" "rethrow")))
 '(matlab-return-add-semicolon t)
 '(matlab-show-periodic-code-details-flag t)
 '(matlab-verify-on-save-flag t t)
 '(matlab-vers-on-startup nil)
 '(mlint-programs (quote ("/opt/linux/x86_64/matlab/7.5/bin/glnxa64/mlint")))
 '(mlint-scan-for-fixes-flag t))


;; Load the package 'matlab-eei-connect'
(add-to-list 'load-path "/opt/linux/x86_64/matlab/7.5/java/extern/EmacsLink/lisp" t) ;; Add the MATLAB_INSTALL_PATH to the load path (at the end)
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
(load "cedet.elc")

;; Enabling various SEMANTIC minor modes.  See semantic/INSTALL for more ideas.
;; Select one of the following
;; (semantic-load-enable-code-helpers)
;; (semantic-load-enable-guady-code-helpers)
;; (semantic-load-enable-excessive-code-helpers)

;; Enable this if you develop in semantic, or develop grammars
;; (semantic-load-enable-semantic-debugging-helpers)


;; ============= End of MATLAB Mode =============
