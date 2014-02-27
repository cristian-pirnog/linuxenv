(load-file "~/.dabbrev/dabbrev.elc")  ;(require 'dabbrev)

;;; Indicate where word list files reside (default: ~/.dabbrev/) 
;(setq dabbrev-wordlist-directory "/usr/share/emacs/20.7/.dabbrev/")

;;; assign your dictionary if it's not American-English.dab
;(setq dabbrev-dictionary "~/.dabbrev/dab/British-English.dab")

;;;   t - Let dictionary completion be available with every buffer. (default)
;;; nil - Dictionary completion is disabled, but word list completion for
;;;       major modes may still be available.
;;; Notice
;;; ------
;;; Whether dictionary completion is enabled or disabled, with any buffer, you can
;;; load dictionary via command `dabbrev-load-dictionary'. By doing so, you can
;;; not only assign a particular dictionary for the document in the buffer, but also
;;; put a `higher' priority on the use of dictionary completion with the very
;;; document. In orther words, even if dictionary completion is disabled by setting
;;; `dabbrev-dictionary-enabled' to nil, manually loading dictionary with
;;; `dabbrev-load-dictionary' will enable dictionary completion on the very document.
;;; The information about which dictionary to use with a document will be desktop-
;;; saved for next Emacs sessions if desktop-saving is your configuration, and you've
;;; not closed the document manually before ending an Emacs session.
;(setq dabbrev-dictionary-enabled nil)

;;; Normally, a word list file is named as <major-mode>.dab. But this may not
;;; work occasionally. For example, c++-mode.dab is an illegal file name on
;;; MS-DOS. In this case, you need to define the mapping between the major
;;; modes and the word list files in your `.emacs' file in the following way
;;;
(setq dabbrev-wordlist-file-mapping
      '((f90-mode . "~/.dabbrev/fortran-mode.dab")))
;;;
;;; where f90-mode is mapped to word list file ~/.dabbrev/fortran-mode.dab. It also
;;; shows you how to have more major modes share one word list. Please notice that
;;; the file name should be given relative or absolute path. If neither relative
;;; nor absolute path is given, the word list file is supposed to reside in the
;;; directory, `dabbrev-wordlist-directory'.


;;; activate desktop-save if needed
(require 'desktop)
(or (file-exists-p (if (string-match "XEmacs\\|Lucid" (version))
		       "~/emacs.dsk"
		     "~/.emacs.desktop"))
    (desktop-save "~/"))
;;; restore desktop of last session
(desktop-load-default)
(desktop-read)

(custom-set-variables
 '(case-fold-search t)
 '(global-font-lock-mode t nil (font-lock))
 '(show-paren-mode t nil (paren))
 '(transient-mark-mode t))
(custom-set-faces)