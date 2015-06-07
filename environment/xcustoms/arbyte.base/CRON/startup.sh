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
resetBinarySequenceNumbers()
{
    local lExchange=${1}

    if [[ ! -f ${cfgDir}/${lExchange}_client.xml ]]; then
      return 0
    fi

    local lSenderTag=$(grep sender_comp_id ${cfgDir}/${lExchange}_client.xml | awk -F'=' '{print $2}' | sed 's/"//g')
    local lTargetTag=$(grep target_comp_id ${cfgDir}/${lExchange}_client.xml | awk -F'=' '{print $2}' | sed 's/"//g')

    if [[ -z ${lTargetTag} ]]; then
      echo "${lExchange}; "
      return 1
    fi

    local lFilePattern=${fixDir}/client.${lSenderTag}.${lTargetTag}
    seqedit -S 1 ${lFilePattern} > /dev/null
    seqedit -R 1 ${lFilePattern} > /dev/null
    return 0
}

#----------------------------------------------
resetTextSequenceNumbers()
{
    local lExchange=${1}
    local lSessionTag=$(grep "mkt=\"${lExchange}\"" ${binDir}/arbyte.xml |  awk -F' ' '{for(i = 1; i<NF; i++) print $i}' | grep session_id | awk -F'=' '{print $2}' | sed 's/"//g')

    echo lSessionTag=${lSessionTag}

    if [[ -z ${lSessionTag} ]]; then
      echo "${lExchange}; "
      return 1
    fi

    echo 1 > ${fixDir}/${lSessionTag}_send_seq.txt
    echo 1 > ${fixDir}/${lSessionTag}_recv_seq.txt
    return 0
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
else
    # Write the date of the last reset
    echo ${date} > ${lastResetFile}

    # ... at the startof the week on CME
    currentWeekNo=$(date +%V)
    lastResetWeekNo=$(date +%V -d ${lastResetDate})
    if [[ ${lastResetWeekNo} -ne ${currentWeekNo} ]]; then
        printf "\nNot necessary to resetting CME seq numbers for week %s\n\n" ${currentWeekNo}
        #failedExchanges=${failedExchanges}$(resetTextSequenceNumbers CME)
    else
        printf "\nCME seq numbers were already reset for week %s on %s.\n\n" ${currentWeekNo} ${lastResetDate}
    fi
    # ... daily on all other exchanges
    failedExchanges=${failedExchanges}$(resetBinarySequenceNumbers EUX)
    failedExchanges=${failedExchanges}$(resetBinarySequenceNumbers ICE)
    failedExchanges=${failedExchanges}$(resetBinarySequenceNumbers ICL)
    failedExchanges=${failedExchanges}$(resetBinarySequenceNumbers LIF)

    if [[ -n ${failedExchanges} ]]; then
	sendMail "Error!!! Failed to reset sequence numbers" "Failed to reset sequence numbers for exchange(s) ${failedExchanges}" ${CRISTIAN}
    fi
fi

# Restore any renamed recovery files
rename "_recover.csv.${date}" '_recover.csv' ${datDir}/*

