#!/bin/bash

##
# Script that installs the environment for the current user
##

InstallFromDir()
{
    local lDirName="$(pwd)/${1}"
    local lUserConfigFile="config.install.${XCUSTOMS_USER}"
    local lFullFileName="$lDirName/$lUserConfigFile"

    if [[ -f ${lFullFileName} ]]; then
	printf "Making symlinks for: %s\n" "${lDirName}"
	InstallFromConfigFile "${lDirName}" "${lUserConfigFile}"
	printf "\t[Done]\n"
    fi
        
    # Run the custom install script (if it exists)
    if [[ -f ${lDirName}/${INSTALL_SCRIPT} ]]; then
	cd $lDirName
	source $INSTALL_SCRIPT
    fi
}

## Main script

# Default values
userBaseDir="${XCUSTOMS_USER}.base"
userCustomDir=${XCUSTOMS_USER}

# Find if there are more directories for the user
userDirs=$(ls | grep "${XCUSTOMS_USER}" | grep -v "${userBaseDir}")
if [[ $(echo ${userDirs} | wc -w) -gt 1 ]]; then
    echo "Found the followig user directories:"
    echo ${userDirs} | tr ' ' '\n'

    if [[ -f .userdir ]]; then
	defaultCustomDir=$(cat .userdir)
    fi

    message="Choose which to install"
    while true; do
	if [[ -n ${defaultCustomDir} ]]; then
	    message=${message}" (default ${defaultCustomDir})"
	fi
	printf "%s" "${message}: "
	read userCustomDir
    
	if [[ -z ${userCustomDir} ]] && [[ -n ${defaultCustomDir} ]]; then
	    userCustomDir=${defaultCustomDir}
	fi

    # Check that the chosen directory exists
	if [[ -d ${userCustomDir} ]]; then
	    echo ${userCustomDir} > .userdir
	    break
	else
	    message="Directory '${userCustomDir}' is not in the list. Choose again: "
	fi
    done
fi

# Install for the base dir
if [[ -d ${userBaseDir} ]]; then
    InstallFromDir ${userBaseDir}
fi


# Check that the chosen directory exists
if [[ -d ${userCustomDir} ]]; then
    InstallFromDir ${userCustomDir}
fi
