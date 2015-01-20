#!/bin/bash

if [ $# -ne 2 ]
then
    echo "$0 startDate endDate"
    exit 1
fi

startD=$1
endD=$2

if [ $endD -le $startD ]
then
	echo "End date ($endD) has to be after start date ($startD)!"
	exit 1
fi

rm -f ./dates.txt

i=$(date --date="$startD" +%Y%m%d)

#echo -e "START DATE: $startD \t END DATE: $endD \t DATE: $i"

while [ $i -le  $endD ]
do
	weekDayNr=$(date --date="$i" +%u)
	#echo -e "DATE: $i \t WEEKDAY: $weekDayNr \t END DATE: $endD"
	
	if [ $weekDayNr -lt 6 ]
	then
		#echo "$i" >> ./dates.txt
		echo "$i"
	fi
	
	i=$(date --date="$i + 1 day" +%Y%m%d)
	#echo "NEW DATE: $i"
	#break
done
