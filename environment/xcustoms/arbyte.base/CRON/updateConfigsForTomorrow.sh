#!/bin/bash


#----------------------------------------------
printUsage()
{
cat << %%USAGE%%
     Usage: $(basename ${0}) [-h]
            $(basename ${0}) --nowait

     Options
       -h
       --help
             Print this help message and exit.

       --nowait
             If a binary is running, do not wait for it to stop, but exit.

%%USAGE%%
}


#----------------------------------------------
# Main script
#----------------------------------------------
ARGS=$(getopt -o hb: -l "help,nowait," -n "$(basename ${0})" -- "$@")

# If wrong arguments, print usage and exit
if [[ $? -ne 0 ]]; then
    printUsage
    exit 1;
fi

eval set -- "$ARGS"

noWait=0
while true; do
    case ${1} in
    -h|--help)
        printUsage
        exit 0
        ;;
    --nowait)
        noWait=1
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



sourceDir=${HOME}/forTomorrow
targetDir=${HOME}/live

sleepTime='10m'
iterations=0
while true; do    
    instances=$(findVPStratLauncherInstances)
    if [[ -z ${instances} ]]; then
        break
    elif [[ ${noWait} == 1 ]]; then
        printf 'Found instances running: %s. Exiting.\n' ${instances}
        exit 1
    fi

    printf 'Found instances running: %s. Sleeping %s.\n' ${instances} ${sleepTime}
    sleep ${sleepTime}
    iterations=$((iterations+1))

    if [[ ${iterations} -gt 6 ]]; then
        Printf "Binary still running after waiting ${iterations} x ${sleepTime}"
        exit 1
    fi
done

# If no source directory, exit
if [[ ! -d ${sourceDir} ]]; then
    printf 'No source dir found: %s. Exiting.\n' ${sourceDir}
    exit 0
elif [[ -z $(ls ${sourceDir}) ]]; then
    printf 'Source dir %s is empty. Exiting.\n' ${sourceDir}
    exit 0
fi

# If no target directory, exit
if [[ ! -d ${targetDir} ]]; then
    printf 'No target dir found: %s. Exiting.\n' ${targetDir}
    exit 1
fi

# Clean-up the target directory
for d in $(ls ${sourceDir}); do
    sd=${sourceDir}/${d}
    td=${targetDir}/${d}
    echo Processing $d

    mkdir -p ${td}

    for f in $(ls ${td}); do
        tf=${td}/${f}
        if [[ -L ${tf} ]]; then
            printf '\tSkipping symbolic link: %s\n' ${tf}
            continue
        elif [[ -d ${tf} ]]; then
            printf '\tSkipping directory: %s\n' ${tf}
            continue
        fi

    printf '\tRemoving file: %s\n' ${tf}
    rm -f ${tf}
    done
done

cp -r ${sourceDir}/* ${targetDir}/ || exit 1
rm -r ${sourceDir}/*

