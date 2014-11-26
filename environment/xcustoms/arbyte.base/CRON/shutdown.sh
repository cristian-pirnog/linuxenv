#!/bin/bash

# Script to be run by the cron job at the end of trading

#----------------------------------------------
getHistoricalLogDir()
{
    local histLogDir=""
    for i in `seq 1 50`; do
	local dir=${date}/${i}
        histLogDir=${liveDir}/log/${dir}
	if [[ ! -d ${histLogDir} ]]; then
            mkdir -p ${histLogDir}
	    
            # Make a symlink to the latest log dir
            latestLog=${histLogDir}/latest
            if [[ -h ${latestLog} ]]; then rm ${latestLog}; fi
            ln -s ${dir} ${latestLog}
            break
	fi
    done

    echo ${histLogDir}
}

#----------------------------------------------
resetSequenceNumbers()
{
    local lExchange=${1}

    if [[ ! -f ${cfgDir}/${lExchange}_client.xml ]]; then
      return 0
    fi

    local lExchangeTag=$(grep target_comp_id ${cfgDir}/${lExchange}_client.xml | awk -F'=' '{print $2}' | sed 's/"//g') 

    if [[ -z ${lExchangeTag} ]]; then
      sendMail "Error!!! Failed to reset sequence numbers" "Failed to reset sequence numbers for exchange ${lExchange}" ${CRISTIAN}
      exit 1
    fi

    local lFilePattern=${fixDir}/'client.*.'${lExchangeTag}
    seqedit -S 1 ${lFilePattern}
    seqedit -R 1 ${lFilePattern}
}

#----------------------------------
# Main script
#----------------------------------

# If the binary still runs, exit
processId=$(findVPStratLauncherInstances)
if [[ -n "${processId}" ]]; then 
    printf "Binary still running (process id: ${processId}). Aborting."
    exit 1
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
bkpDirOnNAS=${arbyteLiveBkpDir}/${date}/$(hostname --short)
ssh ${arbyteNAS} "mkdir -p ${bkpDirOnNAS}"
rsync -azvh ${historicalLogDir} ${arbyteNAS}:${bkpDirOnNAS}


###############################
# Copy files to the compliance shared dir
###############################
# ... the fix8 log files
complianceLogDir=${complianceLogDir}/${date}/$(hostname --short)
mkdir -p ${complianceLogDir}

cp -r ${historicalLogDir}/fix8/* ${complianceLogDir}


###############################
# Clean-up for the next day
###############################
# ... remove all fix log files
rm -f ${fixDir}/*.log.*
rm -f ${datDir}/*

# ... reset sequence numbers
#     ... daily on EUX
resetSequenceNumbers Eurex 
resetSequenceNumbers ICE
#     ... at the end of the week on CME
if [[ $(date +%w) -eq 5 ]]; then
    resetSequenceNumbers CME
fi


###############################
# Update environment from then nas
###############################
# ... libraries
# rsync -azvh ${arbyteNAS}:${libraryDirOnNAS}/ ${libraryDir}



