#!/bin/bash

if [ $# -ne 2 ]
then
    echo "$0 prodFile outputDir"
    exit 1
fi

prodFile=$1
outputDir=$2

if [ ! -f $prodFile ]
then
        echo "$prodFile NOT FOUND!"
        exit 1
fi

if [ ! -d $outputDir ]
then
        echo "$outputDir NOT FOUND!"
fi

YYYYMMDD=$(date +"%Y%m%d")
YYYYMMDD_hhmm=$(date +"%Y%m%d_%H%M")

didRunForDay=$(ls $outputDir | grep missingData_$YYYYMMDD | wc -l)
#echo "didRunForDay = $didRunForDay"
if [ $didRunForDay -ge 1 ]
then
	latestMissingDataFile=$(ls $outputDir | grep missingData_$YYYYMMDD | tail -1)
	isDataMissing=$(wc -l $latestMissingDataFile | awk '{print $1}')
	#echo "latestMissingDataFile= $latestMissingDataFile , isDataMissing= $isDataMissing"
	if [ $isDataMissing -eq 0 ]
	then
		echo "All data for $YYYYMMDD is there; finished"
		exit 1
	fi
fi

# create file with yesterdays date
datesFile=$outputDir/date.txt
date --date="1 days ago" +"%Y%m%d" > $datesFile

createMBBAdata.sh $prodFile $datesFile $outputDir &>/dev/null
rm -f $datesFile

# remove old missingData_YYYYMMDD_hhmm.csv files
oldFilesNames="missingData_"$YYYYMMDD"_*.csv"
rm -f $outputDir/$oldFilesNames

# Rename missingData.csv file to missingData_YYYYMMDD_hhmm.csv
newFileName="missingData_"$YYYYMMDD_hhmm".csv"
#echo $newFileName

if [ ! -f $outputDir/missingData.csv ]
then
	echo "$outputDir/missingData.csv NOT FOUND!"
	exit 1
fi

mv $outputDir/missingData.csv $outputDir/$newFileName
