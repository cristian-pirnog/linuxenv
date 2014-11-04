#!/bin/bash

# Script to be run by the cron job at the end of trading


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

historicalLogDir=$(getHistoricalLogDir)

# Move the cme recover file
if [[ -f ${cmeRecoverFile} ]]; then
    mv ${cmeRecoverFile} ${historicalLogDir}
else
    printf "Failed to move the file %s\n" ${cmeRecoverFile}
fi

# Move the log files
mv ${binDir}/*.log ${historicalLogDir}
mv ${logDir}/*.log ${historicalLogDir}


ftpServer='64.95.232.100'

# Archive and copy the historicalLogDir to the NAS and to Ronin's ftp accoun
archive ${historicalLogDir}
echo "\$ uploadTrail ${historicalLogDir}.tar.gz ${HOSTNAME}" | ftp -v ${ftpServer}
scp -C -r ${historicalLogDir} crpi@10.199.10.104:/volume1/live_trading/log/
