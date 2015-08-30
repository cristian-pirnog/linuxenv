#!/bin/bash

#_______________________________________________________________________________
# SUBFUNCTIONS
#_______________________

function getMbbaTime
{
	local fileName1=$1
	local prodLoc=$2
	local index=$3
	local inputDate=$4
	local serverLoc=$5

	foundFirstUpdateLine=$(grep "1st update" $fileName1 | wc -l)
	timeStampMbba=0
	if [ $foundFirstUpdateLine -ne 1 ]
	then
		timeStampFirstTick=$(grep "Received first tick" $fileName1 | awk -F ',' '{print $3}')
		timeStampFirstCross=$(grep "stage3," $fileName1 | head -2 | tail -1 | awk -F ',' '{print $2}')
		sameTimeStamp=$(echo $timeStampFirstTick $timeStampFirstCross | awk '{if($1==$2){print 1}else{print 0}}')
		
		timeStampMbba=$timeStampFirstTick
		if [ $sameTimeStamp -eq 1 ]
		then
			bidSz=$(grep "stage3," $fileName1 | head -2 | tail -1 | awk -F ',' '{print $6}')
			bidPr=$(grep "stage3," $fileName1 | head -2 | tail -1 | awk -F ',' '{print $7}')
			askPr=$(grep "stage3," $fileName1 | head -2 | tail -1 | awk -F ',' '{print $8}')
			askSz=$(grep "stage3," $fileName1 | head -2 | tail -1 | awk -F ',' '{print $9}')

			if [ $index -eq 2 ]
                	then
				bidSz=$(grep "stage3," $fileName1 | head -2 | tail -1 | awk -F ',' '{print $10}')
                        	bidPr=$(grep "stage3," $fileName1 | head -2 | tail -1 | awk -F ',' '{print $11}')
                        	askPr=$(grep "stage3," $fileName1 | head -2 | tail -1 | awk -F ',' '{print $12}')
                        	askSz=$(grep "stage3," $fileName1 | head -2 | tail -1 | awk -F ',' '{print $13}')
			fi
			timeStampMbba=$(optimizer.sh ronin master Release findTick $prodLoc $timeStampFirstCross $bidSz $bidPr $askPr $askSz $serverLoc 1 | grep TIMESTAMP | awk '{print $2}')
		fi
	else
		timeStamp=$(grep "1st update" $fileName1 | awk -F ',' '{print $2}')
        	bidSize=$(grep "1st update" $fileName1 | awk -F ',' '{print $3}')
	        bidPrice=$(grep "1st update" $fileName1 | awk -F ',' '{print $4}')
	        askPrice=$(grep "1st update" $fileName1 | awk -F ',' '{print $5}')
	        askSize=$(grep "1st update" $fileName1 | awk -F ',' '{print $6}')
	
		#echo "TS: $timeStamp , bSz: $bidSize , bPr: $bidPrice , aPr: $askPrice , aSz: $askSize"
	
		# Overwrite when you want to have top of book for 2nd product
		if [ $index -eq 2 ]
		then
			timeStamp=$(grep "1st update" $fileName1 | awk -F ',' '{print $2}')
	        	bidSize=$(grep "1st update" $fileName1 | awk -F ',' '{print $7}')
	        	bidPrice=$(grep "1st update" $fileName1 | awk -F ',' '{print $8}')
	        	askPrice=$(grep "1st update" $fileName1 | awk -F ',' '{print $9}')
	        	askSize=$(grep "1st update" $fileName1 | awk -F ',' '{print $10}')
		fi
	
		dateFromTs=$(echo $timeStamp | awk '{print substr($1,1,8)}')
		#echo "dateFromTs: $dateFromTs"
		if [ $dateFromTs -ne $inputDate ]
		then
			#echo "Timestamp found for 1st update has different date than date you're analyzing (TS: $timeStamp, dateTs: $dateFromTs, input date: $inputDate)"
			timeStamp=$(grep "Received first tick" $fileName1 | grep -v $timeStamp | tail -1 | awk -F ',' '{print $3}')
			#echo "Adapted timestamp: $timeStamp"
		fi
		
	
		#echo "TS: $timeStamp, BSZ: $bidSize, BP: $bidPrice, AP: $askPrice, ASZ: $askSize"
		#echo "COMMAND: optimizer.sh ronin master Release findTick $prodLoc $timeStamp $bidSize $bidPrice $askPrice $askSize 1 | grep TIMESTAMP | awk '{print $2}'"
	
		# Printing the timestamp that is closest to the one from the production log file
	        timeStampMbba=$(optimizer.sh ronin master Release findTick $prodLoc $timeStamp $bidSize $bidPrice $askPrice $askSize $serverLoc 1 | grep TIMESTAMP | awk '{print $2}')
	fi
	
	echo "$timeStampMbba"
}





#________________________________________________________________________________

if [ $# -ne 3 ]
then
    echo "$0 date orderLogTimeShift skipSim"
    exit 1
fi

date=$1
timeShift=$2
skipSim=$3

if [ $timeShift -ne -1 -a $timeShift -ne 0 -a $timeShift -ne 1 ]
then
	echo "For now, I only allow to shift the start and end time with -1, 0 or 1 hour. Current input value: $timeShift!"
	exit 1
fi

# skipSim=1 means that all steps that require historical data are skipped (useful when historical data is not there yet)
if [ $skipSim -ne 0 -a $skipSim -ne 1 ]
then
	echo "Variable skipSim can only have value 0 or 1 (current input value: $skipSim)!"
	exit 1
fi

baseDir="/mnt/live.logs"
if [ ! -d $baseDir/$date ]
then
	echo "$baseDir/$date DOES NOT EXIST!"
	exit 1
fi

baseSimDir="/mnt/reconciliation"
if [ -d $baseSimDir/$date ]
then
	echo "Reconciliation directory for $date already exists ($baseSimDir/$date); remove first!"
	exit 1
fi
mkdir -p $baseSimDir/$date

summaryFileName="OrderLogSummary_"$date".txt"
rm -f $baseSimDir/$date/$summaryFileName

echo "DATE TRADED ID START STOP SIMLOC PNLUSD FEESUSD PNLLOC FEESLOC AVGRTT MEDRTT MINRTT MAXRTT NRORD ORDVOL NRTRD TRDVOL HITRT" > $baseSimDir/$date/$summaryFileName

summFileNameSim="SimPnls_"$date".txt"
rm -f $summFileNameSim

if [ $skipSim -eq 0 ]
then
	echo "DATE TRAD_ID TRAD_PROD ZPNL MHPNL TOTPNL 1STEQ DIFFCROSS TOTCROSS HITRAT" > $baseSimDir/$date/$summFileNameSim
fi

echo ""

for i in $(ls -d $baseDir/$date/*)
do
	#echo "DIR: $i"

	FILES=$(find $i -name "*.log" | xargs grep stage3 | grep -v "stage3,TimeStamp,TriggeredProd" | awk -F '/|:' '{print $7}' | grep $date | sort -u)
	#echo $FILES

	for j in $FILES
	do
		#echo "FILE: $j"

		nrOfFiles=$(find $i -name $j | wc -l)
		#echo "NR OF FILES FOUND: $nrOfFiles"

		fileName=""
		if [ $nrOfFiles -eq 0 ]
        	then
                	echo "FILE NOT FOUND: $i $j!"
                	exit 1
        	elif [ $nrOfFiles -gt 1 ]
        	then
			nrOfFiles2=$(find $i -name $j | xargs grep stage3 | grep -v "stage3,TimeStamp,TriggeredProd" | awk -F ':' '{print $1}' | sort -u | wc -l)
			#echo "NR OF FILES FOUND2: $nrOfFiles2"
			if [ $nrOfFiles2 -gt 1 ]
			then
				fileName=$(find $i -name $j | xargs grep stage3 | grep -v "stage3,TimeStamp,TriggeredProd" | awk -F ':' '{print $1}' | sort -u | tail -1)
				#echo "FOUND MULTIPLE $j FILES IN $i (ONLY USING LAST ONE: $fileName)!"
			else
				fileName=$(find $i -name $j | xargs grep stage3 | grep -v "stage3,TimeStamp,TriggeredProd" | awk -F ':' '{print $1}' | sort -u)
			fi
        	else
			fileName=$(find $i -name $j | tail -1)
		fi

		directory=$(echo $fileName | awk -F '/' '{print "/"$2"/"$3"/"$4"/"$5"/"$6}')
		nameTmp=$(echo $fileName | awk -F '/' '{print $7}')

		nameTmp=$(echo $nameTmp | sed "s/-spread//g")
		#echo "NEW NAME TMP: $nameTmp"

		prod1=$(echo $nameTmp | awk -F '_|-' '{print $3}')
		prod2=$(echo $nameTmp | awk -F '_|-' '{print $4}')
		startT=$(echo $nameTmp | awk -F '_|-' '{print substr($5,2,6)}')
		stopT=$(echo $nameTmp | awk -F '_|-' '{print substr($6,2,6)}')
		servLoc=$(echo $nameTmp | awk -F '_|-' '{print $7}')
		gridId=$(echo $nameTmp | awk -F '_|-' '{print substr($8,1,length($8)-4)}')

		if [ "$gridId" == "" ]
		then
			servLoc=$(echo $prod1 | awk '{print substr($1,1,3)}')
			gridId=$(echo $nameTmp | awk -F '_|-' '{print substr($7,1,length($7)-4)}')
		fi
	
		#echo "$prod1 $prod2 $startT $stopT $servLoc $gridId"	
		cfgFile=$(ls $directory/configs | grep $prod1 | grep $prod2 | grep $startT | grep $stopT | grep $servLoc | grep $gridId | grep -v state)
		isSpread=$(optimizer.sh ronin master Release translate $directory/configs/$cfgFile | grep IsSingleLeg | awk '{if($2==1){print 0}else{print 1}}')
		execType=$(optimizer.sh ronin master Release translate $directory/configs/$cfgFile | grep OrderType | awk '{print $2}')

		baseName=$prod1"_"$prod2"_"$startT"_"$stopT"_"$servLoc"_"$isSpread"_1_"$gridId

		echo "Analyzing date $date and slot $baseName"

                # Making a new directory to run simulations in
                mkdir -p $baseSimDir/$date/$baseName
                cd $baseSimDir/$date/$baseName

		echo -e "\tanalyzing production order log files"
                ORDER_LOG_FILES=$(ls $directory | grep "_Orders.log" | grep $prod1 | grep $prod2 | grep $startT | grep $stopT | grep $servLoc | grep $gridId | grep $date | sort)
		slotTraded=0
                for k in $ORDER_LOG_FILES
                do
                        #echo -e "\tORDER LOG FILE: $k"
                        orderLogFileTmp=$(echo $k | sed "s/-spread//g")
                        tradedProd=$(echo $orderLogFileTmp | awk -F '_|-' '{if($9=="Orders.log"){print $8}else{print $9}}')
                        newFileName="OrderLog_"$baseName"_"$tradedProd"_"$date".log"
                        #echo "$baseName $tradedProd $date $newFileName"
                        cp $directory/$k ./$newFileName

                        nrOfLinesOrderLog=$(grep -v "No orders to log" $newFileName | wc -l)
                        if [ $nrOfLinesOrderLog -lt 2 ]
                        then
                                #echo -e "\t\tignoring $newFileName ($tradedProd not traded; order log file empty)"
                                continue
                        else
				nrOfExecutionsOrderLog=$(grep OrderExecution $newFileName | wc -l)
				if [ $nrOfExecutionsOrderLog -eq 0 ]
				then
					#echo -e "\t\tignoring $newFileName ($tradedProd not traded; no executions found for this product)"
					continue
				fi
			fi

                        #echo -e "\t\tconstructing order log summary for $newFileName and traded product $tradedProd"
			summFileName2=$(optimizer.sh ronin master Release OrderLogParser $newFileName $timeShift | grep "Saving order log statistics to file" | awk '{print $7}')
                        tail -1 $summFileName2 >> $baseSimDir/$date/$summaryFileName
			slotTraded=1
                done

		if [ $skipSim -eq 1 ]
		then
			echo -e "\tskipping all steps that require historical data"
			continue
		fi

		if [ $slotTraded -eq 0 ]
                then
                        echo -e "\t\tSlot $baseName did not trade in production; skipping simulation for this slot"
                        continue
                fi

		stage3ProdFile="Crossings_prod_"$nameTmp
		strToGrep="stage3,"$date"T"
		grep $strToGrep $fileName | sed "s/,/ /g" | awk '{print substr($2,1,17), $4, $5, $7, $8, $11, $12}' > ./$stage3ProdFile

		#echo "PRODS: $prod1 $prod2 $fileName $date $servLoc"
		#echo -e "\tdetermining start time for simulation"
		timeStamp1=$(getMbbaTime $fileName $prod1 1 $date $servLoc)
		timeStamp2=$(getMbbaTime $fileName $prod2 2 $date $servLoc)

		#echo "TS1: $timeStamp1, TS2: $timeStamp2"
		#exit 1

		latestTimeStampMbba=0
	        if [ "$timeStamp1" == "-" -o "$timeStamp2" == "-" ]
        	then
                	echo -e "\tTIMESTAMP NOT FOUND FOR ONE OF THE PRODS (TS1: $timeStamp1, TS2: $timeStamp2)"
			latestTimeStampMbba=$timeStamp1
			if [ "$timeStamp1" == "-" ]
			then
				latestTimeStampMbba=$timeStamp2
			fi
        	else
			latestTimeStampMbba=$(echo $timeStamp1 $timeStamp2 | awk '{ts1=substr($1,10,99);ts2=substr($2,10,99);if(ts1>ts2){print ts1}else{print ts2}}')
		fi
		#echo "TS USED IN CFG FILE: $latestTimeStampMbba"

		# Find the config corresponding to the log file
		if [ ! -d $directory/configs ]
		then
			echo "$directory DOES NOT HAVE A CONFIGS DIRECTORY!"
			exit 1
		fi

		nrOfCfgFiles=$(ls $directory/configs | grep $prod1 | grep $prod2 | grep $startT | grep $stopT | grep $servLoc | grep $gridId | grep -v state | wc -l)
		if [ $nrOfCfgFiles -eq 0 ]
		then
			echo "NO CONFIG FILES FOUND FOR LOG FILE $fileName IN DIRECTORY $directory/configs!"
			continue
		elif [ $nrOfCfgFiles -ge 2 ]
		then
			echo "MULTIPLE CONFIG FILES FOUND FOR LOG FILE $fileName IN DIRECTORY $directory/configs (NR OF CFG FILES FOUND: $nrOfCfgFiles)!"
                        continue
		fi

		# Edit the config file
		newCfgFileName=$baseName".cfg"
		#echo "NEW CFG FILE: $newCfgFileName"
		#echo -e "\tchanging start time of config"
		#echo "$directory/configs/$cfgFile"
		cp $directory/configs/$cfgFile $newCfgFileName
		optimizer.sh ronin master Release edit $newCfgFileName StartTime $latestTimeStampMbba &>/dev/null

		# Check if there is a state file & run a simulation
		stateFileExists=$(ls $directory/configs | grep $prod1 | grep $prod2 | grep $startT | grep $stopT | grep $servLoc | grep $gridId | grep state.atStart | wc -l)
		stateFileHashError=$(grep "error,Hash ID of current OPTIMAL file not equal to loaded hash ID" $fileName | wc -l)
		#echo "BLA: $fileName $stateFileHashError"
		if [ $stateFileExists -eq 1 -a $stateFileHashError -eq 0 ]
		then
			stateFileOrg=$(ls $directory/configs | grep $prod1 | grep $prod2 | grep $startT | grep $stopT | grep $servLoc | grep $gridId | grep state.atStart)
			stateFileNew=$newCfgFileName".state"
			cp $directory/configs/$stateFileOrg $stateFileNew
			echo -e "\trunning single simulation with server location $servLoc and statefile $stateFileNew"
			optimizer.sh ronin master Release simulate $newCfgFileName $date $date serverLocation:$servLoc logTrades:1 logInternals:1 execution:$execType logExecution:1 loadStatefile:1 > screen.txt
		elif [ $stateFileExists -eq 0 -o $stateFileHashError -eq 1 ]
		then
			echo -e "\trunning single simulation with server location $servLoc (using no stateFile)"
			optimizer.sh ronin master Release simulate $newCfgFileName $date $date serverLocation:$servLoc logTrades:1 logInternals:1 execution:$execType logExecution:1 > screen.txt
		else
			echo "More than 1 stateFile found or more than 1 hast error found (nr state files: $stateFileExists, nr hash errors: $stateFileHashError)!"
			exit 1
		fi
		
		# Calculating hitratio's in simulation
		fileTmp=$(ls | grep _Trades_ | grep $prod1)
		#echo $fileTmp
		hitRatio1=$(awk -F ',' 'BEGIN{tradVol=0;ordVol=0}{if( ($1=="xO" && $6==0) || ($1==" O" && $6==0) ){if($4>0){ordVol+=$4}else{ordVol-=$4}};if($1==" T" && $6==0){if($4>0){tradVol+=$4}else{tradVol-=$4}}}END{hr=0;if(ordVol>0){hr=tradVol/ordVol};print hr}' $fileTmp)
		fileTmp=$(ls | grep _Trades_ | grep $prod2)
		hitRatio2=$(awk -F ',' 'BEGIN{tradVol=0;ordVol=0}{if( ($1=="xO" && $6==0) || ($1==" O" && $6==0) ){if($4>0){ordVol+=$4}else{ordVol-=$4}};if($1==" T" && $6==0){if($4>0){tradVol+=$4}else{tradVol-=$4}}}END{hr=0;if(ordVol>0){hr=tradVol/ordVol};print hr}' $fileTmp)
		#echo "HR1: $hitRatio1, HR2: $hitRatio2"
		
		fileNameSim=$(ls | grep _Internals.log)
		stage3SimFile="Crossings_sim_"$nameTmp
                grep $strToGrep $fileNameSim | sed "s/,/ /g" | awk '{print substr($2,1,17), $4, $5, $7, $8, $11, $12}' > ./$stage3SimFile

		# Check that 1st update is the same; otherwise crossings will never be the same
		#echo -e "\tcomparing 1st update lines between production and simulation"
		firstUpdateProdLine=$(grep "1st update" $fileName | awk -F ',' '{print $1, $4, $5, $8, $9, $11}')
		if [ "$firstUpdateProdLine" == "" ]
		then
			firstUpdateProdLine=$(grep "Received first tick" $fileName | tail -1 | awk -F ',' '{print $1, $2, substr($3,1,17)}')
			firstUpdateSimLine=$(grep "Received first tick" $fileNameSim | tail -1 | awk -F ',' '{print $1, $2, substr($3,1,17)}')
		else
			firstUpdateSimLine=$(grep "1st update" $fileNameSim | awk -F ',' '{print $1, $4, $5, $8, $9, $11}')
		fi

		firstUpdatesSame=0
		#echo "1st UPDATE: $fileName $fileNameSim $firstUpdateProdLine $firstUpdateSimLine"
		if [ "$firstUpdateProdLine" != "$firstUpdateSimLine" ]
		then
			echo -e "\t\t1st UPDATES ARE NOT THE SAME (PROD: $firstUpdateProdLine, SIM: $firstUpdateSimLine)"
			#continue
		else
			echo -e "\t\t1st updates are the same"
			firstUpdatesSame=1
		fi

		# first check nr of lines of crossings files
		#echo -e "\tcomparing crossings between production and simulation"
		nrLinesCrossProd=$(wc -l $stage3ProdFile | awk '{print $1}')
		nrLinesCrossSim=$(wc -l $stage3SimFile | awk '{print $1}')
		if [ $firstUpdatesSame -eq 1 -a $nrLinesCrossProd -ne $nrLinesCrossSim ]
		then
			awk '{if($2!="Liquidation"){print $1, $3, $4, $5, $6, $7, $8}}' $stage3SimFile > ./tmpCrossSim.txt
			mv tmpCrossSim.txt $stage3SimFile

			awk '{if($2!="Liquidation"){print $1, $3, $4, $5, $6, $7, $8}}' $stage3ProdFile > ./tmpCrossProd.txt
                        mv tmpCrossProd.txt $stage3ProdFile

			nrLinesCrossSim=$(wc -l $stage3SimFile | awk '{print $1}')
			nrLinesCrossProd=$(wc -l $stage3ProdFile | awk '{print $1}')
			nrOfLinesDiffBefore=$(diff $stage3ProdFile $stage3SimFile | grep "<" | wc -l)

 			#echo "NROFCROSS: $nrLinesCrossSim $nrLinesCrossProd"
			if [ $nrLinesCrossProd -gt $nrLinesCrossSim ]
			then
				tmpNr=$((nrLinesCrossSim + 1))
                                cat $stage3ProdFile | awk -v nrL=${tmpNr} 'NR<nrL{print $0}' > ./tmpCrossProd.txt
				nrOfLinesDiffAfter=$(diff ./tmpCrossProd.txt $stage3SimFile | grep "<" | wc -l)

				if [ $nrOfLinesDiffBefore -gt $nrOfLinesDiffAfter ]
				then
					echo -e "\t\tMore crossings in production than in simulation; removing crossings in production"
					mv tmpCrossProd.txt $stage3ProdFile
				fi
				rm -f tmpCrossProd.txt
			elif [ $nrLinesCrossSim -gt $nrLinesCrossProd ]
			then
				tmpNr=$((nrLinesCrossProd + 1))
                                cat $stage3SimFile | awk -v nrL=${tmpNr} 'NR<nrL{print $0}' > ./tmpCrossSim.txt
				nrOfLinesDiffAfter=$(diff $stage3ProdFile ./tmpCrossSim.txt | grep "<" | wc -l)
                                
				if [ $nrOfLinesDiffBefore -gt $nrOfLinesDiffAfter ]
                                then
					echo -e "\t\tMore crossings in simulation than in production; removing crossings in simulation"
					mv tmpCrossSim.txt $stage3SimFile
				fi
				rm -f tmpCrossSim.txt
			fi
		fi

		# Check that the crossings are the same
		nrOfLinesDiff=$(diff $stage3ProdFile $stage3SimFile | grep "<" | wc -l)
		if [ $nrOfLinesDiff -eq 0 ]
		then
			echo -e "\t\tcrossings are the same"
		else
			echo -e "\t\tcrossings are different (nr of lines different: $nrOfLinesDiff)!"
		fi

		# Translating .sim into csv
		#echo -e "\ttranslating sim output file to csv"
		simOutputFile=$(ls *.sim)
		optimizer.sh ronin master Release translate $simOutputFile &>/dev/null
		csvFile=$(ls *.sim.csv | awk '{print substr($1,1,length($1)-3)"csv"}')
		#echo "CSV FILE: $csvFile"
                
		# Grepping simulation P&L numbers
		fileSize=$(ls -l $csvFile | awk '{print $5}')
		if [ $fileSize -gt 0 ]
		then
			grep -A1 Pnl $csvFile | grep -v Pnl | awk -F ',' '{if($27>0.00001 || $27<-0.00001){print "'$date'", "'$baseName'", "'$prod1'", $27, $29, $27-$29, "'$firstUpdatesSame'", "'$nrOfLinesDiff'", "'$nrLinesCrossProd'", "'$hitRatio1'"};if($28>0.00001 || $28<-0.00001){ print "'$date'", "'$baseName'", "'$prod2'", $28, $30, $28-$30, "'$firstUpdatesSame'", "'$nrOfLinesDiff'", "'$nrLinesCrossProd'", "'$hitRatio2'"}}' >> $baseSimDir/$date/$summFileNameSim
		else
			echo "$date $baseName $prod1 0 0 0 $firstUpdatesSame $nrOfLinesDiff $nrLinesCrossProd $hitRatio1" >> $baseSimDir/$date/$summFileNameSim
			if [ $isSpread -eq 1 ]
			then
				echo "$date $baseName $prod2 0 0 0 $firstUpdatesSame $nrOfLinesDiff $nrLinesCrossProd $hitRatio2" >> $baseSimDir/$date/$summFileNameSim
			fi
		fi
	done
done

# sort summary file such that it is in the same order as the simulation results file
sort -k1,1 -k3,3 -k2,2 $baseSimDir/$date/$summaryFileName | grep -v "DATE TRADED" | awk 'BEGIN{print "DATE TRADED ID START STOP SIMLOC PNLUSD FEESUSD PNLLOC FEESLOC AVGRTT MEDRTT MINRTT MAXRTT NRORD ORDVOL NRTRD TRDVOL HITRT"}{print $0}' > $baseSimDir/$date/tmp.txt
mv $baseSimDir/$date/tmp.txt $baseSimDir/$date/$summaryFileName

# sort such that it is in the same order as the orderLogSummary file
sort -k1,1 -k2,2 -k3,3 $baseSimDir/$date/$summFileNameSim | grep -v "DATE TRAD_ID" | awk 'BEGIN{print "DATE TRAD_ID TRAD_PROD ZPNL MHPNL TOTPNL 1STEQ DIFFCROSS TOTCROSS HITRATIO"}{print $0}' > $baseSimDir/$date/tmp.txt
mv $baseSimDir/$date/tmp.txt $baseSimDir/$date/$summFileNameSim

# SUMMARY OF SUMMARY
recSumFileName="Reconciliation_OrderLog_vs_Simulation_"$date".txt"
paste $baseSimDir/$date/$summaryFileName $baseSimDir/$date/$summFileNameSim | awk 'BEGIN{print "DATE TRADED ID LOG_PL_USD SIM_PL_USD 1ST_SAME CROSSDIF TOTCROSS HR_LOG HR_SIM"}NR>1{print $1, $2, $3, $7, $25, $26, $27, $28, $19, $29}' > $baseSimDir/$date/$recSumFileName

# THE ERIC TABLE ;-)
reconSumm="reconTable.txt"
cp $baseSimDir/$date/$recSumFileName $baseSimDir/$date/$reconSumm
SLOTS=$(awk 'NR>1{print $3}' $baseSimDir/$date/$reconSumm | sort -u)
slotNr=1
for i in $SLOTS
do
	sed -i "s/$i/$slotNr/g" $baseSimDir/$date/$reconSumm
	((slotNr++))
done

tmpFile="reconTable.tmp"
echo "DATE SLOTID SYMBOL NRDIFFSIG TOTNRSIG LIVEPL SIMPL DIFF %DIFF" > $baseSimDir/$date/$tmpFile
while read line
do
	prod=$(echo $line | awk '{print substr($2,1,length($2)-2)}')
	if [ "$prod" == "TRAD" ]
	then
		continue
	fi

	symbol=$(grep ",$prod," /mnt/config/RONIN/products.csv | awk -F ',' '{print $4}')
	echo $line | awk '{print $1, $3, "'$symbol'", $7, $8, $4, $5, $5-$4, $5/$4}' >> $baseSimDir/$date/$tmpFile
done<$baseSimDir/$date/$reconSumm

awk '{totLogPl+=$4;totSimPl+=$5}END{print "TOTAL", totLogPl, totSimPl, totSimPl-totLogPl,totSimPl/totLogPl}' $baseSimDir/$date/$reconSumm >> $baseSimDir/$date/$tmpFile
mv $baseSimDir/$date/$tmpFile $baseSimDir/$date/$reconSumm

# print hitratio's for sim and prod into the simulation summary file
#awk -F ',' '{if($1=="O" && $6==0){if($4>0){ordVol+=$4}else{ordVol-=$4}};if($1=="T" && $6==0){if($4>0){tradVol+=$4}else{tradVol-=$4}}}END{print ordVol, tradVol, tradVol/ordVol}' 1065_Trades_LIF.CAC.log

yangFileName="Yang_"$date".txt"
yangDate=$(echo $date | awk '{print substr($1,1,4)"."substr($1,5,2)"."substr($1,7,2)}')
echo -e "\nGetting Yang P&L for $yangDate"
#echo "DATE: $yangDate, FILENAME: $baseSimDir/$date/$yangFileName"
/home/$USER/code/ronin/libs/yang/getYangReportPerDate.py $yangDate $baseSimDir/$date/$yangFileName &>/dev/null

# Since this is a windows based file, convert to to unix in order to avoind problems with e.g. end-of-line
dos2unix $baseSimDir/$date/$yangFileName &>/dev/null

# Creating a per prod view
echo -e "\nCreating P&L overview per product"
sumPnlFile="Reconciliation_Yang_vs_OrderLog_"$date".txt"
echo "DATE ALIAS SYMBOL PNLYNGLOC PNLLOGLOC PNLCURR PNLFX FEEYNGLOC FEELOGLOC FEECURR FEEFX" > $baseSimDir/$date/$sumPnlFile

sumReconFile="Reconciliation_"$date".txt"
echo "DATE ALIAS SYMBOL CATEGORY PNLYNGUSD PNLLOGUSD PNLSIMUSD" > $baseSimDir/$date/$sumReconFile

isMatching=1

PRODS=$(awk -F ',' 'NR>1{print $20}' $baseSimDir/$date/$yangFileName | sort -u)
for i in $PRODS
do
	#echo -e "\t$i"

	alias=$(grep ",$i," /mnt/config/RONIN/products.csv | awk -F ',' '{print $3}')
	symbol=$(grep ",$i," /mnt/config/RONIN/products.csv | awk -F ',' '{print $4}')
	categ=$(grep ",$i," /mnt/config/RONIN/products.csv | awk -F ',' '{print $2}')

        pnlPerProd=$(awk 'BEGIN{pnlLoc=0}{if(substr($2,1,length($2)-2)=="'$alias'"){pnlLoc+=$9}}END{print pnlLoc}' $baseSimDir/$date/$summaryFileName)
        feePerProd=$(awk 'BEGIN{feesLoc=0}{if(substr($2,1,length($2)-2)=="'$alias'"){feesLoc+=$10}}END{print feesLoc}' $baseSimDir/$date/$summaryFileName)
        pnlYang=$(grep ",$symbol," $baseSimDir/$date/$yangFileName | awk -F ',' '{print substr($24,1,11)*1}')
        feeYang=$(grep ",$symbol," $baseSimDir/$date/$yangFileName | awk -F ',' '{print $6/$1}')
        fxRateFee=$(grep ",$symbol," $baseSimDir/$date/$yangFileName | awk -F ',' '{print substr($1,1,11)*1}')
        currFee=$(grep ",$symbol," $baseSimDir/$date/$yangFileName | awk -F ',' '{print $4}')
        fxRate=$(grep ",$symbol," $baseSimDir/$date/$yangFileName | awk -F ',' '{print substr($13,1,11)*1}')
        currProd=$(grep ",$symbol," $baseSimDir/$date/$yangFileName | awk -F ',' '{print $20}')
        matchPerProd=$(echo $pnlPerProd $pnlYang $feePerProd $feeYang | awk '{if($1==$2 && $3==$4){print 1}else{print 0}}')

	# get simulated local pnl & fees
	#echo "GETTING SIM PNL & FEE FOR $alias"
	strToFetch="_"$alias".1.log"
	find $baseSimDir/$date -name "*_Trades_*" | grep $strToFetch | xargs cat | grep -v "Product,TimeStamp,Size" > $baseSimDir/$date/allTrades.tmp
	
	nrOfSimTrades=$(wc -l $baseSimDir/$date/allTrades.tmp | awk '{print $1}')
	pnlSim=0
	feeSim=0
	#echo "STR TO FETCH: $strToFetch, NR OF TRDS: $nrOfSimTrades"
	if [ $nrOfSimTrades -gt 0 ]
	then
		optimizer.sh ronin master Release PnlFromTrades $baseSimDir/$date/allTrades.tmp 1 > $baseSimDir/$date/screen.tmp
		pnlSim=$(grep local $baseSimDir/$date/screen.tmp | grep "P&L" | awk 'BEGIN{pl=0}{pl=$6}END{print pl}')
		feeSim=$(grep local $baseSimDir/$date/screen.tmp | grep "Fee" | awk 'BEGIN{fee=0}{fee=$4}END{print fee}')
	fi

	rm -f $baseSimDir/$date/allTrades.tmp $baseSimDir/$date/screen.tmp
	#echo "PROD: $alias, SIM PNL: $pnlSim, SIM FEE: $feeSim"

        if [ $matchPerProd -eq 0 ]
        then
                echo -e "\tYang P&L is different from OrderLog P&L for $alias (Yang (p&l, fees): $pnlYang, $feeYang, Log (p&l, fees): $pnlPerProd, $feePerProd)"
        fi

        isMatching=$(echo $isMatching $matchPerProd | awk '{if($1==1 && $2==1){print 1}else{print 0}}')
        #echo "$alias $pnlPerProd $pnlYang $isMatching"
        echo "$date $alias $symbol $pnlYang $pnlPerProd $currProd $fxRate $feeYang $feePerProd $currFee $fxRateFee" >> $baseSimDir/$date/$sumPnlFile

	echo "$date $alias $symbol $categ $pnlYang $feeYang $pnlPerProd $feePerProd $pnlSim $feeSim $fxRate $fxRateFee" | awk '{print $1, $2, $3, $4, ($5*$11 - $6*$12), ($7*$11 - $8*$12), ($9*$11 - $10*$12)}' >> $baseSimDir/$date/$sumReconFile
done

if [ $isMatching -eq 1 ]
then
	echo -e "\tYang P&L and OrderLog P&L match 100%"
fi

# calculate total P&Ls
awk '{date=$1;yngPl+=$5;logPl+=$6;simPl+=$7}END{print date, "TOTAL", "ALL", "ALL", yngPl, logPl, simPl}' $baseSimDir/$date/$sumReconFile >> $baseSimDir/$date/$sumReconFile

echo -e "\nDATE\t\tTOTAL_YANG_PL\tTOTAL_ORDERLOG_PL\tTOTAL_SIM_PL"
grep TOTAL $baseSimDir/$date/$sumReconFile | awk '{tabs1="\t\t";if(length($5)>7){tabs1="\t"};tabs2="\t\t\t";if(length($6)>7){tabs2="\t\t"};print $1"\t"$5tabs1$6tabs2$7}'
echo ""
