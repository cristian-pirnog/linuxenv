#!/bin/bash

test -f ~/.userfunctions && source ~/.userfunctions

#----------------------------------------------
printUsage()
{
cat << %%USAGE%%
     Usage: $(basename ${0}) -h
            $(basename ${0}) [filter] [-- docker log options]

    Description:
        Attaches to a running docker container.

    Options:
       -h
       --help
             Print this help message and exit.

       -s
       --stopped
	     Include stopped containers.

       --all
	     Show all logs. If not specified, the equivalent of '--tail 100 -f' will be done

       docker log options
             Any options that the 'docker logs' command accepts. These options must
	     will be preceded by a -- and they will be passed directly to the
	     'docker logs' command.
              Example: -- --tail 100 -f

    Arguments
       filter
             The string used for filtering the existing docker containers.

%%USAGE%%
}


#----------------------------------------------
# Main script
#----------------------------------------------
shortOptions='hs'  # Add short options here
longOptions='help,listOptions,all,stopped' # Add long options here
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

noArgs=false
dockerPsArgs=''
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
    --all)
        noArgs=true
        shift
        ;;
    -s|--stopped)
        dockerPsArgs=${dockerPsArgs}' -a'
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

# Uncomment this for enabling debugging
# set -x

if [[ ${hasDoubleDash} != true ]] || [[ ${hasFilter} == true ]]; then
    filter=${1}
    shift
fi

source containerUtils.sh
selectContainer containerId imageName ${filter} ${dockerPsArgs}

printf 'Logs for container %s (id %s):\n\n' ${imageName} ${containerId}
echo '-------------------------------------------'
if [[ ${noArgs} == true ]] || [[ -n "${@}" ]]; then
    ${sudo} docker logs "${@}" ${containerId}
else
    ${sudo} docker logs --tail 100 -f ${containerId}
fi
echo '-------------------------------------------'
echo
