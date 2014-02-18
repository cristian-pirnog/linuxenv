(define-abbrev-table 'pike-mode-abbrev-table '(
    ))

(define-abbrev-table 'idl-mode-abbrev-table '(
    ))

(define-abbrev-table 'java-mode-abbrev-table '(
    ("prt" "System.out.println();" nil 1)

;;  Signature
    ("sign" "Cristian Pirnog" nil 1)

;;  Comment delimiter
    ("cmt" "" java-insert-comment-delimiter 1)

;;  Comment to be put before definition of each method in a class
    ("cc" "" java-insert-comment 1)

;;  Full function skeleton
    ("fn" "" java-insert-full-function 1)

;;  Inserts the package that contains the Trace class
    ("trimp" "import com.valescom.support.trace.java.*;")

;;  Inserts the definition of the theTrace variable
    ("trc" "" java-insert-trace-definition 1)

;;  Insert the trace checking
    ("iftr" "" java-insert-trace-statement 1)

;;  Inserts the base package
    ("bimp" "import com.valescom.support.base.java.*;" nil 1)

;;  Insert an assert
    ("ifas" "" java-insert-assert-statement 1)

;;  Insert a "null" assert
    ("ifnas" "" java-insert-assert-null-statement 1)

;;  Insert a Message statement
    ("msg" "" java-insert-message-statement 1)
    ))

(define-abbrev-table 'objc-mode-abbrev-table '(
    ))

(define-abbrev-table 'c++-mode-abbrev-table '(
    ("stmp" "" cc-insert-header-svn 1)
    ("cmt" "" cc-insert-doxygen-comment 1)
    ("fui" "" cc-insert-for-unsigned-loop 1)
    ("fii" "" cc-insert-for-signed-loop 1)
    ("ie" "" cc-insert-if-else-statement 1)
    ("iei" "" cc-insert-if-else-if-statement 1)
    ("dbg" "" cc-insert-debug-ifded 1)
    ;; These are especialy for Mex C++ files
    ("prt" "" cc-insert-mexPrintf 1)
    ("err" "" cc-insert-mexErrMsgTxt 1)
    ("%f" "%3.12f" nil 1)
    ("cout" "" cc-insert-cout 1)
    ))

(define-abbrev-table 'c-mode-abbrev-table '(
    ("stmp" "" cc-insert-header-svn 1)
    ("fui" "" cc-insert-for-unsigned-loop 1)
    ("ie" "" cc-insert-if-else-statement 1)
    ("iei" "" cc-insert-if-else-if-statement 1)
    ;; These are especialy for Mex C++ files
    ("prt" "" cc-insert-mexPrintf 1)
    ("err" "" cc-insert-mexErrMsgTxt 1)
    ))

(define-abbrev-table 'xml-mode-abbrev-table '(
    ))

(define-abbrev-table 'matlab-mode-abbrev-table '(
    ("hlink" "" matlab-insert-function-hyperlink 1)
    ("stmp" "" matlab-insert-help-end 1)
    ("ctv" "%% Constant values" nil 1)
    ("fori" "" matlab-insert-for-loop 1)
    ("err" "" matlab-insert-error 1)
    ("warn" "" matlab-insert-warning 1)
    ("ife" "" matlab-insert-if-empty-condition 1)
    ("ifne" "" matlab-insert-if-notempty-condition 1)
    ("ifeq" "" matlab-insert-if-isequal-condition 1)
    ("ifneq" "" matlab-insert-if-notisequal-condition 1)
    ("ifex" "" matlab-insert-if-exist-condition 1)
    ("ifnex" "" matlab-insert-if-notexist-condition 1)
    ("prt" "" matlab-insert-fprintf 1)
    ("fop" "" matlab-insert-fopen 1)
    ("fprt" "" matlab-insert-file-fprintf 1)
    ("pinf" "" matlab-insert-productinfo 1)
    ("!=" "~=") ;; Replace C-style negative comparison with Matlab-style
    ("++" "" matlab-insert-increment-statement 1)
    ("+=" "" matlab-insert-add-statement 1)
    ("definp" "" matlab-insert-default-inputs-code 1)
    ("dax" "'5107078979551026806'" nil 1) ; DAX IDS Id
    ("stx" "'5107078979551026664'" nil 1) ; STX IDS Id
    ("cac" "'5107078979551078970'" nil 1) ; CAC IDS Id
    ("EOF" "%% End-of-Function" nil 1)
    ))

(define-abbrev-table 'text-mode-abbrev-table '(
    ("beq" "" latex-insert-equation-tags 1)
    ("benum" "" latex-insert-enumerate-tags 1)
    ("bitem" "" latex-insert-itemize-tags 1)
    ("ec" "" latex-insert-inline-equation-tags 1)
    ("bfig" "" latex-insert-figure-tags 1)
    ("btab" "" latex-insert-table-tags 1)
    ("frac" "\\frac{}{}" backward-char 1)
    ("*" "\\cdot " nil 1)
;;    ("p_i" "\\Delta \\vect{p}_i" nil 1)
;;    ("p_j" "\\Delta \\vect{p}_j" nil 1)
    ))

(define-abbrev-table 'lisp-mode-abbrev-table '(
    ))

(define-abbrev-table 'help-mode-abbrev-table '(
    ))

(define-abbrev-table 'completion-list-mode-abbrev-table '(
    ))

(define-abbrev-table 'fundamental-mode-abbrev-table '(
    ))

(define-abbrev-table 'global-abbrev-table '(
    ("sap" "same as point " nil 1)
    ("svn_branch" "" global-insert-svn-branch-tag 1)
    ("svn_merge" "" global-insert-svn-merge-tag 1)
    ("svn_delete" "" global-insert-svn-delete-tag 1)
    ("sap" "same as point " nil 1)
    ("uatp" "updated according to point " nil 1)
    ))

(define-abbrev-table 'confluence-mode-abbrev-table '(
    ("usrlnk" "[~@nl.imc.local]" nil 1)
    ))
