;; Note: The EmacsLink's matlab-iee.el function from mathworks is written for 
;; Emacs (and NOT Xemacs). However, in Xemacs the following Emacs functions are 
;; not defined: subst-char-in-string, line-beginning-position, line-end-position 
;; ==> XEmacs will throw some 'undefined function' errors sometimes (most notably, 
;; when trying to save changes to a file). As a workaround, this file should be
;; loaded in the init.el file, before the AUTOLOAD call for Matlab mode.

;; ====== added by crpi ======
(unless (fboundp 'subst-char-in-string)
(defun subst-char-in-string (fromchar tochar string &optional
inplace)
"Replace FROMCHAR with TOCHAR in STRING each time it occurs.
Unless optional argument INPLACE is non-nil, return a new string."
(let ((i (length string))
(newstr (if inplace string (copy-sequence string))))
(while (> i 0)
(setq i (1- i))
(if (eq (aref newstr i) fromchar)
(aset newstr i tochar)))
newstr)))

(defun line-beginning-position (&optional n)
(save-excursion
(and n (/= n 1) (forward-line (1- n)))
(beginning-of-line)
(point)))

(defun line-end-position (&optional n)
(save-excursion
(and n (/= n 1) (forward-line (1- n)))
(end-of-line)
(point)))
;; ====== end of added by crpi ======


;; Special things for matlab mode
;;(if (string= system-type "windows-nt")
;;    (load "D:/Program Files/MATLAB/R2007b/java/extern/EmacsLink/lisp/matlab-eei.el" nil t t)
;;  (load "/opt/Software/matlab/7.4/java/extern/EmacsLink/lisp/matlab-eei.el" nil t t))


