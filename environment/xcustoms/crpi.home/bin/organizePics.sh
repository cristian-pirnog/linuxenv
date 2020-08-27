#!/bin/bash

# Goes through all files provided as input, grabs date from each
# and sorts them into subdirectories according to the date
# Creates subdirectories corresponding to the dates as necessary.


#-------------------------
# Function GetTimeStamp
#-------------------------
GetTimeStamp()
{
    local lFileName="$1"
    local lTag="$2"

    exiftool -d "%Y%m%d-%H%M%S" ${lFileName} | grep "$lTag" | head -1 | awk -F ':' '{print $NF}' | replace ' ' ''
}


#-------------------------
#
#-------------------------
GetTargetFileName()
{
    local lPrefix=${1}
    local lTargetDir=${2}
    local lTimeStamp=${3}
    local lExtension=${4}

    local lSuffix=''
    local lIndex=0
    local lNoTargetFile=0
    local lFileName=""
    for i in {1..20}; do
	lFileName=${lPrefix}_${lTimeStamp}${lSuffix}.${lExtension}
	if [[ -f ${lTargetDir}/${lFileName} ]]; then
	    lIndex=$((lIndex + 1))
	    lSuffix=_${lIndex}
	    continue
	fi
	lNoTargetFile=1
	break
    done

    if [[ $lNoTargetFile -eq 0 ]]; then
	lFileName=""
    fi

    echo ${lFileName}

}

#-------------------------
# Function ProcessDir
#-------------------------
ProcessDir()
{
    local lDir=${1}
    local lTargetDir=${2}

    echo "Processing directory ${lDir}"

    rename 's/ /_/g' *


    for myFile in $(ls $lDir)
    do
	if [[ -d "${lDir}/${myFile}" ]]; then
	    ProcessDir "${lDir}/${myFile}" ${lTargetDir}
	# elif [[ -n $(echo "${myFile}" | grep -i 'jpg$\|mpg$\|mov$') ]]; then
	else
	    ProcessFile "${lDir}/${myFile}" ${lTargetDir}
	fi
    done
}


#-------------------------
# Function MoveToTarget
#-------------------------
MoveToTarget()
{
    local lFile=${1}
    local lTargetFile=${2}
    local lChecksum=${3}
    local lChecksumsFile=${4}

    echo "Copying ${lFile} -> ${lTargetFile}"
    cp ${lFile} ${lTargetFile}
    chmod ugo-w ${lTargetFile}
    echo "${lChecksum} $(basename ${lTargetFile})" >> ${lChecksumsFile}
}



#-------------------------
# Function ProcessFile
#-------------------------
ProcessFile()
{
    local lFile=${1}
    local lTargetBaseDir=${2}

    local lExtension=$(echo ${lFile} | awk -F '.' '{print $NF}')
    if [[ -z $(echo -e "jpg\nmpg\nmov\nm2ts\nmts\nmp4" | grep -i ${lExtension}) ]]; then
	echo "Skipping (unknown file type) ${lFile}"
	return
    fi

    # Retrieve the dateName
    local lTag='^Create Date'
    if [[ -n $(echo -e "m2ts\nmts" | grep -i ${lExtension}) ]]; then
	lTag="^Date/Time Original"
    fi

    local lTimeStamp="$(GetTimeStamp ${lFile} ${lTag})"

    # If we don't have a date, get the File Modification Date instead
    if [[ -z ${lTimeStamp} ]]; then
	if [[ -z ${myUseFileModifDate} ]]; then
	    echo -e "\nCould not get date for file: ${lFile}."
	    echo "File modification date is: "$(GetTimeStamp ${lFile} 'File Modification Date')
	    echo "Would you like to use it for all similar files [y/n]?"
	    read myUseFileModifDate
	    myUseFileModifDate=$(echo ${myUseFileModifDate} | tr [:upper:] [:lower:])
	fi

	if [[ ${myUseFileModifDate} = 'y' ]]; then
	    lTimeStamp="$(GetTimeStamp ${lFile} 'File Modification Date')"
	else
	    echo "Could not get date for file: ${lFile}. Skipping it."
	    return
	fi
    fi

    # Check that we have a date, and ignore the file if not
    if [[ -z ${lTimeStamp} ]]; then
	echo "Could not retrieve timestamp for file ${lFile}"
	continue
    fi

    # Keep only the year/month section
    local lYear="$(echo ${lTimeStamp} | cut -c1-4)"
    local lMonth="$(echo ${lTimeStamp} | cut -c5-6)"

    if [[ $(echo ${lYear}) < 2000 ]]; then
	echo "Timestamp ${lTimeStamp} too old for file ${lFile}. Skipping it."
	return
    fi

    # Create the target path
    local lTargetPath=${lTargetBaseDir}/${lYear}/${lMonth}
    local lChecksumsFile=${lTargetPath}/checksums
    if [[ ! -d "${lTargetPath}" ]]; then
        mkdir -pv "${lTargetPath}"
        touch ${lChecksumsFile}
    fi

    # Compute the checksum and fetch it from file
    checksum=$(md5sum ${lFile} | awk '{print $1}')
    grepped=$(grep "${checksum}" ${lChecksumsFile} | awk '{print $2}')

    # Create the prefix
    prefix='IMG'
    if [[ -n $(echo -e "mpg\nmov\nmp4" | grep -i ${lExtension}) ]]; then
	prefix='MOV'
    fi

    # Get the file name of the target
    local lTargetFileName=$(GetTargetFileName ${prefix} ${lTargetPath} ${lTimeStamp} ${lExtension})
    if [[ -z ${lTargetFileName} ]]; then
	echo "Could not create a file name for timestamp ${lTimeStamp}. Too many files for the same second already exist".
	return
    fi

    # Put the picture to the correct location
    # If the checksum is not present
    lTargetFileName="$lTargetPath/$lTargetFileName"
    if [[ -z $grepped ]]; then
	# If a file with the same name exists (but with different checksum)
	MoveToTarget ${lFile} ${lTargetFileName} ${checksum} ${lChecksumsFile}
    # ... else
    else
	# If the file that corresponds to the checksum exists
	if [[ -f ${lTargetPath}/$grepped ]]; then
            echo "File ${lFile} exists as: ${lTargetPath}/$grepped"
	    rm -v ${lFile}
	else
            sed -i "/${checksum}/d" ${lChecksumsFile}
	    MoveToTarget ${lFile} ${lTargetFileName} ${checksum} ${lChecksumsFile}
	fi
    fi

}

#-------------------------
# Main script
#-------------------------

if [[ $OSTYPE = 'darwin16' ]]; then
  myNASmount=/Volumes/backup
else
  myNASmount=/mnt/dsbackup
fi

myBaseDir=${myNASmount}/photos

# Check that the NAS is mounted
if [[ -z $(mount | grep ${myNASmount}) ]]; then
    echo "The NAS does not seem to be mounted. Will not proceed."
    exit 1
fi

# Create the error dir, if not already existing
myErrorDir=${myBaseDir}/withError
mkdir -p ${myErrorDir}

for myFile in $*
do
    if [[ -d ${myFile} ]]; then
	ProcessDir ${myFile} ${myBaseDir}
    else
	ProcessFile ${myFile} ${myBaseDir}
    fi
done
