#!/bin/bash


baseScript=${HOME}/CRON/base.sh
if [[ ! -f ${baseScript} ]]; then
    printf "Could not find base script %s" ${baseScript}
    exit 1
fi


# Source the base script
source ${baseScript}


touch ${cmeRecoverFile}
