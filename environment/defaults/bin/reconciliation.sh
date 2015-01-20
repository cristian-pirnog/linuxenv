#!/bin/bash

#_______________________________________________________________________________
# SUBFUNCTIONS
#_______________________

function getMbbaTime
{
	local fileName1=$1
	local prodLoc=$2
	local index=$3
	
	timeStamp=$(grep "1st update" $fileName1 | awk -F ',' '{print $2}')
        bidSize=$(grep "1st update" $fileName1 | awk -F ',' '{print $3}')
        bidPrice=$(grep "1st update" $fileName1 | awk -F ',' '{print $4}')
        askPrice=$(grep "1st update" $fileName1 | awk -F ',' '{print $5}')
        askSize=$(grep "1st update" $fileName1 | awk -F ',' '{print $6}')

	# Overwrite when you want to have top of book for 2nd product
	if [ $index -eq 2 ]
	then
		timeStamp=$(grep "1st update" $fileName1 | awk -F ',' '{print $2}')
        	bidSize=$(grep "1st update" $fileName1 | awk -F ',' '{print $7}')
        	bidPrice=$(grep "1st update" $fileName1 | awk -F ',' '{print $8}')
        	askPrice=$(grep "1st update" $fileName1 | awk -F ',' '{print $9}')
        	askSize=$(grep "1st update" $fileName1 | awk -F ',' '{print $10}')
	fi

	#echo "TS: $timeStamp, BSZ: $bidSize, BP: $bidPrice, AP: $askPrice, ASZ: $askSize"
	#echo "COMMAND: optimizer.sh ronin master Release findTick $prodLoc $timeStamp $bidSize $bidPrice $askPrice $askSize 1 | grep TIMESTAMP | awk '{print $2}'"

	# Printing the timestamp that is closest to the one from the production log file
        timeStampMbba=$(optimizer.sh ronin master Release findTick $prodLoc $timeStamp $bidSize $bidPrice $askPrice $askSize 1 | grep TIMESTAMP | awk '{print $2}')
	
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

baseSimDir="/mnt/sandbox/reconciliation"
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
	echo "DATE TRAD_ID TRAD_PROD ZPNL MHPNL TOTPNL 1STEQ DIFFCROSS TOTCROSS" > $baseSimDir/$date/$summFileNameSim
fi

recSumFileName="Reconciliation_OrderLog_vs_Simulation_"$date".txt"

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
				echo "FOUND MULTIPLE $j FILES IN $i (ONLY USING LAST ONE: $fileName)!"
			else
				fileName=$(find $i -name $j | xargs grep stage3 | grep -v "stage3,TimeStamp,TriggeredProd" | awk -F ':' '{print $1}' | sort -u)
			fi
			
        	else
			fileName=$(find $i -name $j | tail -1)
		fi

		directory=$(echo $fileName | awk -F '/' '{print "/"$2"/"$3"/"$4"/"$5"/"$6}')
		nameTmp=$(echo $fileName | awk -F '/' '{print $7}')

		isSpread=$(echo $fileName | grep "spread" | wc -l)
		#echo "IS SPREAD: $isSpread OLD NAME TMP: $nameTmp"
		nameTmp=$(echo $nameTmp | sed "s/-spread//g")
		#echo "NEW NAME TMP: $nameTmp"

		prod1=$(echo $nameTmp | awk -F '_|-' '{print $3}')
		prod2=$(echo $nameTmp | awk -F '_|-' '{print $4}')
		startT=$(echo $nameTmp | awk -F '_|-' '{print substr($5,2,6)}')
		stopT=$(echo $nameTmp | awk -F '_|-' '{print substr($6,2,6)}')
		servLoc=$(echo $nameTmp | awk -F '_|-' '{print $7}')
		gridId=$(echo $nameTmp | awk -F '_|-' '{print substr($8,1,length($8)-4)}')
	
		#echo "$prod1 $prod2 $startT $stopT $servLoc $gridId"	
		cfgFile=$(ls $directory/configs | grep $prod1 | grep $prod2 | grep $startT | grep $stopT | grep $servLoc | grep $gridId)

		baseName=$prod1"_"$prod2"_"$startT"_"$stopT"_"$servLoc"_"$isSpread"_1_"$gridId

		echo "Analyzing date $date and slot $baseName"

                # Making a new directory to run simulations in
                mkdir -p $baseSimDir/$date/$baseName
                cd $baseSimDir/$date/$baseName

		echo -e "\tanalyzing production order log files"
                ORDER_LOG_FILES=$(ls $directory | grep "_Orders.log" | grep $prod1 | grep $prod2 | grep $startT | grep $stopT | grep $servLoc | grep $gridId | grep $date)
                for k in $ORDER_LOG_FILES
                do
                        #echo -e "\tORDER LOG FILE: $k"
                        orderLogFileTmp=$(echo $k | sed "s/-spread//g")
                        tradedProd=$(echo $orderLogFileTmp | awk -F '_|-' '{print $9}')
                        newFileName="OrderLog_"$baseName"_"$tradedProd"_"$date".log"
                        #echo "$baseName $tradedProd $date $newFileName"
                        cp $directory/$k ./$newFileName

                        nrOfLinesOrderLog=$(grep -v "No orders to log" $newFileName | wc -l)
                        if [ $nrOfLinesOrderLog -lt 2 ]
                        then
                                echo -e "\t\tignoring $newFileName ($tradedProd not traded; order log file empty)"
                                continue
                        else
				nrOfExecutionsOrderLog=$(grep OrderExecution $newFileName | wc -l)
				if [ $nrOfExecutionsOrderLog -eq 0 ]
				then
					echo -e "\t\tignoring $newFileName ($tradedProd not traded; no executions found for this product)"
					continue
				fi
			fi

                        echo -e "\t\tconstructing order log summary for $newFileName and traded product $tradedProd"
			summFileName2=$(optimizer.sh ronin master Release OrderLogParser $newFileName $timeShift | grep "Saving order log statistics to file" | awk '{print $7}')
                        tail -1 $summFileName2 >> $baseSimDir/$date/$summaryFileName
                done

		if [ $skipSim -eq 1 ]
		then
			echo -e "\tskipping all steps that require historical data"
			continue
		fi

		stage3ProdFile="Crossings_prod_"$nameTmp
		strToGrep="stage3,"$date"T"
		#grep $strToGrep $fileName | sed "s/,/ /g" | awk '{print substr($2,1,19), $3, $4, $5, $6, $7, $8, substr($9,1,19), $10, $11, $12, $13, $14, $15, $16, $17, substr($18,1,19), $19, $20, $21, $22, $23, $24, $25}' > ./$stage3ProdFile
		grep $strToGrep $fileName | sed "s/,/ /g" | awk '{print substr($2,1,17), $3, $4, $5, $6, $7, $8, $11, $13, $16, $17, $20, $22, $25}' > ./$stage3ProdFile

		#echo "PRODS: $prod1 $prod2 $fileName"
		echo -e "\tdetermining start time for simulation"
		timeStamp1=$(getMbbaTime $fileName $prod1 1)
		timeStamp2=$(getMbbaTime $fileName $prod2 2)

		#echo "TS1: $timeStamp1, TS2: $timeStamp2"
		#exit 1

	        if [ "$timeStamp1" == "-" -o "$timeStamp2" == "-" ]
        	then
                	echo "TIMESTAMP NOT FOUND FOR ONE OF THE PRODS (TS1: $timeStamp1, TS2: $timeStamp2)"
                	exit 1
        	fi
	
		latestTimeStampMbba=$(echo $timeStamp1 $timeStamp2 | awk '{ts1=substr($1,10,99);ts2=substr($2,10,99);if(ts1>ts2){print ts1}else{print ts2}}')
		#echo "TS USED IN CFG FILE: $latestTimeStampMbba"

		# Find the config corresponding to the log file
		if [ ! -d $directory/configs ]
		then
			echo "$directory DOES NOT HAVE A CONFIGS DIRECTORY!"
			exit 1
		fi

		nrOfCfgFiles=$(ls $directory/configs | grep $prod1 | grep $prod2 | grep $startT | grep $stopT | grep $servLoc | grep $gridId | wc -l)
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
		echo -e "\tchanging start time of config"
		optimizer.sh ronin master Release edit $directory/configs/$cfgFile StartTime $latestTimeStampMbba $newCfgFileName &>/dev/null

		# Run a simulation
		echo -e "\trunning single simulation with server location $servLoc"
		optimizer.sh ronin master Release simulate $newCfgFileName $date $date serverLocation:$servLoc logTrades:1 logInternals:1 logExecution:1 > screen.txt
		
		# Translating .sim into csv
		simOutputFile=$(ls *.sim)
		echo -e "\ttranslating sim output file to csv"
		optimizer.sh ronin master Release translate $simOutputFile &>/dev/null
		csvFile=$(ls *.sim | awk '{print substr($1,1,length($1)-3)"csv"}')
		#echo "CSV FILE: $csvFile"

		fileNameSim=$(ls | grep _Internals.log)
		stage3SimFile="Crossings_sim_"$nameTmp
                grep $strToGrep $fileNameSim | sed "s/,/ /g" | awk '{print substr($2,1,17), $3, $4, $5, $6, $7, $8, $11, $13, $16, $17, $20, $22, $25}' > ./$stage3SimFile

		# Check that 1st update is the same; otherwise crossings will never be the same
		echo -e "\tcomparing 1st update lines between production and simulation"
		firstUpdateProdLine=$(grep "1st update" $fileName | awk -F ',' '{print $1, $4, $5, $8, $9, $11}')
		firstUpdateSimLine=$(grep "1st update" $fileNameSim | awk -F ',' '{print $1, $4, $5, $8, $9, $11}')
		firstUpdatesSame=0
		if [ "$firstUpdateProdLine" != "$firstUpdateSimLine" ]
		then
			echo -e "\t\t1st UPDATES ARE NOT THE SAME (PROD: $firstUpdateProdLine, SIM: $firstUpdateSimLine)"
			#continue
		else
			echo -e "\t\t1st updates are the same"
			firstUpdatesSame=1
		fi

		# first check nr of lines of crossings files
		echo -e "\tcomparing crossings between production and simulation"
		nrLinesCrossProd=$(wc -l $stage3ProdFile | awk '{print $1}')
		nrLinesCrossSim=$(wc -l $stage3SimFile | awk '{print $1}')
		if [ $firstUpdatesSame -eq 1 -a $nrLinesCrossProd -ne $nrLinesCrossSim ]
		then
			if [ $nrLinesCrossProd -gt $nrLinesCrossSim ]
			then
				echo -e "\t\tMore crossings in production than in simulation; removing crossings in production"
				tmpNr=$((nrLinesCrossSim + 1))
                                cat $stage3ProdFile | awk -v nrL=${tmpNr} 'NR<nrL{print $0}' > ./tmpCrossProd.txt
				mv tmpCrossProd.txt $stage3ProdFile
			else
				echo -e "\t\tMore crossings in simulation than in production; removing crossings in simulation"
				tmpNr=$((nrLinesCrossProd + 1))
                                cat $stage3SimFile | awk -v nrL=${tmpNr} 'NR<nrL{print $0}' > ./tmpCrossSim.txt
                                mv tmpCrossSim.txt $stage3SimFile
			fi
		fi

		# Check that the crossings are the same
		nrOfLinesDiff=$(diff $stage3ProdFile $stage3SimFile | grep "<" | wc -l)
		if [ $nrOfLinesDiff -eq 0 ]
		then
			echo -e "\t\tcrossings are the same!"
		else
			echo -e "\t\tcrossings are different (nr of lines different: $nrOfLinesDiff)!"
		fi

		# Grepping simulation P&L numbers
                grep -A1 Pnl $csvFile | grep -v Pnl | awk -F ',' '{if($27>0.00001 || $27<-0.00001){print "'$date'", "'$baseName'", "'$prod1'", $27, $29, $27-$29, "'$firstUpdatesSame'", "'$nrOfLinesDiff'", "'$nrLinesCrossProd'"};if($28>0.00001 || $28<-0.00001){ print "'$date'", "'$baseName'", "'$prod2'", $28, $30, $28-$30, "'$firstUpdatesSame'", "'$nrOfLinesDiff'", "'$nrLinesCrossProd'"}}' >> $baseSimDir/$date/$summFileNameSim

		# SUMMARY OF SUMMARY
		paste $baseSimDir/$date/$summaryFileName $baseSimDir/$date/$summFileNameSim | awk 'BEGIN{print "DATE", "TRADED", "ID", "ROC_PL_USD", "SIM_PL_USD", "1ST_SAME", "CROSSDIF", "TOTCROSS"}NR>1{print $1, $2, $3, $7, $25, $26, $27, $28}' > $baseSimDir/$date/$recSumFileName
	done
done

yangFileName="Yang_"$date".txt"
yangDate=$(echo $date | awk '{print substr($1,1,4)"."substr($1,5,2)"."substr($1,7,2)}')
echo -e "\nGetting Yang P&L for $yangDate"
/home/$USER/code/ronin/libs/yang/getYangReportPerDate.py $yangDate $baseSimDir/$date/$yangFileName &>/dev/null

# Creating a per prod view
echo -e "Creating P&L overview per product"
sumPnlFile="Reconciliation_Yang_vs_OrderLog_"$date".txt"
echo "DATE ALIAS SYMBOL PNLYNGLOC FEEYNGLOC PNLLOGLOC FEELOGLOC FXRATE" > $baseSimDir/$date/$sumPnlFile

yangTotPnl=0
isMatching=1

PRODS=$(awk 'NR>1{print $2}' $baseSimDir/$date/$summaryFileName | sort -u)
for i in $PRODS
do
	#echo -e "\t$i"
        symbol=$(grep ",$i," /mnt/config/RONIN/products.csv | awk -F ',' '{print $4}')
        pnlPerProd=$(awk '{if($2=="'$i'"){pnlLoc+=$9;feesLoc+=$10}}END{print pnlLoc, feesLoc}' $baseSimDir/$date/$summaryFileName)
        pnlYang=$(grep $symbol $baseSimDir/$date/$yangFileName | awk -F ',' '{print substr($15,1,9)*1, $3/$1}')
        fxRate=$(grep $symbol $baseSimDir/$date/$yangFileName | awk -F ',' '{print substr($1,1,9)*1}')
	matchPerProd=$(echo $pnlPerProd $pnlYang | awk '{if($1==$3 && $2==$4){print 1}else{print 0}}')
	
	if [ $matchPerProd -eq 0 ]
	then
		echo -e "\tYang P&L is different from OrderLog P&L for $i (Yang (p&l, fees): $pnlYang, Log (p&l, fees): $pnlPerProd)"
	fi

	isMatching=$(echo $isMatching $matchPerProd | awk '{if($1==1 && $2==1){print 1}else{print 0}}')
	yangTotPnl=$(echo $pnlYang $yangTotPnl $fxRate | awk '{print $3+($1*$4)-($2*$4)}')
	#echo "$i $pnlPerProd $pnlYang $isMatching $yangTotPnl"
        echo "$date $i $symbol $pnlYang $pnlPerProd $fxRate" >> $baseSimDir/$date/$sumPnlFile
done

if [ $isMatching -eq 1 ]
then
	echo "Yang P&L and OrderLog P&L are matching 100%!"
fi

echo "Total Yang P&L for $date is $yangTotPnl"
