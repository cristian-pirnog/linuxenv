#!/bin/bash

# Run this scrip to install a working environment on CentOS 6.5

#----------------------------------------------
printUsage()
{
cat << %%USAGE%%
     Usage: $(basename ${0}) -h
            $(basename ${0}) --prod host
            $(basename ${0}) --test host
            $(basename ${0}) --all host
            $(basename ${0}) --user userNames host

    Description:
        Update the configurations for the production environment on the given host.

    Options:
       -h
       --help
             Print this help message and exit.

       --prod
            Updates the environment for the production user (arbyteprod).

       --test
            Updates the environment for the test user (arbytetest).

       --all
            Updates the environment for all arbyte users.

       --user userNames
            Updates the environment for the given userNames.

%%USAGE%%
}


#----------------------------------------------
# Main script
#----------------------------------------------
ARGS=$(getopt -o h -l "help,prod,test,all,user:" -n "$(basename ${0})" -- "$@")
scriptOptions=$(echo ${ARGS} | awk -F ' -- ' '{print $1}')

# If wrong arguments, print usage and exit
if [[ $? -ne 0 ]]; then
    printUsage
    exit 1;
fi

eval set -- "$ARGS"

userNames=""
while true; do
    case ${1} in
    -h|--help)
        printUsage
        exit 0
        ;;
    --test)
        userNames="arbytetest"
        shift
        ;;
    --prod)
	userNames="arbyteprod"
        shift
        ;;
    --all)
	userNames="arbytetest arbyteprod"
        shift
        ;;
    --local)
	userNames="${2}"
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

if [[ $# -lt 1 ]]; then
    printUsage
    exit 1
fi

hostName=${1}
shift

if [[ -z ${userNames} ]]; then
    printf "\n---------------------------------------------\n"
    printf "Must specify the target user. See usage below"
    printf "\n---------------------------------------------\n\n"
    printUsage
    exit 1
fi

rsyncCommand="rsync -azvhq"
for user in ${userNames}; do
    userAtHost=${user}@${hostName}
    printf "Updating for ${userAtHost}...\t"
    targetConfigDir='scratch/cluster/config/RONIN'
    ssh -A ${userAtHost} "mkdir -p '${targetConfigDir}'"
    ${rsyncCommand} /mnt/config/RONIN/exchanges.csv ${userAtHost}:${targetConfigDir}
    printf "[Done]\n"
done
