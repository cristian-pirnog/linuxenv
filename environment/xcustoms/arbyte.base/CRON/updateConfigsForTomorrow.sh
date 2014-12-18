#!/bin/bash

sourceDir=${HOME}/forTomorrow
targetDir=${HOME}/live

sleepTime='10m'
while true; do
    instances=$(findVPStratLauncherInstances)
    if [[ -z ${instances} ]]; then
        break
    fi

    printf 'Found instances running: %s. Sleeping ${sleepTime}.\n' ${instances}
    sleep ${sleepTime}
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
    rm ${tf}
    done
done

cp -r ${sourceDir}/* ${targetDir}/ || exit 1
rm -r ${sourceDir}/*

