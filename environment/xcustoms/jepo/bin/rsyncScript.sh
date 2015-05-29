#!/bin/bash

# ___________________________________________________________________________________________________________

function nrOfFilesFound
{
	local dirName1=$1
	local extension1=$2

	find $dirName1 -name "*.$extension1" | xargs ls -l | awk '{if($5>100){print $9}}' | wc -l
}

#__________________________________________________

# EXAMPLE COMMAND: 
# ./rsyncScript.sh cluster:/home/co-vite4/scratch/cluster/results/intraday /mnt/optimization_results/rsyncTestingTmpDir opt 3905

if [ $# -ne 4 ]
then
    echo "$0 fromDir toDir extension nrOfFiles"
    exit 1
fi

startRunTime=$(date +%s)

fromDir=$1
toDir=$2
extension=$3
nrOfFiles=$4

filesFound=0
while [ $filesFound -lt $nrOfFiles ]
do
	/usr/bin/rsync -avz -e "ssh -q -i /home/jepo/.ssh/id_rsa_cron" --timeout=10 --bwlimit=20000 $fromDir/* $toDir
	filesFound=$(nrOfFilesFound $toDir $extension)
	echo -e "FILES WITH EXTENSION $extension FOUND IN DIR $toDir IS $filesFound \t NR OF FILES TO BE FOUND: $nrOfFiles"
done

runTime=$(( $(date +%s) - $startRunTime ))
echo "TOTAL TIME SPEND FOR RSYNC IS $runTime"
