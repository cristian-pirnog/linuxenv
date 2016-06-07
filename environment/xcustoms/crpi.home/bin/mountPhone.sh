#!/bin/bash


#----------------------------------------------
printUsage()
{
cat << %%USAGE%%
     Usage: $(basename ${0}) -h
            $(basename ${0}) 

    Description:
        Mounts an android phone to directory ~/S5.

    Options:
       -h
       --help
             Print this help message and exit.

%%USAGE%%
}


#----------------------------------------------
# Main script
#----------------------------------------------
shortOptions='hu'  # Add short options here
longOptions='help,listOptions' # Add long options here
ARGS=$(getopt -o "${shortOptions}" -l "${longOptions}" -n "$(basename ${0})" -- "$@")

# If wrong arguments, print usage and exit
if [[ $? -ne 0 ]]; then
    printUsage
    exit 1;
fi

eval set -- "$ARGS"

userNames=""
unmount=false
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
    -u)
        unmount=true
        shift
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

#if [[ $# -lt 1 ]]; then
#    printUsage
#    exit 1
#fi

# When debuggin script, we echo all (most) commands, instead of executing them
dbg=echo
dbg=''

targetDir="${HOME}/S5"

if [[ ! -d ${targetDir} ]]; then
    printf "Directory '%s' doesn't exist. Exiting.\n" "${targetDir}"
    exit 1
fi

isMounted=$(mount|grep ${targetDir}|wc -l)

if [[ ${unmount} == true ]]; then
    if [[ ${isMounted} -gt 0 ]]; then
	sudo umount ${targetDir}
    else
	printf "Nothing seems to be mounted on '%s'.\n" ${targetDir}
    fi
else
    if [[ ${isMounted} -gt 0 ]]; then
	printf "Something is already mounted on '%s'.\n" ${targetDir}
    else
	simple-mtpfs ${targetDir}
    fi
fi
