#!/bin/bash

source  ~/.userfunctions

#----------------------------------------------
printUsage()
{
cat << %%USAGE%%
     Usage: $(basename ${0}) -h
            $(basename ${0}) PUT ARGUMENTS AND OPTIONS HERE

    Description:
        PUT DESCRIPTION HERE

    Options:
       -h
       --help
             Print this help message and exit.

       PUT MORE OPTIONS HERE
	     AND DESCRIPTION HERE

    Arguments:
       PUT ARGUMENTS HERE
	     AND DESCRIPTION HERE

%%USAGE%%
}


#----------------------------------------------
# Main script
#----------------------------------------------
shortOptions='h'  # Add short options here
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
#    --OPTION)
#        DO SOMETHING
#        shift
#        ;;
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

if [[ $# -lt 1 ]]; then
    printUsage
    exit 1
fi

# Uncomment this for enabling debugging
# set -x

tag=${1}

if [[ -z $(git tag|egrep "^${tag}$") ]]; then
    exitWithError "Could not find tag ${tag} in the repository."
fi

getAnswer "About to delete tag '${tag}'. Continue?" || exit

git tag -d ${tag}
git push origin :refs/tags/${tag}
