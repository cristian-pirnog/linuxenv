#!/bin/bash


#----------------------------------------------
printUsage()
{
cat << %%USAGE%%
     Usage: $(basename ${0}) -h
            $(basename ${0}) account

    Description:
        PUT DESCRIPTION HERE

    Options:
       -h
       --help
             Print this help message and exit.

    Arguments:
       account
	     The name of the account (e.g. devicetools, swiss, etc.)

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

if [[ $# -lt 1 ]]; then
    printUsage
    exit 1
fi

account=${1}

# When debuggin script, we echo all (most) commands, instead of executing them
dbg=echo
dbg=''

hostIPs=($(cs listVirtualMachines name='%-'${account}'-%'| grep -P ipaddress\|displayname|awk '{print $NF}' | sed -e 's/"//g' -e 's/,//g'))
hostsCount=$(( ${#hostIPs[@]} / 2 ))

if [[ ${hostsCount} -eq 0 ]]; then
    echo "No host found for account " ${account}
    exit 1
elif [[ ${hostsCount} -eq 1 ]]; then
    answer=1
else
    while true; do
	for index in $(seq $((hostsCount)) ); do
	    name=${hostIPs[$(( 2*(index-1) ))]}
	    curIP=${hostIPs[$(( 2*index-1 ))]}
    	    echo -e "[$index]" $name '\t('$curIP')'
	done
	
	printf "\nChoose host (1 to %d, q to quit): " ${index}
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
fi

hostIP=${hostIPs[ $(( 2*answer-1 )) ]}
ssh debian@${hostIP}
