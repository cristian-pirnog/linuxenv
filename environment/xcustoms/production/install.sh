#!/bin/bash

# Cron run times: script name HH MM
cronRunTimes='createBookConfigs.sh 20 30
deploySoftware 22 35
updateProductionMachine 23 30
checkForRunningBinariesInProduction.sh 23 30'

# The list of hosts where the user is deployed
hosts='baar
luzern
zurich'

for h in $hosts; do
    cp CRON/cron.tab.template CRON/cron.tab.${h}
done

while read -r line; do
    script=$(echo ${line} | awk '{print $1}')
    hour=$(echo ${line} | awk '{print $2}')
    minute=$(echo ${line} | awk '{print $3}')

    offset=0
    for h in $hosts; do
        time=$(date +'%M %H' --date="${hour}:${minute} ${offset} minutes")
        sed -i "/${script}/s/__MM_HH__/${time}/" CRON/cron.tab.${h}

        offset=$((offset + 10))
    done
done <<< "${cronRunTimes}"
