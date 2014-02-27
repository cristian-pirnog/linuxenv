;; ============= Haskell Mode ============= 
(add-to-list 'load-path (expand-file-name "~/.emacs.d/lisp/haskell/2.8.0"))

;; Load the bare-bones haskell-mode
(load "haskell-site-file.el")

(add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
(add-hook 'haskell-mode-hook 'turn-on-haskell-indentation)
(add-hook 'haskell-mode-hook 'font-lock-mode)
(add-hook 'haskell-mode-hook 'imenu-add-menubar-index)

(setq haskell-program-name "ghci")