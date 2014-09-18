#!/bin/bash

# Run this scrip to install a working environment on CentOS 6.5

#----------------------------------------------
printUsage()
{
cat << %%USAGE%%
     Usage: $(basename ${0}) [-h]
            $(basename ${0}) [--full] [--local] user@host

    Description:
        Install the production environment on the given host, for the given user.

    Options:
       -h
       --help
             Print this help message and exit.

       --local
            Run only the local part (installation of required libraries and compiler). 
            This option should be used only when running the script locally, on the 
            production server, which should (almost) never be necessary.

%%USAGE%%
}


#----------------------------------------------
# Main script
#----------------------------------------------
ARGS=$(getopt -o h -l "help,local" -n "$(basename ${0})" -- "$@")
scriptOptions=$(echo ${ARGS} | awk -F ' -- ' '{print $1}')

# If wrong arguments, print usage and exit
if [[ $? -ne 0 ]]; then
    printUsage
    exit 1;
fi

eval set -- "$ARGS"


localRun=0
while true; do
    case ${1} in
    -h|--help)
        printUsage
        exit 0
        ;;
    --local)
        localRun=1
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

if [[ ${localRun} != 1 ]] && [[ $# -lt 1 ]]; then
    printUsage
    exit 1
fi

userAtHost=${1}
shift

rsyncCommand="rsync -azvh"
rsyncNoTimeUpdate="rsync -rlpdogzvhc --progress"
tmpDir='${HOME}/tmp/production_env/'


# Update the copy of the stuff on the target server
if [[ ${localRun} == 0 ]]; then
    echo "Updating the source files on the target machine"
    ssh -A ${userAtHost} "mkdir -p ${tmpDir}" || exit 1
    ${rsyncNoTimeUpdate} '/mnt/config/RONIN/production_env/' ${userAtHost}:${tmpDir} || exit 1

    ssh -A ${userAtHost} "mkdir -p bin" || exit 1
    ${rsyncNoTimeUpdate} ${0} ${userAtHost}:bin || exit 1

    echo "Executing the install script on the target machine"
    ssh -A -t ${userAtHost} "cd ${tmpDir} && sudo ~/bin/$(basename $0) --local ${scriptOptions} " || exit 0

    exit 0
fi

yum install bzip2-devel
./do_gcc_make_install.sh
./env_for_building_using_4.8.2.sh
./do_cmake_make_install.sh
./do_boost_make_install.sh
./do_python_make_install.sh
