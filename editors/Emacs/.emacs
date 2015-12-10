;; .emacs

(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/modes"))
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/cedet-1.1/common"))

;; Improved dynamic completion
(load-file "~/.dabbrev/dabbrev.elc")

;;; uncomment this line to disable loading of "default.el" at startup
;; (setq inhibit-default-init t)

;; enable visual feedback on selections
;(setq transient-mark-mode t)

;; default to better frame titles
(setq frame-title-format
      (concat  "%b - emacs@" (system-name)))

;; default to unified diffs
(setq diff-switches "-u")

;; Mapping of back-space key when run in termina, such that we can delete properly
;; (define-key key-translation-map [?\C-h] [?\C-?])
;; (keyboard-translate ?\C-h ?\C-?)
(global-set-key [(control c)] 'delete-backward-char)

;; Enable syntax highlighting
(global-font-lock-mode t)
(setq font-lock-maximum-decoration t)

(setq require-final-newline t) ; always end a file with a newline
(setq vc-follow-symlinks t)    ; automatically follow symlinks
(setq inhibit-startup-message   t)   ; Don't want any startup message 
(setq make-backup-files         nil) ; Don't want any backup files 
(setq auto-save-list-file-name  nil) ; Don't want any .saves files 
(setq auto-save-default         nil) ; Don't want any auto saving

;;; uncomment for CJK utf-8 support for non-Asian users
;; (require 'un-define)
(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(abbrev-mode t)
 '(backward-delete-function (quote backward-delete-char-untabify))
 '(browse-url-browser-function (quote browse-url-netscape))
 '(case-fold-search t)
 '(column-number-mode t)
 '(compilation-read-command nil)
 '(compilation-window-height 5)
 '(dabbrev-upcase-means-case-search t)
 '(delete-key-deletes-forward t)
; '(font-lock-mode t t (font-lock))
 '(inhibit-startup-screen t)
 '(longlines-wrap-follows-window-size nil)
 '(make-backup-files nil)
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
 '(mlint-scan-for-fixes-flag t)
 '(normal-erase-is-backspace t)
 '(show-paren-mode t)
 '(uniquify-buffer-name-style (quote forward) nil (uniquify)))

;;============== Emacs faces ==============
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:inherit t :stipple nil :background "black" :foreground "white" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 121 :width normal :foundry "unknown" :family "DejaVu Sans Mono"))))
 '(custom-comment-tag-face ((((class color) (background light)) (:foreground "#55aaff"))) t)
 '(custom-group-tag-face ((((class color) (background light)) (:foreground "yellow" :underline t))) t)
 '(custom-variable-tag-face ((((class color) (background light)) (:foreground "yellow" :underline t))) t)
 '(diff-added ((t (:foreground "white"))))
 '(diff-added-face ((t (:inherit diff-changed-face))))
 '(diff-changed ((nil (:foreground "cyan"))))
 '(diff-context-face ((((class color) (background dark)) (:foreground "pink"))))
 '(diff-file-header ((nil (:foreground "pink"))))
 '(diff-file-header-face ((t (:background "black" :foreground "yellow" :weight bold))))
 '(diff-function-face ((t (:foreground "magenta"))))
 '(diff-header ((nil (:foreground "yellow" :weight bold))))
 '(diff-header-face ((((class color) (background dark)) (:foreground "yellow"))))
 '(diff-hunk-header ((t (:background "grey15" :foreground "red"))))
 '(diff-hunk-header-face ((t (:foreground "red"))))
 '(diff-index ((t (:foreground "yellow"))))
 '(diff-index-face ((t (:inherit diff-file-header-face :background "black"))))
 '(diff-removed ((t (:foreground "cyan"))))
 '(diff-removed-face ((t (:foreground "cyan"))))
 '(font-lock-builtin-face ((((class color) (min-colors 88) (background dark)) (:foreground "#afff00"))))
 '(font-lock-comment-face ((((class color) (min-colors 88) (background dark)) (:foreground "#ffff00"))))
 '(font-lock-constant-face ((((class color) (min-colors 88) (background dark)) (:foreground "#feabab"))))
 '(font-lock-doc-string-face ((((class color) (min-colors 88) (background dark)) (:foreground "#00ff00"))))
 '(font-lock-function-name-face ((((class color) (min-colors 88) (background dark)) (:foreground "#ff0000"))))
 '(font-lock-keyword-face ((((class color) (min-colors 88) (background dark)) (:foreground "#74f7ff"))))
 '(font-lock-preprocessor-face ((((class color) (min-colors 88) (background dark)) (:foreground "green2"))))
 '(font-lock-reference-face ((((class color) (min-colors 88) (background dark)) (:foreground "#00ffff"))))
 '(font-lock-string-face ((((class color) (min-colors 88) (background dark)) (:foreground "#fd62fd"))))
 '(font-lock-type-face ((((class color) (min-colors 88) (background dark)) (:foreground "steelblue1"))))
 '(font-lock-variable-name-face ((((class color) (min-colors 88) (background dark)) (:foreground "#74ff77")))))

;; =========== End of Emacs faces ===========

;;; --------------------------------------------------
;;; load general definitions
;; These files must be in one of the directories specified in variable load-path
;; Adding directories to this variable is done above
(load "abbrevs")
(load "globalLisp.el")

;; Load special modes (defined in lisp/modes)
(load "matlab-mode.el")
(load "savehist-mode.el")

;; savehist stuff
(setq savehist-additional-variables '(kill-ring search-ring regexp-search-ring))
(savehist-mode 1)


;; Load some custom lisp only when their mode is activated
(add-hook 'latex-mode-hook (load "latexLisp.el"))
(add-hook 'java-mode-hook (load "javaLisp.el"))
(add-hook 'cc-mode-hook (load "ccLisp.el"))
(add-hook 'sh-mode-hook (load "shLisp.el"))

(setq gdb-command-name "gdb --annotate=1")
