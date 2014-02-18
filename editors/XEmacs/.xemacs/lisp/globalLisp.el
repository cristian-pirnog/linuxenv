;; Function for inserting an SVN-merge log line
(defun global-insert-svn-branch-tag()
  (interactive)

  ; Ask the user for the name of the stable branch that was used as source
  (setq trunkName  (read-from-minibuffer "Trunk name: " "main"))
  (setq branchName (read-from-minibuffer "Branch name: " "g"))

  ;; If the branchName is one character only, prepend branch_stable_ to it
  (if (eq (length branchName) 1)
      (progn
        (setq branchName (concat "branch_stable_" branchName))
        (setq myDescription " Description: Creating a new stable branch"))
    (setq myDescription "Creating a new research branch")
    )

  (insert (concat "MatlabInfo:branch; origin:"  trunkName) (concat "; target:" branchName) "; ")
  (insert (concat "description: " myDescription "; "))
  (insert (concat "timestamp: " (current-time-string) ";"))
)



;; Function that reads the value of an environment variable. If the specified
; variable exists, the function returns it's value. Otherwise, it returns the
; aDefaultValue
(defun read-from-environment (aVariableName &optional aDefaultValue)
  (setq myValue (getenv aVariableName))
  (if (= (length myValue) 0 )
    (setq myValue aDefaultValue))

  myValue
)


;; Function for inserting an SVN-merge log line
(defun global-insert-svn-merge-tag()
  (interactive)

  ;; Set the default value of the SOURCE and TARGET branch name
  (setq DEFAULT_STABLE_BRANCH (read-from-environment "PROJECT_STABLE_BRANCH" "anastasius"))
  (setq MAIN_BRANCH "main")

  ; Set the DEFAULT_TARGET_BRANCH to the invocation directory
  (setq DEFAULT_TARGET_BRANCH (read-from-environment "PWD" ""))
  ; ... or to PROJECT_MAIN_BRANCH, if the invocation directory cannot be determined
  (if (string= DEFAULT_TARGET_BRANCH "")
     (setq DEFAULT_TARGET_BRANCH (read-from-environment "PROJECT_MAIN_BRANCH" "main"))
     
     ; else, keep only the file-name
     (setq DEFAULT_TARGET_BRANCH (file-name-nondirectory DEFAULT_TARGET_BRANCH)))

  (setq DEFAULT_REVISION_RANGE (read-from-environment "MERGING_REVISION_RANGE"))

  ; Ask the user for the name of the stable branch that was used as source
  (setq sourceBranchName (read-from-minibuffer "Branch name: " DEFAULT_STABLE_BRANCH))

  ; Ask the user for the name of the stable branch that was used as source
  (setq targetBranchName (read-from-minibuffer "Target branch: " DEFAULT_TARGET_BRANCH))

  ; Choose the targetBranchType based on the targetBranchName
  (if (string= targetBranchName MAIN_BRANCH)
      (setq targetBranchType "development")

    (setq targetBranchType "research"))
  
  ;; If the sourceBranchName is one character only, prepend branch_stable_ to it
  ;(if (eq (length sourceBranchName) 1)
  (if (string= sourceBranchName DEFAULT_STABLE_BRANCH)
      (progn
        ;;(setq sourceBranchName (concat "branch_stable_" sourceBranchName))
        (setq myDescription (concat "Weekly merge from stable branch to " targetBranchType " branch")))
    (setq myDescription (concat "Merge from branch '" sourceBranchName  "' to development branch"))
    )

  ; Ask the user for the range of revisions that was used for merging
  (setq range (read-from-minibuffer "Revision range: " DEFAULT_REVISION_RANGE))
  (setq rangeDelimiter (string-match ":" range))
  ; Only do the expanding if the range has the valid form: R1:R2
  (if (not rangeDelimiter)
      (error "You must specify a revision range in the form: R1:R2")
    
    (aset range rangeDelimiter ?-)
    
    (insert (concat "MatlabInfo:merge; origin:"  sourceBranchName) "; target: " targetBranchName "; ")
    (insert (concat "range:" range "; description: " myDescription "; "))
    (insert (concat "timestamp: " (current-time-string) ";")))
)


;; Function for inserting an SVN-delete log line
(defun global-insert-svn-delete-tag()
  (interactive)

  ; Set the DEFAULT_TARGET_BRANCH to the invocation directory
  (setq DEFAULT_TARGET_BRANCH (read-from-environment "PWD" ""))
  ; ... or to "UNKNOWN", if the invocation directory cannot be determined
  (if (string= DEFAULT_TARGET_BRANCH "")
     (setq DEFAULT_TARGET_BRANCH (read-from-environment "PROJECT_MAIN_BRANCH" "UNKNOWN"))
     
     ; else, keep only the file-name
     (setq DEFAULT_TARGET_BRANCH (file-name-nondirectory DEFAULT_TARGET_BRANCH)))

  ; Ask the user for the name of the stable branch that was used as source
  (setq targetBranchName (read-from-minibuffer "Target branch: " DEFAULT_TARGET_BRANCH))

  ; Choose the targetBranchType based on the targetBranchName
  (if (string-match "SAGMIM-" targetBranchName)
      (setq targetBranchType " bug_fix")
    (setq targetBranchType ""))
  
  (insert (concat "MatlabInfo:delete; target:" targetBranchName "; "))
  (insert "description: Deleted" targetBranchType " branch; ")
  (insert (concat "timestamp: " (current-time-string) ";"))
)
