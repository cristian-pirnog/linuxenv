#!/bin/bash

#_______________________________________________________________________________
# SUBFUNCTIONS
#_______________________


function prevBusDay
{
	dayOfWeek=`date +%w`
	if [ $dayOfWeek -eq 0 ] 
	then
		lookBack=2
	elif [ $dayOfWeek -eq 1 ] 
        then
                lookBack=3
	else
 		lookBack=1
	fi

	prevBusDay=$(date -d "$lookBack day ago" +'%Y%m%d')
	echo "$prevBusDay"
}

#________________________________________________________________________________

if [ $# -ne 2 -a $# -ne 3 ]
then
    echo "$0 mbbaDataDirOnDevServer dataStatusDirOnDevServer [optional: date]"
    exit 1
fi

mbbaDir=$1
statusDir=$2

reconBaseDir="/mnt/sandbox/reconciliation"

reconDate=$(prevBusDay)
if [ $# -eq 3 ]
then
	reconDate=$3
fi

reconDir=$reconBaseDir"/"$reconDate

scrOutputDir=$reconBaseDir"/"screenOutput
mkdir -p $scrOutputDir

#echo "RECON DIR: $reconDir, RECON DATE: $reconDate"

if [ ! -d $reconDir ] # i.e. the reconciliation directory does not exist yet, meaning we haven't run the reconciliation for this date yet
then
	#echo "NO RECON DIR YET; DIR $reconDir DOES NOT EXIST YET"
	
	# check whether dev server is reachable
	ssh jpoepjes@DARB-HAN-APP1 : > /dev/null 2>&1
	returnValue=$?
	if [ $returnValue -ne 0 ]
	then
		echo "Development server is not reachable (jpoepjes@DARB-HAN-APP1); exiting script!"
	fi

	dataStatusDate=$(date -d "$reconDate +1 day" +%Y%m%d)
	isDataThere=$(ssh -X jpoepjes@DARB-HAN-APP1 ls -ltra $statusDir | grep "missingData_$dataStatusDate"| awk 'BEGIN{dataIsThere=0}{if($5==0){dataIsThere=1}}END{print dataIsThere}')

	#echo "dataStatusDate: $dataStatusDate, IS DATA THERE: $isDataThere"
	
	if [ $isDataThere -eq 1 ]
	then
        	echo "Historical data (mbba-files) for $reconDate are available"
		
		# synchronize data
		nrMbbaFiles=$(ssh -X jpoepjes@DARB-HAN-APP1 find $mbbaDir -name "*.mbba" | wc -l)
		#echo "NR OF MBBA FILES: $nrMbbaFiles"
		echo "Rsyncing data from origin jpoepjes@DARB-HAN-APP1:$mbbaDir to /home/data/RONIN/MBBA"
		rsyncScript.sh jpoepjes@DARB-HAN-APP1:$mbbaDir /home/data/RONIN/MBBA mbba $nrMbbaFiles &>/dev/null

		# run reconciliation
		scrOutputFile=$scrOutputDir"/scr_reconciliation_"$reconDate".txt"
		echo "Running reconciliation for $reconDate"
		reconciliation.sh $reconDate 0 0 > $scrOutputFile
	else
        	echo "Historical data (mbba-files) for $reconDate are not yet available"
	fi
else
	echo "Reconciliation directory $reconDir already exists (remove first)!"
fi
