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
datesFile=$outputDir/date.txt
date --date="1 days ago" +"%Y%m%d" > $outputDir/$datesFile

#createMBBAdata.sh $prodFile $outputDir/$datesFile $outputDir &>/dev/null
rm -f $outputDir/$datesFile

# Rename missingData.csv file to missingData_YYYYMMDD_hhmm.csv
YYYYMMDD_hhmm=$(date +"%Y%m%d_%H%M")
newFileName="missingData_"$YYYYMMDD_hhmm".csv"
#echo $newFileName

touch $newFileName
exit 1

if [ ! -f $outputDir/missingData.csv ]
then
	echo "$outputDir/missingData.csv NOT FOUND!"
	exit 1
fi

mv $outputDir/missingData.csv $outputDir/$newFileName
