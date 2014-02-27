(define-abbrev-table 'pike-mode-abbrev-table '(
    ))

(define-abbrev-table 'idl-mode-abbrev-table '(
    ))

(define-abbrev-table 'java-mode-abbrev-table '(
    ("sysout" "System.out.println();" nil 1)

    ("newClass" "" java-insert-class-skeleton 1)

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
    ("cout" "" cc-insert-cout 1)
    ("main" "" cc-insert-main-skeleton 1)
    ("iostream" " " cc-insert-iostream 1) 
    ("newClass" "" cc-insert-class-skeleton 1)
    ("{" "" cc-insert-brackets 1)
    ("tpdf" "#include <Typedefs.hpp>" nil 1)
    ("inc" "#include <.hpp>" nil 1)
    ;; These are especialy for Mex C++ files
    ("prt" "" cc-insert-mexPrintf 1)
    ("err" "" cc-insert-mexErrMsgTxt 1)
    ("%f" "%3.12f" nil 1)
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

(define-abbrev-table 'latex-mode-abbrev-table '(
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
    ("sap" "same as point" nil 1)
    ("svnBranch" "" global-insert-svn-branch-tag 1)
    ("svnMerge" "" global-insert-svn-merge-tag 1)
    ("svnDelete" "" global-insert-svn-delete-tag 1)
    ("uatp" "updated according to point" nil 1)
    ("FTI" "AEX,FTI" nil 1)
    ("MME" "CBT,MME" nil 1)
    ("MMS" "CBT,MMS" nil 1)
    ("YM" "CBT,YM" nil 1)
    ("FSPQ" "CME,FSPQ" nil 1)
    ("JPYUSD" "CME,JPYUSD" nil 1)
    ("NIY" "CME,NIY" nil 1)
    ("SOIL" "CME,SOIL" nil 1)
    ("SOYB" "CME,SOYB" nil 1)
    ("POIL" "NYM,POIL" nil 1)
    ("FBTP" "EUX,FBTP" nil 1)
    ("FBTS" "EUX,FBTS" nil 1)
    ("FDAX" "EUX,FDAX" nil 1)
    ("FDAX_ONE" "EUX," nil 1)
    ("FESX" "EUX,FESX" nil 1)
    ("FESX_ONE" "EUX,FESX" nil 1)
    ("FGBL" "EUX,FGBL" nil 1)
    ("FOAT" "EUX,FOAT" nil 1)
    ("HHI" "HKF,HHI" nil 1)
    ("HSI" "HKF,HSI" nil 1)
    ("BRE" "ICE,BRE" nil 1)
    ("NASQ" "CME,NASQ" nil 1)
    ("NKD" "CME,NKD" nil 1)
    ("GOLD" "CME,GOLD" nil 1)
    ("SILV" "CME,SILV" nil 1)
    ("FCAC" "LIF,FCAC" nil 1)
    ("GILT" "LIF,GILT" nil 1)
    ("CGB" "MSE,CGB" nil 1)
    ("OMX" "OMX,OMX" nil 1)
    ("FTSE" "LIF,FTSE" nil 1)
    ))

(define-abbrev-table 'confluence-mode-abbrev-table '(
    ("newPage" "" confluence-insert-minutes-template 1)
    ("newProj" "" confluence-insert-project-template 1)
    ("DATE" "" insert-date-string 1)
    ("DT" "" insert-date-string-interactive 1)
    ("crpi" "" confluence-insert-user-link 1)
    ("alme" "" confluence-insert-user-link 1)
    ("anvo" "" confluence-insert-user-link 1)
    ("bape" "" confluence-insert-user-link 1)
    ("lufr" "" confluence-insert-user-link 1)
    ("mabr" "" confluence-insert-user-link 1)
    ("mama" "" confluence-insert-user-link 1)
    ("qubo" "" confluence-insert-user-link 1)
    ("robe" "" confluence-insert-user-link 1)
    ("stwi" "" confluence-insert-user-link 1)
    ("thsc" "" confluence-insert-user-link 1)
    ("tohu" "" confluence-insert-user-link 1)
    ))
