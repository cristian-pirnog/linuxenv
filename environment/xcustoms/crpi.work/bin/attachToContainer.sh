#!/bin/bash


#----------------------------------------------
printUsage()
{
cat << %%USAGE%%
     Usage: $(basename ${0}) -h
            $(basename ${0}) [image]

    Description:
        Attaches to a running docker container.

    Options:
       -h
       --help
             Print this help message and exit.

    Arguments:
       image
             If provided, it will attempt to attach to the container that
             corresponds to the given image name. Otherwise, it will list
	     all images that have containers running and ask the user to
	     select one.

%%USAGE%%
}

getContainer()
{
    local lImage=${1}
    docker ps | awk '{print $1, $2}' | tail -n +2 | egrep ' '${lImage}'$' | awk '{print $1}'
}

listContainerImages()
{
    docker ps | awk '{print $2}' | tail -n +2
}


#----------------------------------------------
# Main script
#----------------------------------------------
shortOptions='h'  # Add short options here
longOptions='help,listOptions' # Add long options here
ARGS=$(getopt -o "${shortOptions}" -l "${longOptions}" -n "$(basename ${0})" -- "$@")

# If wrong arguments, print usage and exit
if [[ $? -ne 0 ]]; then
    printUsage
    exit 1;
fi

eval set -- "$ARGS"

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

#if [[ $# -lt 1 ]]; then
#    printUsage
#    exit 1
#fi

imageName="${1}"

# When debuggin script, we echo all (most) commands, instead of executing them
dbg=echo
dbg=''



if [[ -z ${imageName} ]]; then
    images=$(listContainerImages)
    while true; do
	index=0
	for img in ${images}; do
	    index=$((index + 1))
	    echo "[$index] " $img
	done
	printf "\nChoose image (1 to %d, q to quit): " ${index}
	read answer
	
    if [[ ${answer} == 'q' ]]; then
        exit 0
    fi

	if [[ ${answer} -gt 0 ]] && [[ ${answer} -le ${index} ]]; then
	    break
	else
	    printf "The choice must be a number between 1 and ${index}.\n\n"
	fi
    done

    imageName=$(echo ${images} | awk -v answer=${answer} '{print $answer}')
fi


containerId=$(getContainer ${imageName})
if [[ $(echo $containerId|wc -w) -gt 1 ]]; then
    echo "Too many container id's found for image ${imageName}: ${containerId}"
    exit 1
fi

echo -e "\nAttaching to container ${containerId} (image ${imageName})\n"
$dbg docker exec -i -t ${containerId} /bin/bash
