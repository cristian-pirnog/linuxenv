#!/bin/bash

# Script to be run by the cron job at the end of trading

#----------------------------------------------
getHistoricalLogDir()
{
    local histLogDir=""
    for i in `seq 1 50`; do
	local dir=${date}/${i}
        histLogDir=${logDir}/${dir}
	if [[ ! -d ${histLogDir} ]]; then
            mkdir -p ${histLogDir}
	    
            # Make a symlink to the latest log dir
            latestLog=${logDir}/latest
            if [[ -h ${latestLog} ]]; then rm ${latestLog}; fi
            ln -s ${dir} ${latestLog}
            break
	fi
    done

    echo ${histLogDir}
}



#----------------------------------
# Main script
#----------------------------------

# Kill the binary
killVPStratLauncher

baseScript=${HOME}/CRON/base.sh
if [[ ! -f ${baseScript} ]]; then
    printf "Could not find base script %s" ${baseScript}
    exit 1
fi

# Source the base script
source ${baseScript}


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
cp -r ${logDir}/fix8 ${historicalLogDir} || exit -1

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
rm -f ${logDir}/fix8/*.log.*
rm -f ${datDir}/*


###############################
# Update environment from then nas
###############################
# ... libraries
# rsync -azvh ${arbyteNAS}:${libraryDirOnNAS}/ ${libraryDir}



