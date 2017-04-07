#!/bin/bash

#----------------------------------------------
printUsage()
{
cat << %%USAGE%%
     Usage: $(basename ${0}) -h
            $(basename ${0}) [filename] [-o outFile]

    Description:
        Builds an HTML apidoc file from the given (apib) file.

    Options:
       -h
       --help
             Print this help message and exit.

       -o outFile
	     The name of the output file. Defaults to the name of the input
	     file, with html extension.

    Arguments:
       filename
             The name of the file to be used as input. If not provided the
	     script will attempt to find a file called doc/DIRNAME.apib, where
	     DIRNAME is the name of the current directory. If no such file is
	     found, it search for an apib file in the doc directory.

    Requires: aglio

%%USAGE%%
}


#----------------------------------------------
# Main script
#----------------------------------------------
shortOptions='ho:'  # Add short options here
longOptions='help,listOptions' # Add long options here
if $(isMac); then
    ARGS=`getopt "${shortOptions}" $*`
else
    ARGS=$(getopt -u -o "${shortOptions}" -l "${longOptions}" -n "$(basename ${0})" -- "$@")

fi

# If wrong arguments, print usage and exit
if [[ $? -ne 0 ]]; then
    printUsage
    exit 1;
fi

eval set -- "$ARGS"

outputFile=''
while true; do
    case ${1} in
    --listOptions)
        echo '--'$(sed 's/,/ --/g' <<< ${longOptions}) $(echo ${shortOptions} |
            sed 's/[^:]/-& /g') | sed 's/://g'
        exit 0
        ;;
    -h|--help)
        printUsage
        exit 0
        ;;
    -o)
        outputFile=${2}
        shift 2
        ;;
    --)
        shift
        break
        ;;
    "")
        # This is necessary for processing missing optional arguments
        shift
        ;;
    esac
done

# Check for aglio
source ~/.userfunctions
if [[ -z $(which aglio) ]]; then
    exitWithError 'Could not find aglio on your system\n'
fi


inputFile="${1}"
if [[ -z "${inputFile}" ]]; then
    inputFile="doc/$(basename $(pwd)).apib"
    if [[ ! -f ${inputFile} ]]; then
        inputFile=`find doc -name '*.apib'`
        fileCount=$(echo ${inputFile}|wc -w)
        if [[ ${fileCount} -eq 0 ]]; then
            echo "Could not find an apib file in doc directory"
            exit 1
        elif [[ ${fileCount} -gt 1 ]]; then
            echo "Found multiple apib files in doc directory"
        fi
    fi
fi

if [[ -z "${outputFile}" ]]; then
    outputFile=${inputFile%.*}'.html'
fi

# Uncomment this for enabling debugging
#set -x

# Only build if the output file is older than the input file
if [[ ${outputFile} -ot ${inputFile} ]]; then
    aglio -i ${inputFile} --theme-template triple -o ${outputFile}
fi
