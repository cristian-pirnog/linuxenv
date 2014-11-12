#!/bin/bash


#----------------------------------
# Global variables
#----------------------------------
liveDir=${HOME}/live
binDir=${liveDir}/bin
logDir=${liveDir}/log
cfgDir=${liveDir}/cfg
datDir=${liveDir}/dat
libraryDir=/mnt/data/deploy/master/Release/lib/

cmeRecoverFile=${datDir}/cmearbp1_recover.csv

complianceLogDir=/mnt/prodlog.arbyte.share
if [[ $USER == "arbytetest" ]]; then
	complianceLogDir=${complianceLogDir}/test
fi

# Directories on ArByte's NAS
arbyteNAS=livebkp@10.199.10.104
arbyteLiveBkpDir=/volume1/live.logs
libraryDirOnNAS=/volume1/production.libs

date=$(date +%Y%m%d)


#----------------------------------
# Functions
#----------------------------------


