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
    ln -s ${lHistLogDir} ${latestLog}

    echo ${lHistLogDir}
}


#----------------------------------------------
getSessionIds()
{
    grep session_id ${binDir}/arbyte.xml | awk '{for (i=1; i<NF; i++) {if ($i ~ /session_id/) {print $i}}}' | \
sed s/session_id=\"// | sed s/\"//
}

#----------------------------------------------
handleRecoveryFiles()
{
    local lTargetDir=${1}

    echo -e "\nHandling recovery files in ${lTargetDir}"
    shopt -s nullglob
    for f in ${lTargetDir}/*_recover.csv.*; do
	# ... remove old recovery files
	${dbg} rm ${lTargetDir}/*_recover.csv.*
    done
    shopt -u nullglob

    # ... append the date to the current recovery file
    ${dbg} rename '_recover.csv' "_recover.csv.${date}" ${lTargetDir}/*
}

#----------------------------------------------
cleanupCeloxicaFiles()
{
    local lCleanupDate=${1}
    local lDir=${2}

    # Cleanup the client*.Celoxica files
    shopt -s nullglob
    for f in ${lDir}/client*.Celoxica; do
	if [[ -n $(grep '8=FIX' ${f} ) ]]; then
	    sed 's/8=FIX/\
8=FIX/g' ${f} | grep ${lCleanupDate} | tr -d '\n' > ${f}.clean && mv ${f}.clean ${f}
	fi
	
	# If the file is empty, remove it
	if [[ ! -s ${f} ]] ;then
	    rm ${f}*
	fi
    done
    shopt -u nullglob
}


#----------------------------------
# Main script
#----------------------------------

shortOptions='h'
longOptions='help,listOptions,afterRun'
ARGS=$(getopt -o "${shortOptions}" -l "${longOptions}" -n "$(basename ${0})" -- "$@")

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
    --listOptions)
        echo '--'$(sed 's/,/ --/g' <<< ${longOptions}) '-'$(sed 's/\(.\)/\1 /g' <<< ${shortOptions}) | sed 's/://g'
        exit 0
        ;;
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
    printf "Could not find base script %s\n" ${baseScript}
    exit 1
fi

# Source the base script
source ${baseScript}
source ${HOME}/CRON/email.sh

# When debuggin script, we echo all (most) commands, instead of executing them
dbg=echo
dbg=''

###############################
# Copy/Move all relevant files to the historicalLogDir
###############################
historicalLogDir=$(getHistoricalLogDir)
sessions=$(getSessionIds)

# ... move the log files
${dbg} mv ${binDir}/*.log ${historicalLogDir} >/dev/null 2>&1
${dbg} mv ${logDir}/*.log ${historicalLogDir} >/dev/null 2>&1

# ... copy the dat dir (which includes the cmeRecoverFile (if any exists))
${dbg} cp -r ${datDir} ${historicalLogDir} >/dev/null 2>&1

# ... copy the strategy config directory (for future reference)
${dbg} cp -r ${strategyConfigDir} ${historicalLogDir}

# ... copy the arbyte.xml file
${dbg} cp -r ${binDir}/arbyte.xml ${historicalLogDir}

# ... copy the state files to the config directory in the historical log dir
if [[ -n $(ls ${logDir} | grep '.state') ]]; then
    targetStrategyConfigDir=${historicalLogDir}/$(basename ${strategyConfigDir})
    ${dbg} cp ${logDir}/*.state ${targetStrategyConfigDir}
    # ... and append atStop extension to their name
    ${dbg} rename 'state' 'state.atStop' ${targetStrategyConfigDir}/*.state
    
    # Also copy the atStart state files
    ${dbg} cp ${logDir}/*.state.atStart ${targetStrategyConfigDir}   
fi

# ... copy the fix log files
${dbg} cp -r ${fixDir} ${historicalLogDir} || exit -1


###############################
# Copy the historicalLogDir to the NAS
###############################
if [[ ${USER} == arbyteprod ]]; then
    bkpDirOnNAS=${arbyteLiveBkpDir}/${date}/$(hostname --short)
    identityFile="${HOME}/.ssh/id_rsa"
    if [[ -f ${identityFile} ]]; then
	${dbg} ssh -i ${identityFile} ${arbyteNAS} "mkdir -p ${bkpDirOnNAS}" && \
	    ${dbg} rsync -azvh ${historicalLogDir} ${arbyteNAS}:${bkpDirOnNAS}
    fi
fi


###############################
# Copy files to the compliance shared dir
###############################
# ... the fix8 log files
if [[ -d ${complianceLogDir} ]]; then
   complianceLogDir=${complianceLogDir}/${date}/$(hostname --short)
   ${dbg} mkdir -p ${complianceLogDir}

   complianceNumberedLogDir=$(getNextNuberedDir ${complianceLogDir})
   echo complianceNumberedLogDir=${complianceNumberedLogDir}
   ${dbg} cp -r ${historicalLogDir}/fix8/fix_*.log* ${complianceNumberedLogDir}
   rename fix_ ${date}.fix_ ${complianceNumberedLogDir}/*

   shopt -s nullglob
   for s in ${sessions}; do
       txtFile=${historicalLogDir}/fix8/${s}.txt
       if [[ -f ${txtFile} ]]; then
	   targetFile=${date}.$(basename ${txtFile})
           ${dbg} cp ${txtFile} ${complianceNumberedLogDir}/${targetFile}
       fi

       # Eurex-ETI style log files
       datFile=${historicalLogDir}/fix8/${date}.${s}.dat
       if [[ -f ${datFile} ]]; then
	   targetFile=$(basename ${datFile})
	   cp ${datFile} ${complianceNumberedLogDir}/${targetFile}
       fi
   done
   shopt -u nullglob
fi

###############################
# Cleanup for the next day
###############################
# ... remove all fix log files
cleanupCeloxicaFiles ${date} ${fixDir}

handleRecoveryFiles ${datDir}
handleRecoveryFiles ${fixDir}
