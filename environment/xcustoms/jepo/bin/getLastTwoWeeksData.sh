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

# create file with yesterdays date
datesFile=$outputDir/datesTwoWeeks.tmp
startDate=$(date --date="13 days ago" +"%Y%m%d")
stopDate=$(date --date="2 days ago" +"%Y%m%d")
generateDates.sh $startDate $stopDate > $datesFile

createMBBAdata.sh $prodFile $datesFile $outputDir &>/dev/null
rm -f $datesFile

# Rename missingData.csv file to missingData_YYYYMMDD_hhmm.csv
newFileName="missingData_"$startDate"-"$stopDate".csv"
#echo $newFileName

if [ ! -f $outputDir/missingData.csv ]
then
	echo "$outputDir/missingData.csv NOT FOUND!"
	exit 1
fi

mv $outputDir/missingData.csv $outputDir/$newFileName
