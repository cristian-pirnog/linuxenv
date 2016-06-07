#!/bin/bash

# Goes through all files provided as input, grabs artist and title, 
# formats them and renames files accordingly.
# Creates subdirectories corresponding to the artist if necessary


#-------------------------
# Function ProcessDir
#-------------------------
ProcessDir()
{
    local lDir=${1}
    local lTargetDir=${2}

    echo "Processing directory ${lDir}"

    rename 's/ /_/g' *

    find $lDir -mindepth 1 -maxdepth 1 -print0 | while read -d $'\0' lFile
    do
	if [[ -d "$lFile" ]]; then
	    ProcessDir "$lFile" ${lTargetDir}
	else
	    ProcessFile "$lFile" ${lTargetDir}
	fi
    done
}

#-------------------------
# Function MoveToDuplicates
#-------------------------
MoveToDuplicates()
{
    local lFile=${1}
    local lExistingFile=${2}

    echo "Duplicate file "${lFile}
    #mkdir -p ${myBaseDir}/duplicates
    #echo cp "$lFile" "$myBaseDir/duplicates"
    #echo "$(basename ${lFile}) <--> ${lExistingFile}" >> ${myBaseDir}/duplicates/mapping.txt
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

    echo "${lFile} -> ${lTargetFile}"
    if [[ ! -f ${lTargetFile} ]]; then
        cp "$lFile" "$lTargetFile"
	chmod ugo-w "$lTargetFile"
    else
	echo "Target file exists without checksum entry: ${lTargetFile}"
	MoveToDuplicates ${lFile} ${lTargetFile}
    fi
    lName=$(basename "$lTargetFile")
    echo "${lChecksum} ${lName}" >> "$lChecksumsFile"
}



#-------------------------
# Function ProcessFile
#-------------------------
ProcessFile()
{
    local lFile="$1"
    local lTargetBaseDir=${2}

    local lExtension=$(echo ${lFile} | awk -F '.' '{print $NF}')
    if [[ -z $(echo -e "mp3\|m4p\|m4a" | grep -i ${lExtension}) ]]; then
	echo "Skipping (unknown file type ${lExtension}) ${lFile}"
	return
    fi

    # Retrieve the title and artist
    myTitle=$(exiftool "$lFile" | grep -i '^title' | awk -F ':' '{print $NF}' | sed 's/^ //' | replace "/" "-")
    myArtist=$(exiftool "$lFile" | grep -i '^artist' | awk -F ':' '{print $NF}' | sed 's/^ //' | replace "/" "-")
    myAlbum=$(exiftool "$lFile" | grep -i '^album' | awk -F ':' '{print $NF}' | sed 's/^ //' | replace "/" "-")

    # Check that we have a both title and artist
    if [[ ${myTitle} == 'Title' ]]; then
	echo "Could not retrieve title for file $lFile"
	continue
    fi

    if [[ ${myArtist} == 'Artist' ]]; then
	echo "Could not retrieve artist for file $lFile"
	continue
    fi

    # Create the target path
    local lTargetPath=${lTargetBaseDir}/${myArtist}/${myAlbum}
    local lChecksumsFile=${lTargetPath}/checksums
    if [[ ! -d "${lTargetPath}" ]]; then
        mkdir -pv "$lTargetPath"
        touch "$lChecksumsFile"
    fi

    # Compute the checksum and fetch it from file
    checksum=$(md5sum "$lFile" | awk '{print $1}')
    grepped=$(grep "${checksum}" "$lChecksumsFile" | cut -d" " -f2-)

    # Put the file to the correct location
    # If the checksum is not present
    local lNewName="$myArtist - $myTitle.$lExtension"
    if [[ -z $grepped ]]; then
	MoveToTarget "$lFile" "$lTargetPath/$lNewName" ${checksum} "$lChecksumsFile"
    # ... else
    else
	# If the file that corresponds to the checksum exists
	if [[ -f ${lTargetPath}/$grepped ]]; then
            echo "File $lFile exists as: ${lTargetPath}/$grepped"
	    rm -v "$lFile"
	# ... else, if a file with the same name exists (but with different checksum)
	elif [[ -f "${lTargetPath}/$lFile" ]]; then
	    echo "File with same name but different checksum exists exists: $lFile  <-->  ${lTargetPath}/$grepped"
	else
            sed -i "/${checksum}/d" "$lChecksumsFile"
	    MoveToTarget "$lFile" "$lTargetPath/$lNewName" ${checksum} "$lChecksumsFile"
	fi
    fi

}

#-------------------------
# Main script
#-------------------------

myNASmount=/mnt/dsmusic
myBaseDir=${myNASmount}

# Check that the NAS is mounted
if [[ -z $(mount | grep ${myNASmount}) ]]; then
    echo "The NAS does not seem to be mounted. Will not proceed."
    exit 1
fi

# Create the error dir, if not already existing
myErrorDir=${myBaseDir}/withError
mkdir -p ${myErrorDir}

for myFile in *
do
    if [[ -d ${myFile} ]]; then
	ProcessDir "$myFile" "$myBaseDir"
    else
	ProcessFile "$myFile" "$myBaseDir"
    fi
done
