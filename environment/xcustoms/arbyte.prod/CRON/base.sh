#!/bin/bash


#----------------------------------
# Global variables
#----------------------------------
liveDir=${HOME}/live
binDir=${liveDir}/bin
logDir=${liveDir}/log
cfgDir=${liveDir}/cfg
datDir=${liveDir}/dat

cmeRecoverFile=${datDir}/cmearbp1_recover.csv

complianceLogDir=/mnt/prodlog.arbyte.share
if [[ $USER == "arbytetest" ]]; then
	complianceLogDir=${complianceLogDir}/test
fi

arbyteNAS=livebkp@10.199.10.104
arbyteLiveBkpBaseDir=/volume1/live.logs
arbyteLiveBkpDir=${arbyteNAS}:${arbyteLiveBkpBaseDir}

date=$(date +%Y%m%d)


#----------------------------------
# Functions
#----------------------------------


