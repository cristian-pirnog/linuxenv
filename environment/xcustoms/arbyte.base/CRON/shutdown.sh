#!/bin/bash


# Script to be run from the runVPStratLauncher.sh, after the binary stops


#----------------------------------------------
printUsage()
{
    cat << %%USAGE%%
         Usage: $(basename ${0}) [-h]

    Description:
        Run the shutdown procedure, after the VPStratLauncher binary exits.

    Options:
       -h
       --help
             Print this help message and exit.

       --afterRun
             Signals that the script is called after the binary has stopped.
             Consequantly the script does not check if the binary is still 
             running, but just proceeds with the task.
%%USAGE%%
}


#----------------------------------------------
getNextNuberedDir()
{
    local lBaseDir="${1}"

    local lNextNumberedDir=""
    for i in `seq 1 50`; do
        local lNextNumber=${i}
        lNextNumberedDir=${lBaseDir}/${lNextNumber}
        if [[ ! -d ${lNextNumberedDir} ]]; then
            mkdir -p ${lNextNumberedDir}
            break
        fi
    done
    echo ${lNextNumberedDir}
}


#----------------------------------------------
getHistoricalLogDir()
{
    local lDateDir=log/${date}
    local lHistLogDirBase=${liveDir}/${lDateDir}
    local lHistLogDir=$(getNextNuberedDir ${lHistLogDirBase})

    # Make a symlink to the latest log dir
    latestLog=${lHistLogDirBase}/../latest
    if [[ -h ${latestLog} ]]; then rm ${latestLog}; fi
    ln -s ${lDateDir}$(basename ${lHistLogDir}) ${latestLog}

    echo ${lHistLogDir}
}


#----------------------------------
# Main script
#----------------------------------

ARGS=$(getopt -o h -l "help,afterRun" -n "$(basename ${0})" -- "$@")

# If wrong arguments, print usage and exit
if [[ $? -ne 0 ]]; then
    printUsage
    exit 1;
fi

eval set -- "$ARGS"

## Parse options
afterRun=0
while true; do
    case ${1} in
    -h|--help)
        printUsage
        exit 0
        ;;
    --afterRun)
        afterRun=1
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


# If the binary still runs, exit
if [[ ${afterRun} -ne 1 ]]; then
    processId=$(findVPStratLauncherInstances)
    if [[ -n "${processId}" ]]; then 
        printf "Binary still running (process id: ${processId}). Aborting.\n"
        exit 1
    fi
fi

baseScript=${HOME}/CRON/base.sh
if [[ ! -f ${baseScript} ]]; then
    printf "Could not find base script %s" ${baseScript}
    exit 1
fi

# Source the base script
source ${baseScript}
source ${HOME}/CRON/email.sh

###############################
# Copy/Move all relevant files to the historicalLogDir
###############################
historicalLogDir=$(getHistoricalLogDir)
# ... move the log files
mv ${binDir}/*.log ${historicalLogDir} >/dev/null 2>&1
mv ${logDir}/*.log ${historicalLogDir} >/dev/null 2>&1

# ... copy the dat dir (which includes the cmeRecoverFile (if any exists))
cp -r ${datDir} ${historicalLogDir} >/dev/null 2>&1

# ... copy the fix log files
cp -r ${fixDir} ${historicalLogDir} || exit -1

# ... copy the strategy config directory (for future reference)
cp -r ${strategyConfigDir} ${historicalLogDir}

# ... [TODO] copy log files for other protocols

###############################
# Copy the historicalLogDir to the NAS
###############################
#if [[ ${USER} == arbyteprod ]]; then
    bkpDirOnNAS=${arbyteLiveBkpDir}/${date}/$(hostname --short)
    identityFile="${HOME}/.ssh/id_rsa"
    if [[ -f ${identityFile} ]]; then
        ssh -i ${identityFile} ${arbyteNAS} "mkdir -p ${bkpDirOnNAS}" && \
        rsync -azvh ${historicalLogDir} ${arbyteNAS}:${bkpDirOnNAS}
    fi
#fi

###############################
# Copy files to the compliance shared dir
###############################
# ... the fix8 log files
if [[ -d ${complianceLogDir} ]]; then
   complianceLogDir=${complianceLogDir}/${date}/$(hostname --short)
   mkdir -p ${complianceLogDir}

   complianceNumberedLogDir=$(getNextNuberedDir ${complianceLogDir})
   echo complianceNumberedLogDir=${complianceNumberedLogDir}
   cp -r ${historicalLogDir}/fix8/* ${complianceNumberedLogDir}
fi

###############################
# Cleanup for the next day
###############################
# ... remove all fix log files
rm -f ${fixDir}/*.log.*
# ... remove old recovery files
rm ${datDir}/*_recovery.csv.*
# ... append the date to the current recovery file
rename '_recover.csv' "_recover.csv.${date}" ${datDir}/*

