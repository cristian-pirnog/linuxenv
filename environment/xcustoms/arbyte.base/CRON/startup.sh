#!/bin/bash


# Script to be run from the runVPStratLauncher.sh, after the binary stops


#----------------------------------------------
printUsage()
{
    cat << %%USAGE%%
         Usage: $(basename ${0}) [-h]

    Description:
        Run the startup procedure, before we start the VPStratLauncher binary.

    Options:
       -h
       --help
             Print this help message and exit.

%%USAGE%%
}


#----------------------------------------------
resetSequenceNumbers()
{
    local lExchange=${1}

    if [[ ! -f ${cfgDir}/${lExchange}_client.xml ]]; then
      return 0
    fi

    local lSenderTag=$(grep sender_comp_id ${cfgDir}/${lExchange}_client.xml | awk -F'=' '{print $2}' | sed 's/"//g')
    local lTargetTag=$(grep target_comp_id ${cfgDir}/${lExchange}_client.xml | awk -F'=' '{print $2}' | sed 's/"//g')
    echo lTargetTag=$lTargetTag

    if [[ -z ${lTargetTag} ]]; then
      sendMail "Error!!! Failed to reset sequence numbers" "Failed to reset sequence numbers for exchange ${lExchange}" ${CRISTIAN}
      exit 1
    fi

    local lFilePattern=${fixDir}/client.${lSenderTag}.${lTargetTag}
    echo lFilePattern=${lFilePattern}
    seqedit -S 1 ${lFilePattern}
    seqedit -R 1 ${lFilePattern}
}

#----------------------------------
# Main script
#----------------------------------

ARGS=$(getopt -o h -l "help" -n "$(basename ${0})" -- "$@")

# If wrong arguments, print usage and exit
if [[ $? -ne 0 ]]; then
    printUsage
    exit 1;
fi

eval set -- "$ARGS"

## Parse options
while true; do
    case ${1} in
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


# If the binary still runs, exit
if [[ ${afterRun} -ne 1 ]]; then
    processId=$(findVPStratLauncherInstances)
    if [[ -n "${processId}" ]]; then 
        printf "Found binary running (process id: ${processId}). Aborting.\n"
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
# Reset FIX sequence numbers
###############################
lastResetFile=${fixDir}/last_reset.date
lastResetDate=$(cat ${lastResetFile})
if [[ ${date} == ${lastResetDate} ]]; then
    printf "Sequence numbers were already reseted today (${date}). Skipping reset.\n"
    exit 0
fi

# Write the date of the last reset
echo ${date} > ${lastResetFile}

# ... at the startof the week on CME
currentWeekNo=$(date +%V)
lastResetWeekNo=$(date +%V -d ${lastResetDate})
if [[ ${lastResetWeekNo} -ne ${currentWeekNo} ]]; then
    printf "\nResetting CME seq numbers for week %s\n\n" ${currentWeekNo}
    resetSequenceNumbers CME
else
    printf "\nCME seq numbers were already reset for week %s on %s.\n\n" ${currentWeekNo} ${lastResetDate}
fi
# ... daily on all other exchanges
resetSequenceNumbers EUX 
resetSequenceNumbers ICE
resetSequenceNumbers ICL
resetSequenceNumbers LIF

# Restore any renamed recovery files
rename "_recovery.csv.${date}" '_recovery.csv' ${datDir}/*

