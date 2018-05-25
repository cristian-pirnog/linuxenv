#!/bin/bash

source ~/.userfunctions

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

       --version version
  	     The version number/tag to use for the apidoc.html file.

    Arguments:
       filename
             The name of the file to be used as input. If not provided the
	     script will build all apib files in the doc directory.

    Requires: aglio

%%USAGE%%
}


function buildFile()
{
    local lInputFile=${1}
    local lOutputFile=${2}
    local lVersion=${3}

    local lVersionFile=.version
    # Only build if force
    if [[ ${force} == true ]] || \
	   # OR the output file doesn't exist
	   [[ ! -f ${lOutputFile} ]] || \
	   # OR the output file is older than the input file
       [[ ${lOutputFile} -ot ${lInputFile} ]] || \
       # OR a version is given
	   [[ -n ${version} ]] || \
	   # OR the output file is older than the version file
           [[ ${lOutputFile} -ot ${lVersionFile} ]]; then
	echo Building ${lInputFile} to ${lOutputFile}

	# If version file found, use it
	if [[ -z ${lVersion} ]]; then
            if [[ -f ${lVersionFile} ]]; then
    		lVersion=$(cat ${lVersionFile})
            else
		lVersion='N\/A'
            fi
	fi
	
	echo version = ${lVersion}
	tmpFile=$(mktemp -p $(dirname ${lInputFile}))
	cat ${lInputFile} | sed "s/__VERSION__/${lVersion}/" > ${tmpFile}
	lInputFile=${tmpFile}
	
	aglio -i ${lInputFile} --theme-template triple -o ${lOutputFile}
	
	if [[ -n ${tmpFile} ]]; then
	    test -f ${tmpFile} && rm ${tmpFile}
	fi
    fi
}


#----------------------------------------------
# Main script
#----------------------------------------------
shortOptions='ho:f'  # Add short options here
longOptions='help,listOptions,force,version:' # Add long options here
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
force=false
while true; do
    case ${1} in
    --listOptions)
        listOptions
        exit 0
        ;;
    -h|--help)
        printUsage
        exit 0
        ;;
    -f|--force)
        force=true
        shift
        ;;
    -o)
        outputFile=${2}
        shift 2
        ;;
    --version)
        version=${2}
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
if [[ -z $(which aglio) ]]; then
    exitWithError 'Could not find aglio on your system\n'
fi


inputFile="${1}"
if [[ -z ${inputFile} ]]; then
    inputFiles=( $(find doc -name 'apidoc*.apib') )
    if [[ -z ${#inputFiles[@]} ]]; then
        echo "Could not find an apib file in doc directory"
        exit 0
    fi
else
    inputFiles=(${inputFile})
fi

if [[ ${#inputFiles[@]} -gt 1 ]] && [[ -n "${outputFile}" ]]; then
    exitWithError 'Cannot provide an output file when multiple apib files exist'
fi


# Uncomment this for enabling debugging
# set -x

for inputFile in ${inputFiles[@]}; do
    outputFile=${inputFile%.*}'.html'
    buildFile ${inputFile} ${outputFile} ${version}
done
