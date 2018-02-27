#!/bin/bash

test -f ~/.userfunctions && source ~/.userfunctions

#----------------------------------------------
printUsage()
{
cat << %%USAGE%%
     Usage: $(basename ${0}) -h
            $(basename ${0}) [filter] [-- cmd with args]

    Description:
        Lists all running docker containers and lets the user choose to which
        one to attach.

    Options:
       -h
       --help
             Print this help message and exit.

    Arguments
       filter
             The string used for filtering the existing docker containers. If
             there is only one container matching the filter, the script will
             connect directly to it.

    Notes:
       1. For mysql containers, the script will ask whether to connect to the DB
          directly or to connect to the container where the DB is running.
       2. When using the 'filter' argument , the above feature can be skipped by
          ending the filter with an exclamation mark '!', in order to specify
          connecting directly to the DB or with a question mark '?' in order to
	  specify connecting directly to the container.

    Examples:

    $(basename ${0}) api  # list all containers with api in their name and connect to the chosen one
    $(basename ${0}) sql! # list all mysql containers and connect directly to the DB of the chosen one
    $(basename ${0}) sql? # list all mysql containers and connect directly to the container of the chosen one

%%USAGE%%
}


#----------------------------------------------
# Main script
#----------------------------------------------
shortOptions='h'  # Add short options here
longOptions='help,listOptions' # Add long options here
ARGS=$(getopt -o "${shortOptions}" -l "${longOptions}" -n "$(basename ${0})" -- "$@")

if [[ ${1} == '--' ]] || [[ ${2} == '--' ]]; then
    if [[ ${2} == '--' ]]; then
	hasFilter=true
    fi
    hasDoubleDash=true
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

# Uncomment this for enabling debugging
# set -x

noAsk=false
attachToDB=false
if [[ ${hasDoubleDash} != true ]] || [[ ${hasFilter} == true ]]; then
    filter=${1}
    if [[ $filter == *'!' ]] || [[ $filter == *'?' ]]; then
	if [[ $filter == *'!' ]]; then
	    attachToDB=true
	fi
        noAsk=true	
        filter=${filter:0: -1}
    fi
    shift
fi

source containerUtils.sh
selectContainer containerId imageName ${filter}

dockerAttachCommand="${sudo} docker exec -it ${containerId}"
dockerExecCommand="${sudo} docker exec ${containerId}"


## Initialize the command
cmd="${@}"
if [[ -z ${cmd} ]]; then
    cmd=bash
fi

echo -e "\nAttaching to container ${containerId} (image ${imageName})\n"
if [[ -n $(echo ${imageName} | grep sql) ]]; then
    answer='y'
    if [[ $noAsk == false ]]; then
        printf "You're attaching to a 'mysql' container. Would you like to connect to the DB? [y/n] "
        read answer
    fi

    if [[ ${answer} == 'y' ]] && [[ ${attachToDB} == true ]]; then
	    mysqlPwd=$(getContainerEnvVariable ${containerId} MYSQL_ROOT_PASSWORD)

    	if [[ -z ${mysqlPwd} ]]; then
    	    echo "Could not retrieve the password for mysql."
    	    exit 1
    	fi

	dbName=$(getContainerEnvVariable ${containerId} MYSQL_DATABASE | awk '{print $1}')
	cmd="mysql -h localhost -u root -p${mysqlPwd} ${dbName}"
    fi
fi

${dockerAttachCommand} ${cmd}
