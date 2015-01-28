#!/bin/bash

# ___________________________________________________________________________________________________________

function createMBBA
{
	prodLoc=$1
	dateLoc=$2

	a=$(optimizer.sh ronin master Release printData $prodLoc $dateLoc f q useDB:1 &>/dev/null)

        fileExists2=$(find /home/$USER/scratch/cluster/MBBA/$prodLoc* -name "$dateLoc*.mbba" | awk -F '/' '{if(length($7)==(length("'$prodLoc'")+2)){print $7}}' | wc -l)
        if [ $fileExists2 -ge 1 ]
        then
        	#echo "NEW FILE FOUND: $prodLoc $dateLoc"
		fileName2=$(find /home/$USER/scratch/cluster/MBBA/$prodLoc* -name "$dateLoc*.mbba" | awk -F '/' '{if(length($7)==(length("'$prodLoc'")+2)){print $1"/"$2"/"$3"/"$4"/"$5"/"$6"/"$7"/"$8}}' | xargs ls -l | awk 'BEGIN{maxFsz=-1}{if($5>maxFsz){maxFsz=$5;file=$9}}END{print file}')
                fileSize2=$(ls -l $fileName2 | awk '{print $5}')

                if [ $fileSize2 -le 250 ]
                then
			aliasLoc=$(grep ",$prodLoc," /mnt/config/RONIN/products.csv | awk -F ',' '{print $3}')
			isHolidayLoc=$(grep ",$aliasLoc," /mnt/config/RONIN/holidays.csv | grep $dateLoc | grep -v "Missing data" | wc -l)
                        if [ $isHolidayLoc -ge 1 ]
                        then # SMALL FILE IN DB BECAUSE THERE IS A HOLIDAY FOR THIS PROD AND DATE; DON'T TRY TO FETCH THIS FILE
				#echo "NO DATA BECAUSE OF HOLIDAY: $prod $date"
                                holidayDays=$((holidayDays+1))
                                reasonLoc=$(cat /mnt/config/RONIN/holidays.csv | grep ",$aliasLoc," | grep $dateLoc | awk -F ',' '{print $3}')
                                echo "$dateLoc,$prodLoc,No data because of holiday,$reasonLoc" >> $outputDir/missingData.csv
                        else
                		#echo "NEW FILE TOO SMALL: $prodLoc $dateLoc"
                        	#echo "DATA MISSING: $prodLoc $dateLoc"
                        	noDataDays=$((noDataDays+1))
                        	echo "$dateLoc,$prodLoc,Missing data" >> $outputDir/missingData.csv
			fi
                else # FILE EXISTS AND IS FILE SIZE IS LARGE ENOUGH

			# also create sample file in this case
			optimizer.sh ronin master Release printData $prodLoc $dateLoc s q &>/dev/null

                	echo "NEW FILE FOUND AND LARGE ENOUGH: $prodLoc $dateLoc"
                        dataDays=$((dataDays+1))
                fi
        else
        	echo "FILE MISSING FOR $prodLoc ON DATE $dateLoc"
        fi
}

# ___________________________________________________________________________________________________________

if [ $# -ne 3 ]
then
    echo "$0 prodFile datesFile outputDir"
    exit 1
fi

prodFile=$1
datesFile=$2
outputDir=$3

if [ ! -f $prodFile ]
then
        echo "$prodFile NOT FOUND!"
        exit 1
fi

if [ ! -f $datesFile ]
then
	echo "$datesFile NOT FOUND!"
	exit 1
fi

if [ ! -d $outputDir ]
then
	echo "$outputDir NOT FOUND!"
fi
	
totalDays=0
dataDays=0
holidayDays=0
noDataDays=0

touch $outputDir/missingData.csv

while read prod        
do
    #echo "PROD: $prod"

    while read date
    do
        echo -e "PROD: $prod \t DATE: $date"
	totalDays=$((totalDays+1))

	fileExists=$(find /home/$USER/scratch/cluster/MBBA/$prod* -name "$date*.mbba" | awk -F '/' '{if(length($7)==(length("'$prod'")+2)){print $7}}' | wc -l)
	if [ $fileExists -ge 1 ]
        then
		#echo "FILE FOUND: $prod $date"
		fileName=$(find /home/$USER/scratch/cluster/MBBA/$prod* -name "$date*.mbba" | awk -F '/' '{if(length($7)==(length("'$prod'")+2)){print $1"/"$2"/"$3"/"$4"/"$5"/"$6"/"$7"/"$8}}' | xargs ls -l | awk 'BEGIN{maxFsz=-1}{if($5>maxFsz){maxFsz=$5;file=$9}}END{print file}')
		fileSize=$(ls -l $fileName | awk '{print $5}')

		alias=$(grep ",$prod," /mnt/config/RONIN/products.csv | awk -F ',' '{print $3}')
		isHoliday=$(grep ",$alias," /mnt/config/RONIN/holidays.csv | grep $date | grep -v "Missing data" | grep ",closed," | wc -l)
		if [ $isHoliday -ge 1 ]
                then # NO DATA IN DB BECAUSE PRODUCT IS CLOSED ON THIS DATE BECAUSE OF HOLIDAY
                	#echo "NO DATA BECAUSE OF HOLIDAY: $prod $date"
                        holidayDays=$((holidayDays+1))
                        #reason=$(cat /mnt/config/RONIN/holidays.csv | grep ",$alias," | grep $date | awk -F ',' '{print $3}')
                        #echo "$date,$prod,No data because of holiday,$reason" >> $outputDir/missingData.csv
		elif [ $fileSize -le 250 ]
                then
			rm -f $fileName
			createMBBA $prod $date
                else # FILE EXISTS AND IS FILE SIZE IS LARGE ENOUGH

			# Create sample file if not existing
			sampleFileExists=$(find /home/$USER/scratch/cluster/MBBA/$prod* -name "$date*.smpl" | awk -F '/' '{if(length($7)==(length("'$prod'")+2)){print $7}}' | wc -l)
			if [ $sampleFileExists -ne 1 ]
			then
				#echo -e "\t creating sample for $prod and $date"
                        	optimizer.sh ronin master Release printData $prod $date s q &>/dev/null
			fi

			#echo "FILE FOUND AND LARGE ENOUGH: $prod $date"
			dataDays=$((dataDays+1))
		fi
        else
		#echo "FILE NOT FOUND: $prod $date"
		createMBBA $prod $date
        fi
	#break
    done <$datesFile
    #break
done <$prodFile

echo "$totalDays $dataDays $noDataDays $holidayDays" | awk '{print "TOTAL DAYS: "$1, "DAYS WITH DATA: "$2, "DAYS WITHOUT DATA: "$3, "NO DATA HOLIDAY: "$4, "PERCENTAGE COMPLETED: "($1-$3)/$1}'
