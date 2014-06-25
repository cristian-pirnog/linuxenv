#!/bin/bash

# ___________________________________________________________________________________________________________

function file_exists
{
   if [ ! -f $1 ]
   then
	echo "FILE NOT FOUND: $1"
	exit 1
   fi
}

function sleep_until 
{
    inputT=$1
    untilTime=${inputT:0:2}":"${inputT:2:2}":"${inputT:4:2}
    seconds=$(( $(date -d "$untilTime" +%s) - $(date +%s) ))
    echo "Sleeping until $inputT"
    sleep $seconds
}


# Quick & dirty check whether a job finished without problems. Successfully finished when:
# 1. Directory has 4 files or more
# 2. The gridsearch file exists and has more than 4 lines
function test_job_succeeded
{
    local dirName1=$1
    found=$(ls $dirName1 | grep ".opt" | wc -l)
    if [ $found -eq 1 ]
    then
	nrOfFiles=$(ls $dirName1 | wc -l)
	if [ $nrOfFiles -lt 4 ]
	then
		echo "0"
	else
        	gridSearchFile=$(ls $dirName1 | grep ".opt")
        	fileSize=$(ls -alrt $dirName1/$gridSearchFile | grep ".opt" | awk '{print $5}')
		#echo -e "GS FILE: $gridSearchFile DIR: $dirName1/$gridSearchFile SIZE: $fileSize\n"
        	if [ $fileSize -ge 3000 ]
        	then
			echo "1"
		else
			echo "0"
		fi
	fi
    else
	echo "0"
    fi  
}

# ___________________________________________________________________________________________________________



if [[ $# -ne 3 ]]
then
    echo -e "\nUsage:\n\n\t$(basename $0) jobFile startDate stopDate\n"
    exit 1
fi

jobFile=${1}
startD=${2}
stopD=${3}

baseDir="/home/$USER/deploy/master/Release"
libDir="${baseDir}/lib"
binaryFile="${baseDir}/bin/rocardian.optimizer.exe"

# Default break start/stop times 
breakStartTime=80000
breakStopTime=180000

# If WORKING_HOURS defined, use them for start and stop of break time
if [[ -n ${WORKING_HOURS} ]]; then
    breakStartTime=$(echo ${WORKING_HOURS} | cut -d ' ' -f 1)
    breakStopTime=$(echo ${WORKING_HOURS} | cut -d ' ' -f 2)
fi

dateDir=$startD"-"$stopD".opt"

# Test whether binary exists
file_exists $binaryFile

# These grid files need to exists
file_exists /mnt/config/grids/singleLeg_intraday.grid
file_exists /mnt/config/grids/spread_intraday.grid
file_exists /mnt/config/grids/spread_overnight.grid

if [ "$jobFile" == "TestCaseDefinition_ID_index.txt" ]
then
	partDirName="intraday/index"
elif [ "$jobFile" == "TestCaseDefinition_ID_nonindex.txt" ]
then
	partDirName="intraday/nonindex"
elif [ "$jobFile" == "TestCaseDefinition_ON_index.txt" ]
then
	partDirName="overnight/index"
elif [ "$jobFile" == "TestCaseDefinition_ON_nonindex.txt" ]
then
        partDirName="overnight/nonindex"
else
	echo "INCORRECT JOB FILE GIVEN (DON'T INCLUDE FULL PATH, JUST FILENAME): $jobFile"
	exit 1
fi

tmpDir="/mnt/optimization_results/"$partDirName"/"$dateDir
if [ ! -d $tmpDir ]
then
     mkdir $tmpDir

     # Make sure that all the optimization directories and files are read & write for everybody
     chmod -R 777 $tmpDir
fi

#echo "TCD FILE: /mnt/config/testCaseFiles/$jobFile"

# These job files need to exist
file_exists /mnt/config/testCaseFiles/$jobFile
file_exists /mnt/config/testCaseFiles/TestCaseDefinition_ID_index.txt
file_exists /mnt/config/testCaseFiles/TestCaseDefinition_ID_nonindex.txt
file_exists /mnt/config/testCaseFiles/TestCaseDefinition_ON_index.txt
file_exists /mnt/config/testCaseFiles/TestCaseDefinition_ON_nonindex.txt

currentPath=$(pwd)
maxRunTime=0

while read line           
do           
    #echo -e "$line"
    
    if [ "${line:0:1}" == "#" ]
    then
        #echo "LINE START WITH # ($line)"
        continue
    fi

    jobId=$(echo $line | awk '{print $8}')
    exch1=$(echo $jobId | awk -F '_' '{print substr($1,1,3)}')
    exch2=$(echo $jobId | awk -F '_' '{print substr($2,1,3)}')
    prod1=$(echo $line | awk '{print $1}')
    prod2=$(echo $line | awk '{print $2}')
    dirName="/mnt/optimization_results/"$partDirName"/"$dateDir"/"$jobId

    #echo "DIRNAME: $dirName EXCH1: $exch1, EXCH2: $exch2"
    
    if [ -d $dirName ]
    then
	#echo "FOUND $dirName"
	
	# Check whether the job is finished or not or whether 1 of the 2 products is CME.HRWHT
	if [ -f $dirName/.isRunning -o "$prod1" == "CME.HRWHT" -o "$prod2" == "CME.HRWHT" ]
	then
		#echo "Directory $dirName exists, but job is running or 1 of the products is CME.HRWHT; continuing!"
		continue
	fi

	# If you are here, then it means job has finished (i.e. is not running at the moment, but might have failed; tested below)
	if [ "$exch1" == "CME" -a "$exch2" == "CME" ]
    	then
		jobSucceeded=$(test_job_succeeded $dirName)
		#echo -e "JOB: $dirName SUCC: $jobSucceeded\n"
		#continue
		if [ $jobSucceeded -eq 0 ]
		then
			#echo "$dirName DID NOT SUCCEED!"
			
			# Checking again whether .isRunning file exists just to be sure that I am not deleting a job that is running
			if [ ! -f $dirName/.isRunning ]
			then
				#echo "Deleting directory $dirName!"
				rm -rf $dirName
			
				# If command did not succeed, then continue
				if [ $? -ne 0 ]
				then
					#echo "Deleting $dirName did not succeed!"
					continue
				fi
			fi
		else
			#echo "$dirName SUCCEEDED!"
			continue
		fi
	else
		continue
	fi
    fi

    # Check again whether this job is running, because I am trying to avoid a race condition
    if [ ! -d $dirName ]
    then
	#echo "Trying to make directory $dirName!"
    	
	# Piping stdout and stderr to nothing, such that you are not getting any error messages on the screen
	# mkdir can still fail unfortunately, because it takes a while before dir is created on the NAS and
	# therefore it can still happen that two processes are creating the same dir at the same time and
	# one of these processes will fail
	
	# always make the directory (if you're here, then this directory doesn't exist yet)
	mkdir $dirName &> /dev/null

	# If command did not succeed, then continue
	if [ $? -ne 0 ]
	then
		#echo "Could not make directory $dirName, continuing!"
		continue
	fi
    else
	#echo "Directory $dirName actually exists (avoided race condition); continuing!"
	continue
    fi

    touch $dirName/.isRunning
    chmod 777 $dirName
    cd $dirName

    if [ "$exch1" != "CME" -o "$exch2" != "CME" ]
    then
	echo "One of the products is not a CME product (prod1: $prod1, prod2: $prod2). Skipping optimization!" > $dirName/screenOutput.txt
    	rm .isRunning
	continue;
    fi

    if [ "$prod1" == "CME.HRWHT" -o "$prod2" == "CME.HRWHT" ]
    then
	echo "One of the products is CME.HRWHT (prod1: $prod1, prod2: $prod2). No data for this product. Skipping optimization!" > $dirName/screenOutput.txt
    	rm .isRunning
	continue
    fi

    startT=$(echo $line | awk '{print "T"$3}')
    stopT=$(echo $line | awk '{print "T"$4}')
    simLoc=$(echo $line | awk '{print $5}')
    isSpr=$(echo $line | awk '{print $6}')
    isIntraday=$(echo $line | awk '{print $7}')

    if [ $isIntraday -eq 1 -a $isSpr -eq 0 ]
    then
        gridFile="/mnt/config/grids/singleLeg_intraday.grid"
    elif [ $isIntraday -eq 1 -a $isSpr -eq 1 ]
    then
        gridFile="/mnt/config/grids/spread_intraday.grid"
    elif [ $isIntraday -eq 0 -a $isSpr -eq 1 ]
    then
        gridFile="/mnt/config/grids/spread_overnight.grid"
    else
        echo "No grid file found for isIntraday $isIntraday and isSpread $isSpr!"
        exit 1
    fi

    echo -e "PROD1: $prod1 \t PROD2: $prod2 \t START: $startT \t STOP: $stopT \t SIMLOC: $simLoc \t ISSPREAD: $isSpr \t GRIDFILE: $gridFile \t DIRNAME: $dirName"

    weekDay=$(date +%u)
    currentT1=$(date +"%H%M%S")
    currentT2=$(date --date="-$maxRunTime seconds ago" +"%H%M%S")
    echo -e "WEEK DAY: ${weekDay} \t CURRENT TIME ADAPTED: $currentT2 \t CURRENT TIME: $currentT1 \t START NOT RUN TIME: $breakStartTime \t STOP NOT RUN TIME: $breakStopTime \t MAX RUN TIME: $maxRunTime" 
    if [[ ${weekDay} -lt 6 ]] && [[ $currentT2 -ge $breakStartTime ]] && [[ $currentT1 -le $breakStopTime ]]; then
        sleep_until $breakStopTime
    fi

    # Test whether binary is still there, if not, wait 60 sec
    if [ ! -f $binaryFile ]
    then
	sleep 60
	if [ ! -f $binaryFile ]
    	then
		echo "BINARY FILE NOT FOUND AFTER 60 SEC OF WAITING (FILE: $binaryFile). SKIPPING $jobId!"
		rm .isRunning
		continue
	fi
    fi

    theDate=$(date +"%Y%m%d %H:%M:%S") 
    echo -e "Running optimization for\t$jobId\t($startD-$stopD)\t(started at $theDate)"
    startRunTime=$(date +%s)
    LD_LIBRARY_PATH=${libDir} $binaryFile optimize $prod1 $prod2 $gridFile $startT $stopT $isIntraday $startD $stopD serverLocation:$simLoc > screenOutput.txt
    runTime=$(( $(date +%s) - $startRunTime ))

    # Make sure that all the optimization directories and files are read & write for everybody
    chmod -R 777 $dirName

    #echo "NEW RUN TIME: $runTime"
    if [ $runTime -gt $maxRunTime ]
    then
        maxRunTime=$(( $runTime ))
    fi
    #echo "MAX RUN TIME: $maxRunTime"

    rm .isRunning
    #break

done </mnt/config/testCaseFiles/$jobFile 

cd $currentPath

theDate=$(date +"%Y%m%d %H:%M:%S")
echo -e "\n\tOptimization finished at $theDate\n"

# NAME1      NAME2       START   STOP    SIMLOC  SPREAD  ID	FULLNAME
#CME.AUDUSD  CME.CADUSD  000000  090000  CME     0       1	CME.AUDUSD_CME.CADUSD_000000_090000_CME_0
#CME.AUDUSD  CME.CADUSD  000000  090000  CME     1       1	CME.AUDUSD_CME.CADUSD_000000_090000_CME_1

# rocardian.optimizer optimize instr1 instr2 configFile startTime stopTime isIntraday beginDate endDate [settings]
