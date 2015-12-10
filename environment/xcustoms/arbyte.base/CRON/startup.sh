#!/bin/bash


# Script to be run from the runVPStratLauncher.sh, before the binary starts


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


baseScript=${HOME}/CRON/base.sh
if [[ ! -f ${baseScript} ]]; then
    printf "Could not find base script %s" ${baseScript}
    exit 1
fi

# Source the base script
source ${baseScript}
source ${HOME}/CRON/email.sh

# If the binary still runs, exit
if [[ ${afterRun} -ne 1 ]]; then
    processId=$(findVPStratLauncherInstances)

    if [[ -n "${processId}" ]]; then 
	exitWithEMail "Binary not started" "Found binary running (process id: ${processId})" ${arbyteDudes} ${outputFile}
    fi
fi


# When debuggin script, we echo all (most) commands, instead of executing them
dbg=echo
dbg=''

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

    # ... daily on all other exchanges
    failedExchanges=${failedExchanges}$(resetBinarySequenceNumbers EUX)
    failedExchanges=${failedExchanges}$(resetBinarySequenceNumbers ICE)
    failedExchanges=${failedExchanges}$(resetBinarySequenceNumbers ICL)
    failedExchanges=${failedExchanges}$(resetBinarySequenceNumbers LIF)

    if [[ -n ${failedExchanges} ]]; then
	${dbg} sendMail "Error!!! Failed to reset sequence numbers" "Failed to reset sequence numbers for exchange(s) ${failedExchanges}" ${CRISTIAN}
    fi
fi

# Restore any renamed recovery file
${dbg} rename "_recover.csv.${date}" '_recover.csv' ${datDir}/*
${dbg} rename "_recover.csv.${date}" '_recover.csv' ${fixDir}/*

# Process the state files...
${dbg} rm ${logDir}/*.state.atStart
for f in $(ls ${logDir} | grep .cfg.state); do 
    configFile=$HOME/live/configs/$(echo $f | sed 's/.state//'); 
 
    # ... removing those that don't have a correspondent config file
    if [[ ! -f ${configFile} ]]; then 
        ${dbg} rm ${logDir}/${f}
    # ... and copying those that do have one with extension .atStart
    else
        ${dbg} cp ${logDir}/${f} ${logDir}/${f}.atStart
    fi 
done


