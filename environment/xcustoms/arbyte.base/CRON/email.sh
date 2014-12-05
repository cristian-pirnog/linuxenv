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
