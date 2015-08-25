#!/bin/bash

CRISTIAN='pirnog@gmail.com'
GIULIANO='giuliano.tirenni@gmail.com'
JENS='jens.poepjes@gmail.com'
BRANDON='bleung@vitessetech.com'

#----------------------------------------------
sendMail()
{
    local subject=${1}
    local message=${2}
    local recipients="${3}"

    if [[ -z ${recipients} ]]; then
        recipients=${CRISTIAN}
        message=${message}"\n\nAlso, no recipients list was specified."
    fi

   mail -s "${USER}@${HOST}: ${subject}" ${recipients} << EOF
   ${message}
EOF
}

#----------------------------------
exitWithEMail()
{
    local lSubject="${1}"
    local lMsg="${2}"
    local lRecipients="${3}"
    local lExitCode=${4}
    local lLogFile=${5}

    if [[ $# -lt 4 ]]; then
	echo "Function exitWithEMail requires at least 4 input arguments: subject, message, recipients, exitCode [logFile]"
	return
    fi

    # Send e-mail
    sendMail ${lSubject} ${lMsg} ${lRecipients}

    # Print the message to the log file
    if [[ -n ${lLogFile} ]]; then
	printf '%s\n' "${lMsg}" >> ${lLogFile}
    fi

    # Exit
    exit ${lExitCode}
}

