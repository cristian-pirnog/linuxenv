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
startDate=$(date --date="5 days ago" +"%Y%m%d")
stopDate=$(date --date="1 days ago" +"%Y%m%d")

outputFileName=$outputDir"/DataQualityAnalysis_"$startDate"-"$stopDate".txt"
#echo "$prodFile $startDate $stopDate $outputFileName"
optimizer.sh ronin master Release DataQuality $prodFile $startDate $stopDate $outputFileName > /dev/null 2>&1
