;; Function for inserting the LATEX "inline equation" tags
(defun sh-initializeScript()
  (interactive)
  ;; Check if the buffer is empty
  (goto-char (point-max))

  (if (or (bobp)
	  (y-or-n-p "Script initialization should only be done on empty buffers. Continue?"))
      (progn
	(insert "#!/bin/bash\n")
	(insert "\n")
	(insert "#----------------------------------------------\n")
	(insert "printUsage()\n")
	(insert "{\n")
	(insert "cat << %%USAGE%%\n")
	(insert "     Usage: $(basename ${0}) -h\n")
	(insert "            $(basename ${0}) PUT ARGUMENTS AND OPTIONS HERE\n")
	(insert "\n")
	(insert "    Description:\n")
	(insert "        PUT DESCRIPTION HERE\n")
	(insert "\n")
	(insert "    Options:\n")
	(insert "       -h\n")
	(insert "       --help\n")
	(insert "             Print this help message and exit.\n")
	(insert "\n")
	(insert "       PUT MORE OPTIONS HERE\n")
	(insert "	     AND DESCRIPTION HERE\n")
	(insert "\n")
	(insert "    Arguments:\n")
	(insert "       PUT ARGUMENTS HERE\n")
	(insert "	     AND DESCRIPTION HERE\n")
	(insert "\n")
	(insert "%%USAGE%%\n")
	(insert "}\n")
	(insert "\n")
	(insert "\n")
	(insert "#----------------------------------------------\n")
	(insert "# Main script\n")
	(insert "#----------------------------------------------\n")
    (insert "shortOptions='h'  # Add short options here\n")
    (insert "longOptions='help,listOptions' # Add long options here\n")
    (insert "ARGS=$(getopt -o \"${shortOptions}\" -l \"${longOptions}\" -n \"$(basename ${0})\" -- \"$@\")\n")
	(insert "scriptOptions=$(echo ${ARGS} | awk -F ' -- ' '{print $1}')\n")
	(insert "\n")
	(insert "# If wrong arguments, print usage and exit\n")
	(insert "if [[ $? -ne 0 ]]; then\n")
	(insert "    printUsage\n")
	(insert "    exit 1;\n")
	(insert "fi\n")
	(insert "\n")
	(insert "eval set -- \"$ARGS\"\n")
	(insert "\n")
	(insert "userNames=\"\"\n")
	(insert "while true; do\n")
	(insert "    case ${1} in\n")
    (insert "    --listOptions)\n")
    (insert "        echo '--'$(sed 's/,/ --/g' <<< ${longOptions}) '-'$(sed 's/\(.\)/\1 /g' <<< ${shortOptions}) | sed 's/://g'\n")
    (insert "        exit 0\n")
    (insert "        ;;\n")
    (insert "    -h|--help)\n")
	(insert "        printUsage\n")
	(insert "        exit 0\n")
	(insert "        ;;\n")
	(insert "#    --OPTION)\n")
	(insert "#        DO SOMETHING\n")
	(insert "#        shift\n")
	(insert "#        ;;\n")
	(insert "    --)\n")
	(insert "        shift\n")
	(insert "        break\n")
	(insert "        ;;\n")
	(insert "    \"\")\n")
	(insert "        # This is necessary for processing missing optional arguments \n")
	(insert "        shift\n")
	(insert "        ;;\n")
	(insert "    esac\n")
	(insert "done\n")
	(insert "\n")
	(insert "#if [[ $# -lt 1 ]]; then\n")
	(insert "#    printUsage\n")
	(insert "#    exit 1\n")
	(insert "#fi\n")
	(insert "\n")
	(beginning-of-buffer)
	(end-of-line)
	)
    (insert "initScript ")
    )
  )
